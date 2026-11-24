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

            // Pop every operand first (execution-specs order), so a short stack is a
            // StackUnderflow even when the memory range is unpayable.
            var topics_tmp: [4]u256 = undefined;
            for (topics_tmp[0..topic_count]) |*topic| topic.* = try frame.popStack();

            // Gas cost + memory expansion for log data. Zero-length data ignores the offset.
            const range = try frame.memoryRange(offset, length);
            const length_u32: u32 = if (range) |r| r.len else 0;
            try frame.consumeGas(logGasCost(topic_count, length_u32) +| frame.memoryRangeCost(range));
            if (range) |r| try frame.expandMemory(r.end);

            const evm = frame.getEvm();
            // Logs live for one transaction: allocate them in the transaction arena.
            const alloc = if (comptime @hasField(@TypeOf(evm.*), "tx_arena"))
                evm.tx_arena.allocator()
            else
                evm.arena.allocator();

            const data_slice: []u8 = if (range) |r| try frame.readMemoryAlloc(alloc, r) else &[_]u8{};
            const topics_slice: []u256 = if (topic_count > 0) try alloc.dupe(u256, topics_tmp[0..topic_count]) else &[_]u256{};

            try evm.logs.append(alloc, call_result.Log{
                .address = frame.address,
                .topics = topics_slice,
                .data = data_slice,
            });

            frame.pc += 1;
        }
    };
}
