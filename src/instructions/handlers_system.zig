/// System opcode handlers for the EVM (CALL, CREATE, SELFDESTRUCT)
const std = @import("std");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const Address = primitives.Address.Address;
const precompiles = @import("precompiles");

/// Handlers struct - provides system operation handlers for a Frame type
/// The FrameType must have methods: getEvm, consumeGas, popStack, pushStack,
/// memoryRange, memoryRangeCost, expandMemory, readMemoryAlloc, writeMemorySlice
/// and fields appropriate for system operations
pub fn Handlers(FrameType: type) type {
    const CallParams = FrameType.EvmType.CallParams;

    return struct {
        const CallKind = enum { call, callcode, delegatecall, staticcall };

        /// Base CALL-family cost before EIP-2929 (Berlin) replaced it with access costs.
        inline fn preBerlinCallGas(hardfork: primitives.Hardfork) u64 {
            return if (hardfork.isBefore(.TANGERINE_WHISTLE))
                GasConstants.CallBaseCost
            else
                GasConstants.CallCodeCost;
        }

        /// Low 160 bits of a stack word as an address.
        fn addressFromWord(word: u256) Address {
            var bytes: [20]u8 = undefined;
            var i: usize = 0;
            while (i < 20) : (i += 1) {
                bytes[19 - i] = @truncate(word >> @intCast(i * 8));
            }
            return Address{ .bytes = bytes };
        }

        fn addressToWord(address: Address) u256 {
            var val: u256 = 0;
            for (address.bytes) |b| val = (val << 8) | b;
            return val;
        }

        /// EIP-161 "alive": the account has a balance, code, or a nonce.
        fn accountIsAlive(evm: anytype, address: Address) bool {
            if (evm.host) |h| {
                return h.getBalance(address) > 0 or h.getCode(address).len > 0 or h.getNonce(address) > 0;
            }
            return (evm.balances.get(address) orelse 0) > 0 or
                (evm.code.get(address) orelse &[_]u8{}).len > 0 or
                (evm.nonces.get(address) orelse 0) > 0;
        }

        /// Record `address` as touched (EIP-161) through the journal that message
        /// checkpoints roll back, mirroring `Evm.touchAccount`.
        fn touchAccount(evm: anytype, address: Address) !void {
            const entry = try evm.touched_accounts.getOrPut(address);
            if (entry.found_existing) return;
            evm.touched_journal.append(evm.tx_arena.allocator(), address) catch |err| {
                _ = evm.touched_accounts.remove(address);
                return err;
            };
        }

        /// Shared CREATE / CREATE2 implementation.
        fn createCommon(frame: *FrameType, comptime is_create2: bool) FrameType.EvmError!void {
            const evm = frame.getEvm();

            // EIP-1014: CREATE2 opcode was introduced in Constantinople hardfork
            if (is_create2 and evm.hardfork.isBefore(.CONSTANTINOPLE)) return error.InvalidOpcode;

            // EIP-214: CREATE/CREATE2 cannot be executed in static call context
            if (frame.is_static) return error.StaticCallViolation;

            // Clear return_data at the start (per Python reference implementation)
            frame.return_data = &[_]u8{};

            const value = try frame.popStack();
            const offset = try frame.popStack();
            const length = try frame.popStack();
            const salt: u256 = if (is_create2) try frame.popStack() else 0;

            // EIP-3860 (Shanghai+): reject oversize initcode before expanding or copying
            // memory. Exceptional halt: all gas is consumed.
            if (evm.hardfork.isAtLeast(.SHANGHAI) and length > GasConstants.MaxInitcodeSize) {
                frame.gas_remaining = 0;
                return error.OutOfGas;
            }

            // A zero-length init code never touches memory, whatever its offset.
            const range = try frame.memoryRange(offset, length);
            const len: u32 = if (range) |r| r.len else 0;
            const base_cost = if (is_create2) frame.create2GasCost(len) else frame.createGasCost(len);
            try frame.consumeGas(base_cost +| frame.memoryRangeCost(range));

            // Read init code from memory
            var init_code: []const u8 = &.{};
            var init_code_buf: ?[]u8 = null;
            defer if (init_code_buf) |buf| frame.allocator.free(buf);
            if (range) |r| {
                try frame.expandMemory(r.end);
                const code = try frame.readMemoryAlloc(frame.allocator, r);
                init_code_buf = code;
                init_code = code;
            }

            // Calculate available gas
            const remaining_gas = @as(u64, @intCast(@max(frame.gas_remaining, 0)));
            // EIP-150: all but 1/64th (introduced in Tangerine Whistle)
            // Before EIP-150: forward all remaining gas
            const max_gas = if (evm.hardfork.isAtLeast(.TANGERINE_WHISTLE))
                remaining_gas - (remaining_gas / 64)
            else
                remaining_gas;

            const result = try evm.inner_create(value, init_code, max_gas, if (is_create2) salt else null);

            // Update gas
            const gas_used = max_gas -| result.gas_left;
            // Safely cast gas_used - if it exceeds i64::MAX, clamp gas_remaining to 0
            const gas_used_i64 = std.math.cast(i64, gas_used) orelse {
                frame.gas_remaining = 0;
                return error.OutOfGas;
            };
            frame.gas_remaining -= gas_used_i64;

            // Set return_data according to CREATE semantics:
            // - On success: return_data is empty
            // - On failure: return_data is the child's output
            frame.return_data = if (result.success) &[_]u8{} else result.output;

            // Push address onto stack (0 if failed)
            try frame.pushStack(if (result.success) addressToWord(result.address) else 0);

            frame.pc += 1;
        }

        /// Shared CALL / CALLCODE / DELEGATECALL / STATICCALL implementation.
        ///
        /// Mirrors execution-specs `system.py`: compute memory expansion and extra gas,
        /// derive the forwarded gas, charge everything at once, then expand memory.
        fn callCommon(frame: *FrameType, comptime kind: CallKind) FrameType.EvmError!void {
            const evm = frame.getEvm();

            // EIP-7: DELEGATECALL was introduced in Homestead hardfork
            if (kind == .delegatecall and evm.hardfork.isBefore(.HOMESTEAD)) return error.InvalidOpcode;
            // EIP-214: STATICCALL was introduced in Byzantium hardfork
            if (kind == .staticcall and evm.hardfork.isBefore(.BYZANTIUM)) return error.InvalidOpcode;

            const has_value_arg = kind == .call or kind == .callcode;
            const gas = try frame.popStack();
            const address_u256 = try frame.popStack();
            const value_arg: u256 = if (has_value_arg) try frame.popStack() else 0;
            const in_offset = try frame.popStack();
            const in_length = try frame.popStack();
            const out_offset = try frame.popStack();
            const out_length = try frame.popStack();

            // EIP-214: CALL with non-zero value cannot be executed in static call context
            if (kind == .call and frame.is_static and value_arg > 0) return error.StaticCallViolation;

            const call_address = addressFromWord(address_u256);

            // Memory regions. Zero-length regions ignore their offsets entirely; a
            // non-empty region past the u32 memory model is unaffordable (OutOfGas).
            const in_range = try frame.memoryRange(in_offset, in_length);
            const out_range = try frame.memoryRange(out_offset, out_length);
            const in_end: u64 = if (in_range) |r| r.end else 0;
            const out_end: u64 = if (out_range) |r| r.end else 0;
            const max_end = @max(in_end, out_end);
            // Both regions are charged together, so only the incremental expansion is paid.
            const mem_cost: u64 = if (max_end > 0) frame.memoryExpansionCost(max_end) else 0;

            // Extra gas: base cost (pre-Berlin), value transfer, new account, access costs.
            var gas_cost: u64 = mem_cost;
            if (evm.hardfork.isBefore(.BERLIN)) {
                gas_cost +|= preBerlinCallGas(evm.hardfork);
            }
            if (has_value_arg and value_arg > 0) {
                gas_cost +|= GasConstants.CallValueTransferGas;
            }
            if (kind == .call) {
                // Before EIP-161 (Spurious Dragon) any call to a non-existent account pays
                // the new-account charge. From Spurious Dragon only a value-bearing call to
                // a dead (empty) account pays it.
                const charge_new_account = if (evm.hardfork.isBefore(.SPURIOUS_DRAGON))
                    !evm.accountExists(call_address)
                else
                    value_arg > 0 and !accountIsAlive(evm, call_address);
                if (charge_new_account) gas_cost +|= GasConstants.CallNewAccountGas;
            }

            // EIP-2929 (Berlin+): access target account (warm/cold).
            // Returns 0 pre-Berlin, 100 warm, 2600 cold.
            gas_cost +|= try evm.accessAddress(call_address);

            // EIP-7702 (Prague+): a delegated target also charges for accessing its delegate.
            if (comptime @hasDecl(@TypeOf(evm.*), "get_delegated_target")) {
                if (evm.get_delegated_target(call_address)) |delegate| {
                    gas_cost +|= try evm.accessAddress(delegate);
                }
            }

            // Forwarded gas.
            const gas_limit: u64 = std.math.cast(u64, gas) orelse std.math.maxInt(u64);
            const forwarded_gas: u64 = if (evm.hardfork.isBefore(.TANGERINE_WHISTLE)) blk: {
                // Before EIP-150 the requested gas is charged in full; asking for more
                // than remains is an out-of-gas halt, not a clamp.
                try frame.consumeGas(gas_cost +| gas_limit);
                break :blk gas_limit;
            } else blk: {
                // EIP-150: forward at most all but 1/64th of the gas left after extra costs.
                const remaining: u64 = @intCast(@max(frame.gas_remaining, 0));
                const after_charge = remaining -| gas_cost;
                const max_gas = after_charge - (after_charge / 64);
                const forwarded = @min(gas_limit, max_gas);
                try frame.consumeGas(gas_cost +| forwarded);
                break :blk forwarded;
            };

            // The stipend is free to the caller.
            const available_gas: u64 = if (has_value_arg and value_arg > 0)
                forwarded_gas +| GasConstants.CallStipend
            else
                forwarded_gas;

            // Memory grows only once the charge has succeeded.
            try frame.expandMemory(max_end);

            // Read input data from memory
            var input_data: []const u8 = &.{};
            var input_data_buf: ?[]u8 = null;
            const frame_allocator = frame.allocator;
            defer if (input_data_buf) |buf| frame_allocator.free(buf);
            if (in_range) |r| {
                const data = try frame.readMemoryAlloc(frame_allocator, r);
                input_data_buf = data;
                input_data = data;
            }

            const params = switch (kind) {
                .call => CallParams{ .call = .{
                    .caller = frame.address,
                    .to = call_address,
                    .value = value_arg,
                    .input = input_data,
                    .gas = available_gas,
                } },
                .callcode => CallParams{ .callcode = .{
                    .caller = frame.address,
                    .to = call_address,
                    .value = value_arg,
                    .input = input_data,
                    .gas = available_gas,
                } },
                // EIP-7: DELEGATECALL keeps the parent's caller and call value.
                .delegatecall => CallParams{ .delegatecall = .{
                    .caller = frame.caller,
                    .to = call_address,
                    .input = input_data,
                    .gas = available_gas,
                    .value = frame.value,
                } },
                .staticcall => CallParams{ .staticcall = .{
                    .caller = frame.address,
                    .to = call_address,
                    .input = input_data,
                    .gas = available_gas,
                } },
            };
            const result = evm.inner_call(params);
            // Nested execution may move frames; re-fetch the active frame.
            const active_frame = evm.getCurrentFrame() orelse return error.MemoryError;

            // Write output to memory (expansion was charged upfront). Only the bytes the
            // child returned are written; the rest of the output region is untouched.
            if (out_range) |r| {
                const copy_len = @min(@as(usize, r.len), result.output.len);
                try active_frame.writeMemorySlice(r.offset, result.output[0..copy_len]);
            }

            active_frame.return_data = result.output;
            try active_frame.pushStack(if (result.success) 1 else 0);

            // Refund unused gas (including any unused stipend).
            // Per Python: evm.gas_left += child_evm.gas_left
            const gas_to_refund = @min(result.gas_left, available_gas);
            const gas_to_refund_i64 = std.math.cast(i64, gas_to_refund) orelse std.math.maxInt(i64);
            active_frame.gas_remaining = active_frame.gas_remaining +| gas_to_refund_i64;

            active_frame.pc += 1;
        }

        /// CREATE opcode (0xf0) - Create a new contract
        pub fn create(frame: *FrameType) FrameType.EvmError!void {
            return createCommon(frame, false);
        }

        /// CALL opcode (0xf1) - Message call into an account
        pub fn call(frame: *FrameType) FrameType.EvmError!void {
            return callCommon(frame, .call);
        }

        /// CALLCODE opcode (0xf2) - Message call into this account with another account's code
        pub fn callcode(frame: *FrameType) FrameType.EvmError!void {
            return callCommon(frame, .callcode);
        }

        /// DELEGATECALL opcode (0xf4) - Message call with another account's code, but keep current msg.sender and msg.value
        pub fn delegatecall(frame: *FrameType) FrameType.EvmError!void {
            return callCommon(frame, .delegatecall);
        }

        /// STATICCALL opcode (0xfa) - Static message call (no state modifications allowed)
        pub fn staticcall(frame: *FrameType) FrameType.EvmError!void {
            return callCommon(frame, .staticcall);
        }

        /// CREATE2 opcode (0xf5) - Create a new contract with deterministic address
        pub fn create2(frame: *FrameType) FrameType.EvmError!void {
            return createCommon(frame, true);
        }

        /// SELFDESTRUCT opcode (0xff) - Halt execution and register account for deletion
        pub fn selfdestruct(frame: *FrameType) FrameType.EvmError!void {
            const beneficiary_u256 = try frame.popStack();
            const beneficiary = addressFromWord(beneficiary_u256);

            const evm_ptr = frame.getEvm();

            // Base: 0 before Tangerine Whistle, 5000 after (EIP-150).
            var gas_cost = frame.selfdestructGasCost();

            // EIP-2929 (Berlin): Check if beneficiary is warm, add cold access cost if needed
            // Per Python reference: if beneficiary not in evm.accessed_addresses, add it and charge cold access
            // IMPORTANT: Unlike CALL which always charges an access cost (warm=100 or cold=2600),
            // SELFDESTRUCT only charges if the beneficiary is cold (not already accessed)
            if (frame.hardfork.isAtLeast(.BERLIN)) {
                const is_warm = evm_ptr.access_list_manager.is_address_warm(beneficiary);
                if (!is_warm) {
                    // Mark as warm and charge cold access cost
                    // (Python: evm.accessed_addresses.add(beneficiary) then gas_cost += GAS_COLD_ACCOUNT_ACCESS)
                    _ = try evm_ptr.access_list_manager.warm_addresses.getOrPut(beneficiary);
                    gas_cost += GasConstants.ColdAccountAccessCost; // +2600
                }
            }

            const self_balance = if (evm_ptr.host) |h|
                h.getBalance(frame.address)
            else
                evm_ptr.balances.get(frame.address) orelse 0;

            // New-beneficiary surcharge (25000) by fork:
            // - before Tangerine Whistle: none
            // - Tangerine Whistle (EIP-150): beneficiary does not exist
            // - Spurious Dragon+ (EIP-161): beneficiary is dead and the balance is non-zero
            if (frame.hardfork.isAtLeast(.SPURIOUS_DRAGON)) {
                if (self_balance > 0 and !accountIsAlive(evm_ptr, beneficiary)) {
                    gas_cost += GasConstants.CallNewAccountGas;
                }
            } else if (frame.hardfork.isAtLeast(.TANGERINE_WHISTLE)) {
                if (!evm_ptr.accountExists(beneficiary)) {
                    gas_cost += GasConstants.CallNewAccountGas;
                }
            }

            try frame.consumeGas(gas_cost);

            // EIP-214: SELFDESTRUCT cannot be executed in static call context
            // This check must happen AFTER gas charging (Python reference line 525)
            if (frame.is_static) return error.StaticCallViolation;

            // EIP-161: SELFDESTRUCT touches the beneficiary, so an existing empty
            // beneficiary is deleted at transaction end even for a 0-wei transfer.
            try touchAccount(evm_ptr, beneficiary);

            // Transfer balance from originator to beneficiary
            // Pre-Cancun vs Cancun+ have different balance transfer semantics
            if (frame.hardfork.isAtLeast(.CANCUN)) {
                // EIP-6780 (Cancun+): move_ether semantics. When sender == recipient the
                // balance is decreased then increased, so it stays the same.
                try evm_ptr.setBalanceWithSnapshot(frame.address, 0);

                // Read beneficiary balance AFTER zeroing the originator (sender == recipient case)
                const beneficiary_balance = if (evm_ptr.host) |h|
                    h.getBalance(beneficiary)
                else
                    evm_ptr.balances.get(beneficiary) orelse 0;
                try evm_ptr.setBalanceWithSnapshot(beneficiary, beneficiary_balance + self_balance);
            } else {
                // Pre-Cancun: read beneficiary balance BEFORE modifying anything so a
                // self-beneficiary ends with zero balance.
                const beneficiary_balance = if (evm_ptr.host) |h|
                    h.getBalance(beneficiary)
                else
                    evm_ptr.balances.get(beneficiary) orelse 0;

                try evm_ptr.setBalanceWithSnapshot(beneficiary, beneficiary_balance + self_balance);
                try evm_ptr.setBalanceWithSnapshot(frame.address, 0);
            }

            // The pre-London selfdestruct refund (24000) is granted at most once per account
            // per transaction: only when it is not already marked for deletion.
            const already_marked_for_deletion = evm_ptr.selfdestructed_accounts.contains(frame.address);

            // EIP-6780 (Cancun+): Only delete if created in same transaction
            // Pre-Cancun: Always delete the account
            if (frame.hardfork.isAtLeast(.CANCUN)) {
                if (evm_ptr.created_accounts.contains(frame.address)) {
                    // Mark for deletion - actual deletion at end of transaction
                    try evm_ptr.selfdestructed_accounts.put(frame.address, {});
                    // EIP-6780: burn the balance unconditionally (self-beneficiary case).
                    try evm_ptr.setBalanceWithSnapshot(frame.address, 0);
                }
                // If not created in same tx: balance transferred but code/storage/nonce persist
            } else {
                try evm_ptr.selfdestructed_accounts.put(frame.address, {});
            }

            // Apply refund to EVM's gas_refund counter (at most once per account per tx).
            const refund = frame.selfdestructRefund();
            if (refund > 0 and !already_marked_for_deletion) {
                evm_ptr.add_refund(refund);
            }

            frame.stopped = true;
        }
    };
}
