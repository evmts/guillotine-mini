/// Local-only access helpers for Voltaire `Blockchain`.
///
/// Purpose:
/// - Provide a stable, client-local API for reads that MUST NOT cross the
///   storage boundary (no fork-cache lookups, no allocations).
/// - Concentrate any knowledge of `Blockchain` internals in one place so call
///   sites never reach into fields like `block_store` directly.
/// - Enables future changes in Voltaire internals to be absorbed here without
///   cascading edits across the client.
///
/// FIXME(voltaire): This module currently reaches into `chain.block_store`
/// internals as a stopgap until first-class local-only getters are exposed by
/// Voltaire. Track this dependency and migrate to upstream accessors when
/// available to remove the layering-violation risk.
const blockchain = @import("blockchain");
const primitives = @import("primitives");

const Chain = blockchain.Blockchain;
const Block = primitives.Block;

/// Returns a block by hash from the local store only (no fork-cache fetch).
///
/// NOTE: This intentionally avoids the unified `getBlockByHash` to guarantee
/// local-only semantics. If Voltaire exposes first-class local getters in the
/// future, switch the implementation here to those accessors.
pub inline fn get_block_local(chain: *Chain, hash: primitives.Hash.Hash) ?Block.Block {
    // Prefer an upstream getter if available; fallback to internals
    if (@hasDecl(Chain, "getBlockLocal")) {
        const Fn = fn (*Chain, primitives.Hash.Hash) ?Block.Block;
        const f: Fn = @field(Chain, "getBlockLocal");
        return f(chain, hash);
    }
    return chain.block_store.getBlock(hash);
}

/// Returns a canonical block by number from the local store only.
pub inline fn get_block_by_number_local(chain: *Chain, number: u64) ?Block.Block {
    const h = chain.getCanonicalHash(number) orelse return null;
    // Resolve canonical hash locally, then perform a strict local lookup.
    // Never fall back to fork-cache fetches and never suppress errors.
    return get_block_local(chain, h);
}

test {
    @import("std").testing.refAllDecls(@This());
}

test "local_access: returns null for missing" {
    const std = @import("std");
    var chain = try Chain.init(std.testing.allocator, null);
    defer chain.deinit();

    try std.testing.expect(get_block_local(&chain, primitives.Hash.ZERO) == null);
    try std.testing.expect(get_block_by_number_local(&chain, 0) == null);
}

test "local_access: gets block by hash and number after canonical" {
    const std = @import("std");

    var chain = try Chain.init(std.testing.allocator, null);
    defer chain.deinit();

    const block = try Block.genesis(1, std.testing.allocator);
    try chain.putBlock(block);

    const by_hash = get_block_local(&chain, block.hash) orelse return error.UnexpectedNull;
    try std.testing.expect(@import("primitives").Hash.equals(&block.hash, &by_hash.hash));

    // Not canonical yet → number lookup should be null.
    try std.testing.expect(get_block_by_number_local(&chain, 0) == null);

    try chain.setCanonicalHead(block.hash);
    const by_number = get_block_by_number_local(&chain, 0) orelse return error.UnexpectedNull;
    try std.testing.expect(@import("primitives").Hash.equals(&block.hash, &by_number.hash));
}
