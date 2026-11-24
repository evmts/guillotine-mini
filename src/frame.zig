const inspector_mod = @import("inspector.zig");
const trace = @import("trace.zig");
/// Frame implementation for tracing
/// This mirrors the architecture of frame/frame.zig but simplified for validation
const std = @import("std");
const log = @import("logger.zig");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Address = primitives.Address.Address;
const Hardfork = @import("voltaire").Hardfork;
const opcode_utils = @import("opcode.zig");
const precompiles = @import("precompiles");
const evm_mod = @import("evm.zig");
const EvmConfig = @import("evm_config.zig").EvmConfig;
const Bytecode = @import("bytecode.zig").Bytecode;

// Handler modules
const handlers_arithmetic = @import("instructions/handlers_arithmetic.zig");
const handlers_comparison = @import("instructions/handlers_comparison.zig");
const handlers_bitwise = @import("instructions/handlers_bitwise.zig");
const handlers_keccak = @import("instructions/handlers_keccak.zig");
const handlers_context = @import("instructions/handlers_context.zig");
const handlers_block = @import("instructions/handlers_block.zig");
const handlers_stack = @import("instructions/handlers_stack.zig");
const handlers_memory = @import("instructions/handlers_memory.zig");
const handlers_storage = @import("instructions/handlers_storage.zig");
const handlers_control_flow = @import("instructions/handlers_control_flow.zig");
const handlers_log = @import("instructions/handlers_log.zig");
const handlers_system = @import("instructions/handlers_system.zig");

