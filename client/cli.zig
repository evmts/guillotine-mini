/// CLI argument parsing for the Guillotine runner.
///
/// Mirrors Nethermind.Runner.Program option parsing at a minimal surface.
const std = @import("std");
const primitives = @import("primitives");
const config_mod = @import("config.zig");

const ChainId = primitives.ChainId;
const NetworkId = primitives.NetworkId;
const Hardfork = primitives.Hardfork;
const TraceConfig = primitives.TraceConfig;
const RunnerConfig = config_mod.RunnerConfig;

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
    \\  --version            show version information
    \\  -h, --help            show this help
    \\
;

/// Parse CLI arguments into a runner configuration.
pub fn parse_args(
    args: []const []const u8,
    config: *RunnerConfig,
    trace_enabled: *bool,
    writer: anytype,
) !void {
    var idx: usize = 1;
    while (idx < args.len) : (idx += 1) {
        const arg = args[idx];
        if (std.mem.eql(u8, arg, "--version")) {
            try write_version(writer);
            return error.VersionRequested;
        }
        if (std.mem.eql(u8, arg, "--help") or std.mem.eql(u8, arg, "-h")) {
            writer.writeAll(usage) catch |err| {
                const any_err: anyerror = err;
                if (any_err != error.NoSpaceLeft) return err;
            };
            return error.HelpRequested;
        }

        if (std.mem.eql(u8, arg, "--trace")) {
            const tracer = config.trace_config.tracer;
            const timeout = config.trace_config.timeout;
            config.trace_config = TraceConfig.enableAll();
            config.trace_config.tracer = tracer;
            config.trace_config.timeout = timeout;
            trace_enabled.* = true;
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
                trace_enabled.* = true;
                continue;
            }

            config.trace_config.timeout = value;
            trace_enabled.* = true;
            continue;
        }

        return error.UnknownOption;
    }
}

/// Write version information to the provided writer.
/// Public to enable unit testing and reuse by the runner entry point.
pub fn write_version(writer: anytype) !void {
    // Keep output stable and minimal; avoid dynamic git plumbing here.
    // Nethermind prints version and commit; we start with a static name.
    try writer.writeAll("guillotine-mini 0.0.0 (runner)\n");
}

// ============================================================================
// Tests
// ============================================================================

test "cli parses flags into runner config" {
    var config = RunnerConfig{};
    var trace_enabled = false;
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

    try parse_args(args, &config, &trace_enabled, stream.writer());

    try std.testing.expect(trace_enabled);
    try std.testing.expectEqual(ChainId.from(11155111), config.chain_id);
    try std.testing.expectEqual(NetworkId.from(5), config.network_id.?);
    try std.testing.expectEqual(Hardfork.SHANGHAI, config.hardfork);
    try std.testing.expect(config.trace_config.tracer != null);
    try std.testing.expect(config.trace_config.timeout != null);
    try std.testing.expect(std.mem.eql(u8, config.trace_config.tracer.?, "callTracer"));
    try std.testing.expect(std.mem.eql(u8, config.trace_config.timeout.?, "5s"));
}

test "cli prints usage on help flag" {
    var config = RunnerConfig{};
    var trace_enabled = false;
    var buffer: [256]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const args = &[_][]const u8{ "guillotine-mini", "--help" };

    try std.testing.expectError(
        error.HelpRequested,
        parse_args(args, &config, &trace_enabled, stream.writer()),
    );

    const output = stream.getWritten();
    try std.testing.expect(std.mem.containsAtLeast(u8, output, 1, "Usage:"));
    try std.testing.expect(!trace_enabled);
}

test "cli prints version and exits on --version" {
    var config = RunnerConfig{};
    var trace_enabled = false;
    var buffer: [128]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);
    const args = &[_][]const u8{ "guillotine-mini", "--version" };

    try std.testing.expectError(
        error.VersionRequested,
        parse_args(args, &config, &trace_enabled, stream.writer()),
    );

    const output = stream.getWritten();
    try std.testing.expect(std.mem.containsAtLeast(u8, output, 1, "guillotine-mini"));
}

test "cli rejects missing or invalid values" {
    const Case = struct {
        args: []const []const u8,
        expected: anyerror,
    };

    const cases = [_]Case{
        .{ .args = &[_][]const u8{ "guillotine-mini", "--chain-id" }, .expected = error.MissingChainId },
        .{ .args = &[_][]const u8{ "guillotine-mini", "--chain-id", "nope" }, .expected = error.InvalidChainId },
        .{ .args = &[_][]const u8{ "guillotine-mini", "--network-id" }, .expected = error.MissingNetworkId },
        .{ .args = &[_][]const u8{ "guillotine-mini", "--network-id", "bad" }, .expected = error.InvalidNetworkId },
        .{ .args = &[_][]const u8{ "guillotine-mini", "--hardfork" }, .expected = error.MissingHardfork },
        .{ .args = &[_][]const u8{ "guillotine-mini", "--hardfork", "Atlantis" }, .expected = error.InvalidHardfork },
        .{ .args = &[_][]const u8{ "guillotine-mini", "--trace-tracer" }, .expected = error.MissingTraceTracer },
        .{ .args = &[_][]const u8{ "guillotine-mini", "--trace-timeout" }, .expected = error.MissingTraceTimeout },
        .{ .args = &[_][]const u8{ "guillotine-mini", "--unknown" }, .expected = error.UnknownOption },
    };

    for (cases) |case| {
        var config = RunnerConfig{};
        var trace_enabled = false;
        var buffer: [128]u8 = undefined;
        var stream = std.io.fixedBufferStream(&buffer);
        try std.testing.expectError(
            case.expected,
            parse_args(case.args, &config, &trace_enabled, stream.writer()),
        );
    }
}

test "write_version outputs stable line" {
    var buffer: [64]u8 = undefined;
    var stream = std.io.fixedBufferStream(&buffer);

    try write_version(stream.writer());

    const output = stream.getWritten();
    try std.testing.expectEqualStrings(
        "guillotine-mini 0.0.0 (runner)\n",
        output,
    );
}
