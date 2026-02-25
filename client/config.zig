/// Runner configuration defaults and helpers.
///
/// Mirrors the minimal configuration surface required by the CLI entry point.
const std = @import("std");
const primitives = @import("voltaire");

const ChainId = primitives.ChainId;
const NetworkId = primitives.NetworkId;
const Hardfork = primitives.Hardfork;
const TraceConfig = primitives.TraceConfig;

const default_chain_id: ChainId.ChainId = ChainId.MAINNET;
const default_network_id: ?NetworkId.NetworkId = null;
const default_hardfork: Hardfork = Hardfork.DEFAULT;
const default_trace_config: TraceConfig = TraceConfig.from();

/// Runner configuration for CLI bootstrapping.
pub const RunnerConfig = struct {
    /// EIP-155 chain id.
    chain_id: ChainId.ChainId = default_chain_id,
    /// Optional devp2p network id override (defaults to chain id).
    network_id: ?NetworkId.NetworkId = default_network_id,
    /// Hardfork selection for EVM configuration.
    hardfork: Hardfork = default_hardfork,
    /// Trace configuration for debug tracing.
    trace_config: TraceConfig = default_trace_config,

    /// Returns the effective network id, defaulting to the chain id.
    pub fn effective_network_id(self: RunnerConfig) NetworkId.NetworkId {
        return self.network_id orelse NetworkId.from(self.chain_id);
    }
};

// ============================================================================
// Tests
// ============================================================================

test "runner config defaults chain id to mainnet" {
    const cfg = RunnerConfig{};
    try std.testing.expectEqual(ChainId.MAINNET, cfg.chain_id);
}

test "runner config resolves network id from chain id" {
    const cfg = RunnerConfig{ .chain_id = ChainId.SEPOLIA };
    try std.testing.expectEqual(NetworkId.from(ChainId.SEPOLIA), cfg.effective_network_id());
}

test "runner config respects network id override" {
    const cfg = RunnerConfig{
        .chain_id = ChainId.SEPOLIA,
        .network_id = NetworkId.MAINNET,
    };
    try std.testing.expectEqual(NetworkId.MAINNET, cfg.effective_network_id());
}

test "runner config defaults hardfork to primitives default" {
    const cfg = RunnerConfig{};
    try std.testing.expectEqual(Hardfork.DEFAULT, cfg.hardfork);
}

test "runner config defaults trace config" {
    const cfg = RunnerConfig{};
    try std.testing.expect(cfg.trace_config.equals(TraceConfig.from()));
}