/// Creates a configured Frame type that matches the given Evm config.
pub fn Frame(comptime config: EvmConfig) type {
    return struct {
        const Self = @This();
        const max_memory_size = @min(config.memory_limit, std.math.maxInt(u32)) & ~@as(u64, 31);
        pub const EvmType = evm_mod.Evm(config);
        pub const EvmError = @import("errors.zig").CallError;

        // Instantiate handler modules
        const ArithmeticHandlers = handlers_arithmetic.Handlers(Self);
        const ComparisonHandlers = handlers_comparison.Handlers(Self);
        const BitwiseHandlers = handlers_bitwise.Handlers(Self);
        const KeccakHandlers = handlers_keccak.Handlers(Self);
        const ContextHandlers = handlers_context.Handlers(Self);
        const BlockHandlers = handlers_block.Handlers(Self);
        const StackHandlers = handlers_stack.Handlers(Self);
        const MemoryHandlers = handlers_memory.Handlers(Self);
        const StorageHandlers = handlers_storage.Handlers(Self);
        const ControlFlowHandlers = handlers_control_flow.Handlers(Self);
        const LogHandlers = handlers_log.Handlers(Self);
        const SystemHandlers = handlers_system.Handlers(Self);

        stack: std.ArrayList(u256),
        memory: std.ArrayListUnmanaged(u8),
        memory_size: u32,
        iterations: u32 = 0,
        pc: u32,
        gas_remaining: i64,
        bytecode: Bytecode,
        caller: Address,
        address: Address,
        value: u256,
        calldata: []const u8,
        output: []u8,
        return_data: []const u8,
        stopped: bool,
        reverted: bool,
        evm_ptr: *anyopaque,
        allocator: std.mem.Allocator,
        authorized: ?u256,
        call_depth: u32,
        hardfork: Hardfork,
        is_static: bool,
        frame_id: u64 = 0,
        parent_frame_id: ?u64 = null,
        code_address: Address,
        step_metering: bool = false,
        step_child_gas_spent: u64 = 0,
        step_attempted_gas: u64 = 0,
        step_memory_expansion_gas: u64 = 0,

        /// Initialize a new frame for bytecode execution
        ///
        /// Creates a new execution frame with the given parameters. Performs bytecode analysis
        /// to identify valid jump destinations (JUMPDEST opcodes).
        ///
        /// Parameters:
        ///   - allocator: Memory allocator for frame resources
        ///   - bytecode_raw: Raw bytecode to execute
        ///   - gas: Initial gas available for execution (signed for gas refunds)
        ///   - caller: Address that initiated this call
        ///   - address: Address being executed (contract address)
        ///   - value: Wei value transferred with this call
        ///   - calldata: Input data for the call
        ///   - evm_ptr: Opaque pointer to parent Evm instance
        ///   - hardfork: Active hardfork for gas metering and feature flags
        ///   - is_static: Whether this is a static call (no state modifications allowed)
        ///
        /// Returns: Initialized Frame instance
        ///
        /// Errors:
        ///   - OutOfMemory: If allocation fails for stack, memory, or bytecode analysis
        pub fn init(
            allocator: std.mem.Allocator,
            bytecode_raw: []const u8,
            gas: i64,
            caller: Address,
            address: Address,
            value: u256,
            calldata: []const u8,
            evm_ptr: *anyopaque,
            hardfork: Hardfork,
            is_static: bool,
        ) !Self {
            var stack = std.ArrayList(u256){};
            try stack.ensureTotalCapacity(allocator, @min(config.stack_size, 64));
            errdefer stack.deinit(allocator);

            const memory_buf: std.ArrayListUnmanaged(u8) = .{};

            // Analyze bytecode to identify valid jump destinations
            var bytecode = try Bytecode.init(allocator, bytecode_raw);
            errdefer bytecode.deinit();

            return Self{
                .stack = stack,
                .memory = memory_buf,
                .memory_size = 0,
                .pc = 0,
                .gas_remaining = gas,
                .bytecode = bytecode,
                .caller = caller,
                .address = address,
                .code_address = address,
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
                .is_static = is_static,
            };
        }

        /// Clean up resources
        pub fn deinit(self: *Self) void {
            // Free output if it was heap-allocated (e.g. by RETURN/REVERT handlers).
            // When using an arena allocator this is harmless (arena frees everything at once).
            if (self.output.len > 0) {
                self.allocator.free(self.output);
            }
            self.stack.deinit(self.allocator);
            self.memory.deinit(self.allocator);
            self.bytecode.deinit();
        }

        /// Get the Evm instance matching this Frame's config
        ///
        /// Retrieves a typed pointer to the parent EVM instance from the opaque pointer.
        /// This is a helper for instruction handlers that need to access EVM state
        /// (storage, balances, nested calls, etc.).
        ///
        /// Returns: Typed pointer to parent Evm instance with matching config
        pub fn getEvm(self: *Self) *evm_mod.Evm(config) {
            return @ptrCast(@alignCast(self.evm_ptr));
        }

        /// Push value onto stack
        pub fn pushStack(self: *Self, value: u256) EvmError!void {
            if (self.stack.items.len >= config.stack_size) {
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

        /// Overwrite the top stack word in place.
        /// Precondition: the stack is non-empty (callers peek first).
        pub fn setStackTop(self: *Self, value: u256) void {
            std.debug.assert(self.stack.items.len > 0);
            self.stack.items[self.stack.items.len - 1] = value;
        }

        inline fn wordCount(bytes: u64) u64 {
            return (bytes + 31) / 32;
        }

        /// Calculate word-aligned memory size for EVM compliance
        pub inline fn wordAlignedSize(bytes: u64) u32 {
            const words = wordCount(bytes);
            return @intCast(words * 32);
        }

        /// Ensure contiguous memory backing covers `[0, end)` with zero-initialized new bytes.
        pub inline fn ensureMemoryBytes(self: *Self, end: u32) EvmError!void {
            const end_usize: usize = @intCast(end);
            if (end_usize <= self.memory.items.len) return;
            return self.growMemoryBytes(end_usize);
        }

        fn growMemoryBytes(self: *Self, end_usize: usize) EvmError!void {
            @branchHint(.cold);
            if (end_usize > max_memory_size) return error.OutOfGas;
            const old_len = self.memory.items.len;
            const aligned_len = (end_usize + 31) & ~@as(usize, 31);
            try self.memory.resize(self.allocator, aligned_len);
            @memset(self.memory.items[old_len..aligned_len], 0);
        }

        /// Read byte from memory
        pub inline fn readMemory(self: *const Self, offset: u32) u8 {
            const idx: usize = @intCast(offset);
            return if (idx < self.memory.items.len) self.memory.items[idx] else 0;
        }

        /// Safe add helper for u32 indices
        inline fn add_u32(a: u32, b: u32) EvmError!u32 {
            return std.math.add(u32, a, b) catch return error.OutOfBounds;
        }

        /// Write byte to memory
        pub inline fn writeMemory(self: *Self, offset: u32, value: u8) EvmError!void {
            const end_u32 = try add_u32(offset, 1);
            try self.ensureMemoryBytes(end_u32);
            self.memory.items[offset] = value;
            // EVM memory expands to word-aligned (32-byte) boundaries
            const word_aligned_size = wordAlignedSize(@as(u64, end_u32));
            if (word_aligned_size > self.memory_size) self.memory_size = word_aligned_size;
        }

        /// Read a big-endian 32-byte word from memory (zero-padded past backing len)
        pub inline fn readMemoryWord(self: *const Self, offset: u32) EvmError!u256 {
            const end = try add_u32(offset, 32);
            const off_usize: usize = @intCast(offset);
            const end_usize: usize = @intCast(end);
            if (end_usize <= self.memory.items.len) {
                return std.mem.readInt(u256, self.memory.items[off_usize..][0..32], .big);
            }
            var buf: [32]u8 = [_]u8{0} ** 32;
            if (off_usize < self.memory.items.len) {
                const avail = self.memory.items.len - off_usize;
                @memcpy(buf[0..avail], self.memory.items[off_usize..][0..avail]);
            }
            return std.mem.readInt(u256, &buf, .big);
        }

        /// Write a big-endian 32-byte word to memory
        pub inline fn writeMemoryWord(self: *Self, offset: u32, value: u256) EvmError!void {
            const end = try add_u32(offset, 32);
            try self.ensureMemoryBytes(end);
            std.mem.writeInt(u256, self.memory.items[@intCast(offset)..][0..32], value, .big);
            const word_aligned_size = wordAlignedSize(@as(u64, end));
            if (word_aligned_size > self.memory_size) self.memory_size = word_aligned_size;
        }

        /// Return a zero-copy slice of memory `[offset, offset + len)` (growing zero-filled backing if needed)
        pub inline fn readMemorySlice(self: *Self, offset: u32, len: u32) EvmError![]const u8 {
            if (len == 0) return &[_]u8{};
            const end = try add_u32(offset, len);
            try self.ensureMemoryBytes(end);
            return self.memory.items[@intCast(offset)..@intCast(end)];
        }

        /// Copy `dest.len` bytes from memory starting at `offset`, zero-padding past backing length
        pub inline fn copyFromMemory(self: *const Self, dest: []u8, offset: u32) EvmError!void {
            if (dest.len == 0) return;
            _ = try add_u32(offset, @intCast(dest.len));
            const off_usize: usize = @intCast(offset);
            if (off_usize >= self.memory.items.len) {
                @memset(dest, 0);
                return;
            }
            const avail = @min(dest.len, self.memory.items.len - off_usize);
            @memcpy(dest[0..avail], self.memory.items[off_usize .. off_usize + avail]);
            if (avail < dest.len) {
                @memset(dest[avail..], 0);
            }
        }

        /// Write a contiguous byte slice to memory at `offset`
        pub inline fn writeMemorySlice(self: *Self, offset: u32, data: []const u8) EvmError!void {
            if (data.len == 0) return;
            const end = try add_u32(offset, @intCast(data.len));
            try self.ensureMemoryBytes(end);
            @memcpy(self.memory.items[@intCast(offset)..@intCast(end)], data);
            const word_aligned_size = wordAlignedSize(@as(u64, end));
            if (word_aligned_size > self.memory_size) self.memory_size = word_aligned_size;
        }

        /// Copy `len` bytes from `src[src_off..]` into memory at `dest_off`, zero-padding beyond `src.len`
        pub inline fn writeMemoryZeroPadded(self: *Self, dest_off: u32, src: []const u8, src_off: u64, len: u32) EvmError!void {
            if (len == 0) return;
            const end = try add_u32(dest_off, len);
            try self.ensureMemoryBytes(end);
            const dst = self.memory.items[@intCast(dest_off)..@intCast(end)];
            if (src_off < src.len) {
                const start: usize = @intCast(src_off);
                const avail = @min(@as(usize, @intCast(len)), src.len - start);
                @memcpy(dst[0..avail], src[start .. start + avail]);
                if (avail < dst.len) {
                    @memset(dst[avail..], 0);
                }
            } else {
                @memset(dst, 0);
            }
            const word_aligned_size = wordAlignedSize(@as(u64, end));
            if (word_aligned_size > self.memory_size) self.memory_size = word_aligned_size;
        }

        /// Copy `len` bytes within memory (handles overlapping regions with zero heap allocations)
        pub inline fn copyMemory(self: *Self, dest: u32, src: u32, len: u32) EvmError!void {
            if (len == 0) return;
            const dest_end = try add_u32(dest, len);
            const src_end = try add_u32(src, len);
            const max_end = @max(dest_end, src_end);
            try self.ensureMemoryBytes(max_end);
            const dst_slice = self.memory.items[@intCast(dest)..@intCast(dest_end)];
            const src_slice = self.memory.items[@intCast(src)..@intCast(src_end)];
            if (dest <= src) {
                std.mem.copyForwards(u8, dst_slice, src_slice);
            } else {
                std.mem.copyBackwards(u8, dst_slice, src_slice);
            }
            const word_aligned_size = wordAlignedSize(@as(u64, max_end));
            if (word_aligned_size > self.memory_size) self.memory_size = word_aligned_size;
        }

        /// Get current opcode
        pub fn getCurrentOpcode(self: *const Self) ?u8 {
            return self.bytecode.getOpcode(self.pc);
        }

        /// Read immediate data for PUSH operations
        pub fn readImmediate(self: *const Self, size: u8) ?u256 {
            return self.bytecode.readImmediate(self.pc, size);
        }

        /// ----------------------------------- GAS ---------------------------------- ///
        /// Consume gas
        pub fn consumeGas(self: *Self, amount: u64) EvmError!void {
            if (self.step_metering) {
                @branchHint(.unlikely);
                self.step_attempted_gas +|= amount;
            }
            // Check if amount is too large to fit in i64 or exceeds remaining gas
            if (amount > std.math.maxInt(i64) or self.gas_remaining < @as(i64, @intCast(amount))) {
                self.gas_remaining = 0;
                return error.OutOfGas;
            }
            self.gas_remaining -= @intCast(amount);
        }

        /// Calculate memory expansion cost
        /// The total memory cost for n words is: 3n + n²/512, where a word is 32 bytes.
        pub fn memoryExpansionCost(self: *Self, end_bytes: u64) u64 {
            const cost = self.calculateMemoryExpansionCost(end_bytes);
            if (self.step_metering) {
                @branchHint(.unlikely);
                self.step_memory_expansion_gas +|= cost;
            }
            return cost;
        }

        fn calculateMemoryExpansionCost(self: *const Self, end_bytes: u64) u64 {
            const current_size = @as(u64, self.memory_size);

            if (end_bytes <= current_size) return 0;

            // Callers combine this sentinel with other costs using saturating addition.
            if (end_bytes > max_memory_size) return std.math.maxInt(u64);

            const current_words = wordCount(current_size);
            const new_words = wordCount(end_bytes);

            // Check for overflow in word * word calculation using saturating multiplication
            // If overflow would occur, return max gas to trigger OutOfGas
            const current_words_squared = std.math.mul(u64, current_words, current_words) catch return std.math.maxInt(u64);
            const new_words_squared = std.math.mul(u64, new_words, new_words) catch return std.math.maxInt(u64);

            // Calculate cost for each size with overflow protection
            const current_linear = std.math.mul(u64, GasConstants.MemoryGas, current_words) catch return std.math.maxInt(u64);
            const current_quadratic = current_words_squared / GasConstants.QuadCoeffDiv;
            const current_cost = std.math.add(u64, current_linear, current_quadratic) catch return std.math.maxInt(u64);

            const new_linear = std.math.mul(u64, GasConstants.MemoryGas, new_words) catch return std.math.maxInt(u64);
            const new_quadratic = new_words_squared / GasConstants.QuadCoeffDiv;
            const new_cost = std.math.add(u64, new_linear, new_quadratic) catch return std.math.maxInt(u64);

            return std.math.sub(u64, new_cost, current_cost) catch return std.math.maxInt(u64);
        }

        /// Calculate gas cost for external account operations (EIP-150, EIP-1884, EIP-2929 aware)
        /// Note: This returns 700 for Tangerine Whistle+ (EXTCODESIZE/EXTCODECOPY use this)
        /// BALANCE and EXTCODEHASH have their own gas cost calculations
        pub fn externalAccountGasCost(self: *Self, address: Address) !u64 {
            const evm = self.getEvm();

            if (self.hardfork.isAtLeast(.BERLIN)) {
                // Post-Berlin: Cold/warm access pattern (EIP-2929)
                @branchHint(.likely);
                return try evm.accessAddress(address);
            } else if (self.hardfork.isAtLeast(.TANGERINE_WHISTLE)) {
                // EIP-150 (Tangerine Whistle): EXTCODESIZE/EXTCODECOPY cost 700 gas
                return 700;
            } else {
                // Pre-EIP-150: Lower cost (20 gas)
                return 20;
            }
        }

        /// Calculate SELFDESTRUCT gas cost (EIP-150 aware)
        pub fn selfdestructGasCost(self: *const Self) u64 {
            if (self.hardfork.isBefore(.TANGERINE_WHISTLE)) {
                @branchHint(.cold);
                return 0; // Pre-EIP-150: Free operation
            }
            return GasConstants.SelfdestructGas; // Post-EIP-150: 5000 gas
        }

        /// Calculate SELFDESTRUCT refund (EIP-3529 aware)
        pub fn selfdestructRefund(self: *const Self) u64 {
            if (self.hardfork.isAtLeast(.LONDON)) {
                @branchHint(.likely);
                return 0; // EIP-3529: No refund in London+
            }
            return GasConstants.SelfdestructRefundGas; // Pre-London: 24,000 refund
        }

        /// Calculate CREATE gas cost (EIP-3860 aware)
        pub fn createGasCost(self: *const Self, init_code_size: u32) u64 {
            var gas_cost: u64 = GasConstants.CreateGas; // Base 32,000 gas

            if (self.hardfork.isAtLeast(.SHANGHAI)) {
                @branchHint(.likely);
                const word_count = wordCount(@as(u64, init_code_size));
                gas_cost += word_count * GasConstants.InitcodeWordGas;
            }

            return gas_cost;
        }

        /// Calculate CREATE2 gas cost (EIP-3860 aware)
        pub fn create2GasCost(self: *const Self, init_code_size: u32) u64 {
            var gas_cost: u64 = GasConstants.CreateGas; // Base 32,000 gas

            // Keccak256 hash cost for hashing init_code (per-word only, no base cost)
            // According to the reference implementation, CREATE2 only charges per-word cost
            const init_code_word_count = wordCount(@as(u64, init_code_size));
            gas_cost += init_code_word_count * GasConstants.Keccak256WordGas;

            if (self.hardfork.isAtLeast(.SHANGHAI)) {
                // Additional init code word cost (EIP-3860)
                @branchHint(.likely);
                gas_cost += init_code_word_count * GasConstants.InitcodeWordGas;
            }

            return gas_cost;
        }

        /// ----------------------------------- OPCODES ---------------------------------- ///
        /// Execute a single opcode - delegates to Evm for external ops
        ///
        /// Executes one EVM opcode instruction. Handles all standard EVM opcodes as well as
        /// custom opcode overrides (JavaScript handlers or native Zig handlers configured via EvmConfig).
        ///
        /// Handler priority:
        ///   1. JavaScript custom handlers (if registered via root_c.zig)
        ///   2. Native Zig custom handlers (configured via EvmConfig.opcode_overrides)
        ///   3. Default EVM opcode implementations
        ///
        /// Parameters:
        ///   - opcode: The opcode byte to execute (0x00-0xFF)
        ///
        /// Returns: void
        ///
        /// Errors:
        ///   - OutOfGas: If insufficient gas for operation
        ///   - StackUnderflow: If stack has insufficient items
        ///   - StackOverflow: If stack exceeds the configured size
        ///   - InvalidJumpDestination: If JUMP/JUMPI targets invalid location
        ///   - StaticCallViolation: If state-modifying op in static context
        ///   - InvalidOpcode: If opcode is not recognized
        ///   - Other errors: Depending on specific opcode requirements
        pub fn executeOpcode(self: *Self, opcode: u8) EvmError!void {
            // Check for JavaScript custom opcode handler first
            const root_c = @import("root_c.zig");
            if (root_c.jsOpcodeCallbacksEnabled() and root_c.tryCallJsOpcodeHandler(opcode, @intFromPtr(self))) {
                // JavaScript handler executed successfully
                return;
            }

            // Check for config-based opcode override (native Zig handlers)
            if (comptime config.opcode_overrides.len > 0) {
                const evm = self.getEvm();
                if (evm.getOpcodeOverride(opcode)) |handler_ptr| {
                    // Cast the handler to the correct function type
                    // Handler signature: fn(*Frame) FrameError!void
                    const handler: *const fn (*Self) EvmError!void = @ptrCast(@alignCast(handler_ptr));
                    return handler(self);
                }
            }

            // Default opcode handling
            switch (opcode) {
                0x00 => try ControlFlowHandlers.stop(self),
                0x01 => try ArithmeticHandlers.add(self),
                0x02 => try ArithmeticHandlers.mul(self),
                0x03 => try ArithmeticHandlers.sub(self),
                0x04 => try ArithmeticHandlers.div(self),
                0x05 => try ArithmeticHandlers.sdiv(self),
                0x06 => try ArithmeticHandlers.mod(self),
                0x07 => try ArithmeticHandlers.smod(self),
                0x08 => try ArithmeticHandlers.addmod(self),
                0x09 => try ArithmeticHandlers.mulmod(self),
                0x0a => try ArithmeticHandlers.exp(self),
                0x0b => try ArithmeticHandlers.signextend(self),
                0x10 => try ComparisonHandlers.lt(self),
                0x11 => try ComparisonHandlers.gt(self),
                0x12 => try ComparisonHandlers.slt(self),
                0x13 => try ComparisonHandlers.sgt(self),
                0x14 => try ComparisonHandlers.eq(self),
                0x15 => try ComparisonHandlers.iszero(self),
                0x16 => try BitwiseHandlers.op_and(self),
                0x17 => try BitwiseHandlers.op_or(self),
                0x18 => try BitwiseHandlers.op_xor(self),
                0x19 => try BitwiseHandlers.op_not(self),
                0x1a => try BitwiseHandlers.byte(self),
                0x1b => try BitwiseHandlers.shl(self),
                0x1c => try BitwiseHandlers.shr(self),
                0x1d => try BitwiseHandlers.sar(self),
                0x1e => try BitwiseHandlers.clz(self),
                0x20 => try KeccakHandlers.sha3(self),
                0x30 => try ContextHandlers.address(self),
                0x31 => try ContextHandlers.balance(self),
                0x32 => try ContextHandlers.origin(self),
                0x33 => try ContextHandlers.caller(self),
                0x34 => try ContextHandlers.callvalue(self),
                0x35 => try ContextHandlers.calldataload(self),
                0x36 => try ContextHandlers.calldatasize(self),
                0x37 => try ContextHandlers.calldatacopy(self),
                0x38 => try ContextHandlers.codesize(self),
                0x39 => try ContextHandlers.codecopy(self),
                0x3a => try ContextHandlers.gasprice(self),
                0x3b => try ContextHandlers.extcodesize(self),
                0x3c => try ContextHandlers.extcodecopy(self),
                0x3d => try ContextHandlers.returndatasize(self),
                0x3e => try ContextHandlers.returndatacopy(self),
                0x3f => try ContextHandlers.extcodehash(self),
                0x40 => try BlockHandlers.blockhash(self),
                0x41 => try BlockHandlers.coinbase(self),
                0x42 => try BlockHandlers.timestamp(self),
                0x43 => try BlockHandlers.number(self),
                0x44 => try BlockHandlers.difficulty(self),
                0x45 => try BlockHandlers.gaslimit(self),
                0x46 => try BlockHandlers.chainid(self),
                0x47 => try BlockHandlers.selfbalance(self),
                0x48 => try BlockHandlers.basefee(self),
                0x49 => try BlockHandlers.blobhash(self),
                0x4a => try BlockHandlers.blobbasefee(self),
                0x50 => try StackHandlers.pop(self),
                0x51 => try MemoryHandlers.mload(self),
                0x52 => try MemoryHandlers.mstore(self),
                0x53 => try MemoryHandlers.mstore8(self),
                0x54 => try StorageHandlers.sload(self),
                0x55 => try StorageHandlers.sstore(self),
                0x56 => try ControlFlowHandlers.jump(self),
                0x57 => try ControlFlowHandlers.jumpi(self),
                0x58 => try ControlFlowHandlers.pc(self),
                0x59 => try MemoryHandlers.msize(self),
                0x5a => try ContextHandlers.gas(self),
                0x5b => try ControlFlowHandlers.jumpdest(self),
                0x5c => try StorageHandlers.tload(self),
                0x5d => try StorageHandlers.tstore(self),
                0x5e => try MemoryHandlers.mcopy(self),
                0x5f...0x7f => try StackHandlers.push(self, opcode),
                0x80...0x8f => try StackHandlers.dup(self, opcode),
                0x90...0x9f => try StackHandlers.swap(self, opcode),
                0xa0...0xa4 => try LogHandlers.log(self, opcode),
                0xf0 => try SystemHandlers.create(self),
                0xf1 => try SystemHandlers.call(self),
                0xf2 => try SystemHandlers.callcode(self),
                0xf3 => try ControlFlowHandlers.ret(self),
                0xf4 => try SystemHandlers.delegatecall(self),
                0xf5 => try SystemHandlers.create2(self),
                0xfa => try SystemHandlers.staticcall(self),
                0xfd => try ControlFlowHandlers.revert(self),
                0xff => try SystemHandlers.selfdestruct(self),
                else => return error.InvalidOpcode,
            }
        }

        /// Get memory contents as a slice (for tracing)
        fn getMemorySlice(self: *Self, allocator: std.mem.Allocator) ![]u8 {
            if (self.memory_size == 0) return &[_]u8{};

            const mem_slice = try allocator.alloc(u8, self.memory_size);
            const copy_len = @min(mem_slice.len, self.memory.items.len);
            if (copy_len > 0) {
                @memcpy(mem_slice[0..copy_len], self.memory.items[0..copy_len]);
            }
            if (copy_len < mem_slice.len) {
                @memset(mem_slice[copy_len..], 0);
            }
            return mem_slice;
        }

        /// Execute a single step
        pub fn step(self: *Self) EvmError!void {
            if (self.stopped or self.reverted or self.pc >= self.bytecode.len()) {
                return;
            }
            const opcode = self.getCurrentOpcode() orelse return;

            const evm = self.getEvm();
            const tracer = evm.tracer;
            const observer = evm.inspector;
            if (observer == null and (tracer == null or !tracer.?.enabled)) {
                return self.executeOpcode(opcode);
            } else {
                @branchHint(.unlikely);
                return self.stepObserved(evm, tracer, observer, opcode);
            }
        }

        fn stepObserved(self: *Self, evm: *EvmType, tracer: ?*trace.Tracer, observer: ?inspector_mod.Inspector, opcode: u8) EvmError!void {
            const sink = if (observer) |candidate|
                if (candidate.opcode_mask.contains(opcode)) candidate else null
            else
                null;
            if (sink == null and tracer == null) return self.executeOpcode(opcode);

            const capture = if (tracer) |active| active.willCapture() else false;
            const emit_opcode = if (sink) |active| active.vtable.onOpcode != null else false;
            const capture_memory = (capture and tracer.?.config.tracksMemory()) or
                (emit_opcode and sink.?.capture_memory);
            const allocator = self.allocator;
            const memory = if (capture_memory) try self.getMemorySlice(allocator) else null;
            defer if (memory) |bytes| allocator.free(bytes);

            const event: inspector_mod.OpcodeEvent = .{
                .frame_id = self.frame_id,
                .pc = self.pc,
                .op = opcode,
                .op_name = opcode_utils.getOpName(opcode),
                .gas = @intCast(@max(self.gas_remaining, 0)),
                .memory_size = self.memory_size,
                .memory = memory,
                .stack = self.stack.items,
                .return_data = self.return_data,
                .depth = @max(1, evm.frames.items.len),
                .refund = @intCast(@min(evm.gas_refund, std.math.maxInt(i64))),
                .address = self.address,
                .code_address = self.code_address,
            };
            var token: ?usize = null;
            if (tracer) |active| {
                const storage = if (capture and active.config.tracksStorage()) try self.traceStorage(evm) else null;
                defer if (storage) |slots| allocator.free(slots);
                token = try active.capture(.{
                    .pc = event.pc,
                    .op = opcode,
                    .opName = event.op_name,
                    .gas = event.gas,
                    .gasCost = 0,
                    .memory = event.memory,
                    .memSize = event.memory_size,
                    .stack = event.stack,
                    .returnData = event.return_data,
                    .depth = event.depth,
                    .refund = event.refund,
                    .storage = storage,
                }, false);
            }
            if (emit_opcode) {
                @branchHint(.unlikely);
                sink.?.onOpcode(event);
            }
            self.step_metering = true;
            self.step_attempted_gas = 0;
            self.step_child_gas_spent = 0;
            self.step_memory_expansion_gas = 0;
            const result = self.executeOpcode(opcode);
            self.step_metering = false;

            const gas_after: u64 = @intCast(@max(self.gas_remaining, 0));
            // CALL debits forwarded gas via consumeGas and later credits the unused
            // portion. CREATE's execution and deposit costs are child-only charges.
            const gas_cost = if (self.step_attempted_gas != 0)
                self.step_attempted_gas
            else
                event.gas -| (gas_after +| self.step_child_gas_spent);
            const fault: ?[]const u8 = if (result) |_|
                if (self.reverted) inspector_mod.formatErrorName(error.RevertExecution) else null
            else |err| if (err == error.NeedAsyncData) null else inspector_mod.formatErrorName(err);
            if (token) |step_token| tracer.?.finishStep(step_token, gas_cost, fault);
            if (sink) |active| {
                @branchHint(.unlikely);
                const end: inspector_mod.OpcodeEndEvent = .{
                    .frame_id = event.frame_id,
                    .pc = event.pc,
                    .op = opcode,
                    .gas_cost = gas_cost,
                    .gas_after = gas_after,
                    .memory_expansion_gas = self.step_memory_expansion_gas,
                    .error_name = fault,
                };
                active.onOpcodeEnd(end);
                if (fault != null) active.onFault(end);
            }
            return result;
        }

        fn traceStorage(self: *Self, evm: *EvmType) EvmError![]trace.StorageEntry {
            var snapshot: std.ArrayList(trace.StorageEntry) = .{};
            defer snapshot.deinit(self.allocator);
            var slots = evm.storage.trace_slots.keyIterator();
            while (slots.next()) |key| {
                if (!std.mem.eql(u8, &key.address, &self.address.bytes)) continue;
                const value = evm.storage.peek(self.address, key.slot) orelse continue;
                try snapshot.append(self.allocator, .{ .slot = key.slot, .value = value });
            }
            std.mem.sort(trace.StorageEntry, snapshot.items, {}, struct {
                fn lessThan(_: void, first: trace.StorageEntry, second: trace.StorageEntry) bool {
                    return first.slot < second.slot;
                }
            }.lessThan);
            return snapshot.toOwnedSlice(self.allocator);
        }

        /// Main execution loop
        pub fn execute(self: *Self) EvmError!void {
            while (!self.stopped and !self.reverted and self.pc < self.bytecode.len()) {
                if (config.loop_quota) |quota| {
                    if (self.iterations == quota) return error.ExecutionTimeout;
                }
                try self.step();
                if (config.loop_quota != null) self.iterations += 1;
            }
        }
    };
}
