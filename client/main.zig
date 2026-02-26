/// CLI entry point for the Guillotine runner.
///
/// Mirrors Nethermind.Runner.Program as the process-level entrypoint.
const std = @import("std");
const primitives = @import("voltaire");
const evm_mod = @import("evm");
const config_mod = @import("config.zig");
const cli = @import("cli.zig");

const Chain = primitives.Chain;
const Hex = primitives.Hex;
const FeeMarket = primitives.FeeMarket;
const Blob = primitives.Blob;
const RunnerConfig = config_mod.RunnerConfig;
const Tracer = evm_mod.Tracer;

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
    cli.parse_args(args, &config, &trace_enabled, writer) catch |err| switch (err) {
        error.HelpRequested => return,
        error.VersionRequested => return,
        else => return err,
    };

    const network_id = config.effective_network_id();
    const chain = Chain.fromId(config.chain_id) orelse return error.UnknownChainId;

    const genesis_block_context = try load_genesis_block_context(config.chain_id, config.hardfork);
    const block_context = if (genesis_block_context) |ctx| ctx else blk: {
        const fallback_gas_limit = Chain.getGasLimit(chain);
        const fallback_base_fee: u256 = if (config.hardfork.isAtLeast(.LONDON))
            @as(u256, FeeMarket.initialBaseFee(0, fallback_gas_limit))
        else
            0;
        const fallback_blob_base_fee: u256 = if (config.hardfork.isAtLeast(.CANCUN))
            @as(u256, Blob.calculateBlobGasPrice(0))
        else
            0;
        const now = std.time.timestamp();
        const fallback_timestamp: u64 = if (now >= 0) @as(u64, @intCast(now)) else 0;
        const is_merge = config.hardfork.isAtLeast(.MERGE);
        break :blk evm_mod.BlockContext{
            .chain_id = @as(u256, config.chain_id),
            .block_number = 0,
            .block_timestamp = fallback_timestamp,
            .block_difficulty = if (is_merge) 0 else 1,
            .block_prevrandao = 0,
            .block_coinbase = primitives.ZERO_ADDRESS,
            .block_gas_limit = fallback_gas_limit,
            .block_base_fee = fallback_base_fee,
            .blob_base_fee = fallback_blob_base_fee,
        };
    };
    const gas_limit = block_context.block_gas_limit;

    var tracer_instance: Tracer = undefined;
    if (trace_enabled) {
        tracer_instance = Tracer.init(allocator);
        tracer_instance.config = config.trace_config;
        tracer_instance.enable();
        defer tracer_instance.deinit();
    }

    var evm_instance: EvmType = undefined;
    try evm_instance.init(allocator, null, config.hardfork, block_context, primitives.ZERO_ADDRESS, 0, null);
    defer evm_instance.deinit();

    if (trace_enabled) {
        evm_instance.setTracer(&tracer_instance);
    }

    try writer.writeAll("guillotine-mini runner configured\n");
    try writer.print(
        "chain_id={d} network_id={d} chain={s} hardfork={s} gas_limit={d}\n",
        .{ config.chain_id, network_id, Chain.getName(chain), @tagName(config.hardfork), gas_limit },
    );

    if (trace_enabled) {
        const tracer = config.trace_config.tracer orelse "none";
        const timeout = config.trace_config.timeout orelse "none";
        try writer.print("trace=enabled tracer={s} timeout={s}\n", .{ tracer, timeout });
    } else {
        try writer.writeAll("trace=disabled\n");
    }
}

fn load_genesis_block_context(chain_id: u64, hardfork: primitives.Hardfork) !?evm_mod.BlockContext {
    const genesis_path = switch (chain_id) {
        1 => "execution-specs/src/ethereum/assets/mainnet.json",
        11155111 => "execution-specs/src/ethereum/assets/sepolia.json",
        1337803 => "execution-specs/src/ethereum/assets/zhejiang.json",
        else => return null,
    };

    const file = try std.fs.cwd().openFile(genesis_path, .{});
    defer file.close();

    var reader = file.deprecatedReader();

    var timestamp: ?u64 = null;
    var gas_limit: ?u64 = null;
    var difficulty: ?u256 = null;
    var mix_hash: ?u256 = null;
    var coinbase: ?primitives.Address = null;

    var line_buf: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&line_buf, '\n')) |line| {
        if (timestamp == null and std.mem.indexOf(u8, line, "\"timestamp\"") != null) {
            timestamp = try parse_genesis_value(u64, line);
        } else if (gas_limit == null and std.mem.indexOf(u8, line, "\"gasLimit\"") != null) {
            gas_limit = try parse_genesis_value(u64, line);
        } else if (difficulty == null and std.mem.indexOf(u8, line, "\"difficulty\"") != null) {
            difficulty = try parse_genesis_value(u256, line);
        } else if (mix_hash == null and (std.mem.indexOf(u8, line, "\"mixHash\"") != null or std.mem.indexOf(u8, line, "\"mixhash\"") != null)) {
            mix_hash = try parse_genesis_value(u256, line);
        } else if (coinbase == null and std.mem.indexOf(u8, line, "\"coinbase\"") != null) {
            coinbase = try parse_genesis_value(primitives.Address, line);
        }

        if (timestamp != null and gas_limit != null and difficulty != null and mix_hash != null and coinbase != null) {
            break;
        }
    }

    if (timestamp == null or gas_limit == null or difficulty == null or mix_hash == null or coinbase == null) {
        return error.InvalidGenesis;
    }

    const is_merge = hardfork.isAtLeast(.MERGE);
    const block_base_fee: u256 = if (hardfork.isAtLeast(.LONDON))
        @as(u256, FeeMarket.initialBaseFee(0, gas_limit.?))
    else
        0;
    const blob_base_fee: u256 = if (hardfork.isAtLeast(.CANCUN))
        @as(u256, Blob.calculateBlobGasPrice(0))
    else
        0;

    return evm_mod.BlockContext{
        .chain_id = @as(u256, chain_id),
        .block_number = 0,
        .block_timestamp = timestamp.?,
        .block_difficulty = if (is_merge) 0 else difficulty.?,
        .block_prevrandao = if (is_merge) mix_hash.? else 0,
        .block_coinbase = coinbase.?,
        .block_gas_limit = gas_limit.?,
        .block_base_fee = block_base_fee,
        .blob_base_fee = blob_base_fee,
    };
}

fn parse_genesis_value(comptime T: type, line: []const u8) !T {
    const colon = std.mem.indexOfScalar(u8, line, ':') orelse return error.InvalidGenesis;
    var start = colon + 1;
    while (start < line.len and std.ascii.isWhitespace(line[start])) start += 1;
    if (start >= line.len or line[start] != '"') return error.InvalidGenesis;
    start += 1;
    const end = std.mem.indexOfScalarPos(u8, line, start, '"') orelse return error.InvalidGenesis;
    const value = line[start..end];

    if (T == primitives.Address) {
        return primitives.Address.fromHex(value);
    }

    if (value.len >= 2 and value[0] == '0' and (value[1] == 'x' or value[1] == 'X')) {
        if (T == u64) return Hex.hexToU64(value);
        if (T == u256) return Hex.hexToU256(value);
        @compileError("Unsupported genesis hex value type");
    }

    if (T == u64) return std.fmt.parseInt(u64, value, 10);
    if (T == u256) return std.fmt.parseInt(u256, value, 10);

    @compileError("Unsupported genesis value type");
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
