/// Frame implementation for tracing
/// This mirrors the architecture of frame/frame.zig but simplified for validation
const std = @import("std");
const log = @import("logger.zig");
const primitives = @import("primitives");
const evm_mod = @import("evm.zig");
const GasConstants = primitives.GasConstants;
const Address = primitives.Address.Address;
const Evm = evm_mod.Evm;
const EvmError = @import("errors.zig").CallError;
const Hardfork = @import("hardfork.zig").Hardfork;
const opcode_utils = @import("opcode.zig");

pub const Frame = struct {
    const Self = @This();

    // Stack
    stack: std.ArrayList(u256),

    // Memory
    memory: std.AutoHashMap(u32, u8),
    memory_size: u32,

    // Execution state
    pc: u32,
    gas_remaining: i64,
    bytecode: []const u8,

    // Valid jump destinations for JUMP/JUMPI
    valid_jumpdests: std.AutoArrayHashMap(u32, void),

    // Call context
    caller: Address,
    address: Address,
    value: u256,
    calldata: []const u8,

    // Output
    output: []u8,
    return_data: []const u8,

    // Execution status
    stopped: bool,
    reverted: bool,

    // Reference to Evm (like Frame has evm_ptr)
    evm_ptr: *anyopaque,

    // Allocator for frame operations
    allocator: std.mem.Allocator,

    // EIP-3074 AUTH state
    authorized: ?u256,
    call_depth: u32,
    
    // Active hardfork configuration for gas rules
    hardfork: Hardfork,

    /// Analyze bytecode to identify valid JUMPDEST locations
    fn validateJumpDests(_: std.mem.Allocator, bytecode: []const u8, valid_jumpdests: *std.AutoArrayHashMap(u32, void)) !void {
        var pc: u32 = 0;
        while (pc < bytecode.len) {
            const opcode = bytecode[pc];

            // Check if this is a JUMPDEST
            if (opcode == 0x5b) {
                try valid_jumpdests.put(pc, {});
                pc += 1;
            } else if (opcode >= 0x60 and opcode <= 0x7f) {
                // PUSH1 through PUSH32
                const push_size = opcode - 0x5f; // Number of bytes to push
                // Skip the PUSH opcode and its immediate data
                pc += 1 + push_size;
            } else {
                pc += 1;
            }
        }
    }

    /// Initialize a new frame
    pub fn init(
        allocator: std.mem.Allocator,
        bytecode: []const u8,
        gas: i64,
        caller: Address,
        address: Address,
        value: u256,
        calldata: []const u8,
        evm_ptr: *anyopaque,
        hardfork: Hardfork,
    ) !Self {
        var stack = std.ArrayList(u256){};
        try stack.ensureTotalCapacity(allocator, 1024);
        errdefer stack.deinit(allocator);

        var memory_map = std.AutoHashMap(u32, u8).init(allocator);
        errdefer memory_map.deinit();

        // Analyze bytecode to identify valid jump destinations
        var valid_jumpdests = std.AutoArrayHashMap(u32, void).init(allocator);
        errdefer valid_jumpdests.deinit();
        try validateJumpDests(allocator, bytecode, &valid_jumpdests);

        return Self{
            .stack = stack,
            .memory = memory_map,
            .memory_size = 0,
            .pc = 0,
            .gas_remaining = gas,
            .bytecode = bytecode,
            .valid_jumpdests = valid_jumpdests,
            .caller = caller,
            .address = address,
            .value = value,
            .calldata = calldata,
            .output = &[_]u8{},
            .return_data = &[_]u8{},
            .stopped = false,
            .reverted = false,
            .evm_ptr = evm_ptr,
            .allocator = allocator,
            .authorized = null,
            .call_depth = 0,
            .hardfork = hardfork,
        };
    }

    /// Clean up resources
    pub fn deinit(self: *Self) void {
        // Note: When using arena allocator from Evm, this becomes a no-op
        // The arena will clean up all memory at once when Evm is destroyed
        self.stack.deinit(self.allocator);
        self.memory.deinit();
        self.valid_jumpdests.deinit();
        // No need to free output or return_data when using arena
    }

    /// Get the Evm instance
    pub fn getEvm(self: *Self) *Evm {
        return @as(*Evm, @ptrCast(@alignCast(self.evm_ptr)));
    }

    /// Push value onto stack
    pub fn pushStack(self: *Self, value: u256) EvmError!void {
        if (self.stack.items.len >= 1024) {
            return error.StackOverflow;
        }
        try self.stack.append(self.allocator, value);
    }

    /// Pop value from stack
    pub fn popStack(self: *Self) EvmError!u256 {
        if (self.stack.items.len == 0) {
            return error.StackUnderflow;
        }
        const value = self.stack.items[self.stack.items.len - 1];
        self.stack.items.len -= 1;
        return value;
    }

    /// Peek at top of stack
    pub fn peekStack(self: *const Self, index: usize) EvmError!u256 {
        if (index >= self.stack.items.len) {
            return error.StackUnderflow;
        }
        return self.stack.items[self.stack.items.len - 1 - index];
    }

    inline fn wordCount(bytes: u64) u64 {
        return (bytes + 31) / 32;
    }
    
    /// Calculate word-aligned memory size for EVM compliance
    inline fn wordAlignedSize(bytes: u64) u32 {
        const words = wordCount(bytes);
        return @intCast(words * 32);
    }

    /// Read byte from memory
    pub fn readMemory(self: *Self, offset: u32) u8 {
        return self.memory.get(offset) orelse 0;
    }

    /// Write byte to memory
    pub fn writeMemory(self: *Self, offset: u32, value: u8) EvmError!void {
        try self.memory.put(offset, value);
        // EVM memory expands to word-aligned (32-byte) boundaries
        const end_offset = std.math.cast(u64, offset + 1) orelse return error.OutOfBounds;
        const word_aligned_size = wordAlignedSize(end_offset);
        if (word_aligned_size > self.memory_size) self.memory_size = word_aligned_size;
    }

    /// Get current opcode
    pub fn getCurrentOpcode(self: *const Self) ?u8 {
        if (self.pc >= self.bytecode.len) {
            return null;
        }
        return self.bytecode[self.pc];
    }

    /// Read immediate data for PUSH operations
    pub fn readImmediate(self: *const Self, size: u8) ?u256 {
        if (self.pc + 1 + size > self.bytecode.len) {
            return null;
        }

        var result: u256 = 0;
        var i: u8 = 0;
        while (i < size) : (i += 1) {
            result = (result << 8) | self.bytecode[self.pc + 1 + i];
        }
        return result;
    }

    /// ----------------------------------- GAS ---------------------------------- ///
    /// Consume gas
    pub fn consumeGas(self: *Self, amount: u64) EvmError!void {
        // Check if amount is too large to fit in i64 or exceeds remaining gas
        if (amount > std.math.maxInt(i64) or self.gas_remaining < @as(i64, @intCast(amount))) {
            self.gas_remaining = 0;
            return error.OutOfGas;
        }
        self.gas_remaining -= @intCast(amount);
    }

    /// Calculate memory expansion cost
    /// The total memory cost for n words is: 3n + n²/512, where a word is 32 bytes.
    fn memoryExpansionCost(self: *const Self, end_bytes: u64) u64 {
        const current_size = @as(u64, self.memory_size);

        if (end_bytes <= current_size) return 0;

        // Cap memory size to prevent gas calculation overflow
        // Max reasonable memory is 16MB (0x1000000 bytes) which is ~500k words
        // At that size, gas cost would be ~125 billion, far exceeding any reasonable gas limit
        const max_memory: u64 = 0x1000000;
        // Return a large value that won't overflow when added to other gas costs
        // but will still trigger OutOfGas (maxInt(i64) is ~9 quintillion)
        if (end_bytes > max_memory) return std.math.maxInt(i64);

        const current_words = wordCount(current_size);
        const new_words = wordCount(end_bytes);

        // Calculate cost for each size
        const current_cost = GasConstants.MemoryGas * current_words + (current_words * current_words) / GasConstants.QuadCoeffDiv;
        const new_cost = GasConstants.MemoryGas * new_words + (new_words * new_words) / GasConstants.QuadCoeffDiv;

        return new_cost - current_cost;
    }

    /// Calculate gas cost for external account operations (EIP-150 aware)
    fn externalAccountGasCost(self: *Self, address: Address) !u64 {
        const evm = self.getEvm();

        if (self.hardfork.isAtLeast(.BERLIN)) {
            // Post-Berlin: Cold/warm access pattern
            @branchHint(.likely);
            return try evm.accessAddress(address);
        } else if (self.hardfork.isAtLeast(.TANGERINE_WHISTLE)) {
            // Post-EIP-150, Pre-Berlin: Fixed higher cost
            return GasConstants.GasExtStep;
        } else {
            // Pre-EIP-150: Lower cost
            return GasConstants.GasQuickStep;
        }
    }

    /// Calculate SELFDESTRUCT gas cost (EIP-150 aware)
    fn selfdestructGasCost(self: *const Self) u64 {
        if (self.hardfork.isBefore(.TANGERINE_WHISTLE)) {
            @branchHint(.cold);
            return 0; // Pre-EIP-150: Free operation
        }
        return GasConstants.SelfdestructGas; // Post-EIP-150: 5000 gas
    }

    /// Calculate SELFDESTRUCT refund (EIP-3529 aware)
    fn selfdestructRefund(self: *const Self) u64 {
        if (self.hardfork.isAtLeast(.LONDON)) {
            @branchHint(.likely);
            return 0; // EIP-3529: No refund in London+
        }
        return GasConstants.SelfdestructRefundGas; // Pre-London: 24,000 refund
    }

    /// Calculate CREATE gas cost (EIP-3860 aware)
    fn createGasCost(self: *const Self, init_code_size: u32) u64 {
        var gas_cost: u64 = GasConstants.CreateGas; // Base 32,000 gas
        
        if (self.hardfork.isAtLeast(.SHANGHAI)) {
            @branchHint(.likely);
            const word_count = wordCount(@as(u64, init_code_size));
            gas_cost += word_count * GasConstants.InitcodeWordGas;
        }
        
        return gas_cost;
    }

    /// Calculate CREATE2 gas cost (EIP-3860 aware)
    fn create2GasCost(self: *const Self, init_code_size: u32) u64 {
        var gas_cost: u64 = GasConstants.CreateGas; // Base 32,000 gas

        // Keccak256 hash cost for hashing init_code
        // CREATE2 only charges for the keccak256 of init_code, not for the address calculation
        const init_code_word_count = wordCount(@as(u64, init_code_size));
        gas_cost += init_code_word_count * GasConstants.Keccak256WordGas;

        if (self.hardfork.isAtLeast(.SHANGHAI)) {
            // Additional init code word cost (EIP-3860)
            @branchHint(.likely);
            gas_cost += init_code_word_count * GasConstants.InitcodeWordGas;
        }

        return gas_cost;
    }

    /// Calculate KECCAK256 gas cost (replaces manual calculation)
    fn keccak256GasCost(data_size: u32) u64 {
        const words = wordCount(@as(u64, data_size));
        return GasConstants.Keccak256Gas + words * GasConstants.Keccak256WordGas;
    }

    /// Calculate copy operation gas cost (replaces manual calculations)
    fn copyGasCost(size: u32) u64 {
        const words = wordCount(@as(u64, size));
        return GasConstants.CopyGas * words;
    }

    /// Calculate LOG operation gas cost (replaces manual calculation)
    fn logGasCost(topic_count: u8, data_size: u32) u64 {
        const base_cost = GasConstants.LogGas;
        const topic_cost = @as(u64, topic_count) * GasConstants.LogTopicGas;
        const data_cost = @as(u64, data_size) * GasConstants.LogDataGas;
        return base_cost + topic_cost + data_cost;
    }

    /// ----------------------------------- OPCODES ---------------------------------- ///
    /// Execute a single opcode - delegates to Evm for external ops
    pub fn executeOpcode(self: *Self, opcode: u8) EvmError!void {
        const evm = self.getEvm();

        switch (opcode) {
            // STOP
            0x00 => {
                self.stopped = true;
                return;
            },
            // ADD
            0x01 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();
                const b = try self.popStack();
                try self.pushStack(a +% b);
                self.pc += 1;
            },
            // MUL
            0x02 => {
                try self.consumeGas(GasConstants.GasFastStep);
                const a = try self.popStack();
                const b = try self.popStack();
                try self.pushStack(a *% b);
                self.pc += 1;
            },
            // SUB
            0x03 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const top = try self.popStack();
                const second = try self.popStack();
                try self.pushStack(top -% second);
                self.pc += 1;
            },
            // DIV
            0x04 => {
                try self.consumeGas(GasConstants.GasFastStep);
                const top = try self.popStack();
                const second = try self.popStack();
                const result = if (second == 0) 0 else top / second;
                try self.pushStack(result);
                self.pc += 1;
            },
            // SDIV
            0x05 => {
                try self.consumeGas(GasConstants.GasFastStep);
                const top = try self.popStack();
                const second = try self.popStack();
                const top_signed = @as(i256, @bitCast(top));
                const second_signed = @as(i256, @bitCast(second));
                const MIN_SIGNED = @as(u256, 1) << 255;
                const result = if (second == 0) 0 else if (top == MIN_SIGNED and second == std.math.maxInt(u256)) MIN_SIGNED else @as(u256, @bitCast(@divTrunc(top_signed, second_signed)));
                try self.pushStack(result);
                self.pc += 1;
            },
            // MOD
            0x06 => {
                try self.consumeGas(GasConstants.GasFastStep);
                const top = try self.popStack();
                const second = try self.popStack();
                const result = if (second == 0) 0 else top % second;
                try self.pushStack(result);
                self.pc += 1;
            },
            // SMOD
            0x07 => {
                try self.consumeGas(GasConstants.GasFastStep);
                const top = try self.popStack();
                const second = try self.popStack();
                const top_signed = @as(i256, @bitCast(top));
                const second_signed = @as(i256, @bitCast(second));
                const MIN_SIGNED = @as(u256, 1) << 255;
                const result = if (second == 0) 0 else if (top == MIN_SIGNED and second == std.math.maxInt(u256)) 0 else @as(u256, @bitCast(@rem(top_signed, second_signed)));
                try self.pushStack(result);
                self.pc += 1;
            },
            // ADDMOD
            0x08 => {
                try self.consumeGas(GasConstants.GasMidStep);
                const a = try self.popStack();
                const b = try self.popStack();
                const n = try self.popStack();
                const result = if (n == 0) 0 else blk: {
                    const a_wide = @as(u512, a);
                    const b_wide = @as(u512, b);
                    const n_wide = @as(u512, n);
                    break :blk @as(u256, @truncate((a_wide + b_wide) % n_wide));
                };
                try self.pushStack(result);
                self.pc += 1;
            },
            // MULMOD
            0x09 => {
                try self.consumeGas(GasConstants.GasMidStep);
                const a = try self.popStack();
                const b = try self.popStack();
                const n = try self.popStack();
                const result = if (n == 0) 0 else blk: {
                    // Use u512 to avoid overflow
                    const a_wide = @as(u512, a);
                    const b_wide = @as(u512, b);
                    const n_wide = @as(u512, n);
                    break :blk @as(u256, @truncate((a_wide * b_wide) % n_wide));
                };
                try self.pushStack(result);
                self.pc += 1;
            },

            // EXP
            0x0a => {
                const base = try self.popStack();
                const exp = try self.popStack();

                // EIP-160: Dynamic gas cost for EXP
                // Gas cost = GasSlowStep + gas_per_byte * ((log2(exponent) / 8) + 1)
                // This calculates the number of bytes needed to represent the exponent
                const exp_bytes: u32 = if (exp == 0) 0 else blk: {
                    // Find position of highest bit set
                    const bit_position = 255 - @clz(exp);
                    // Calculate byte count: (bit_position / 8) + 1
                    break :blk @as(u32, bit_position / 8 + 1);
                };

                // TODO: these constants should be in gas_constants.zig as well
                // Use modern EIP-160 gas cost (50 gas per byte) for EXP
                const gas_per_byte: u32 = 50;
                // Calculate gas cost based on the number of bytes needed to represent the exponent
                const gas_cost = GasConstants.GasSlowStep + gas_per_byte * exp_bytes;
                try self.consumeGas(gas_cost);

                // Square-and-multiply algorithm for base^exp
                var result: u256 = 1;
                var b = base;
                var e = exp;
                while (e > 0) : (e >>= 1) {
                    if (e & 1 == 1) {
                        result *%= b;
                    }
                    b *%= b;
                }
                try self.pushStack(result);
                self.pc += 1;
            },

            // SIGNEXTEND
            0x0b => {
                try self.consumeGas(GasConstants.GasFastStep);
                const byte_num = try self.popStack();
                const value = try self.popStack();

                const result = if (byte_num >= 31) value else blk: {
                    const bit_index = @as(u8, @intCast(byte_num)) * 8 + 7;
                    const bit = (value >> @intCast(bit_index)) & 1;
                    const mask = (@as(u256, 1) << @intCast(bit_index + 1)) - 1;
                    if (bit == 1) {
                        break :blk value | ~mask;
                    } else {
                        break :blk value & mask;
                    }
                };
                try self.pushStack(result);
                self.pc += 1;
            },

            // LT
            0x10 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();     // Top of stack
                const b = try self.popStack();     // Second from top
                try self.pushStack(if (a < b) 1 else 0);  // Compare a < b
                self.pc += 1;
            },

            // GT
            0x11 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();     // Top of stack
                const b = try self.popStack();     // Second from top
                try self.pushStack(if (a > b) 1 else 0);  // Compare a > b
                self.pc += 1;
            },

            // SLT
            0x12 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();     // Top of stack
                const b = try self.popStack();     // Second from top
                const a_signed = @as(i256, @bitCast(a));
                const b_signed = @as(i256, @bitCast(b));
                try self.pushStack(if (a_signed < b_signed) 1 else 0);  // Compare a < b (signed)
                self.pc += 1;
            },

            // SGT
            0x13 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();     // Top of stack
                const b = try self.popStack();     // Second from top
                const a_signed = @as(i256, @bitCast(a));
                const b_signed = @as(i256, @bitCast(b));
                try self.pushStack(if (a_signed > b_signed) 1 else 0);  // Compare a > b (signed)
                self.pc += 1;
            },

            // EQ
            0x14 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const top = try self.popStack();
                const second = try self.popStack();
                try self.pushStack(if (top == second) 1 else 0); // EQ is symmetric
                self.pc += 1;
            },

            // ISZERO
            0x15 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();
                try self.pushStack(if (a == 0) 1 else 0);
                self.pc += 1;
            },

            // AND
            0x16 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();
                const b = try self.popStack();
                try self.pushStack(a & b);
                self.pc += 1;
            },

            // OR
            0x17 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();
                const b = try self.popStack();
                try self.pushStack(a | b);
                self.pc += 1;
            },

            // XOR
            0x18 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();
                const b = try self.popStack();
                try self.pushStack(a ^ b);
                self.pc += 1;
            },

            // NOT
            0x19 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const a = try self.popStack();
                try self.pushStack(~a);
                self.pc += 1;
            },

            // BYTE
            0x1a => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const i = try self.popStack();
                const x = try self.popStack();
                const result = if (i >= 32) 0 else (x >> @intCast(8 * (31 - i))) & 0xff;
                try self.pushStack(result);
                self.pc += 1;
            },

            // SHL
            0x1b => {
                // EIP-145: SHL opcode was introduced in Constantinople hardfork
                if (evm.hardfork.isBefore(.CONSTANTINOPLE)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasFastestStep);
                const shift = try self.popStack();
                const value = try self.popStack();
                const result = if (shift >= 256) 0 else value << @intCast(shift);
                try self.pushStack(result);
                self.pc += 1;
            },

            // SHR
            0x1c => {
                // EIP-145: SHR opcode was introduced in Constantinople hardfork
                if (evm.hardfork.isBefore(.CONSTANTINOPLE)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasFastestStep);
                const shift = try self.popStack();
                const value = try self.popStack();
                const result = if (shift >= 256) 0 else value >> @intCast(shift);
                try self.pushStack(result);
                self.pc += 1;
            },

            // SAR
            0x1d => {
                // EIP-145: SAR opcode was introduced in Constantinople hardfork
                if (evm.hardfork.isBefore(.CONSTANTINOPLE)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasFastestStep);
                const shift = try self.popStack();
                const value = try self.popStack();
                const value_signed = @as(i256, @bitCast(value));
                const result = if (shift >= 256) blk: {
                    break :blk if (value_signed < 0) @as(u256, @bitCast(@as(i256, -1))) else 0;
                } else blk: {
                    break :blk @as(u256, @bitCast(value_signed >> @intCast(shift)));
                };
                try self.pushStack(result);
                self.pc += 1;
            },

            // SHA3/KECCAK256
            0x20 => {
                const offset = try self.popStack();
                const size = try self.popStack();

                // Use centralized gas calculation
                const size_u32 = std.math.cast(u32, size) orelse return error.OutOfBounds;
                const gas_cost = keccak256GasCost(size_u32);
                try self.consumeGas(gas_cost);

                // Handle empty data case
                if (size == 0) {
                    // Keccak-256("") = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470
                    const empty_hash: u256 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
                    try self.pushStack(empty_hash);
                    self.pc += 1;
                } else {
                    const offset_u32 = std.math.cast(u32, offset) orelse return error.OutOfBounds;

                    // Charge memory expansion to cover [offset, offset+size)
                    const end_addr = @as(u64, offset_u32) + @as(u64, size_u32);
                    const mem_cost = self.memoryExpansionCost(end_addr);
                    try self.consumeGas(mem_cost);
                    const aligned_size = wordAlignedSize(end_addr);
                    if (aligned_size > self.memory_size) self.memory_size = aligned_size;

                    // Read data from memory
                    var data = try self.allocator.alloc(u8, size_u32);
                    // No defer free needed with arena allocator

                    var i: u32 = 0;
                    while (i < size_u32) : (i += 1) {
                        data[i] = self.readMemory(offset_u32 + i);
                    }

                    // Compute Keccak-256 hash using std library
                    var hash_bytes: [32]u8 = undefined;
                    std.crypto.hash.sha3.Keccak256.hash(data, &hash_bytes, .{});

                    // Convert hash bytes to u256 (big-endian)
                    const hash_u256 = std.mem.readInt(u256, &hash_bytes, .big);
                    try self.pushStack(hash_u256);
                    self.pc += 1;
                }
            },

            // ADDRESS
            0x30 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                const addr_u256 = primitives.Address.to_u256(self.address);
                try self.pushStack(addr_u256);
                self.pc += 1;
            },

            // BALANCE
            0x31 => {
                const addr_int = try self.popStack();
                var addr_bytes: [20]u8 = undefined;
                var i: usize = 0;
                while (i < 20) : (i += 1) {
                    addr_bytes[19 - i] = @as(u8, @truncate(addr_int >> @intCast(i * 8)));
                }
                const addr = Address{ .bytes = addr_bytes };

                // EIP-150/EIP-2929: hardfork-aware account access cost
                const access_cost = try self.externalAccountGasCost(addr);
                try self.consumeGas(access_cost);
                const balance = evm.get_balance(addr);
                try self.pushStack(balance);
                self.pc += 1;
            },

            // ORIGIN
            0x32 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                const origin_u256 = primitives.Address.to_u256(evm.origin);
                try self.pushStack(origin_u256);
                self.pc += 1;
            },

            // CALLER
            0x33 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                const caller_u256 = primitives.Address.to_u256(self.caller);
                try self.pushStack(caller_u256);
                self.pc += 1;
            },

            // CALLVALUE
            0x34 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(self.value);
                self.pc += 1;
            },

            // CALLDATALOAD
            0x35 => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const offset = try self.popStack();
                if (offset > std.math.maxInt(u32)) {
                    try self.pushStack(0);
                } else {
                    const off = @as(u32, @intCast(offset));
                    var result: u256 = 0;
                    var i: u32 = 0;
                    while (i < 32) : (i += 1) {
                        const idx = off + i;
                        const byte = if (idx < self.calldata.len) self.calldata[idx] else 0;
                        result = (result << 8) | byte;
                    }
                    try self.pushStack(result);
                }
                self.pc += 1;
            },

            // CALLDATASIZE
            0x36 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(self.calldata.len);
                self.pc += 1;
            },

            // CALLDATACOPY
            0x37 => {
                const dest_offset = try self.popStack();
                const offset = try self.popStack();
                const length = try self.popStack();

                const dest_off = std.math.cast(u32, dest_offset) orelse return error.OutOfBounds;
                const src_off = std.math.cast(u32, offset) orelse return error.OutOfBounds;
                const len = std.math.cast(u32, length) orelse return error.OutOfBounds;

                // Charge base + memory expansion + copy per word
                const end_bytes_copy: u64 = @as(u64, dest_off) + @as(u64, len);
                const mem_cost4 = self.memoryExpansionCost(end_bytes_copy);
                const copy_cost = copyGasCost(len);
                try self.consumeGas(GasConstants.GasFastestStep + mem_cost4 + copy_cost);

                // Copy calldata to memory
                var i: u32 = 0;
                while (i < len) : (i += 1) {
                    const src_idx = src_off + i;
                    const byte = if (src_idx < self.calldata.len) self.calldata[src_idx] else 0;
                    try self.writeMemory(dest_off + i, byte);
                }
                self.pc += 1;
            },

            // CODESIZE
            0x38 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(self.bytecode.len);
                self.pc += 1;
            },

            // CODECOPY
            0x39 => {
                const dest_offset = try self.popStack();
                const offset = try self.popStack();
                const length = try self.popStack();

                const dest_off = std.math.cast(u32, dest_offset) orelse return error.OutOfBounds;
                const src_off = std.math.cast(u32, offset) orelse return error.OutOfBounds;
                const len = std.math.cast(u32, length) orelse return error.OutOfBounds;

                const end_bytes_code: u64 = @as(u64, dest_off) + @as(u64, len);
                const mem_cost5 = self.memoryExpansionCost(end_bytes_code);
                const copy_cost = copyGasCost(len);
                try self.consumeGas(GasConstants.GasFastestStep + mem_cost5 + copy_cost);

                // Copy code to memory
                var i: u32 = 0;
                while (i < len) : (i += 1) {
                    const src_idx = src_off + i;
                    const byte = if (src_idx < self.bytecode.len) self.bytecode[src_idx] else 0;
                    try self.writeMemory(dest_off + i, byte);
                }
                self.pc += 1;
            },

            // GASPRICE
            0x3a => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(evm.gas_price);
                self.pc += 1;
            },

            // RETURNDATASIZE
            0x3d => {
                // EIP-211: RETURNDATASIZE was introduced in Byzantium hardfork
                if (evm.hardfork.isBefore(.BYZANTIUM)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(self.return_data.len);
                self.pc += 1;
            },

            // RETURNDATACOPY
            0x3e => {
                // EIP-211: RETURNDATACOPY was introduced in Byzantium hardfork
                if (evm.hardfork.isBefore(.BYZANTIUM)) return error.InvalidOpcode;

                const dest_offset = try self.popStack();
                const offset = try self.popStack();
                const length = try self.popStack();

                const dest_off = std.math.cast(u32, dest_offset) orelse return error.OutOfBounds;
                const src_off = std.math.cast(u32, offset) orelse return error.OutOfBounds;
                const len = std.math.cast(u32, length) orelse return error.OutOfBounds;

                // Check bounds
                if (src_off + len > self.return_data.len) {
                    return error.OutOfBounds;
                }

                const end_bytes_ret: u64 = @as(u64, dest_off) + @as(u64, len);
                const mem_cost6 = self.memoryExpansionCost(end_bytes_ret);
                const copy_cost = copyGasCost(len);
                try self.consumeGas(GasConstants.GasFastestStep + mem_cost6 + copy_cost);

                // Copy return data to memory
                var i: u32 = 0;
                while (i < len) : (i += 1) {
                    const byte = self.return_data[src_off + i];
                    try self.writeMemory(dest_off + i, byte);
                }
                self.pc += 1;
            },

            // BLOCKHASH
            0x40 => {
                try self.consumeGas(GasConstants.GasExtStep);
                const block_number = try self.popStack();
                // Simple mock: return a hash based on block number
                const current_block = evm.block_context.block_number;
                if (block_number >= current_block or current_block > block_number + 256) {
                    try self.pushStack(0);
                } else {
                    // Mock hash based on block number
                    try self.pushStack(block_number * 0x123456789abcdef);
                }
                self.pc += 1;
            },

            // COINBASE
            0x41 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                const coinbase_u256 = primitives.Address.to_u256(evm.block_context.block_coinbase);
                try self.pushStack(coinbase_u256);
                self.pc += 1;
            },

            // TIMESTAMP
            0x42 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(evm.block_context.block_timestamp);
                self.pc += 1;
            },

            // NUMBER
            0x43 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(evm.block_context.block_number);
                self.pc += 1;
            },

            // DIFFICULTY/PREVRANDAO
            0x44 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                if (evm.hardfork.isAtLeast(.MERGE)) {
                    try self.pushStack(evm.block_context.block_prevrandao);
                } else {
                    try self.pushStack(evm.block_context.block_difficulty);
                }
                self.pc += 1;
            },

            // GASLIMIT
            0x45 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(@as(u256, evm.block_context.block_gas_limit));
                self.pc += 1;
            },

            // CHAINID
            0x46 => {
                // EIP-1344: CHAINID was introduced in Istanbul hardfork
                if (evm.hardfork.isBefore(.ISTANBUL)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(@as(u256, evm.block_context.chain_id));
                self.pc += 1;
            },

            // SELFBALANCE
            0x47 => {
                // EIP-1884: SELFBALANCE was introduced in Istanbul hardfork
                if (evm.hardfork.isBefore(.ISTANBUL)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasFastStep);
                const balance = evm.get_balance(self.address);
                try self.pushStack(balance);
                self.pc += 1;
            },

            // BASEFEE
            0x48 => {
                // EIP-3198: BASEFEE was introduced in London hardfork
                if (evm.hardfork.isBefore(.LONDON)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(evm.block_context.block_base_fee);
                self.pc += 1;
            },

            // BLOBHASH
            0x49 => {
                // EIP-4844: BLOBHASH was introduced in Cancun hardfork
                if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasFastestStep);
                const index = try self.popStack();

                // Return the blob hash at the given index, or 0 if out of bounds
                // Use std.math.cast to safely convert u256 to usize, returns null if overflow
                const hash_value = if (std.math.cast(usize, index)) |index_usize| blk: {
                    if (index_usize < evm.blob_versioned_hashes.len) {
                        // Convert the 32-byte blob hash to u256
                        const blob_hash = evm.blob_versioned_hashes[index_usize];
                        var value: u256 = 0;
                        for (blob_hash) |byte| {
                            value = (value << 8) | byte;
                        }
                        break :blk value;
                    } else {
                        // Index out of bounds, return 0
                        break :blk 0;
                    }
                } else blk: {
                    // Index too large to represent as usize, definitely out of bounds
                    break :blk 0;
                };
                try self.pushStack(hash_value);
                self.pc += 1;
            },

            // BLOBBASEFEE
            0x4a => {
                // EIP-7516: BLOBBASEFEE was introduced in Cancun hardfork
                if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(evm.block_context.blob_base_fee);
                self.pc += 1;
            },

            // POP
            0x50 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                _ = try self.popStack();
                self.pc += 1;
            },

            // MLOAD
            0x51 => {
                const offset = try self.popStack();
                const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;

                // Charge base + memory expansion for reading 32 bytes
                const end_bytes: u64 = @as(u64, off) + 32;
                const mem_cost = self.memoryExpansionCost(end_bytes);
                try self.consumeGas(GasConstants.GasFastestStep + mem_cost);
                const aligned_size = wordAlignedSize(end_bytes);
                if (aligned_size > self.memory_size) self.memory_size = aligned_size;

                // Read word from memory
                var result: u256 = 0;
                var idx: u32 = 0;
                while (idx < 32) : (idx += 1) {
                    const byte = self.readMemory(off + idx);
                    result = (result << 8) | byte;
                }
                try self.pushStack(result);
                self.pc += 1;
            },

            // MSTORE
            0x52 => {
                const offset = try self.popStack();
                const value = try self.popStack();

                const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;

                // Charge base + memory expansion for writing 32 bytes
                const end_bytes2: u64 = @as(u64, off) + 32;
                const mem_cost2 = self.memoryExpansionCost(end_bytes2);
                try self.consumeGas(GasConstants.GasFastestStep + mem_cost2);

                // Write word to memory
                var idx: u32 = 0;
                while (idx < 32) : (idx += 1) {
                    const byte = @as(u8, @truncate(value >> @intCast((31 - idx) * 8)));
                    try self.writeMemory(off + idx, byte);
                }
                self.pc += 1;
            },

            // MSTORE8
            0x53 => {
                const offset = try self.popStack();
                const value = try self.popStack();

                const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;
                const end_bytes3: u64 = @as(u64, off) + 1;
                const mem_cost3 = self.memoryExpansionCost(end_bytes3);
                try self.consumeGas(GasConstants.GasFastestStep + mem_cost3);
                const byte_value = @as(u8, @truncate(value));
                try self.writeMemory(off, byte_value);
                self.pc += 1;
            },

            // SLOAD
            0x54 => {
                const key = try self.popStack();

                // EIP-2929: charge warm/cold storage access cost and warm the slot
                const access_cost = try evm.accessStorageSlot(self.address, key);
                // Access cost already includes the full SLOAD gas cost (100 for warm, 2100 for cold)
                try self.consumeGas(access_cost);

                const value = evm.get_storage(self.address, key);
                try self.pushStack(value);
                self.pc += 1;
            },

            // SSTORE
            0x55 => {
                const key = try self.popStack();
                const value = try self.popStack();

                // Debug: log SSTORE operations for slot 0
                // if (key == 0) {
                //     std.debug.print("SSTORE at pc={} addr={any} storing key={} value={}\n", .{self.pc, self.address.bytes, key, value});
                // }

                // Get current and original values for gas calculation
                const current_value = evm.get_storage(self.address, key);
                const original_value = evm.get_original_storage(self.address, key);

                // EIP-2929: Check if storage slot is cold and warm it
                const access_cost = try evm.accessStorageSlot(self.address, key);
                const is_cold = access_cost == GasConstants.ColdSloadCost;

                // Calculate SSTORE gas cost using proper EIP-2200/EIP-3529 logic
                const gas_cost = GasConstants.sstore_gas_cost(current_value, original_value, value, is_cold);
                try self.consumeGas(gas_cost);

                // EIP-3529: Only clearing (non-zero -> zero) is eligible for refund
                if (current_value != 0 and value == 0) {
                    evm.add_refund(GasConstants.SstoreRefundGas);
                }

                try evm.set_storage(self.address, key, value);
                self.pc += 1;
            },

            // JUMP
            0x56 => {
                try self.consumeGas(GasConstants.GasMidStep);
                const dest = try self.popStack();
                const dest_pc = std.math.cast(u32, dest) orelse return error.OutOfBounds;

                // Validate jump destination
                if (!self.valid_jumpdests.contains(dest_pc)) return error.InvalidJump;
                
                self.pc = dest_pc;
            },

            // JUMPI
            0x57 => {
                try self.consumeGas(GasConstants.GasSlowStep);
                const dest = try self.popStack();
                const condition = try self.popStack();

                if (condition != 0) {
                    const dest_pc = std.math.cast(u32, dest) orelse return error.OutOfBounds;

                    // Validate jump destination
                    if (!self.valid_jumpdests.contains(dest_pc)) return error.InvalidJump;

                    self.pc = dest_pc;
                } else {
                    self.pc += 1;
                }
            },

            // PC
            0x58 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(self.pc);
                self.pc += 1;
            },

            // MSIZE
            0x59 => {
                try self.consumeGas(GasConstants.GasQuickStep);
                // Memory size is already tracked as word-aligned in memory_size field
                try self.pushStack(self.memory_size);
                self.pc += 1;
            },

            // GAS
            0x5a => {
                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(@intCast(self.gas_remaining));
                self.pc += 1;
            },

            // JUMPDEST
            0x5b => {
                try self.consumeGas(GasConstants.JumpdestGas);
                self.pc += 1;
            },

            // TLOAD
            0x5c => {
                // EIP-1153: TLOAD was introduced in Cancun hardfork
                if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.TLoadGas);
                const key = try self.popStack();
                const value = evm.get_transient_storage(self.address, key);
                try self.pushStack(value);
                self.pc += 1;
            },

            // TSTORE
            0x5d => {
                // EIP-1153: TSTORE was introduced in Cancun hardfork
                if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.TStoreGas);
                const key = try self.popStack();
                const value = try self.popStack();
                try evm.set_transient_storage(self.address, key, value);
                self.pc += 1;
            },

            // PUSH0
            0x5f => {
                // EIP-3855: PUSH0 was introduced in Shanghai hardfork
                if (evm.hardfork.isBefore(.SHANGHAI)) return error.InvalidOpcode;

                try self.consumeGas(GasConstants.GasQuickStep);
                try self.pushStack(0);
                self.pc += 1;
            },

            // PUSH1-PUSH32
            0x60...0x7f => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const push_size = opcode - 0x5f;

                // Check bounds - need to read push_size bytes after the opcode
                if (self.pc + push_size >= self.bytecode.len) {
                    return error.InvalidPush;
                }

                // Read immediate value from bytecode
                var value: u256 = 0;
                for (0..push_size) |i| {
                    value = (value << 8) | self.bytecode[self.pc + 1 + i];
                }

                try self.pushStack(value);
                self.pc += 1 + push_size;
            },

            // DUP1-DUP16
            0x80...0x8f => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const n = opcode - 0x7f;
                if (self.stack.items.len < n) {
                    return error.StackUnderflow;
                }
                const value = self.stack.items[self.stack.items.len - n];
                try self.pushStack(value);
                self.pc += 1;
            },

            // SWAP1-SWAP16
            0x90...0x9f => {
                try self.consumeGas(GasConstants.GasFastestStep);
                const n = opcode - 0x8f;
                if (self.stack.items.len <= n) {
                    return error.StackUnderflow;
                }
                const top_idx = self.stack.items.len - 1;
                const swap_idx = self.stack.items.len - 1 - n;
                const temp = self.stack.items[top_idx];
                self.stack.items[top_idx] = self.stack.items[swap_idx];
                self.stack.items[swap_idx] = temp;
                self.pc += 1;
            },

            // LOG0-LOG4
            0xa0...0xa4 => {
                const topic_count = opcode - 0xa0;
                const offset = try self.popStack();
                const length = try self.popStack();

                // Pop topics
                var i: u8 = 0;
                while (i < topic_count) : (i += 1) {
                    _ = try self.popStack();
                }

                // Gas cost
                const length_u32 = std.math.cast(u32, length) orelse return error.OutOfBounds;
                const log_cost = logGasCost(topic_count, length_u32);
                try self.consumeGas(log_cost);

                // In minimal implementation, we don't actually emit logs
                _ = offset;
                self.pc += 1;
            },

            // CREATE
            0xf0 => {
                const value = try self.popStack();
                const offset = try self.popStack();
                const length = try self.popStack();

                const len = std.math.cast(u32, length) orelse return error.OutOfBounds;
                const gas_cost = self.createGasCost(len);
                try self.consumeGas(gas_cost);

                // Read init code from memory
                var init_code: []const u8 = &.{};
                if (length > 0 and length <= std.math.maxInt(u32)) {
                    const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;

                    // Check memory bounds and charge for expansion
                    const end_bytes = @as(u64, off) + @as(u64, len);
                    const mem_cost = self.memoryExpansionCost(end_bytes);
                    try self.consumeGas(mem_cost);

                    const code = try self.allocator.alloc(u8, len);
                    var j: u32 = 0;
                    while (j < len) : (j += 1) {
                        code[j] = self.readMemory(off + j);
                    }
                    init_code = code;
                }

                // Calculate available gas
                const remaining_gas = @as(u64, @intCast(@max(self.gas_remaining, 0)));
                // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
                // Before EIP-150: forward all remaining gas
                const max_gas = if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                    remaining_gas - (remaining_gas / 64)
                else
                    remaining_gas;

                // Perform CREATE
                const result = try evm.inner_create(value, init_code, max_gas, null);

                // Update gas
                const gas_used = max_gas - result.gas_left;
                self.gas_remaining -= @intCast(gas_used);

                // Set return_data according to CREATE semantics:
                // - On success: return_data is empty
                // - On failure: return_data is the child's output
                if (result.success) {
                    self.return_data = &[_]u8{};
                } else {
                    self.return_data = result.output;
                }

                // Push address onto stack (0 if failed)
                const addr_u256 = if (result.success) blk: {
                    var val: u256 = 0;
                    for (result.address.bytes) |b| {
                        val = (val << 8) | b;
                    }
                    break :blk val;
                } else 0;
                try self.pushStack(addr_u256);

                self.pc += 1;
            },

            // CALL
            0xf1 => {
                // Pop all 7 arguments
                const gas = try self.popStack();
                const address_u256 = try self.popStack();
                const value_arg = try self.popStack();
                const in_offset = try self.popStack();
                const in_length = try self.popStack();
                const out_offset = try self.popStack();
                const out_length = try self.popStack();

                // Convert address
                var addr_bytes: [20]u8 = undefined;
                var i: usize = 0;
                while (i < 20) : (i += 1) {
                    addr_bytes[19 - i] = @as(u8, @truncate(address_u256 >> @intCast(i * 8)));
                }
                const call_address = Address{ .bytes = addr_bytes };

                // Base gas cost
                var gas_cost: u64 = GasConstants.CallGas;
                if (value_arg > 0) {
                    gas_cost += GasConstants.CallValueTransferGas;

                    // Check if target is a precompile (addresses 0x01-0x0A)
                    // Precompiles are considered to always exist and should not incur new account cost
                    const is_precompile = address_u256 >= 1 and address_u256 <= 10;

                    // EIP-150: Check if target account exists
                    // If calling non-existent account with value, add account creation cost
                    const target_exists = is_precompile or blk: {
                        if (evm.host) |h| {
                            const has_balance = h.getBalance(call_address) > 0;
                            const has_code = h.getCode(call_address).len > 0;
                            const has_nonce = h.getNonce(call_address) > 0;
                            break :blk has_balance or has_code or has_nonce;
                        } else {
                            const has_balance = (evm.balances.get(call_address) orelse 0) > 0;
                            const has_code = (evm.code.get(call_address) orelse &[_]u8{}).len > 0;
                            const has_nonce = (evm.nonces.get(call_address) orelse 0) > 0;
                            break :blk has_balance or has_code or has_nonce;
                        }
                    };
                    if (!target_exists) {
                        gas_cost += GasConstants.CallNewAccountGas; // +25000 for creating new account
                    }
                }
                // EIP-2929: access target account (warm/cold)
                const access_cost = try evm.accessAddress(call_address);
                gas_cost += access_cost;
                try self.consumeGas(gas_cost);

                // Charge memory expansion cost for input region
                if (in_length > 0) {
                    const in_end = @as(u64, @intCast(in_offset)) + @as(u64, @intCast(in_length));
                    const mem_cost_in = self.memoryExpansionCost(in_end);
                    try self.consumeGas(mem_cost_in);
                }

                // Read input data from memory
                var input_data: []const u8 = &.{};
                if (in_length > 0 and in_length <= std.math.maxInt(u32)) {
                    const in_off = std.math.cast(u32, in_offset) orelse return error.OutOfBounds;
                    const in_len = std.math.cast(u32, in_length) orelse return error.OutOfBounds;

                    // Check if in_off + in_len would overflow
                    const end_offset = in_off +% in_len;
                    if (end_offset >= in_off) {
                        const data = try self.allocator.alloc(u8, in_len);
                        var j: u32 = 0;
                        while (j < in_len) : (j += 1) {
                            data[j] = self.readMemory(in_off + j);
                        }
                        input_data = data;
                    }
                    // else: overflow occurred, use empty input data
                }
                // Note: No defer free needed - arena allocator will clean up

                // Calculate available gas
                const gas_limit = if (gas > std.math.maxInt(u64)) std.math.maxInt(u64) else @as(u64, @intCast(gas));
                const remaining_gas = @as(u64, @intCast(@max(self.gas_remaining, 0)));
                // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
                // Before EIP-150: forward all remaining gas
                const max_gas = if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                    remaining_gas - (remaining_gas / 64)
                else
                    remaining_gas;
                const available_gas_without_stipend = @min(gas_limit, max_gas);

                // Add gas stipend for value transfers (stipend is free, caller doesn't pay for it)
                const available_gas = if (value_arg > 0)
                    available_gas_without_stipend + GasConstants.CallStipend
                else
                    available_gas_without_stipend;

                // Perform the inner call (regular CALL)
                const result = try evm.inner_call(call_address, value_arg, input_data, available_gas, .Call);

                // Write output to memory
                if (out_length > 0 and result.output.len > 0) {
                    const out_off = std.math.cast(u32, out_offset) orelse return error.OutOfBounds;
                    const out_len_u32 = std.math.cast(u32, out_length) orelse return error.OutOfBounds;
                    const result_len_u32 = std.math.cast(u32, result.output.len) orelse return error.OutOfBounds;
                    const copy_len = @min(out_len_u32, result_len_u32);

                    const end_bytes_callcopy: u64 = @as(u64, out_off) + @as(u64, copy_len);
                    const mem_cost_out = self.memoryExpansionCost(end_bytes_callcopy);
                    try self.consumeGas(mem_cost_out);

                    var k: u32 = 0;
                    while (k < copy_len) : (k += 1) {
                        try self.writeMemory(out_off + k, result.output[k]);
                    }
                }

                // Store return data
                self.return_data = result.output;

                // Push success status
                const success_val: u256 = if (result.success) 1 else 0;
                try self.pushStack(success_val);

                // Update gas - only charge caller for gas without stipend
                // The stipend is free additional gas for the callee
                const gas_used_total = available_gas - result.gas_left;
                const gas_used_by_caller = @min(gas_used_total, available_gas_without_stipend);
                self.gas_remaining -= @intCast(gas_used_by_caller);

                // Debug: log if call failed
                // if (!result.success) {
                //     std.debug.print("CALL FAIL: pc={} gas_left={} gas_used={}\n", .{self.pc, result.gas_left, gas_used_total});
                // }

                self.pc += 1;
            },

            // CALLCODE
            0xf2 => {
                // Similar to CALL but executes code in current context
                // Pop all 7 arguments
                const gas = try self.popStack();
                const address_u256 = try self.popStack();
                const value_arg = try self.popStack();
                const in_offset = try self.popStack();
                const in_length = try self.popStack();
                const out_offset = try self.popStack();
                const out_length = try self.popStack();

                // Convert address
                var addr_bytes: [20]u8 = undefined;
                var i: usize = 0;
                while (i < 20) : (i += 1) {
                    addr_bytes[19 - i] = @as(u8, @truncate(address_u256 >> @intCast(i * 8)));
                }
                const call_address = Address{ .bytes = addr_bytes };

                // Base gas cost
                var gas_cost: u64 = GasConstants.CallGas;
                if (value_arg > 0) {
                    gas_cost += GasConstants.CallValueTransferGas;
                }
                // EIP-2929: access target account (warm/cold)
                const access_cost = try evm.accessAddress(call_address);
                gas_cost += access_cost;
                try self.consumeGas(gas_cost);

                // Charge memory expansion cost for input region
                if (in_length > 0) {
                    const in_end = @as(u64, @intCast(in_offset)) + @as(u64, @intCast(in_length));
                    const mem_cost_in = self.memoryExpansionCost(in_end);
                    try self.consumeGas(mem_cost_in);
                }

                // Read input data from memory
                var input_data: []const u8 = &.{};
                if (in_length > 0 and in_length <= std.math.maxInt(u32)) {
                    const in_off = std.math.cast(u32, in_offset) orelse return error.OutOfBounds;
                    const in_len = std.math.cast(u32, in_length) orelse return error.OutOfBounds;

                    // Check if in_off + in_len would overflow
                    const end_offset = in_off +% in_len;
                    if (end_offset >= in_off) {
                        const data = try self.allocator.alloc(u8, in_len);
                        var j: u32 = 0;
                        while (j < in_len) : (j += 1) {
                            data[j] = self.readMemory(in_off + j);
                        }
                        input_data = data;
                    }
                    // else: overflow occurred, use empty input data
                }
                // Note: No defer free needed - arena allocator will clean up

                // Calculate available gas
                const gas_limit = if (gas > std.math.maxInt(u64)) std.math.maxInt(u64) else @as(u64, @intCast(gas));
                const remaining_gas = @as(u64, @intCast(@max(self.gas_remaining, 0)));
                // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
                // Before EIP-150: forward all remaining gas
                const max_gas = if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                    remaining_gas - (remaining_gas / 64)
                else
                    remaining_gas;
                const available_gas_without_stipend = @min(gas_limit, max_gas);

                // Add gas stipend for value transfers (stipend is free, caller doesn't pay for it)
                const available_gas = if (value_arg > 0)
                    available_gas_without_stipend + GasConstants.CallStipend
                else
                    available_gas_without_stipend;

                // Perform the inner call (CALLCODE)
                const result = try evm.inner_call(call_address, value_arg, input_data, available_gas, .CallCode);

                // Write output to memory
                if (out_length > 0 and result.output.len > 0) {
                    const out_off = std.math.cast(u32, out_offset) orelse return error.OutOfBounds;
                    const out_len_u32 = std.math.cast(u32, out_length) orelse return error.OutOfBounds;
                    const result_len_u32 = std.math.cast(u32, result.output.len) orelse return error.OutOfBounds;
                    const copy_len = @min(out_len_u32, result_len_u32);

                    const end_bytes_callcode: u64 = @as(u64, out_off) + @as(u64, copy_len);
                    const mem_cost_out = self.memoryExpansionCost(end_bytes_callcode);
                    try self.consumeGas(mem_cost_out);

                    var k: u32 = 0;
                    while (k < copy_len) : (k += 1) {
                        try self.writeMemory(out_off + k, result.output[k]);
                    }
                }

                // Store return data
                self.return_data = result.output;

                // Push success status
                try self.pushStack(if (result.success) 1 else 0);

                // Update gas - only charge caller for gas without stipend
                const gas_used_total = available_gas - result.gas_left;
                const gas_used_by_caller = @min(gas_used_total, available_gas_without_stipend);
                self.gas_remaining -= @intCast(gas_used_by_caller);

                self.pc += 1;
            },

            // RETURN
            0xf3 => {
                const offset = try self.popStack();
                const length = try self.popStack();

                if (length > 0) {
                    const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;
                    const len = std.math.cast(u32, length) orelse return error.OutOfBounds;

                    // Check if off + len would overflow
                    const end_offset = off +% len;
                    if (end_offset < off) {
                        // Overflow occurred, return out of bounds error
                        return error.OutOfBounds;
                    }

                    // Charge memory expansion for the return slice
                    const end_bytes = @as(u64, off) + @as(u64, len);
                    const mem_cost = self.memoryExpansionCost(end_bytes);
                    try self.consumeGas(mem_cost);
                    const aligned_size = wordAlignedSize(end_bytes);
                    if (aligned_size > self.memory_size) self.memory_size = aligned_size;

                    self.output = try self.allocator.alloc(u8, len);
                    var idx: u32 = 0;
                    while (idx < len) : (idx += 1) {
                        self.output[idx] = self.readMemory(off + idx);
                    }
                }

                self.stopped = true;
                return;
            },

            // DELEGATECALL
            0xf4 => {
                // EIP-7: DELEGATECALL was introduced in Homestead hardfork
                if (evm.hardfork.isBefore(.HOMESTEAD)) return error.InvalidOpcode;

                // Pop all 6 arguments (no value)
                const gas = try self.popStack();
                const address_u256 = try self.popStack();
                const in_offset = try self.popStack();
                const in_length = try self.popStack();
                const out_offset = try self.popStack();
                const out_length = try self.popStack();

                // Convert address
                var addr_bytes: [20]u8 = undefined;
                var i: usize = 0;
                while (i < 20) : (i += 1) {
                    addr_bytes[19 - i] = @as(u8, @truncate(address_u256 >> @intCast(i * 8)));
                }
                const call_address = Address{ .bytes = addr_bytes };

                // Base gas cost + EIP-2929 account access
                var gas_cost: u64 = GasConstants.CallGas;
                const access_cost = try evm.accessAddress(call_address);
                gas_cost += access_cost;
                try self.consumeGas(gas_cost);

                // Charge memory expansion cost for input region
                if (in_length > 0) {
                    const in_end = @as(u64, @intCast(in_offset)) + @as(u64, @intCast(in_length));
                    const mem_cost_in = self.memoryExpansionCost(in_end);
                    try self.consumeGas(mem_cost_in);
                }

                // Read input data from memory
                var input_data: []const u8 = &.{};
                if (in_length > 0 and in_length <= std.math.maxInt(u32)) {
                    const in_off = std.math.cast(u32, in_offset) orelse return error.OutOfBounds;
                    const in_len = std.math.cast(u32, in_length) orelse return error.OutOfBounds;

                    // Check if in_off + in_len would overflow
                    const end_offset = in_off +% in_len;
                    if (end_offset >= in_off) {
                        const data = try self.allocator.alloc(u8, in_len);
                        var j: u32 = 0;
                        while (j < in_len) : (j += 1) {
                            data[j] = self.readMemory(in_off + j);
                        }
                        input_data = data;
                    }
                    // else: overflow occurred, use empty input data
                }
                // Note: No defer free needed - arena allocator will clean up

                // Calculate available gas
                const gas_limit = if (gas > std.math.maxInt(u64)) std.math.maxInt(u64) else @as(u64, @intCast(gas));
                const remaining_gas = @as(u64, @intCast(@max(self.gas_remaining, 0)));
                // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
                // Before EIP-150: forward all remaining gas
                const max_gas = if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                    remaining_gas - (remaining_gas / 64)
                else
                    remaining_gas;
                const available_gas = @min(gas_limit, max_gas);

                // Perform the inner call (DELEGATECALL)
                const result = try evm.inner_call(call_address, self.value, input_data, available_gas, .DelegateCall);

                // Write output to memory
                if (out_length > 0 and result.output.len > 0) {
                    const out_off = std.math.cast(u32, out_offset) orelse return error.OutOfBounds;
                    const out_len_u32 = std.math.cast(u32, out_length) orelse return error.OutOfBounds;
                    const result_len_u32 = std.math.cast(u32, result.output.len) orelse return error.OutOfBounds;
                    const copy_len = @min(out_len_u32, result_len_u32);

                    const end_bytes_delegate: u64 = @as(u64, out_off) + @as(u64, copy_len);
                    const mem_cost_out = self.memoryExpansionCost(end_bytes_delegate);
                    try self.consumeGas(mem_cost_out);

                    var k: u32 = 0;
                    while (k < copy_len) : (k += 1) {
                        try self.writeMemory(out_off + k, result.output[k]);
                    }
                }

                // Store return data
                self.return_data = result.output;

                // Push success status
                try self.pushStack(if (result.success) 1 else 0);

                // Update gas
                const gas_used = available_gas - result.gas_left;
                self.gas_remaining -= @intCast(gas_used);

                self.pc += 1;
            },

            // CREATE2
            0xf5 => {
                // EIP-1014: CREATE2 opcode was introduced in Constantinople hardfork
                if (evm.hardfork.isBefore(.CONSTANTINOPLE)) return error.InvalidOpcode;

                const value = try self.popStack();
                const offset = try self.popStack();
                const length = try self.popStack();
                const salt = try self.popStack();

                const len = std.math.cast(u32, length) orelse return error.OutOfBounds;
                const gas_cost = self.create2GasCost(len);
                try self.consumeGas(gas_cost);

                // Read init code from memory
                var init_code: []const u8 = &.{};
                if (length > 0 and length <= std.math.maxInt(u32)) {
                    const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;

                    // Check memory bounds and charge for expansion
                    const end_bytes = @as(u64, off) + @as(u64, len);
                    const mem_cost = self.memoryExpansionCost(end_bytes);
                    try self.consumeGas(mem_cost);

                    const code = try self.allocator.alloc(u8, len);
                    var j: u32 = 0;
                    while (j < len) : (j += 1) {
                        code[j] = self.readMemory(off + j);
                    }
                    init_code = code;
                }

                // Calculate available gas
                const remaining_gas = @as(u64, @intCast(@max(self.gas_remaining, 0)));
                // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
                // Before EIP-150: forward all remaining gas
                const max_gas = if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                    remaining_gas - (remaining_gas / 64)
                else
                    remaining_gas;

                // Perform CREATE2 with salt
                const result = try evm.inner_create(value, init_code, max_gas, salt);

                // Update gas
                const gas_used = max_gas - result.gas_left;
                self.gas_remaining -= @intCast(gas_used);

                // Set return_data according to EIP-1014:
                // - On success: return_data is empty
                // - On failure: return_data is the child's output
                if (result.success) {
                    self.return_data = &[_]u8{};
                } else {
                    self.return_data = result.output;
                }

                // Push address onto stack (0 if failed)
                const addr_u256 = if (result.success) blk: {
                    var val: u256 = 0;
                    for (result.address.bytes) |b| {
                        val = (val << 8) | b;
                    }
                    break :blk val;
                } else 0;
                try self.pushStack(addr_u256);

                self.pc += 1;
            },

            // STATICCALL
            0xfa => {
                // EIP-214: STATICCALL was introduced in Byzantium hardfork
                if (evm.hardfork.isBefore(.BYZANTIUM)) return error.InvalidOpcode;

                // Pop all 6 arguments (no value for static call)
                const gas = try self.popStack();
                const address_u256 = try self.popStack();
                const in_offset = try self.popStack();
                const in_length = try self.popStack();
                const out_offset = try self.popStack();
                const out_length = try self.popStack();

                // Convert address
                var addr_bytes: [20]u8 = undefined;
                var i: usize = 0;
                while (i < 20) : (i += 1) {
                    addr_bytes[19 - i] = @as(u8, @truncate(address_u256 >> @intCast(i * 8)));
                }
                const call_address = Address{ .bytes = addr_bytes };

                // Base gas cost + EIP-2929 account access
                var call_gas_cost: u64 = GasConstants.CallGas;
                const access_cost = try evm.accessAddress(call_address);
                call_gas_cost += access_cost;
                try self.consumeGas(call_gas_cost);

                // Charge memory expansion cost for input region
                if (in_length > 0) {
                    const in_end = @as(u64, @intCast(in_offset)) + @as(u64, @intCast(in_length));
                    const mem_cost_in = self.memoryExpansionCost(in_end);
                    try self.consumeGas(mem_cost_in);
                }

                // Read input data from memory
                var input_data: []const u8 = &.{};
                if (in_length > 0 and in_length <= std.math.maxInt(u32)) {
                    const in_off = std.math.cast(u32, in_offset) orelse return error.OutOfBounds;
                    const in_len = std.math.cast(u32, in_length) orelse return error.OutOfBounds;

                    // Check if in_off + in_len would overflow
                    const end_offset = in_off +% in_len;
                    if (end_offset >= in_off) {
                        const data = try self.allocator.alloc(u8, in_len);
                        var j: u32 = 0;
                        while (j < in_len) : (j += 1) {
                            data[j] = self.readMemory(in_off + j);
                        }
                        input_data = data;
                    }
                    // else: overflow occurred, use empty input data
                }
                // Note: No defer free needed - arena allocator will clean up

                // Calculate available gas
                const gas_limit = if (gas > std.math.maxInt(u64)) std.math.maxInt(u64) else @as(u64, @intCast(gas));
                const remaining_gas = @as(u64, @intCast(@max(self.gas_remaining, 0)));
                // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
                // Before EIP-150: forward all remaining gas
                const max_gas = if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                    remaining_gas - (remaining_gas / 64)
                else
                    remaining_gas;
                const available_gas = @min(gas_limit, max_gas);

                // Perform the inner call (STATICCALL)
                const result = try evm.inner_call(call_address, 0, input_data, available_gas, .StaticCall);

                // Write output to memory
                if (out_length > 0 and result.output.len > 0) {
                    const out_off = std.math.cast(u32, out_offset) orelse return error.OutOfBounds;
                    const out_len_u32 = std.math.cast(u32, out_length) orelse return error.OutOfBounds;
                    const result_len_u32 = std.math.cast(u32, result.output.len) orelse return error.OutOfBounds;
                    const copy_len = @min(out_len_u32, result_len_u32);

                    const end_bytes_static: u64 = @as(u64, out_off) + @as(u64, copy_len);
                    const mem_cost_out = self.memoryExpansionCost(end_bytes_static);
                    try self.consumeGas(mem_cost_out);

                    var k: u32 = 0;
                    while (k < copy_len) : (k += 1) {
                        try self.writeMemory(out_off + k, result.output[k]);
                    }
                }

                // Store return data
                self.return_data = result.output;

                // Push success status
                try self.pushStack(if (result.success) 1 else 0);

                // Update gas
                const gas_used = available_gas - result.gas_left;
                self.gas_remaining -= @intCast(gas_used);

                self.pc += 1;
            },

            // MCOPY (EIP-5656)
            0x5e => {
                // EIP-5656: MCOPY was introduced in Cancun hardfork
                if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;

                // Stack order (top to bottom): dest, src, len
                // Pop order: dest (first), src (second), len (third)
                const dest = try self.popStack();
                const src = try self.popStack();
                const len = try self.popStack();

                // Calculate memory expansion cost BEFORE bounds checking
                // Per EIP-5656, if len == 0, no memory expansion occurs regardless of src/dest values
                // Otherwise, memory must be expanded to accommodate BOTH src+len and dest+len

                const mem_cost = if (len == 0)
                    0  // Zero-length copies don't expand memory
                else blk: {
                    // Safe conversion: if values don't fit in u64, use maxInt(u64) which will trigger
                    // massive gas cost in memoryExpansionCost
                    const dest_u64 = std.math.cast(u64, dest) orelse std.math.maxInt(u64);
                    const src_u64 = std.math.cast(u64, src) orelse std.math.maxInt(u64);
                    const len_u64 = std.math.cast(u64, len) orelse std.math.maxInt(u64);

                    // Calculate end positions for both source and destination
                    const end_dest: u64 = dest_u64 +| len_u64;  // saturating add to prevent overflow
                    const end_src: u64 = src_u64 +| len_u64;

                    // Memory expansion must cover BOTH ranges - use the maximum
                    const max_end = @max(end_dest, end_src);
                    break :blk self.memoryExpansionCost(max_end);
                };

                // For copy cost, we need to handle len > u32::MAX specially
                // If len doesn't fit in u32, the copy cost will be astronomical
                const copy_cost = if (len <= std.math.maxInt(u32))
                    copyGasCost(@intCast(len))
                else
                    std.math.maxInt(i64);  // Huge value that will trigger OutOfGas

                try self.consumeGas(GasConstants.GasFastestStep + mem_cost + copy_cost);

                // Fast path: zero length - gas charged but no copy needed
                if (len == 0) {
                    self.pc += 1;
                    return;
                }

                // Now that gas is charged, do bounds checking for actual memory operations
                const dest_u32 = std.math.cast(u32, dest) orelse return error.OutOfBounds;
                const src_u32 = std.math.cast(u32, src) orelse return error.OutOfBounds;
                const len_u32 = std.math.cast(u32, len) orelse return error.OutOfBounds;

                // Copy via temporary buffer to handle overlapping regions
                const tmp = try self.allocator.alloc(u8, len_u32);
                // No defer free needed with arena allocator

                var i: u32 = 0;
                while (i < len_u32) : (i += 1) {
                    tmp[i] = self.readMemory(src_u32 + i);
                }
                i = 0;
                while (i < len_u32) : (i += 1) {
                    try self.writeMemory(dest_u32 + i, tmp[i]);
                }

                self.pc += 1;
            },

            // REVERT
            0xfd => {
                // EIP-140: REVERT was introduced in Byzantium hardfork
                if (evm.hardfork.isBefore(.BYZANTIUM)) return error.InvalidOpcode;

                const offset = try self.popStack();
                const length = try self.popStack();

                if (length > 0) {
                    const off = std.math.cast(u32, offset) orelse return error.OutOfBounds;
                    const len = std.math.cast(u32, length) orelse return error.OutOfBounds;

                    // Charge memory expansion for the revert slice
                    const end_bytes: u64 = @as(u64, off) + @as(u64, len);
                    const mem_cost = self.memoryExpansionCost(end_bytes);
                    try self.consumeGas(mem_cost);
                    const aligned_size = wordAlignedSize(end_bytes);
                    if (aligned_size > self.memory_size) self.memory_size = aligned_size;

                    self.output = try self.allocator.alloc(u8, len);
                    var idx: u32 = 0;
                    while (idx < len) : (idx += 1) {
                        self.output[idx] = self.readMemory(off + idx);
                    }
                }

                self.reverted = true;
                return;
            },

            // EXTCODESIZE
            0x3b => {
                // Get code size of external account
                const addr_int = try self.popStack();
                const ext_addr = primitives.Address.from_u256(addr_int);

                // EIP-150/EIP-2929: hardfork-aware account access cost
                const access_cost = try self.externalAccountGasCost(ext_addr);
                try self.consumeGas(access_cost);

                // For Frame, we don't have access to external code
                // Just return 0 for now
                try self.pushStack(0);
                self.pc += 1;
            },

            // EXTCODECOPY
            0x3c => {
                // Copy external account code to memory
                const addr_int = try self.popStack();
                const dest_offset = try self.popStack();
                const offset = try self.popStack();
                const size = try self.popStack();

                const ext_addr = primitives.Address.from_u256(addr_int);

                // Gas cost calculation
                if (size > 0) {
                    const size_u32 = std.math.cast(u32, size) orelse return error.OutOfBounds;
                    const copy_cost = copyGasCost(size_u32);

                    // EIP-150/EIP-2929: hardfork-aware account access
                    const access_cost = try self.externalAccountGasCost(ext_addr);
                    try self.consumeGas(access_cost + copy_cost);

                    const dest = std.math.cast(u32, dest_offset) orelse return error.OutOfBounds;
                    const len = size_u32;
                    const end = @as(u64, dest) + @as(u64, len);
                    const mem_cost = self.memoryExpansionCost(end);
                    try self.consumeGas(mem_cost);

                    // For Frame, just write zeros to memory
                    _ = offset;
                    var i: u32 = 0;
                    while (i < len) : (i += 1) {
                        try self.writeMemory(dest + i, 0);
                    }
                } else {
                    // EIP-150/EIP-2929: charge account access cost even if size is zero
                    const access_cost = try self.externalAccountGasCost(ext_addr);
                    try self.consumeGas(access_cost);
                }
                self.pc += 1;
            },

            // EXTCODEHASH
            0x3f => {
                // EIP-1052: EXTCODEHASH opcode was introduced in Constantinople hardfork
                if (evm.hardfork.isBefore(.CONSTANTINOPLE)) return error.InvalidOpcode;

                // Get code hash of external account
                const addr_int = try self.popStack();
                const ext_addr = primitives.Address.from_u256(addr_int);

                // EIP-150/EIP-2929: hardfork-aware account access cost
                const access_cost = try self.externalAccountGasCost(ext_addr);
                try self.consumeGas(access_cost);

                // For Frame, return empty code hash
                // Empty code hash = keccak256("")
                const empty_hash: u256 = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
                try self.pushStack(empty_hash);
                self.pc += 1;
            },

            // TODO: Figure out what we want to do with AUTH and AUTHCALL as they were removed
            // from prague in favor of EIP-7702 (account abstraction) and currently not planned to be implemented
            // AUTH (EIP-3074)
            0xf6 => {
                // AUTH opcode from EIP-3074
                // Stack: [authority, commitment, sig_v, sig_r, sig_s] → [success]
                // Stack order (top to bottom): sig_s, sig_r, sig_v, commitment, authority
                try self.consumeGas(3100); // Base cost for AUTH

                // Pop 5 values from stack in correct order (top first)
                const sig_s = try self.popStack();
                const sig_r = try self.popStack();
                const sig_v = try self.popStack();
                const commitment = try self.popStack();
                const authority = try self.popStack();
                _ = commitment; // Used for signature verification in real implementation

                // Basic validation as per spec
                // sig_v must be 27 or 28, sig_r and sig_s must be non-zero
                if (sig_v != 27 and sig_v != 28) {
                    // Invalid signature v value, push failure
                    try self.pushStack(0);
                    self.pc += 1;
                    return;
                }

                if (sig_r == 0 or sig_s == 0) {
                    // Invalid signature r/s values, push failure
                    try self.pushStack(0);
                    self.pc += 1;
                    return;
                }

                // Check if r and s are within valid range (less than secp256k1 order)
                const SECP256K1_N: u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
                if (sig_r >= SECP256K1_N or sig_s >= SECP256K1_N) {
                    // Signature values out of range
                    try self.pushStack(0);
                    self.pc += 1;
                    return;
                }

                // For Frame testing: simulate successful AUTH if authority is non-zero
                // This allows testing the AUTH/AUTHCALL flow without actual crypto
                if (authority != 0) {
                    // Store the authorized address (lower 160 bits of authority)
                    self.authorized = authority & (((@as(u256, 1) << 160) - 1));
                    try self.pushStack(1); // Success
                } else {
                    // Zero authority always fails
                    self.authorized = null;
                    try self.pushStack(0); // Failure
                }
                self.pc += 1;
            },

            // AUTHCALL (EIP-3074)
            0xf7 => {
                // AUTHCALL opcode from EIP-3074
                // Stack: [gas, to, value, in_offset, in_size, out_offset, out_size, auth] → [success]
                try self.consumeGas(GasConstants.WarmStorageReadCost);

                // Pop 8 values from stack (in reverse order, top first)
                const auth_flag = try self.popStack();
                const out_size = try self.popStack();
                const out_offset = try self.popStack();
                const in_size = try self.popStack();
                const in_offset = try self.popStack();
                const value = try self.popStack();
                const to_addr = try self.popStack();
                const gas_param = try self.popStack();
                _ = to_addr; // Would be used in real implementation for target address

                // Check if we have authorization (auth_flag must be 1 and authorized must be set)
                if (auth_flag != 1 or self.authorized == null) {
                    // No authorization, push failure
                    try self.pushStack(0);
                    self.pc += 1;
                    return;
                }

                // Validate gas parameter
                if (gas_param > std.math.maxInt(i64)) {
                    try self.pushStack(0);
                    self.pc += 1;
                    return;
                }

                // Calculate memory expansion cost for input
                if (in_size > 0) {
                    const in_end = std.math.add(u256, in_offset, in_size) catch {
                        try self.pushStack(0);
                        self.pc += 1;
                        return;
                    };
                    if (in_end > std.math.maxInt(u32)) {
                        try self.pushStack(0);
                        self.pc += 1;
                        return;
                    }
                    const in_end_u32 = std.math.cast(u32, in_end) orelse return error.OutOfBounds;
                    const mem_cost = self.memoryExpansionCost(in_end_u32);
                    try self.consumeGas(mem_cost);
                }

                // Calculate memory expansion cost for output
                if (out_size > 0) {
                    const out_end = std.math.add(u256, out_offset, out_size) catch {
                        try self.pushStack(0);
                        self.pc += 1;
                        return;
                    };
                    if (out_end > std.math.maxInt(u32)) {
                        try self.pushStack(0);
                        self.pc += 1;
                        return;
                    }
                    const out_end_u32 = std.math.cast(u32, out_end) orelse return error.OutOfBounds;
                    const mem_cost = self.memoryExpansionCost(out_end_u32);
                    try self.consumeGas(mem_cost);
                }

                // Additional gas for value transfer
                if (value != 0) {
                    try self.consumeGas(9000); // CallValueTransferGas
                }

                // For Frame: simulate call success if authorized
                // The call is made with the authorized address as the caller
                // In a real implementation, this would make an actual call
                self.call_depth += 1;
                defer self.call_depth -= 1;

                // Simulate successful authorized call
                try self.pushStack(1); // Success
                self.pc += 1;
            },

            // INVALID
            0xfe => {
                // INVALID opcode always fails
                // Consume all remaining gas
                self.gas_remaining = 0;
                return error.InvalidOpcode;
            },

            // SELFDESTRUCT
            0xff => {
                const beneficiary_u256 = try self.popStack();

                // Convert beneficiary to address
                var beneficiary_bytes: [20]u8 = undefined;
                var i: usize = 0;
                while (i < 20) : (i += 1) {
                    beneficiary_bytes[19 - i] = @truncate(beneficiary_u256 >> @intCast(i * 8));
                }
                const beneficiary = Address{ .bytes = beneficiary_bytes };

                const evm_ptr = self.getEvm();

                // Calculate gas cost (EIP-6780/Berlin)
                // Base: 5000 gas
                // +2600 if beneficiary is cold (EIP-2929/Berlin)
                // +25000 if beneficiary doesn't exist and we have balance
                var gas_cost = self.selfdestructGasCost();

                // EIP-2929 (Berlin): Check if beneficiary is warm, add cold access cost if needed
                if (self.hardfork.isAtLeast(.BERLIN)) {
                    const is_warm = evm_ptr.warm_addresses.contains(beneficiary);
                    if (!is_warm) {
                        gas_cost += GasConstants.ColdAccountAccessCost; // +2600
                        try evm_ptr.warm_addresses.put(beneficiary, {});
                    }
                }

                const self_balance = if (evm_ptr.host) |h|
                    h.getBalance(self.address)
                else
                    evm_ptr.balances.get(self.address) orelse 0;

                // Check if beneficiary is alive (has code, balance, or nonce)
                // Add new account cost if not alive and we have balance
                if (self_balance > 0) {
                    const beneficiary_is_alive = blk: {
                        if (evm_ptr.host) |h| {
                            const has_balance = h.getBalance(beneficiary) > 0;
                            const has_code = h.getCode(beneficiary).len > 0;
                            const has_nonce = h.getNonce(beneficiary) > 0;
                            break :blk has_balance or has_code or has_nonce;
                        } else {
                            const has_balance = (evm_ptr.balances.get(beneficiary) orelse 0) > 0;
                            const has_code = (evm_ptr.code.get(beneficiary) orelse &[_]u8{}).len > 0;
                            const has_nonce = (evm_ptr.nonces.get(beneficiary) orelse 0) > 0;
                            break :blk has_balance or has_code or has_nonce;
                        }
                    };
                    if (!beneficiary_is_alive) {
                        gas_cost += GasConstants.CallNewAccountGas; // +25000 for creating new account
                    }
                }

                try self.consumeGas(gas_cost);

                // EIP-6780: Move ether from originator to beneficiary
                // This is ALWAYS done regardless of whether account was created in same tx
                // Per spec: move_ether is called unconditionally, even when sender == recipient
                if (self_balance > 0) {
                    if (evm_ptr.host) |h| {
                        // Reduce originator balance first
                        h.setBalance(self.address, 0);
                        // Then increase beneficiary balance (read AFTER reducing originator)
                        const beneficiary_balance = h.getBalance(beneficiary);
                        h.setBalance(beneficiary, beneficiary_balance + self_balance);
                    } else {
                        // Reduce originator balance first
                        try evm_ptr.balances.put(self.address, 0);
                        // Then increase beneficiary balance (read AFTER reducing originator)
                        const beneficiary_balance = evm_ptr.balances.get(beneficiary) orelse 0;
                        try evm_ptr.balances.put(beneficiary, beneficiary_balance + self_balance);
                    }
                }

                // EIP-6780: Only delete account if created in same transaction
                const was_created_this_tx = evm_ptr.created_accounts.contains(self.address);

                if (was_created_this_tx) {
                    // When account was created in same tx, fully delete the account (EIP-6780)
                    // This happens after move_ether above
                    // If beneficiary == originator: balance was increased then set to 0 (burning ether)
                    // If beneficiary != originator: balance was already set to 0 in move_ether
                    if (evm_ptr.host) |h| {
                        // Clear all account state: balance, code, and nonce
                        h.setBalance(self.address, 0);
                        h.setCode(self.address, &[_]u8{});
                        h.setNonce(self.address, 0);
                        // Note: storage would also be cleared in full implementation
                    } else {
                        // Clear all account state in EVM storage
                        try evm_ptr.balances.put(self.address, 0);
                        try evm_ptr.code.put(self.address, &[_]u8{});
                        try evm_ptr.nonces.put(self.address, 0);
                        // Note: storage would also be cleared in full implementation
                    }
                }
                // Otherwise: Balance already transferred above, code persists per EIP-6780

                // Apply refund to EVM's gas_refund counter
                const refund = self.selfdestructRefund();
                if (refund > 0) {
                    evm_ptr.gas_refund += refund;
                }

                self.stopped = true;
            },

            else => {
                return error.InvalidOpcode;
            },
        }
    }

    /// Get memory contents as a slice (for tracing)
    fn getMemorySlice(self: *Self, allocator: std.mem.Allocator) ![]u8 {
        if (self.memory_size == 0) return &[_]u8{};

        const mem_slice = try allocator.alloc(u8, self.memory_size);
        var i: u32 = 0;
        while (i < self.memory_size) : (i += 1) {
            mem_slice[i] = self.readMemory(i);
        }
        return mem_slice;
    }

    /// Calculate gas cost for an opcode (approximate, for tracing)
    fn estimateGasCost(_: *Self, op: u8) u64 {
        // This is a simplified estimation for tracing purposes
        // The actual gas cost is calculated within executeOpcode
        return switch (op) {
            0x00 => 0, // STOP
            0x01, 0x03, 0x10...0x1d, 0x50 => GasConstants.GasFastestStep, // Fast ops
            0x02, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a => GasConstants.GasFastStep, // Math ops
            0x20 => GasConstants.Keccak256Gas, // KECCAK256
            0x31 => GasConstants.GasExtStep, // BALANCE
            0x3b, 0x3c, 0x3f => GasConstants.GasExtStep, // EXT* ops
            0x54 => GasConstants.SloadGas, // SLOAD
            0x55 => GasConstants.SstoreSetGas, // SSTORE (approximate)
            0x5f => GasConstants.GasQuickStep, // PUSH0
            0xf0 => GasConstants.CreateGas, // CREATE
            0xf1, 0xf2, 0xf4, 0xfa => GasConstants.CallGas, // CALL variants
            0xf5 => GasConstants.CreateGas, // CREATE2
            0xff => GasConstants.SelfdestructGas, // SELFDESTRUCT
            else => GasConstants.GasFastestStep,
        };
    }

    /// Execute a single step
    pub fn step(self: *Self) EvmError!void {
        if (self.stopped or self.reverted or self.pc >= self.bytecode.len) {
            return;
        }
        const opcode = self.getCurrentOpcode() orelse return;

        // Capture trace before executing opcode
        const evm = self.getEvm();
        if (evm.tracer) |tracer| {
            const gas_before = @as(u64, @intCast(@max(self.gas_remaining, 0)));
            const gas_cost = self.estimateGasCost(opcode);

            // Get memory slice for tracing
            const mem_slice = self.getMemorySlice(self.allocator) catch null;

            // Capture trace entry
            tracer.captureState(
                @as(u64, self.pc),
                opcode,
                gas_before,
                gas_cost,
                mem_slice,
                self.stack.items,
                self.return_data,
                evm.frames.items.len,
                @as(i64, @intCast(evm.gas_refund)),
                opcode_utils.getOpName(opcode),
            ) catch {};
        }

        try self.executeOpcode(opcode);
    }

    /// Main execution loop
    pub fn execute(self: *Self) EvmError!void {
        var iteration_count: u64 = 0;
        const max_iterations: u64 = 10_000_000; // Prevent infinite loops (reasonable limit ~10M ops)
        while (!self.stopped and !self.reverted and self.pc < self.bytecode.len) {
            iteration_count += 1;
            if (iteration_count > max_iterations) {
                return error.ExecutionTimeout;
            }
            try self.step();
        }
    }
};
