/// CLI entry point for the Guillotine runner.
///
/// Mirrors Nethermind.Runner.Program as the process-level entrypoint.
const std = @import("std");
const primitives = @import("primitives");
const evm_mod = @import("evm");
const config_mod = @import("config.zig");

const ChainId = primitives.ChainId;
const NetworkId = primitives.NetworkId;
const Hardfork = primitives.Hardfork;
const TraceConfig = primitives.TraceConfig;
const Chain = primitives.Chain;
const FeeMarket = primitives.FeeMarket;
const Blob = primitives.Blob;
const RunnerConfig = config_mod.RunnerConfig;
const Tracer = evm_mod.Tracer;

const usage =
    \\guillotine-mini runner
    \\Usage: guillotine-mini [options]
    \\
    \\Options:
    \\  --chain-id <u64>      EIP-155 chain id (default: 1)
    \\  --network-id <u64>    devp2p network id (default: chain id)
    \\  --hardfork <name>     hardfork (e.g., Shanghai, Cancun, Prague)
    \\  --trace               enable full tracing
    \\  --trace-tracer <name> set tracer name (e.g., callTracer)
    \\  --trace-timeout <dur> set tracer timeout (e.g., 5s)
    \\  -h, --help            show this help
    \\
;

/// Process entry point for the runner CLI.
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(gpa.deinit() == .ok);
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const EvmType = evm_mod.Evm(evm_mod.EvmConfig{});
    const stdout = std.fs.File.stdout();
    var stdout_buffer: [4096]u8 = undefined;
    var writer = stdout.writer(stdout_buffer[0..]);
    defer writer.interface.flush() catch |err| std.debug.panic("stdout flush failed: {s}", .{@errorName(err)});
    try run(EvmType, allocator, args, &writer.interface);
}

fn run(
    comptime EvmType: type,
    allocator: std.mem.Allocator,
    args: []const []const u8,
    writer: anytype,
) !void {
    var config = RunnerConfig{};
    var trace_enabled = false;

    var idx: usize = 1;
    while (idx < args.len) : (idx += 1) {
        const arg = args[idx];
        if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            try writer.writeAll(usage);
            return;
        }

        if (std.mem.eql(u8, arg, "--trace")) {
            const tracer = config.trace_config.tracer;
            const timeout = config.trace_config.timeout;
            config.trace_config = TraceConfig.enableAll();
            config.trace_config.tracer = tracer;
            config.trace_config.timeout = timeout;
            trace_enabled = true;
            continue;
        }

        const is_chain_id = std.mem.eql(u8, arg, "--chain-id");
        const is_network_id = std.mem.eql(u8, arg, "--network-id");
        const is_hardfork = std.mem.eql(u8, arg, "--hardfork");
        const is_trace_tracer = std.mem.eql(u8, arg, "--trace-tracer");
        const is_trace_timeout = std.mem.eql(u8, arg, "--trace-timeout");

        if (is_chain_id or is_network_id or is_hardfork or is_trace_tracer or is_trace_timeout) {
            const missing_err = if (is_chain_id)
                error.MissingChainId
            else if (is_network_id)
                error.MissingNetworkId
            else if (is_hardfork)
                error.MissingHardfork
            else if (is_trace_tracer)
                error.MissingTraceTracer
            else
                error.MissingTraceTimeout;

            idx += 1;
            if (idx >= args.len) return missing_err;
            const value = args[idx];

            if (is_chain_id) {
                const parsed = std.fmt.parseInt(u64, value, 10) catch return error.InvalidChainId;
                config.chain_id = ChainId.from(parsed);
                continue;
            }

            if (is_network_id) {
                const parsed = std.fmt.parseInt(u64, value, 10) catch return error.InvalidNetworkId;
                config.network_id = NetworkId.from(parsed);
                continue;
            }

            if (is_hardfork) {
                config.hardfork = Hardfork.fromString(value) orelse return error.InvalidHardfork;
                continue;
            }

            if (is_trace_tracer) {
                config.trace_config.tracer = value;
                trace_enabled = true;
                continue;
            }

            config.trace_config.timeout = value;
            trace_enabled = true;
            continue;
        }

        return error.UnknownOption;
    }

    const network_id = config.effective_network_id();
    const chain = Chain.fromId(config.chain_id) orelse return error.UnknownChainId;

    const gas_limit = Chain.getGasLimit(chain);
    const block_number: u64 = 0;
    const block_timestamp: u64 = 0;
    const block_prevrandao: u256 = if (config.hardfork.isAtLeast(.MERGE)) blk: {
        const chain_component: u256 = @as(u256, config.chain_id) << 192;
        const number_component: u256 = @as(u256, block_number) << 128;
        const gas_component: u256 = @as(u256, gas_limit) << 64;
        break :blk chain_component | number_component | gas_component | 1;
    } else 0;
    const block_difficulty: u256 = if (config.hardfork.isAtLeast(.MERGE)) 0 else @as(u256, gas_limit);
    const block_base_fee: u256 = if (config.hardfork.isAtLeast(.LONDON))
        @as(u256, FeeMarket.initialBaseFee(0, gas_limit))
    else
        0;
    const blob_base_fee: u256 = if (config.hardfork.isAtLeast(.CANCUN))
        @as(u256, Blob.calculateBlobGasPrice(0))
    else
        0;

    const block_context = evm_mod.BlockContext{
        .chain_id = @as(u256, config.chain_id),
        .block_number = block_number,
        .block_timestamp = block_timestamp,
        .block_difficulty = block_difficulty,
        .block_prevrandao = block_prevrandao,
        .block_coinbase = primitives.ZERO_ADDRESS,
        .block_gas_limit = gas_limit,
        .block_base_fee = block_base_fee,
        .blob_base_fee = blob_base_fee,
    };

    var tracer_instance: Tracer = undefined;
    if (trace_enabled) {
        tracer_instance = Tracer.init(allocator);
        tracer_instance.enable();
        defer tracer_instance.deinit();
    }

    var evm_instance: EvmType = undefined;
    try evm_instance.init(allocator, null, config.hardfork, block_context, null);
    defer evm_instance.deinit();

    if (trace_enabled) {
        evm_instance.setTracer(&tracer_instance);
    }

    try writer.writeAll("guillotine-mini runner configured\n");
    try writer.print(
        "chain_id={d} network_id={d} chain={s} hardfork={s} gas_limit={d}\n",
        .{ config.chain_id, network_id, Chain.getName(chain), @tagName(config.hardfork), Chain.getGasLimit(chain) },
    );

    if (trace_enabled) {
        const tracer = config.trace_config.tracer orelse "none";
        const timeout = config.trace_config.timeout orelse "none";
        try writer.print("trace=enabled tracer={s} timeout={s}\n", .{ tracer, timeout });
    } else {
        try writer.writeAll("trace=disabled\n");
    }
}

