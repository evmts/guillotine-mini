/// Chain - minimal block lookup interface for chain management.
///
/// Nethermind parallel: IBlockFinder read surface (subset).
/// Voltaire backend: blockchain.Blockchain.
const std = @import("std");
const primitives = @import("primitives");
const blockchain = @import("blockchain");

const Block = primitives.Block;
const Hash = primitives.Hash;
const ChainId = primitives.ChainId;

/// Type-erased chain access wrapper backed by a Voltaire Blockchain.
pub const Chain = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const ChainError = anyerror;

    pub const VTable = struct {
        getBlockByHash: *const fn (ptr: *anyopaque, hash: Hash.Hash) ChainError!?Block.Block,
        getBlockByNumber: *const fn (ptr: *anyopaque, number: u64) ChainError!?Block.Block,
    };

    /// Create a Chain view over a Voltaire Blockchain backend.
    pub fn fromVoltaire(store: *blockchain.Blockchain) Chain {
        return .{
            .ptr = @ptrCast(store),
            .vtable = &voltaire_vtable,
        };
    }

    /// Get block by hash (local store, then fork cache if configured).
    pub fn getBlockByHash(self: Chain, hash: Hash.Hash) !?Block.Block {
        return self.vtable.getBlockByHash(self.ptr, hash);
    }

    /// Get block by number from the canonical chain.
    pub fn getBlockByNumber(self: Chain, number: u64) !?Block.Block {
        return self.vtable.getBlockByNumber(self.ptr, number);
    }
};

fn voltaireGetBlockByHash(ptr: *anyopaque, hash: Hash.Hash) !?Block.Block {
    const store: *blockchain.Blockchain = @ptrCast(@alignCast(ptr));
    return store.getBlockByHash(hash);
}

fn voltaireGetBlockByNumber(ptr: *anyopaque, number: u64) !?Block.Block {
    const store: *blockchain.Blockchain = @ptrCast(@alignCast(ptr));
    return store.getBlockByNumber(number);
}

const voltaire_vtable = Chain.VTable{
    .getBlockByHash = voltaireGetBlockByHash,
    .getBlockByNumber = voltaireGetBlockByNumber,
};

// =============================================================================
// Tests
// =============================================================================

test "Chain - getBlockByHash returns stored block" {
    const allocator = std.testing.allocator;
    var store = try blockchain.Blockchain.init(allocator, null);
    defer store.deinit();

    const chain = Chain.fromVoltaire(&store);
    const genesis = try Block.genesis(ChainId.MAINNET, allocator);
    try store.putBlock(genesis);

    const retrieved = try chain.getBlockByHash(genesis.hash);
    try std.testing.expect(retrieved != null);
    try std.testing.expectEqual(@as(u64, 0), retrieved.?.header.number);
}

test "Chain - getBlockByNumber returns canonical block" {
    const allocator = std.testing.allocator;
    var store = try blockchain.Blockchain.init(allocator, null);
    defer store.deinit();

    const chain = Chain.fromVoltaire(&store);
    const genesis = try Block.genesis(ChainId.MAINNET, allocator);
    try store.putBlock(genesis);
    try store.setCanonicalHead(genesis.hash);

    const retrieved = try chain.getBlockByNumber(0);
    try std.testing.expect(retrieved != null);
    try std.testing.expectEqual(@as(u64, 0), retrieved.?.header.number);
}
