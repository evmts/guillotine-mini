/// CLI entry point for the Guillotine runner.
///
/// Mirrors Nethermind.Runner.Program as the process-level entrypoint.
const std = @import("std");
const primitives = @import("primitives");
const evm_mod = @import("evm");

const ChainId = primitives.ChainId;
const NetworkId = primitives.NetworkId;
const Hardfork = primitives.Hardfork;
const TraceConfig = primitives.TraceConfig;
const Chain = primitives.Chain;

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

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const EvmType = evm_mod.Evm(evm_mod.EvmConfig{});
    try run(EvmType, allocator, args, std.io.getStdOut().writer());
}

pub fn run(
    comptime EvmType: type,
    allocator: std.mem.Allocator,
    args: []const []const u8,
    writer: anytype,
) !void {
    var chain_id: ChainId.ChainId = ChainId.MAINNET;
    var network_id: NetworkId.NetworkId = NetworkId.MAINNET;
    var network_set = false;
    var hardfork: Hardfork = Hardfork.DEFAULT;
    var trace_config: TraceConfig = TraceConfig.from();
    var trace_enabled = false;

    var idx: usize = 1;
    while (idx < args.len) : (idx += 1) {
        const arg = args[idx];
        if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            try writer.writeAll(usage);
            return;
        }

        if (std.mem.eql(u8, arg, "--chain-id")) {
            idx += 1;
            if (idx >= args.len) return error.MissingChainId;
            const parsed = std.fmt.parseInt(u64, args[idx], 10) catch return error.InvalidChainId;
            chain_id = ChainId.from(parsed);
            continue;
        }

        if (std.mem.eql(u8, arg, "--network-id")) {
            idx += 1;
            if (idx >= args.len) return error.MissingNetworkId;
            const parsed = std.fmt.parseInt(u64, args[idx], 10) catch return error.InvalidNetworkId;
            network_id = NetworkId.from(parsed);
            network_set = true;
            continue;
        }

        if (std.mem.eql(u8, arg, "--hardfork")) {
            idx += 1;
            if (idx >= args.len) return error.MissingHardfork;
            hardfork = Hardfork.fromString(args[idx]) orelse return error.InvalidHardfork;
            continue;
        }

        if (std.mem.eql(u8, arg, "--trace")) {
            trace_config = TraceConfig.enableAll();
            trace_enabled = true;
            continue;
        }

        if (std.mem.eql(u8, arg, "--trace-tracer")) {
            idx += 1;
            if (idx >= args.len) return error.MissingTraceTracer;
            trace_config.tracer = args[idx];
            trace_enabled = true;
            continue;
        }

        if (std.mem.eql(u8, arg, "--trace-timeout")) {
            idx += 1;
            if (idx >= args.len) return error.MissingTraceTimeout;
            trace_config.timeout = args[idx];
            trace_enabled = true;
            continue;
        }

        return error.UnknownOption;
    }

    if (!network_set) {
        network_id = NetworkId.from(chain_id);
    }

    const chain = Chain.fromId(chain_id) orelse return error.UnknownChainId;

    const block_context = evm_mod.BlockContext{
        .chain_id = @as(u256, chain_id),
        .block_number = 0,
        .block_timestamp = 0,
        .block_difficulty = 0,
        .block_prevrandao = 0,
        .block_coinbase = primitives.ZERO_ADDRESS,
        .block_gas_limit = Chain.getGasLimit(chain),
        .block_base_fee = 0,
        .blob_base_fee = 0,
    };

    var evm_instance: EvmType = undefined;
    try evm_instance.init(allocator, null, hardfork, block_context, null);
    defer evm_instance.deinit();

    try writer.writeAll("guillotine-mini runner configured\n");
    try writer.print(
        "chain_id={d} network_id={d} chain={s} hardfork={s} gas_limit={d}\n",
        .{ chain_id, network_id, Chain.getName(chain), @tagName(hardfork), Chain.getGasLimit(chain) },
    );

    if (trace_enabled) {
        const tracer = trace_config.tracer orelse "none";
        const timeout = trace_config.timeout orelse "none";
        try writer.print("trace=enabled tracer={s} timeout={s}\n", .{ tracer, timeout });
    } else {
        try writer.writeAll("trace=disabled\n");
    }
}

// ============================================================================
// Tests
// ============================================================================

test "main is a no-op placeholder" {
    try main();
    try std.testing.expect(true);
}
