/// Execution context opcode handlers for the EVM
const std = @import("std");
const HandlerConfig = @import("frame_interface.zig").HandlerConfig;
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Address = primitives.Address;
const hardfork_hooks = @import("../hardfork_hooks.zig");

/// Handlers struct - provides execution context operation handlers for a Frame type
/// The FrameType must have methods: consumeGas, popStack, pushStack, getEvm, memoryRange,
/// memoryRangeCost, copyToMemory
/// and fields: pc, address, caller, value, calldata, bytecode, return_data, hardfork
pub fn Handlers(FrameType: type) type {
    return HandlersWithConfig(FrameType, .{});
}

/// `Handlers` with comptime `HandlerConfig`. `.charge_gas = false` removes every
/// `consumeGas` call so callers can meter gas themselves.
pub fn HandlersWithConfig(FrameType: type, comptime config: HandlerConfig) type {
    return struct {
        inline fn charge(frame: *FrameType, amount: u64) FrameType.EvmError!void {
            if (config.charge_gas) try frame.consumeGas(amount);
        }

        /// True when a miss-aware `Evm` getter has requested host data the async
        /// transaction has not supplied yet. Evm types without async support never suspend.
        inline fn asyncPending(evm: anytype) bool {
            if (comptime @hasField(@TypeOf(evm.*), "async_restart_pending")) return evm.async_restart_pending;
            return false;
        }

        /// Copy gas: 3 per 32-byte word.
        fn copyGasCost(size: u32) u64 {
            return GasConstants.CopyGas * ((@as(u64, size) + 31) / 32);
        }

        /// Shared CALLDATACOPY / CODECOPY / EXTCODECOPY body after pops and `extra_cost`.
        /// A zero-length copy charges no expansion and ignores both offsets. Source bytes
        /// past the end of `src` (at any offset, including >= 2^64) read as zero.
        fn copyPadded(frame: *FrameType, extra_cost: u64, dest_offset: u256, src_offset: u256, length: u256, src: []const u8) FrameType.EvmError!void {
            const range = try frame.memoryRange(dest_offset, length);
            const len: u32 = if (range) |r| r.len else 0;
            try charge(frame, extra_cost +| copyGasCost(len) +| frame.memoryRangeCost(range));
            if (range) |r| try frame.copyToMemory(r, src, src_offset);
            frame.pc += 1;
        }

        /// ADDRESS opcode (0x30) - Get address of currently executing account
        pub fn address(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasQuickStep);
            const addr_u256 = primitives.Address.toU256(frame.address);
            try frame.pushStack(addr_u256);
            frame.pc += 1;
        }

        /// BALANCE opcode (0x31) - Get balance of an account
        pub fn balance(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            const addr_int = try frame.popStack();
            const addr = Address.fromU256(addr_int);

            // Gas cost: hardfork-aware
            // Berlin+: cold/warm access (2600/100)
            // Istanbul-Berlin: 700 gas (EIP-1884)
            // Tangerine Whistle-Petersburg: 400 gas
            // Pre-Tangerine Whistle: 20 gas
            const warm_cold_cost = try evm.accessAddress(addr);
            const access_cost: u64 = if (evm.hardfork.isAtLeast(.BERLIN))
                warm_cold_cost
            else if (evm.hardfork.isAtLeast(.ISTANBUL))
                @as(u64, 700)
            else if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                @as(u64, 400)
            else
                @as(u64, 20);
            try charge(frame, access_cost);
            const bal = evm.get_balance(addr);
            try frame.pushStack(bal);
            frame.pc += 1;
        }

        /// ORIGIN opcode (0x32) - Get execution origination address
        pub fn origin(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            try charge(frame, GasConstants.GasQuickStep);
            const origin_u256 = primitives.Address.toU256(evm.origin);
            try frame.pushStack(origin_u256);
            frame.pc += 1;
        }

        /// CALLER opcode (0x33) - Get caller address
        pub fn caller(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasQuickStep);
            const caller_u256 = primitives.Address.toU256(frame.caller);
            try frame.pushStack(caller_u256);
            frame.pc += 1;
        }

        /// CALLVALUE opcode (0x34) - Get deposited value by instruction/transaction responsible for this execution
        pub fn callvalue(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasQuickStep);
            try frame.pushStack(frame.value);
            frame.pc += 1;
        }

        /// CALLDATALOAD opcode (0x35) - Get input data of current environment
        pub fn calldataload(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasFastestStep);
            const offset = try frame.popStack();
            var word: [32]u8 = [_]u8{0} ** 32;
            if (offset < frame.calldata.len) {
                const start: usize = @intCast(offset);
                const n = @min(32, frame.calldata.len - start);
                @memcpy(word[0..n], frame.calldata[start..][0..n]);
            }
            try frame.pushStack(std.mem.readInt(u256, &word, .big));
            frame.pc += 1;
        }

        /// CALLDATASIZE opcode (0x36) - Get size of input data in current environment
        pub fn calldatasize(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasQuickStep);
            try frame.pushStack(frame.calldata.len);
            frame.pc += 1;
        }

        /// CALLDATACOPY opcode (0x37) - Copy input data in current environment to memory
        pub fn calldatacopy(frame: *FrameType) FrameType.EvmError!void {
            const dest_offset = try frame.popStack();
            const offset = try frame.popStack();
            const length = try frame.popStack();
            try copyPadded(frame, GasConstants.GasFastestStep, dest_offset, offset, length, frame.calldata);
        }

        /// CODESIZE opcode (0x38) - Get size of code running in current environment
        pub fn codesize(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasQuickStep);
            try frame.pushStack(frame.bytecode.len());
            frame.pc += 1;
        }

        /// CODECOPY opcode (0x39) - Copy code running in current environment to memory
        pub fn codecopy(frame: *FrameType) FrameType.EvmError!void {
            const dest_offset = try frame.popStack();
            const offset = try frame.popStack();
            const length = try frame.popStack();
            try copyPadded(frame, GasConstants.GasFastestStep, dest_offset, offset, length, frame.bytecode.code);
        }

        /// GASPRICE opcode (0x3a) - Get price of gas in current environment
        pub fn gasprice(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            try charge(frame, GasConstants.GasQuickStep);
            try frame.pushStack(evm.gas_price);
            frame.pc += 1;
        }

        /// EXTCODESIZE opcode (0x3b) - Get size of an account's code
        pub fn extcodesize(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // Get code size of external account
            const addr_int = try frame.popStack();
            const ext_addr = primitives.Address.fromU256(addr_int);

            // Gas cost: hardfork-aware
            // Amsterdam (EIP-8038): cold=3100, warm=200 (account access + 100 code load)
            // Berlin-Osaka: cold/warm access (2600/100)
            // Tangerine Whistle-Berlin: 700 gas (EIP-150/EIP-1884)
            // Pre-Tangerine Whistle: 20 gas
            const warm_cold_cost = try evm.accessAddress(ext_addr);
            const access_cost: u64 = if (evm.hardfork.isAtLeast(.BERLIN))
                warm_cold_cost + hardfork_hooks.GasSchedule.forFork(evm.hardfork).extcode_extra
            else if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                @as(u64, 700)
            else
                @as(u64, 20);
            try charge(frame, access_cost);

            const code = evm.get_raw_code(ext_addr);
            if (asyncPending(evm)) return error.NeedAsyncData;
            try frame.pushStack(code.len);
            frame.pc += 1;
        }

        /// EXTCODECOPY opcode (0x3c) - Copy an account's code to memory
        pub fn extcodecopy(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // Copy external account code to memory
            const addr_int = try frame.popStack();
            const dest_offset = try frame.popStack();
            const offset = try frame.popStack();
            const size = try frame.popStack();

            const ext_addr = primitives.Address.fromU256(addr_int);

            // Gas cost: hardfork-aware
            // Amsterdam (EIP-8038): cold=3100, warm=200 (account access + 100 code load)
            // Berlin-Osaka: cold/warm access (2600/100)
            // Tangerine Whistle-Berlin: 700 gas (EIP-150)
            // Pre-Tangerine Whistle: 20 gas
            const warm_cold_cost = try evm.accessAddress(ext_addr);
            const access_cost: u64 = if (evm.hardfork.isAtLeast(.BERLIN))
                warm_cold_cost + hardfork_hooks.GasSchedule.forFork(evm.hardfork).extcode_extra
            else if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                @as(u64, 700)
            else
                @as(u64, 20);

            // Miss-aware read: an unsupplied code field suspends before any charge.
            const code = evm.get_raw_code(ext_addr);
            if (asyncPending(evm)) return error.NeedAsyncData;
            // A zero-length copy charges only account access gas, with no memory expansion
            // and no offset checks; code bytes past the end read as zero.
            try copyPadded(frame, access_cost, dest_offset, offset, size, code);
        }

        /// RETURNDATASIZE opcode (0x3d) - Get size of output data from the previous call
        pub fn returndatasize(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-211: RETURNDATASIZE was introduced in Byzantium hardfork
            if (evm.hardfork.isBefore(.BYZANTIUM)) return error.InvalidOpcode;

            try charge(frame, GasConstants.GasQuickStep);
            try frame.pushStack(frame.return_data.len);
            frame.pc += 1;
        }

        /// RETURNDATACOPY opcode (0x3e) - Copy output data from the previous call to memory
        pub fn returndatacopy(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-211: RETURNDATACOPY was introduced in Byzantium hardfork
            if (evm.hardfork.isBefore(.BYZANTIUM)) return error.InvalidOpcode;

            const dest_offset = try frame.popStack();
            const offset = try frame.popStack();
            const length = try frame.popStack();

            const range = try frame.memoryRange(dest_offset, length);
            const len: u32 = if (range) |r| r.len else 0;
            try charge(frame, GasConstants.GasFastestStep +| copyGasCost(len) +| frame.memoryRangeCost(range));

            // EIP-211: reading past the end of the return data is an exceptional halt,
            // even for a zero-length copy.
            const rd_len = frame.return_data.len;
            if (offset > rd_len or length > rd_len - @as(usize, @intCast(offset))) {
                return error.OutOfBounds;
            }

            if (range) |r| try frame.copyToMemory(r, frame.return_data, offset);
            frame.pc += 1;
        }

        /// EXTCODEHASH opcode (0x3f) - Get hash of an account's code
        pub fn extcodehash(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-1052: EXTCODEHASH opcode was introduced in Constantinople hardfork
            if (evm.hardfork.isBefore(.CONSTANTINOPLE)) return error.InvalidOpcode;

            // Get code hash of external account
            const addr_int = try frame.popStack();
            const ext_addr = primitives.Address.fromU256(addr_int);

            // Gas cost: hardfork-aware
            // Berlin+: cold/warm access (2600/100)
            // Istanbul-Berlin: 700 gas (EIP-1884)
            // Constantinople-Petersburg: 400 gas
            const warm_cold_cost = try evm.accessAddress(ext_addr);
            const access_cost: u64 = if (evm.hardfork.isAtLeast(.BERLIN))
                warm_cold_cost
            else if (evm.hardfork.isAtLeast(.ISTANBUL))
                @as(u64, 700)
            else
                @as(u64, 400);
            try charge(frame, access_cost);

            const code = evm.get_raw_code(ext_addr);
            if (asyncPending(evm)) return error.NeedAsyncData;

            if (code.len == 0) {
                // EIP-161 emptiness reads balance and nonce through the miss-aware getters.
                const is_empty = evm.accountIsEmpty(ext_addr);
                if (asyncPending(evm)) return error.NeedAsyncData;
                if (is_empty) {
                    try frame.pushStack(0);
                } else if (evm.accountExists(ext_addr)) {
                    var empty_hash: [32]u8 = undefined;
                    std.crypto.hash.sha3.Keccak256.hash(&[_]u8{}, &empty_hash, .{});

                    var empty_hash_u256: u256 = 0;
                    for (empty_hash) |byte| {
                        empty_hash_u256 = (empty_hash_u256 << 8) | byte;
                    }
                    try frame.pushStack(empty_hash_u256);
                } else {
                    try frame.pushStack(0);
                }
            } else {
                var hash: [32]u8 = undefined;
                std.crypto.hash.sha3.Keccak256.hash(code, &hash, .{});

                var hash_u256: u256 = 0;
                for (hash) |byte| {
                    hash_u256 = (hash_u256 << 8) | byte;
                }
                try frame.pushStack(hash_u256);
            }
            frame.pc += 1;
        }

        /// GAS opcode (0x5a) - Get the amount of available gas
        pub fn gas(frame: *FrameType) FrameType.EvmError!void {
            try charge(frame, GasConstants.GasQuickStep);
            try frame.pushStack(@intCast(frame.gas_remaining));
            frame.pc += 1;
        }
    };
}
