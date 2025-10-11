/// Block context opcode handlers for the EVM
const std = @import("std");
const primitives = @import("primitives");
const GasConstants = primitives.GasConstants;

/// Handlers struct - provides block context operation handlers for a Frame type
/// The FrameType must have methods: consumeGas, popStack, pushStack
/// and fields: pc (program counter), address, evm (EVM context)
pub fn Handlers(FrameType: type) type {
    return struct {
        /// BLOCKHASH opcode (0x40) - Get hash of recent block
        pub fn blockhash(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            try frame.consumeGas(GasConstants.GasExtStep);
            const block_number = try frame.popStack();
            // Simple mock: return a hash based on block number
            const current_block = evm.block_context.block_number;
            if (block_number >= current_block or current_block > block_number + 256) {
                try frame.pushStack(0);
            } else {
                // Mock hash based on block number
                try frame.pushStack(block_number * 0x123456789abcdef);
            }
            frame.pc += 1;
        }

        /// COINBASE opcode (0x41) - Get block coinbase address
        pub fn coinbase(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            try frame.consumeGas(GasConstants.GasQuickStep);
            const coinbase_u256 = primitives.Address.to_u256(evm.block_context.block_coinbase);
            try frame.pushStack(coinbase_u256);
            frame.pc += 1;
        }

        /// TIMESTAMP opcode (0x42) - Get block timestamp
        pub fn timestamp(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            try frame.consumeGas(GasConstants.GasQuickStep);
            try frame.pushStack(evm.block_context.block_timestamp);
            frame.pc += 1;
        }

        /// NUMBER opcode (0x43) - Get block number
        pub fn number(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            try frame.consumeGas(GasConstants.GasQuickStep);
            try frame.pushStack(evm.block_context.block_number);
            frame.pc += 1;
        }

        /// DIFFICULTY/PREVRANDAO opcode (0x44) - Get block difficulty or prevrandao
        /// Pre-Merge: returns block difficulty
        /// Post-Merge: returns prevrandao value
        pub fn difficulty(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            try frame.consumeGas(GasConstants.GasQuickStep);
            if (evm.hardfork.isAtLeast(.MERGE)) {
                try frame.pushStack(evm.block_context.block_prevrandao);
            } else {
                try frame.pushStack(evm.block_context.block_difficulty);
            }
            frame.pc += 1;
        }

        /// GASLIMIT opcode (0x45) - Get block gas limit
        pub fn gaslimit(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            try frame.consumeGas(GasConstants.GasQuickStep);
            try frame.pushStack(@as(u256, evm.block_context.block_gas_limit));
            frame.pc += 1;
        }

        /// CHAINID opcode (0x46) - Get chain ID (EIP-1344, Istanbul+)
        pub fn chainid(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-1344: CHAINID was introduced in Istanbul hardfork
            if (evm.hardfork.isBefore(.ISTANBUL)) return error.InvalidOpcode;

            try frame.consumeGas(GasConstants.GasQuickStep);
            try frame.pushStack(evm.block_context.chain_id);
            frame.pc += 1;
        }

        /// SELFBALANCE opcode (0x47) - Get balance of currently executing account (EIP-1884, Istanbul+)
        pub fn selfbalance(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-1884: SELFBALANCE was introduced in Istanbul hardfork
            if (evm.hardfork.isBefore(.ISTANBUL)) return error.InvalidOpcode;

            try frame.consumeGas(GasConstants.GasFastStep);
            const balance = evm.get_balance(frame.address);
            try frame.pushStack(balance);
            frame.pc += 1;
        }

        /// BASEFEE opcode (0x48) - Get base fee per gas (EIP-3198, London+)
        pub fn basefee(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-3198: BASEFEE was introduced in London hardfork
            if (evm.hardfork.isBefore(.LONDON)) return error.InvalidOpcode;

            try frame.consumeGas(GasConstants.GasQuickStep);
            try frame.pushStack(evm.block_context.block_base_fee);
            frame.pc += 1;
        }

        /// BLOBHASH opcode (0x49) - Get versioned blob hash (EIP-4844, Cancun+)
        pub fn blobhash(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-4844: BLOBHASH was introduced in Cancun hardfork
            if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;

            try frame.consumeGas(GasConstants.GasFastestStep);
            const index = try frame.popStack();

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
            try frame.pushStack(hash_value);
            frame.pc += 1;
        }

        /// BLOBBASEFEE opcode (0x4a) - Get blob base fee (EIP-7516, Cancun+)
        pub fn blobbasefee(frame: *FrameType) FrameType.EvmError!void {
            const evm = frame.getEvm();
            // EIP-7516: BLOBBASEFEE was introduced in Cancun hardfork
            if (evm.hardfork.isBefore(.CANCUN)) return error.InvalidOpcode;

            try frame.consumeGas(GasConstants.GasQuickStep);
            try frame.pushStack(evm.block_context.blob_base_fee);
            frame.pc += 1;
        }
    };
}
