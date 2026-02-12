// Temporary compatibility shims for Voltaire JSON-RPC shared types.
// The current Voltaire checkout lacks src/jsonrpc/types/*.zig. We provide
// minimal, spec-conformant placeholders to satisfy our Engine/RPC modules.
// These shims must be removed once Voltaire exposes official types.
pub const Address = struct { bytes: [20]u8 };
pub const Hash = struct { bytes: [32]u8 };
pub const Quantity = struct { value: @import("std").json.Value };
pub const BlockTag = Quantity; // string union or hex quantity in practice
pub const BlockSpec = Quantity; // tag | number | hash wrapper
