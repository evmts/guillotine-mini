/// Log opcode handlers for the EVM (LOG0-LOG4)
const std = @import("std");
const primitives = @import("voltaire");
const GasConstants = primitives.GasConstants;
const call_result = @import("../call_result.zig");

/// Calculate LOG operation gas cost
inline fn logGasCost(topic_count: u8, data_size: u32) u64 {
    const base_cost = GasConstants.LogGas;
    const topic_cost = @as(u64, topic_count) * GasConstants.LogTopicGas;
    const data_cost = @as(u64, data_size) * GasConstants.LogDataGas;
    return base_cost + topic_cost + data_cost;
}

/// Handlers struct - provides log operation handlers for a Frame type
/// The FrameType must have methods: consumeGas, popStack, memoryExpansionCost
/// and fields: pc, memory_size, is_static
pub fn Handlers(FrameType: type) type {
    return struct {
        /// LOG0-LOG4 opcodes (0xa0-0xa4) - Emit log entries with 0-4 indexed topics
        /// Takes opcode as parameter to determine topic count (0xa0=LOG0, 0xa1=LOG1, etc.)
        pub fn log(frame: *FrameType, opcode: u8) FrameType.EvmError!void {
            // EIP-214: LOG opcodes cannot be executed in static call context
            if (frame.is_static) return error.StaticCallViolation;

            const topic_count = opcode - 0xa0;
            const offset = try frame.popStack();
            const length = try frame.popStack();

            // Gas cost + memory expansion for log data. Zero-length data ignores the offset.
            const range = try frame.memoryRange(offset, length);
            const length_u32: u32 = if (range) |r| r.len else 0;
            try frame.consumeGas(logGasCost(topic_count, length_u32) +| frame.memoryRangeCost(range));
            if (range) |r| try frame.expandMemory(r.end);

            const evm = frame.getEvm();

            // Read topics (store them so we can add to log)
            const topics_len: usize = topic_count;
            var topics_tmp: [4]u256 = undefined; // max 4 topics
            var ti: usize = 0;
            while (ti < topics_len) : (ti += 1) {
                topics_tmp[ti] = try frame.popStack();
            }

            // Read data from memory
            var data_slice: []u8 = &[_]u8{};
            if (range) |r| {
                data_slice = try frame.readMemoryAlloc(evm.arena.allocator(), r);
            }

            // Allocate topics in arena and copy (reverse order if needed)
            var topics_slice: []u256 = &[_]u256{};
            if (topics_len > 0) {
                const alloc = evm.arena.allocator();
                const topics_buf = try alloc.alloc(u256, topics_len);
                var k: usize = 0;
                while (k < topics_len) : (k += 1) {
                    topics_buf[k] = topics_tmp[k];
                }
                topics_slice = topics_buf;
            }

            // Append log to EVM logs buffer
            const log_entry = call_result.Log{
                .address = frame.address,
                .topics = topics_slice,
                .data = data_slice,
            };
            try evm.logs.append(evm.arena.allocator(), log_entry);

            frame.pc += 1;
        }
    };
}
