/// Local-only access helpers for Voltaire `Blockchain`.
///
/// Purpose:
/// - Provide a stable, client-local API for reads that MUST NOT cross the
///   storage boundary (no fork-cache lookups, no allocations).
/// - Concentrate any knowledge of `Blockchain` internals in one place so call
///   sites never reach into fields like `block_store` directly.
/// - Enables future changes in Voltaire internals to be absorbed here without
///   cascading edits across the client.
const blockchain = @import("blockchain");
const primitives = @import("primitives");

const Chain = blockchain.Blockchain;
const Block = primitives.Block;

/// Returns a block by hash from the local store only (no fork-cache fetch).
///
/// NOTE: This intentionally avoids the unified `getBlockByHash` to guarantee
/// local-only semantics. If Voltaire exposes first-class local getters in the
/// future, switch the implementation here to those accessors.
pub inline fn getBlockLocal(chain: *Chain, hash: primitives.Hash.Hash) ?Block.Block {
    return chain.block_store.getBlock(hash);
}

/// Returns a canonical block by number from the local store only.
pub inline fn getBlockByNumberLocal(chain: *Chain, number: u64) ?Block.Block {
    return chain.block_store.getBlockByNumber(number);
}

test {
    @import("std").testing.refAllDecls(@This());
}