// ============================================================================
// Tests
// ============================================================================

test "runner parses CLI flags and emits config" {
    const allocator = std.testing.allocator;
    const EvmType = evm_mod.Evm(evm_mod.EvmConfig{});

    var buffer: [512]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const args = &[_][]const u8{
        "guillotine-mini",
        "--chain-id",
        "11155111",
        "--network-id",
        "5",
        "--hardfork",
        "Shanghai",
        "--trace",
        "--trace-tracer",
        "callTracer",
        "--trace-timeout",
        "5s",
    };

    try run(EvmType, allocator, args, stream.writer());

    const output = stream.getWritten();
    try std.testing.expect(std.mem.containsAtLeast(u8, output, 1, "chain_id=11155111"));
    try std.testing.expect(std.mem.containsAtLeast(u8, output, 1, "network_id=5"));
    try std.testing.expect(std.mem.containsAtLeast(u8, output, 1, "hardfork=SHANGHAI"));
    try std.testing.expect(std.mem.containsAtLeast(u8, output, 1, "trace=enabled"));
    try std.testing.expect(std.mem.containsAtLeast(u8, output, 1, "tracer=callTracer"));
    try std.testing.expect(std.mem.containsAtLeast(u8, output, 1, "timeout=5s"));

    var help_buffer: [1024]u8 = undefined;
    var help_stream = std.io.fixedBufferStream(&help_buffer);
    const help_args = &[_][]const u8{ "guillotine-mini", "--help" };
    try run(EvmType, allocator, help_args, help_stream.writer());

    const help_output = help_stream.getWritten();
    try std.testing.expect(std.mem.containsAtLeast(u8, help_output, 1, "Usage:"));
}

test "runner main accepts default args" {
    const allocator = std.testing.allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 1) return error.SkipZigTest;

    try main();
}
