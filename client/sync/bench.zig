/// Benchmarks for the Sync module (sync status resolution, mode checks, headers request builders).
const std = @import("std");
const bench = @import("bench_utils");
const primitives = @import("voltaire");
const mode = @import("mode.zig");
const status = @import("status.zig");
const headers = @import("headers.zig");
const full = @import("full.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var suite = bench.BenchSuite.init(allocator, "client/sync");
    defer suite.deinit();

    suite.section("SyncMode & SyncStatus Resolution");
    {
        const modes = [_]u32{
            mode.SyncMode.none,
            mode.SyncMode.waiting_for_block,
            mode.SyncMode.fast_blocks,
            mode.SyncMode.fast_bodies,
            mode.SyncMode.fast_receipts,
            mode.SyncMode.full,
            mode.SyncMode.snap_sync,
            mode.SyncMode.state_nodes,
        };
        const n: usize = 5_000_000;
        var timer = try std.time.Timer.start();
        var acc: usize = 0;
        for (0..n) |i| {
            const m = modes[i & 7];
            const s = status.default_to_sync_status(m, @intCast(i), @intCast(i + (i & 15)));
            acc +%= @intFromBool(s.isSyncing());
            acc +%= @intFromBool(mode.not_syncing(m));
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("default_to_sync_status + mode checks", n, timer.read()));
    }

    suite.section("HeadersRequest & Full Sync Helpers");
    {
        const n: usize = 2_000_000;
        var timer = try std.time.Timer.start();
        var acc: usize = 0;
        for (0..n) |i| {
            const req = headers.HeadersRequest.ascendingFrom(primitives.BlockNumber.from(@intCast(i)), 192);
            const skel = try headers.HeadersRequest.skeletonFrom(primitives.BlockNumber.from(@intCast(i)), 192, 64, false);
            acc +%= req.limit +% skel.skip;
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("HeadersRequest.ascendingFrom + skeletonFrom", n, timer.read()));
    }

    {
        const PeerInfoModule = primitives.PeerInfo;
        const peer_id: primitives.PeerId.PeerId = [_]u8{0} ** 64;
        const caps = &[_][]const u8{};
        const network = PeerInfoModule.NetworkInfo{
            .local_address = "",
            .remote_address = "",
            .inbound = false,
            .trusted = false,
            .static = false,
        };
        const protocols = PeerInfoModule.Protocols{ .eth = null };
        const peers = [_]PeerInfoModule.PeerInfo{
            PeerInfoModule.init(peer_id, "Nethermind/v1.30.0", caps, network, protocols),
            PeerInfoModule.init(peer_id, "Geth/v1.14.0", caps, network, protocols),
            PeerInfoModule.init(peer_id, "Besu/v24.0.0", caps, network, protocols),
            PeerInfoModule.init(peer_id, "Reth/v1.0.0", caps, network, protocols),
        };
        const n: usize = 2_000_000;
        var timer = try std.time.Timer.start();
        var acc: usize = 0;
        for (0..n) |i| {
            const peer = peers[i & 3];
            acc +%= full.max_headers_per_request(peer) +% full.max_bodies_per_request(peer) +% full.max_receipts_per_request(peer);
        }
        std.mem.doNotOptimizeAway(acc);
        try suite.record(bench.make_result("full sync peer request cap helpers", n, timer.read()));
    }

    try suite.finish();
}
