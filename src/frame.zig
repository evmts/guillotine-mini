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

const dispatcher_mod = @import("instructions/dispatcher.zig");

/// Creates a configured Frame type that matches the given Evm config.
pub fn Frame(comptime config: EvmConfig) type {
    return struct {
        const Self = @This();
        pub const EvmType = evm_mod.Evm(config);
        pub const EvmError = @import("errors.zig").CallError;

        /// Standard opcode table shared with every Frame instantiation.
        const Dispatcher = dispatcher_mod.Dispatcher(Self);

        stack: std.ArrayList(u256),
        /// Backing bytes for EVM memory. May be shorter than `memory_size`;
        /// bytes past `memory.items.len` read as zero.
        memory: std.ArrayList(u8),
        memory_size: u32,
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
            try stack.ensureTotalCapacity(allocator, 1024);
            errdefer stack.deinit(allocator);

            // Analyze bytecode to identify valid jump destinations
            var bytecode = try Bytecode.init(allocator, bytecode_raw);
            errdefer bytecode.deinit();

            return Self{
                .stack = stack,
                .memory = .empty,
                .memory_size = 0,
                .pc = 0,
                .gas_remaining = gas,
                .bytecode = bytecode,
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

        /// Peek at the stack item `index_from_top` positions below the top (0 = top).
        pub fn peekStack(self: *const Self, index_from_top: usize) EvmError!u256 {
            if (index_from_top >= self.stack.items.len) {
                return error.StackUnderflow;
            }
            return self.stack.items[self.stack.items.len - 1 - index_from_top];
        }

        /// Number of 32-byte words covering `bytes`. Never overflows.
        inline fn wordCount(bytes: u64) u64 {
            return bytes / 32 + @intFromBool(bytes % 32 != 0);
        }

        /// Calculate word-aligned memory size for EVM compliance.
        /// Returns OutOfGas when the aligned size does not fit the u32 memory model;
        /// no transaction can pay for 4 GiB of memory, so this is the spec outcome.
        pub inline fn wordAlignedSize(bytes: u64) EvmError!u32 {
            const aligned = std.math.mul(u64, wordCount(bytes), 32) catch return error.OutOfGas;
            return std.math.cast(u32, aligned) orelse error.OutOfGas;
        }

        /// Largest end offset whose word-aligned size fits in `memory_size` (u32).
        pub const max_memory_end: u64 = std.math.maxInt(u32) - 31;

        /// A non-empty memory region `[offset, end)` validated against the u32 memory model.
        pub const MemoryRange = struct {
            offset: u32,
            len: u32,
            end: u64,
        };

        /// Validate a u256 memory region from the stack.
        ///
        /// Returns null when `len == 0`: a zero-length region never expands memory, and its
        /// offset is ignored even when it lies beyond the u32 memory model.
        /// Returns OutOfGas (and burns all gas) when a non-empty region ends past
        /// `max_memory_end`, because its expansion cost exceeds any payable gas.
        pub fn memoryRange(self: *Self, offset: u256, len: u256) EvmError!?MemoryRange {
            if (len == 0) return null;
            if (offset > max_memory_end or len > max_memory_end) {
                self.gas_remaining = 0;
                return error.OutOfGas;
            }
            const off: u64 = @intCast(offset);
            const length: u64 = @intCast(len);
            const end = off + length;
            if (end > max_memory_end) {
                self.gas_remaining = 0;
                return error.OutOfGas;
            }
            return .{ .offset = @intCast(off), .len = @intCast(length), .end = end };
        }

        /// Expansion cost for an optional range (0 for an empty range).
        pub fn memoryRangeCost(self: *const Self, range: ?MemoryRange) u64 {
            const r = range orelse return 0;
            return self.memoryExpansionCost(r.end);
        }

        /// Grow the logical memory size to cover `end` bytes. Call only after charging gas.
        pub fn expandMemory(self: *Self, end: u64) EvmError!void {
            if (end == 0) return;
            const aligned = try wordAlignedSize(end);
            if (aligned > self.memory_size) self.memory_size = aligned;
        }

        /// Grow the backing buffer so `memory.items[0..end]` is addressable, zero-filling new bytes.
        fn ensureMemoryBacking(self: *Self, end: u64) EvmError!void {
            if (end <= self.memory.items.len) return;
            const aligned = try wordAlignedSize(end);
            const old_len = self.memory.items.len;
            try self.memory.resize(self.allocator, aligned);
            @memset(self.memory.items[old_len..], 0);
        }

        /// Write `bytes` to memory at `dest` and grow the logical size to cover them.
        pub fn writeMemorySlice(self: *Self, dest: u32, bytes: []const u8) EvmError!void {
            if (bytes.len == 0) return;
            const end = @as(u64, dest) + @as(u64, bytes.len);
            try self.ensureMemoryBacking(end);
            @memcpy(self.memory.items[dest..][0..bytes.len], bytes);
            try self.expandMemory(end);
        }

        /// Copy `src[src_offset..]` into memory `[range.offset, range.end)`, zero-padding
        /// bytes past the end of `src`. Any `src_offset`, including one past 2^64, is valid.
        pub fn copyToMemory(self: *Self, range: MemoryRange, src: []const u8, src_offset: u256) EvmError!void {
            try self.ensureMemoryBacking(range.end);
            const dst = self.memory.items[range.offset..][0..range.len];
            const available: usize = if (src_offset >= src.len) 0 else @min(dst.len, src.len - @as(usize, @intCast(src_offset)));
            if (available > 0) {
                const start: usize = @intCast(src_offset);
                @memcpy(dst[0..available], src[start..][0..available]);
            }
            @memset(dst[available..], 0);
            try self.expandMemory(range.end);
        }

        /// Read memory `[range.offset, range.end)` into a new buffer; bytes past the backing read as zero.
        pub fn readMemoryAlloc(self: *Self, allocator: std.mem.Allocator, range: MemoryRange) EvmError![]u8 {
            const buf = try allocator.alloc(u8, range.len);
            const backing = self.memory.items;
            const start: usize = range.offset;
            const available: usize = if (start >= backing.len) 0 else @min(buf.len, backing.len - start);
            if (available > 0) @memcpy(buf[0..available], backing[start..][0..available]);
            @memset(buf[available..], 0);
            return buf;
        }

        /// Read byte from memory
        pub fn readMemory(self: *Self, offset: u32) u8 {
            if (offset >= self.memory.items.len) return 0;
            return self.memory.items[offset];
        }

        /// Safe add helper for u32 indices
        inline fn add_u32(a: u32, b: u32) EvmError!u32 {
            return std.math.add(u32, a, b) catch return error.OutOfBounds;
        }

        /// Write byte to memory
        pub fn writeMemory(self: *Self, offset: u32, value: u8) EvmError!void {
            // EVM memory expands to word-aligned (32-byte) boundaries
            const end_offset: u64 = @as(u64, offset) + 1;
            const word_aligned_size = std.math.cast(u32, wordCount(end_offset) * 32) orelse return error.OutOfBounds;
            if (offset >= self.memory.items.len) {
                // Grow the backing buffer to the word boundary and zero-fill the gap.
                const old_len = self.memory.items.len;
                try self.memory.resize(self.allocator, word_aligned_size);
                @memset(self.memory.items[old_len..], 0);
            }
            self.memory.items[offset] = value;
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
            // Check if amount is too large to fit in i64 or exceeds remaining gas
            if (amount > std.math.maxInt(i64) or self.gas_remaining < @as(i64, @intCast(amount))) {
                self.gas_remaining = 0;
                return error.OutOfGas;
            }
            self.gas_remaining -= @intCast(amount);
        }

        /// Calculate memory expansion cost
        /// The total memory cost for n words is: 3n + n²/512, where a word is 32 bytes.
        pub fn memoryExpansionCost(self: *const Self, end_bytes: u64) u64 {
            const current_size = @as(u64, self.memory_size);

            if (end_bytes <= current_size) return 0;

            // No artificial size cap: compute the exact Ethereum cost and return
            // maxInt(u64) only when the math genuinely overflows u64. consumeGas
            // rejects anything above maxInt(i64) as OutOfGas.
            const current_words = wordCount(current_size);
            const new_words = (std.math.add(u64, end_bytes, 31) catch return std.math.maxInt(u64)) / 32;

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
        ///   - StackOverflow: If stack exceeds 1024 items
        ///   - InvalidJumpDestination: If JUMP/JUMPI targets invalid location
        ///   - StaticCallViolation: If state-modifying op in static context
        ///   - InvalidOpcode: If opcode is not recognized
        ///   - Other errors: Depending on specific opcode requirements
        pub fn executeOpcode(self: *Self, opcode: u8) EvmError!void {
            // Check for JavaScript custom opcode handler first
            const root_c = @import("root_c.zig");
            if (root_c.tryCallJsOpcodeHandler(opcode, @intFromPtr(self))) {
                // JavaScript handler executed successfully
                return;
            }

            // Check for config-based opcode override (native Zig handlers)
            const evm = self.getEvm();
            if (evm.getOpcodeOverride(opcode)) |handler_ptr| {
                // Cast the handler to the correct function type
                // Handler signature: fn(*Frame) FrameError!void
                const handler: *const fn (*Self) EvmError!void = @ptrCast(@alignCast(handler_ptr));
                return handler(self);
            }

            // Standard opcodes: the Dispatcher is the single opcode table.
            return Dispatcher.execute(self, opcode);
        }

        /// Get memory contents as a slice (for tracing)
        pub fn getMemorySlice(self: *Self, allocator: std.mem.Allocator) ![]u8 {
            if (self.memory_size == 0) return &[_]u8{};

            const mem_slice = try allocator.alloc(u8, self.memory_size);
            const copy_len = @min(self.memory.items.len, self.memory_size);
            @memcpy(mem_slice[0..copy_len], self.memory.items[0..copy_len]);
            @memset(mem_slice[copy_len..], 0);
            return mem_slice;
        }

        /// Execute a single step
        pub fn step(self: *Self) EvmError!void {
            if (self.stopped or self.reverted or self.pc >= self.bytecode.len()) {
                return;
            }
            const opcode = self.getCurrentOpcode() orelse return;

            // Capture trace before executing opcode
            const evm = self.getEvm();
            if (evm.tracer) |tracer| {
                if (!tracer.enabled or tracer.entries.items.len >= tracer.max_entries) {
                    try self.executeOpcode(opcode);
                    return;
                }
                const frame_index = evm.frames.items.len - 1;
                const trace_allocator = self.allocator;
                const gas_before = @as(u64, @intCast(@max(self.gas_remaining, 0)));
                const mem_slice: ?[]const u8 = if (tracer.config.tracksMemory()) try self.getMemorySlice(self.allocator) else null;
                defer if (mem_slice) |memory| trace_allocator.free(memory);
                const entry_index = tracer.entries.items.len;
                // Capture before execution: nested calls may reallocate frames,
                // and RPC stack/memory snapshots describe the entering opcode.
                try tracer.captureStep(@as(u64, self.pc), opcode, gas_before, 0, mem_slice, self.memory_size, self.stack.items, self.return_data, evm.frames.items.len, evm.gas_refund, opcode_utils.getOpName(opcode));
                const execution_result = self.executeOpcode(opcode);
                if (execution_result) |_| {} else |err| {
                    if (err == error.NeedAsyncData) {
                        // A suspension is not a fault: the opcode re-executes on resume and
                        // records its own entry then. Drop this one if nothing followed it.
                        if (tracer.entries.items.len == entry_index + 1) discardTraceEntry(tracer, tracer.entries.pop().?);
                        return err;
                    }
                }
                const gas_after = @as(u64, @intCast(@max(evm.frames.items[frame_index].gas_remaining, 0)));
                tracer.entries.items[entry_index].gasCost = gas_before -| gas_after;
                if (execution_result) |_| {} else |err| {
                    tracer.entries.items[entry_index].error_msg = try tracer.allocator.dupe(u8, @errorName(err));
                }
                try execution_result;
                return;
            }

            try self.executeOpcode(opcode);
        }

        /// Free the buffers `Tracer.captureState` duplicated for an entry that was removed.
        fn discardTraceEntry(tracer: anytype, entry: anytype) void {
            if (entry.memory) |m| if (m.len > 0) tracer.allocator.free(m);
            if (entry.returnData) |r| if (r.len > 0) tracer.allocator.free(r);
            if (entry.stack.len > 0) tracer.allocator.free(entry.stack);
            tracer.allocator.free(entry.opName);
            if (entry.error_msg) |msg| tracer.allocator.free(msg);
        }

        /// Main execution loop
        pub fn execute(self: *Self) EvmError!void {
            // config.loop_quota bounds opcode steps per frame; null means unlimited.
            if (config.loop_quota) |max_iterations| {
                var iteration_count: u64 = 0;
                while (!self.stopped and !self.reverted and self.pc < self.bytecode.len()) {
                    iteration_count += 1;
                    if (iteration_count > max_iterations) {
                        return error.ExecutionTimeout;
                    }
                    try self.step();
                }
            } else {
                while (!self.stopped and !self.reverted and self.pc < self.bytecode.len()) {
                    try self.step();
                }
            }
        }
    };
}
