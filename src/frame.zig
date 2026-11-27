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

const dispatcher_mod = @import("instructions/dispatcher.zig");
const u256_math = @import("u256_math.zig");
const compiled_code = @import("compiled_code.zig");
const hardfork_hooks = @import("hardfork_hooks.zig");

/// Creates a configured Frame type that matches the given Evm config.
pub fn Frame(comptime config: EvmConfig) type {
    return struct {
        const Self = @This();
        const max_memory_size = @min(config.memory_limit, std.math.maxInt(u32)) & ~@as(u64, 31);
        pub const EvmType = evm_mod.Evm(config);
        pub const EvmError = @import("errors.zig").CallError;

        /// Standard opcode table shared with every Frame instantiation.
        const Dispatcher = dispatcher_mod.Dispatcher(Self);

        stack: std.ArrayList(u256),
        /// Contiguous backing bytes for EVM memory. May be shorter than `memory_size`;
        /// bytes past `memory.items.len` read as zero.
        memory: std.ArrayList(u8),
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
        /// EIP-8037 (Amsterdam+): gas reserved for state creation (drawn before `gas_remaining`).
        state_gas_reservoir: u64 = 0,
        /// EIP-8037 (Amsterdam+): state gas spilled from `gas_remaining` in this frame/children.
        state_gas_spilled: u64 = 0,
        /// EIP-8037 (Amsterdam+): net state gas charged in this frame and committed children.
        state_gas_used: i64 = 0,

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
            var self = try initLazy(allocator, bytecode_raw, gas, caller, address, value, calldata, evm_ptr, hardfork, is_static);
            errdefer self.deinit();
            try self.bytecode.ensureAnalyzed();
            return self;
        }

        /// Fast frame initialization that defers JUMPDEST bitset analysis until
        /// an un-compiled fallback path actually needs it.
        pub fn initLazy(
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
            try stack.ensureTotalCapacity(allocator, @min(config.stack_size, 32));
            errdefer stack.deinit(allocator);

            return Self{
                .stack = stack,
                .memory = .empty,
                .memory_size = 0,
                .pc = 0,
                .gas_remaining = gas,
                .bytecode = Bytecode.initLazy(allocator, bytecode_raw),
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

        /// Peek at the stack item `index_from_top` positions below the top (0 = top).
        pub fn peekStack(self: *const Self, index_from_top: usize) EvmError!u256 {
            if (index_from_top >= self.stack.items.len) {
                return error.StackUnderflow;
            }
            return self.stack.items[self.stack.items.len - 1 - index_from_top];
        }

        /// Overwrite the top stack word in place.
        /// Precondition: the stack is non-empty (callers peek first).
        pub fn setStackTop(self: *Self, value: u256) void {
            std.debug.assert(self.stack.items.len > 0);
            self.stack.items[self.stack.items.len - 1] = value;
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
            // The configured `memory_limit` caps every non-empty region the same way.
            const limit: u64 = @min(max_memory_end, max_memory_size);
            if (offset > limit or len > limit) {
                self.gas_remaining = 0;
                return error.OutOfGas;
            }
            const off: u64 = @intCast(offset);
            const length: u64 = @intCast(len);
            const end = off + length;
            if (end > limit) {
                self.gas_remaining = 0;
                return error.OutOfGas;
            }
            return .{ .offset = @intCast(off), .len = @intCast(length), .end = end };
        }

        /// Expansion cost for an optional range (0 for an empty range).
        pub fn memoryRangeCost(self: *Self, range: ?MemoryRange) u64 {
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
            if (end > max_memory_size) return error.OutOfGas;
            return self.growMemoryBytes(@intCast(end));
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
            const word_aligned_size = try wordAlignedSize(@as(u64, end_u32));
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
            const word_aligned_size = try wordAlignedSize(@as(u64, end));
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
            const word_aligned_size = try wordAlignedSize(@as(u64, end));
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
            const word_aligned_size = try wordAlignedSize(@as(u64, max_end));
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

        /// Charge EIP-8037 state gas (Amsterdam+): draws from `state_gas_reservoir` first,
        /// spilling any remainder into `gas_remaining`. Fails with `OutOfGas` if regular
        /// gas cannot cover the spill.
        pub fn chargeStateGas(self: *Self, amount: u64) EvmError!void {
            if (amount == 0) return;
            const from_reservoir = @min(self.state_gas_reservoir, amount);
            const from_gas_left = amount - from_reservoir;
            if (self.step_metering and from_gas_left > 0) {
                @branchHint(.unlikely);
                self.step_attempted_gas +|= from_gas_left;
            }
            if (from_gas_left > std.math.maxInt(i64) or self.gas_remaining < @as(i64, @intCast(from_gas_left))) {
                self.gas_remaining = 0;
                return error.OutOfGas;
            }
            self.state_gas_reservoir -= from_reservoir;
            self.gas_remaining -= @intCast(from_gas_left);
            self.state_gas_spilled +|= from_gas_left;
            self.state_gas_used +|= @as(i64, @intCast(@min(amount, std.math.maxInt(i64))));
        }

        /// Refund EIP-8037 state gas in LIFO source order: refill `state_gas_spilled` back
        /// into `gas_remaining` first, then credit any remainder to `state_gas_reservoir`.
        pub fn refundStateGas(self: *Self, amount: u64) void {
            if (amount == 0) return;
            const to_gas_left = @min(self.state_gas_spilled, amount);
            const to_reservoir = amount - to_gas_left;
            self.state_gas_spilled -= to_gas_left;
            self.gas_remaining +|= @as(i64, @intCast(@min(to_gas_left, std.math.maxInt(i64))));
            self.state_gas_reservoir +|= to_reservoir;
            self.state_gas_used -|= @as(i64, @intCast(@min(amount, std.math.maxInt(i64))));
        }

        /// Commit a succeeded child frame's EIP-8037 state gas accounting into this parent frame,
        /// discharging any child restoration advance against this frame's spilled state gas.
        pub fn mergeChildStateGas(self: *Self, child_reservoir: u64, child_spilled: u64, child_used: i64) void {
            self.state_gas_reservoir = child_reservoir;
            self.state_gas_spilled +|= child_spilled;
            self.state_gas_used +|= child_used;
            if (child_used < 0) {
                const advance: u64 = @abs(child_used);
                const discharge = @min(@min(self.state_gas_spilled, advance), self.state_gas_reservoir);
                self.state_gas_reservoir -= discharge;
                self.state_gas_spilled -= discharge;
                self.gas_remaining +|= @as(i64, @intCast(@min(discharge, std.math.maxInt(i64))));
            }
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

            // No artificial size cap: compute the exact Ethereum cost and return
            // maxInt(u64) only when the math genuinely overflows u64. consumeGas
            // rejects anything above maxInt(i64) as OutOfGas. The configured
            // `memory_limit` is enforced by `memoryRange` and the backing growth paths.
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

        /// Calculate CREATE gas cost (EIP-3860 / EIP-8038 aware)
        pub fn createGasCost(self: *const Self, init_code_size: u32) u64 {
            var gas_cost: u64 = hardfork_hooks.GasSchedule.forFork(self.hardfork).create.regular;

            if (self.hardfork.isAtLeast(.SHANGHAI)) {
                @branchHint(.likely);
                const word_count = wordCount(@as(u64, init_code_size));
                gas_cost += word_count * GasConstants.InitcodeWordGas;
            }

            return gas_cost;
        }

        /// Calculate CREATE2 gas cost (EIP-3860 / EIP-8038 aware)
        pub fn create2GasCost(self: *const Self, init_code_size: u32) u64 {
            var gas_cost: u64 = hardfork_hooks.GasSchedule.forFork(self.hardfork).create.regular;

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
                // memSize is the frame's logical memory size, recorded even when
                // memory-byte capture is disabled.
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
            const suspended = if (result) |_| false else |err| err == error.NeedAsyncData;
            const fault: ?[]const u8 = if (result) |_|
                if (self.reverted) inspector_mod.formatErrorName(error.RevertExecution) else null
            else |err| if (suspended) null else inspector_mod.formatErrorName(err);
            if (token) |step_token| {
                if (suspended) {
                    // A suspension is not a fault: the opcode re-executes on resume and
                    // records its own entry then. Drop this one if nothing followed it,
                    // and never stamp an error on it.
                    discardPendingTraceEntry(tracer.?, step_token);
                } else {
                    tracer.?.finishStep(step_token, gas_cost, fault);
                }
            }
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
            std.mem.sortUnstable(trace.StorageEntry, snapshot.items, {}, struct {
                fn lessThan(_: void, first: trace.StorageEntry, second: trace.StorageEntry) bool {
                    return first.slot < second.slot;
                }
            }.lessThan);
            return snapshot.toOwnedSlice(self.allocator);
        }

        /// Remove the pending entry for `token` when it is still the newest retained step.
        /// Used when an opcode suspends with `error.NeedAsyncData`: the opcode re-executes on
        /// resume and records its own entry then.
        fn discardPendingTraceEntry(tracer: *trace.Tracer, token: usize) void {
            if (token < tracer.first_retained_step) return;
            const index = token - tracer.first_retained_step;
            if (index + 1 != tracer.entries.items.len) return;
            const entry = tracer.entries.pop().?;
            entry.deinit(tracer.allocator);
        }

        inline fn effectiveStackCap(self: *const Self) usize {
            return @min(self.stack.capacity, config.stack_size);
        }

        fn growStackCold(self: *Self, pc: usize, gas: i64, sp: usize) EvmError!void {
            @branchHint(.cold);
            self.pc = @intCast(pc);
            self.gas_remaining = gas;
            self.stack.items.len = sp;
            if (sp >= config.stack_size) return error.StackOverflow;
            const new_cap = @min(config.stack_size, @max(self.stack.capacity * 2, 128));
            try self.stack.ensureTotalCapacityPrecise(self.allocator, new_cap);
        }

        /// Fast-path labeled-switch threaded interpreter loop.
        /// Keeps pc, gas, sp, and stack pointer in CPU registers with zero per-opcode
        /// tracer/inspector/JS-callback checks and comptime-specialized PUSH/DUP/SWAP.
        fn executeFast(self: *Self) EvmError!void {
            const code = self.bytecode.code;
            const code_len = code.len;
            if (self.stopped or self.reverted or self.pc >= code_len) return;
            try self.bytecode.ensureAnalyzed();

            var pc: usize = self.pc;
            var gas: i64 = self.gas_remaining;
            var sp: usize = self.stack.items.len;
            var stack_ptr: [*]u256 = self.stack.items.ptr;
            var stack_cap: usize = self.effectiveStackCap();
            const hardfork = self.hardfork;

            sw: switch (code[pc]) {
                // 0x00: STOP
                0x00 => {
                    self.stopped = true;
                    self.pc = @intCast(pc);
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    return;
                },
                // 0x01: ADD
                0x01 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] +% stack_ptr[sp - 1];
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x02: MUL
                0x02 => {
                    gas -= GasConstants.GasFastStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] *% stack_ptr[sp - 1];
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x03: SUB
                0x03 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] -% stack_ptr[sp - 1];
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x04: DIV
                0x04 => {
                    gas -= GasConstants.GasFastStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = u256_math.div(stack_ptr[sp], stack_ptr[sp - 1]);
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x06: MOD
                0x06 => {
                    gas -= GasConstants.GasFastStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = u256_math.mod(stack_ptr[sp], stack_ptr[sp - 1]);
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x08: ADDMOD
                0x08 => {
                    gas -= GasConstants.GasMidStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 3) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    const a = stack_ptr[sp - 1];
                    const b = stack_ptr[sp - 2];
                    const n = stack_ptr[sp - 3];
                    sp -= 2;
                    stack_ptr[sp - 1] = u256_math.addmod(a, b, n);
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x09: MULMOD
                0x09 => {
                    gas -= GasConstants.GasMidStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 3) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    const a = stack_ptr[sp - 1];
                    const b = stack_ptr[sp - 2];
                    const n = stack_ptr[sp - 3];
                    sp -= 2;
                    stack_ptr[sp - 1] = u256_math.mulmod(a, b, n);
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x10: LT
                0x10 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp] < stack_ptr[sp - 1]);
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x11: GT
                0x11 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp] > stack_ptr[sp - 1]);
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x12: SLT
                0x12 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(@as(i256, @bitCast(stack_ptr[sp])) < @as(i256, @bitCast(stack_ptr[sp - 1])));
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x13: SGT
                0x13 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(@as(i256, @bitCast(stack_ptr[sp])) > @as(i256, @bitCast(stack_ptr[sp - 1])));
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x14: EQ
                0x14 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp] == stack_ptr[sp - 1]);
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x15: ISZERO
                0x15 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 1) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp - 1] == 0);
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x16: AND
                0x16 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] & stack_ptr[sp - 1];
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x17: OR
                0x17 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] | stack_ptr[sp - 1];
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x18: XOR
                0x18 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] ^ stack_ptr[sp - 1];
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x19: NOT
                0x19 => {
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 1) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    stack_ptr[sp - 1] = ~stack_ptr[sp - 1];
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x1b: SHL (Constantinople+)
                0x1b => {
                    if (hardfork.isBefore(.CONSTANTINOPLE)) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.InvalidOpcode;
                    }
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    const shift = stack_ptr[sp];
                    const value = stack_ptr[sp - 1];
                    stack_ptr[sp - 1] = if (shift >= 256) 0 else value << @as(u8, @intCast(shift));
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x1c: SHR (Constantinople+)
                0x1c => {
                    if (hardfork.isBefore(.CONSTANTINOPLE)) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.InvalidOpcode;
                    }
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    const shift = stack_ptr[sp];
                    const value = stack_ptr[sp - 1];
                    stack_ptr[sp - 1] = if (shift >= 256) 0 else value >> @as(u8, @intCast(shift));
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x36: CALLDATASIZE
                0x36 => {
                    gas -= GasConstants.GasQuickStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp >= stack_cap) {
                        try self.growStackCold(pc, gas, sp);
                        stack_ptr = self.stack.items.ptr;
                        stack_cap = self.effectiveStackCap();
                    }
                    stack_ptr[sp] = self.calldata.len;
                    sp += 1;
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x50: POP
                0x50 => {
                    gas -= GasConstants.GasQuickStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 1) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x56: JUMP
                0x56 => {
                    gas -= GasConstants.GasMidStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 1) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    sp -= 1;
                    const dest = stack_ptr[sp];
                    const dest_pc = std.math.cast(u32, dest) orelse {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.InvalidJumpDestination;
                    };
                    if (!self.bytecode.isValidJumpDest(dest_pc)) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.InvalidJump;
                    }
                    pc = dest_pc;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x57: JUMPI
                0x57 => {
                    gas -= GasConstants.GasSlowStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < 2) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    const dest = stack_ptr[sp - 1];
                    const cond = stack_ptr[sp - 2];
                    sp -= 2;
                    if (cond != 0) {
                        const dest_pc = std.math.cast(u32, dest) orelse {
                            self.pc = @intCast(pc);
                            self.gas_remaining = gas;
                            self.stack.items.len = sp;
                            return error.InvalidJumpDestination;
                        };
                        if (!self.bytecode.isValidJumpDest(dest_pc)) {
                            self.pc = @intCast(pc);
                            self.gas_remaining = gas;
                            self.stack.items.len = sp;
                            return error.InvalidJump;
                        }
                        pc = dest_pc;
                    } else {
                        pc += 1;
                    }
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x58: PC
                0x58 => {
                    gas -= GasConstants.GasQuickStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp >= stack_cap) {
                        try self.growStackCold(pc, gas, sp);
                        stack_ptr = self.stack.items.ptr;
                        stack_cap = self.effectiveStackCap();
                    }
                    stack_ptr[sp] = pc;
                    sp += 1;
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x59: MSIZE
                0x59 => {
                    gas -= GasConstants.GasQuickStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp >= stack_cap) {
                        try self.growStackCold(pc, gas, sp);
                        stack_ptr = self.stack.items.ptr;
                        stack_cap = self.effectiveStackCap();
                    }
                    stack_ptr[sp] = self.memory_size;
                    sp += 1;
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x5a: GAS
                0x5a => {
                    gas -= GasConstants.GasQuickStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp >= stack_cap) {
                        try self.growStackCold(pc, gas, sp);
                        stack_ptr = self.stack.items.ptr;
                        stack_cap = self.effectiveStackCap();
                    }
                    stack_ptr[sp] = @as(u64, @intCast(gas));
                    sp += 1;
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x5b: JUMPDEST
                0x5b => {
                    gas -= GasConstants.JumpdestGas;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x5f: PUSH0 (Shanghai+)
                0x5f => {
                    if (hardfork.isBefore(.SHANGHAI)) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.InvalidOpcode;
                    }
                    gas -= GasConstants.GasQuickStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp >= stack_cap) {
                        try self.growStackCold(pc, gas, sp);
                        stack_ptr = self.stack.items.ptr;
                        stack_cap = self.effectiveStackCap();
                    }
                    stack_ptr[sp] = 0;
                    sp += 1;
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x60..0x7f: PUSH1..PUSH32 (comptime-specialized!)
                inline 0x60...0x7f => |op| {
                    const n: usize = op - 0x5f;
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp >= stack_cap) {
                        try self.growStackCold(pc, gas, sp);
                        stack_ptr = self.stack.items.ptr;
                        stack_cap = self.effectiveStackCap();
                    }
                    const start = pc + 1;
                    const value: u256 = if (start + n <= code_len) blk: {
                        const IntType = std.meta.Int(.unsigned, n * 8);
                        break :blk @as(u256, std.mem.readInt(IntType, code[start..][0..n], .big));
                    } else blk: {
                        var buf: [32]u8 = [_]u8{0} ** 32;
                        if (start < code_len) {
                            const avail = @min(code_len - start, n);
                            @memcpy(buf[32 - n .. 32 - n + avail], code[start .. start + avail]);
                        }
                        break :blk std.mem.readInt(u256, &buf, .big);
                    };
                    stack_ptr[sp] = value;
                    sp += 1;
                    pc += 1 + n;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x80..0x8f: DUP1..DUP16 (comptime-specialized!)
                inline 0x80...0x8f => |op| {
                    const n: usize = op - 0x7f;
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp < n) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    if (sp >= stack_cap) {
                        try self.growStackCold(pc, gas, sp);
                        stack_ptr = self.stack.items.ptr;
                        stack_cap = self.effectiveStackCap();
                    }
                    stack_ptr[sp] = stack_ptr[sp - n];
                    sp += 1;
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // 0x90..0x9f: SWAP1..SWAP16 (comptime-specialized!)
                inline 0x90...0x9f => |op| {
                    const n: usize = op - 0x8f;
                    gas -= GasConstants.GasFastestStep;
                    if (gas < 0) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.OutOfGas;
                    }
                    if (sp <= n) {
                        self.pc = @intCast(pc);
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return error.StackUnderflow;
                    }
                    const top = stack_ptr[sp - 1];
                    stack_ptr[sp - 1] = stack_ptr[sp - 1 - n];
                    stack_ptr[sp - 1 - n] = top;
                    pc += 1;
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
                // All other opcodes delegate to Dispatcher with full frame sync
                else => |op| {
                    self.pc = @intCast(pc);
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    try Dispatcher.execute(self, op);
                    if (self.stopped or self.reverted) return;
                    pc = self.pc;
                    gas = self.gas_remaining;
                    sp = self.stack.items.len;
                    stack_ptr = self.stack.items.ptr;
                    stack_cap = self.effectiveStackCap();
                    if (pc >= code_len) break :sw;
                    continue :sw code[pc];
                },
            }

            self.pc = @intCast(pc);
            self.gas_remaining = gas;
            self.stack.items.len = sp;
        }

        fn ensureStackCapCold(self: *Self, raw_pc: u32, gas: i64, sp: usize, needed: usize) EvmError!void {
            @branchHint(.cold);
            self.pc = raw_pc;
            self.gas_remaining = gas;
            self.stack.items.len = sp;
            if (needed > config.stack_size) return error.StackOverflow;
            const new_cap = @min(config.stack_size, @max(self.stack.capacity * 2, needed));
            try self.stack.ensureTotalCapacityPrecise(self.allocator, new_cap);
        }

        const CompiledBreak = union(enum) {
            done,
            fallback: u32,
            deopt,
        };

        /// Basic-block fused, superinstruction-accelerated threaded interpreter.
        /// Validates gas and stack bounds once per basic block (`begin_block`) and executes
        /// fused opcodes with zero per-op gas/stack/PC-bounds checks.
        ///
        /// Snapshots `ops`, `const_pool`, and `jumpdests` at entry so `compiled.*` is never
        /// dereferenced across nested CALLs (which may evict this slot in `CodeCache`).
        fn executeCompiled(self: *Self, compiled: *const compiled_code.CompiledCode) EvmError!void {
            const ops = compiled.ops;
            const const_pool = compiled.const_pool;
            const jumpdests = compiled.jumpdests;
            const code = self.bytecode.code;

            var ip: usize = 0;
            while (true) {
                switch (try self.executeCompiledChunk(ops, const_pool, jumpdests, &ip)) {
                    .done => return,
                    .fallback => |raw_pc| {
                        try Dispatcher.execute(self, code[raw_pc]);
                        if (self.stopped or self.reverted) return;
                    },
                    .deopt => return self.executeFast(),
                }
            }
        }

        /// Executes compiled instructions until frame completion, a `.fallback` opcode
        /// (popping this function's stack frame before nested CALL/CREATE recursion),
        /// or a block-entry guard failure (`.deopt`).
        noinline fn executeCompiledChunk(
            self: *Self,
            ops: []const compiled_code.Inst,
            const_pool: []const u256,
            jumpdests: []const compiled_code.JumpDestEntry,
            ip_ptr: *usize,
        ) EvmError!CompiledBreak {
            var ip: usize = ip_ptr.*;
            var gas: i64 = self.gas_remaining;
            var sp: usize = self.stack.items.len;
            var stack_ptr: [*]u256 = self.stack.items.ptr;
            var stack_cap: usize = self.effectiveStackCap();

            sw: switch (ops[ip].op) {
                .begin_block => {
                    const inst = ops[ip];
                    const meta: compiled_code.BlockMeta = @bitCast(inst.imm);
                    if (gas < meta.gas or sp < meta.min_stack or sp + meta.max_growth > config.stack_size) {
                        @branchHint(.unlikely);
                        // Cold error path: delegate to un-fused executeFast for exact error tag & PC.
                        self.pc = inst.aux;
                        self.gas_remaining = gas;
                        self.stack.items.len = sp;
                        return .deopt;
                    }
                    if (sp + meta.max_growth > stack_cap) {
                        @branchHint(.unlikely);
                        try self.ensureStackCapCold(inst.aux, gas, sp, sp + meta.max_growth);
                        stack_ptr = self.stack.items.ptr;
                        stack_cap = self.effectiveStackCap();
                    }
                    gas -= meta.gas;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .stop => {
                    self.stopped = true;
                    self.pc = ops[ip].aux;
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    return .done;
                },
                .push0 => {
                    stack_ptr[sp] = 0;
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_u64 => {
                    stack_ptr[sp] = ops[ip].imm;
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_const => {
                    stack_ptr[sp] = const_pool[@intCast(ops[ip].imm)];
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_jump => {
                    const target = ops[ip].aux;
                    if (target == compiled_code.INVALID_TARGET) {
                        @branchHint(.unlikely);
                        self.pc = @intCast(ops[ip].imm);
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.InvalidJump;
                    }
                    ip = target;
                    continue :sw ops[ip].op;
                },
                .push_jumpi => {
                    sp -= 1;
                    if (stack_ptr[sp] != 0) {
                        const target = ops[ip].aux;
                        if (target == compiled_code.INVALID_TARGET) {
                            @branchHint(.unlikely);
                            self.pc = @intCast(ops[ip].imm);
                            self.gas_remaining = 0;
                            self.stack.items.len = sp;
                            return error.InvalidJump;
                        }
                        ip = target;
                    } else {
                        ip += 1;
                    }
                    continue :sw ops[ip].op;
                },
                .iszero_push_jumpi => {
                    sp -= 1;
                    if (stack_ptr[sp] == 0) {
                        const target = ops[ip].aux;
                        if (target == compiled_code.INVALID_TARGET) {
                            @branchHint(.unlikely);
                            self.pc = @intCast(ops[ip].imm);
                            self.gas_remaining = 0;
                            self.stack.items.len = sp;
                            return error.InvalidJump;
                        }
                        ip = target;
                    } else {
                        ip += 1;
                    }
                    continue :sw ops[ip].op;
                },
                .dup1_iszero_push_jumpi => {
                    if (stack_ptr[sp - 1] == 0) {
                        const target = ops[ip].aux;
                        if (target == compiled_code.INVALID_TARGET) {
                            @branchHint(.unlikely);
                            self.pc = @intCast(ops[ip].imm);
                            self.gas_remaining = 0;
                            self.stack.items.len = sp;
                            return error.InvalidJump;
                        }
                        ip = target;
                    } else {
                        ip += 1;
                    }
                    continue :sw ops[ip].op;
                },
                .push_add => {
                    stack_ptr[sp - 1] +%= ops[ip].imm;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_sub => {
                    stack_ptr[sp - 1] = @as(u256, ops[ip].imm) -% stack_ptr[sp - 1];
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_swap1_sub => {
                    stack_ptr[sp - 1] -%= ops[ip].imm;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_mul => {
                    stack_ptr[sp - 1] *%= ops[ip].imm;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_lt => {
                    stack_ptr[sp - 1] = @intFromBool(@as(u256, ops[ip].imm) < stack_ptr[sp - 1]);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_swap1_lt => {
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp - 1] < @as(u256, ops[ip].imm));
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_gt => {
                    stack_ptr[sp - 1] = @intFromBool(@as(u256, ops[ip].imm) > stack_ptr[sp - 1]);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_swap1_gt => {
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp - 1] > @as(u256, ops[ip].imm));
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_eq => {
                    stack_ptr[sp - 1] = @intFromBool(@as(u256, ops[ip].imm) == stack_ptr[sp - 1]);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_and => {
                    stack_ptr[sp - 1] &= ops[ip].imm;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_shl => {
                    const shift = ops[ip].imm;
                    stack_ptr[sp - 1] = if (shift >= 256) 0 else stack_ptr[sp - 1] << @intCast(shift);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .push_shr => {
                    const shift = ops[ip].imm;
                    stack_ptr[sp - 1] = if (shift >= 256) 0 else stack_ptr[sp - 1] >> @intCast(shift);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .swap1_pop => {
                    stack_ptr[sp - 2] = stack_ptr[sp - 1];
                    sp -= 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .add => {
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] +% stack_ptr[sp - 1];
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .mul => {
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] *% stack_ptr[sp - 1];
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .sub => {
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] -% stack_ptr[sp - 1];
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .div => {
                    sp -= 1;
                    stack_ptr[sp - 1] = u256_math.div(stack_ptr[sp], stack_ptr[sp - 1]);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .sdiv => {
                    sp -= 1;
                    const a = stack_ptr[sp];
                    const b = stack_ptr[sp - 1];
                    if (b == 0) {
                        stack_ptr[sp - 1] = 0;
                    } else {
                        const a_neg = (a >> 255) != 0;
                        const b_neg = (b >> 255) != 0;
                        const abs_a = if (a_neg) (0 -% a) else a;
                        const abs_b = if (b_neg) (0 -% b) else b;
                        const q = u256_math.div(abs_a, abs_b);
                        stack_ptr[sp - 1] = if (a_neg != b_neg) (0 -% q) else q;
                    }
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .mod => {
                    sp -= 1;
                    stack_ptr[sp - 1] = u256_math.mod(stack_ptr[sp], stack_ptr[sp - 1]);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .smod => {
                    sp -= 1;
                    const a = stack_ptr[sp];
                    const b = stack_ptr[sp - 1];
                    if (b == 0) {
                        stack_ptr[sp - 1] = 0;
                    } else {
                        const a_neg = (a >> 255) != 0;
                        const b_neg = (b >> 255) != 0;
                        const abs_a = if (a_neg) (0 -% a) else a;
                        const abs_b = if (b_neg) (0 -% b) else b;
                        const r = u256_math.mod(abs_a, abs_b);
                        stack_ptr[sp - 1] = if (a_neg) (0 -% r) else r;
                    }
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .addmod => {
                    const a = stack_ptr[sp - 1];
                    const b = stack_ptr[sp - 2];
                    const n = stack_ptr[sp - 3];
                    sp -= 2;
                    stack_ptr[sp - 1] = u256_math.addmod(a, b, n);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .mulmod => {
                    const a = stack_ptr[sp - 1];
                    const b = stack_ptr[sp - 2];
                    const n = stack_ptr[sp - 3];
                    sp -= 2;
                    stack_ptr[sp - 1] = u256_math.mulmod(a, b, n);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .signextend => {
                    sp -= 1;
                    const byte_num = stack_ptr[sp];
                    const val = stack_ptr[sp - 1];
                    if (byte_num < 31) {
                        const bit_idx: u8 = @intCast(byte_num * 8 + 7);
                        const mask = (@as(u256, 1) << bit_idx) - 1;
                        if (((val >> bit_idx) & 1) != 0) {
                            stack_ptr[sp - 1] = val | ~mask;
                        } else {
                            stack_ptr[sp - 1] = val & mask;
                        }
                    }
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .lt => {
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp] < stack_ptr[sp - 1]);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .gt => {
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp] > stack_ptr[sp - 1]);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .slt => {
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(@as(i256, @bitCast(stack_ptr[sp])) < @as(i256, @bitCast(stack_ptr[sp - 1])));
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .sgt => {
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(@as(i256, @bitCast(stack_ptr[sp])) > @as(i256, @bitCast(stack_ptr[sp - 1])));
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .eq => {
                    sp -= 1;
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp] == stack_ptr[sp - 1]);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .iszero => {
                    stack_ptr[sp - 1] = @intFromBool(stack_ptr[sp - 1] == 0);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .bit_and => {
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] & stack_ptr[sp - 1];
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .bit_or => {
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] | stack_ptr[sp - 1];
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .bit_xor => {
                    sp -= 1;
                    stack_ptr[sp - 1] = stack_ptr[sp] ^ stack_ptr[sp - 1];
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .bit_not => {
                    stack_ptr[sp - 1] = ~stack_ptr[sp - 1];
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .byte_op => {
                    sp -= 1;
                    const idx = stack_ptr[sp];
                    const val = stack_ptr[sp - 1];
                    stack_ptr[sp - 1] = if (idx >= 32) 0 else (val >> @intCast(248 - idx * 8)) & 0xff;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .shl => {
                    sp -= 1;
                    const shift = stack_ptr[sp];
                    stack_ptr[sp - 1] = if (shift >= 256) 0 else stack_ptr[sp - 1] << @intCast(shift);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .shr => {
                    sp -= 1;
                    const shift = stack_ptr[sp];
                    stack_ptr[sp - 1] = if (shift >= 256) 0 else stack_ptr[sp - 1] >> @intCast(shift);
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .sar => {
                    sp -= 1;
                    const shift = stack_ptr[sp];
                    const val_i: i256 = @bitCast(stack_ptr[sp - 1]);
                    stack_ptr[sp - 1] = if (shift >= 256)
                        (if (val_i < 0) std.math.maxInt(u256) else 0)
                    else
                        @bitCast(val_i >> @intCast(shift));
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .pop => {
                    sp -= 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .pc_op => {
                    stack_ptr[sp] = ops[ip].aux;
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                inline .dup1, .dup2, .dup3, .dup4, .dup5, .dup6, .dup7, .dup8, .dup9, .dup10, .dup11, .dup12, .dup13, .dup14, .dup15, .dup16 => |op_tag| {
                    const n: usize = @intFromEnum(op_tag) - @intFromEnum(compiled_code.Op.dup1) + 1;
                    stack_ptr[sp] = stack_ptr[sp - n];
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                inline .swap1, .swap2, .swap3, .swap4, .swap5, .swap6, .swap7, .swap8, .swap9, .swap10, .swap11, .swap12, .swap13, .swap14, .swap15, .swap16 => |op_tag| {
                    const n: usize = @intFromEnum(op_tag) - @intFromEnum(compiled_code.Op.swap1) + 1;
                    const top = stack_ptr[sp - 1];
                    stack_ptr[sp - 1] = stack_ptr[sp - 1 - n];
                    stack_ptr[sp - 1 - n] = top;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .jump => {
                    sp -= 1;
                    const dest = stack_ptr[sp];
                    if (dest > std.math.maxInt(u32)) {
                        @branchHint(.unlikely);
                        self.pc = ops[ip].aux;
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.InvalidJump;
                    }
                    const target_ip = compiled_code.resolveJumpDestSlice(jumpdests, @intCast(dest)) orelse {
                        @branchHint(.unlikely);
                        self.pc = ops[ip].aux;
                        self.gas_remaining = 0;
                        self.stack.items.len = sp;
                        return error.InvalidJump;
                    };
                    ip = target_ip;
                    continue :sw ops[ip].op;
                },
                .jumpi => {
                    sp -= 2;
                    const dest = stack_ptr[sp + 1];
                    const cond = stack_ptr[sp];
                    if (cond != 0) {
                        if (dest > std.math.maxInt(u32)) {
                            @branchHint(.unlikely);
                            self.pc = ops[ip].aux;
                            self.gas_remaining = 0;
                            self.stack.items.len = sp;
                            return error.InvalidJump;
                        }
                        const target_ip = compiled_code.resolveJumpDestSlice(jumpdests, @intCast(dest)) orelse {
                            @branchHint(.unlikely);
                            self.pc = ops[ip].aux;
                            self.gas_remaining = 0;
                            self.stack.items.len = sp;
                            return error.InvalidJump;
                        };
                        ip = target_ip;
                    } else {
                        ip += 1;
                    }
                    continue :sw ops[ip].op;
                },
                .address_op => {
                    stack_ptr[sp] = std.mem.readInt(u160, &self.address.bytes, .big);
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .caller => {
                    stack_ptr[sp] = std.mem.readInt(u160, &self.caller.bytes, .big);
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .callvalue => {
                    stack_ptr[sp] = self.value;
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .calldatasize => {
                    stack_ptr[sp] = self.calldata.len;
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .returndatasize => {
                    stack_ptr[sp] = self.return_data.len;
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .calldataload => {
                    const off = stack_ptr[sp - 1];
                    if (off +| 32 <= self.calldata.len) {
                        const o: usize = @intCast(off);
                        stack_ptr[sp - 1] = std.mem.readInt(u256, self.calldata[o..][0..32], .big);
                    } else if (off >= self.calldata.len) {
                        stack_ptr[sp - 1] = 0;
                    } else {
                        const o: usize = @intCast(off);
                        var word: [32]u8 = [_]u8{0} ** 32;
                        const avail = self.calldata.len - o;
                        @memcpy(word[0..avail], self.calldata[o..]);
                        stack_ptr[sp - 1] = std.mem.readInt(u256, &word, .big);
                    }
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .msize => {
                    stack_ptr[sp] = self.memory_size;
                    sp += 1;
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .mload => {
                    if (sp >= 1 and gas >= GasConstants.GasFastestStep) {
                        const off = stack_ptr[sp - 1];
                        if (off <= self.memory_size and off + 32 <= self.memory_size) {
                            gas -= GasConstants.GasFastestStep;
                            const o: usize = @intCast(off);
                            if (o + 32 <= self.memory.items.len) {
                                stack_ptr[sp - 1] = std.mem.readInt(u256, self.memory.items[o..][0..32], .big);
                            } else {
                                var word: [32]u8 = [_]u8{0} ** 32;
                                if (o < self.memory.items.len) {
                                    const avail = self.memory.items.len - o;
                                    @memcpy(word[0..avail], self.memory.items[o..]);
                                }
                                stack_ptr[sp - 1] = std.mem.readInt(u256, &word, .big);
                            }
                            ip += 1;
                            continue :sw ops[ip].op;
                        }
                    }
                    self.pc = ops[ip].aux;
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    try Dispatcher.execute(self, 0x51);
                    if (self.stopped or self.reverted) return .done;
                    gas = self.gas_remaining;
                    sp = self.stack.items.len;
                    stack_ptr = self.stack.items.ptr;
                    stack_cap = self.effectiveStackCap();
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .mstore => {
                    if (sp >= 2 and gas >= GasConstants.GasFastestStep) {
                        const off = stack_ptr[sp - 1];
                        if (off <= self.memory.items.len and off + 32 <= self.memory.items.len and off + 32 <= self.memory_size) {
                            gas -= GasConstants.GasFastestStep;
                            const o: usize = @intCast(off);
                            std.mem.writeInt(u256, self.memory.items[o..][0..32], stack_ptr[sp - 2], .big);
                            sp -= 2;
                            ip += 1;
                            continue :sw ops[ip].op;
                        }
                    }
                    self.pc = ops[ip].aux;
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    try Dispatcher.execute(self, 0x52);
                    if (self.stopped or self.reverted) return .done;
                    gas = self.gas_remaining;
                    sp = self.stack.items.len;
                    stack_ptr = self.stack.items.ptr;
                    stack_cap = self.effectiveStackCap();
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .mstore8 => {
                    if (sp >= 2 and gas >= GasConstants.GasFastestStep) {
                        const off = stack_ptr[sp - 1];
                        if (off < self.memory.items.len and off < self.memory_size) {
                            gas -= GasConstants.GasFastestStep;
                            self.memory.items[@intCast(off)] = @truncate(stack_ptr[sp - 2]);
                            sp -= 2;
                            ip += 1;
                            continue :sw ops[ip].op;
                        }
                    }
                    self.pc = ops[ip].aux;
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    try Dispatcher.execute(self, 0x53);
                    if (self.stopped or self.reverted) return .done;
                    gas = self.gas_remaining;
                    sp = self.stack.items.len;
                    stack_ptr = self.stack.items.ptr;
                    stack_cap = self.effectiveStackCap();
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .mcopy => {
                    if (sp >= 3) {
                        const dst = stack_ptr[sp - 1];
                        const src = stack_ptr[sp - 2];
                        const size = stack_ptr[sp - 3];
                        if (size == 0) {
                            if (gas >= GasConstants.GasFastestStep) {
                                gas -= GasConstants.GasFastestStep;
                                sp -= 3;
                                ip += 1;
                                continue :sw ops[ip].op;
                            }
                        } else if (dst <= self.memory.items.len and src <= self.memory.items.len and size <= self.memory.items.len) {
                            const d: usize = @intCast(dst);
                            const s: usize = @intCast(src);
                            const n: usize = @intCast(size);
                            const end = @max(d + n, s + n);
                            if (end <= self.memory.items.len and end <= self.memory_size) {
                                const words: u64 = @intCast((n + 31) >> 5);
                                const cost_u64: u64 = GasConstants.GasFastestStep + words * GasConstants.CopyGas;
                                const cost: i64 = @intCast(cost_u64);
                                if (gas >= cost) {
                                    gas -= cost;
                                    if (d < s) {
                                        std.mem.copyForwards(u8, self.memory.items[d .. d + n], self.memory.items[s .. s + n]);
                                    } else if (d > s) {
                                        std.mem.copyBackwards(u8, self.memory.items[d .. d + n], self.memory.items[s .. s + n]);
                                    }
                                    sp -= 3;
                                    ip += 1;
                                    continue :sw ops[ip].op;
                                }
                            }
                        }
                    }
                    self.pc = ops[ip].aux;
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    try Dispatcher.execute(self, 0x5e);
                    if (self.stopped or self.reverted) return .done;
                    gas = self.gas_remaining;
                    sp = self.stack.items.len;
                    stack_ptr = self.stack.items.ptr;
                    stack_cap = self.effectiveStackCap();
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .keccak256 => {
                    if (sp >= 2) {
                        const off = stack_ptr[sp - 1];
                        const size = stack_ptr[sp - 2];
                        if (size == 0) {
                            if (gas >= GasConstants.Keccak256Gas) {
                                gas -= GasConstants.Keccak256Gas;
                                sp -= 1;
                                stack_ptr[sp - 1] = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
                                ip += 1;
                                continue :sw ops[ip].op;
                            }
                        } else if (off <= self.memory.items.len and size <= self.memory.items.len) {
                            const o: usize = @intCast(off);
                            const n: usize = @intCast(size);
                            if (o + n <= self.memory.items.len and o + n <= self.memory_size) {
                                const words: u64 = @intCast((n + 31) >> 5);
                                const cost_u64: u64 = GasConstants.Keccak256Gas + words * GasConstants.Keccak256WordGas;
                                const cost: i64 = @intCast(cost_u64);
                                if (gas >= cost) {
                                    gas -= cost;
                                    const digest = primitives.Hash.keccak256(self.memory.items[o .. o + n]);
                                    sp -= 1;
                                    stack_ptr[sp - 1] = std.mem.readInt(u256, &digest, .big);
                                    ip += 1;
                                    continue :sw ops[ip].op;
                                }
                            }
                        }
                    }
                    self.pc = ops[ip].aux;
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    try Dispatcher.execute(self, 0x20);
                    if (self.stopped or self.reverted) return .done;
                    gas = self.gas_remaining;
                    sp = self.stack.items.len;
                    stack_ptr = self.stack.items.ptr;
                    stack_cap = self.effectiveStackCap();
                    ip += 1;
                    continue :sw ops[ip].op;
                },
                .fallback => {
                    const raw_pc = ops[ip].aux;
                    self.pc = raw_pc;
                    self.gas_remaining = gas;
                    self.stack.items.len = sp;
                    ip_ptr.* = ip + 1;
                    return .{ .fallback = raw_pc };
                },
            }
        }

        /// Main execution loop
        pub fn execute(self: *Self) EvmError!void {
            const evm = self.getEvm();
            const observed = evm.inspector != null or
                (evm.tracer != null and evm.tracer.?.enabled) or
                (comptime config.opcode_overrides.len > 0) or
                (comptime config.loop_quota != null) or
                @import("root_c.zig").jsOpcodeCallbacksEnabled();
            if (observed) {
                @branchHint(.unlikely);
                while (!self.stopped and !self.reverted and self.pc < self.bytecode.len()) {
                    // config.loop_quota bounds opcode steps per frame; null (the default) means unlimited.
                    if (config.loop_quota) |quota| {
                        if (self.iterations >= quota) return error.ExecutionTimeout;
                    }
                    try self.step();
                    if (config.loop_quota != null) self.iterations += 1;
                }
                return;
            }
            if (comptime config.enable_compiled_interpreter) {
                if (self.pc == 0 and !self.stopped and !self.reverted and !evm.async_active and
                    !hardfork_hooks.supportsAmsterdam(self.hardfork) and self.bytecode.code.len > 0)
                {
                    const compiled = try evm.code_cache.getOrCompile(evm.allocator, self.bytecode.code, self.hardfork);
                    return self.executeCompiled(compiled);
                }
                return self.executeFast();
            }
            try self.bytecode.ensureAnalyzed();
            while (!self.stopped and !self.reverted and self.pc < self.bytecode.len()) {
                try self.step();
            }
        }
    };
}
