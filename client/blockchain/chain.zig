/// Chain management aliases backed by Voltaire primitives.
const blockchain = @import("blockchain");

pub const Chain = blockchain.Blockchain;
pub const ForkBlockCache = blockchain.ForkBlockCache;
pub const BlockStore = blockchain.BlockStore;

test {
    @import("std").testing.refAllDecls(@This());
}
