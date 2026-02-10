const std = @import("std");
const primitives = @import("primitives");

const tx_mod = primitives.Transaction;
const TxPoolConfig = @import("pool.zig").TxPoolConfig;

/// Validate the RLP-encoded size of a transaction against pool limits.
///
/// - Uses Voltaire Transaction encoders to compute raw network bytes:
///   - Legacy: RLP(list [...])
///   - EIP-1559 / EIP-7702: 1-byte type prefix + RLP(list [...])
///   - EIP-4844: 1-byte type prefix + RLP(list [...]) — blobs not included
/// - Applies `cfg.max_blob_tx_size` to blob txs (EIP-4844), else `cfg.max_tx_size`.
/// - Returns an error when the encoded size exceeds the configured limit.
pub fn fits_size_limits(
    tx: anytype,
    cfg: TxPoolConfig,
) (error{ MaxTxSizeExceeded, MaxBlobTxSizeExceeded } || std.mem.Allocator.Error)!void {
    const T = @TypeOf(tx);

    // Compute raw encoded length using Voltaire encoders
    const encoded_len: usize = comptime blk: {
        if (T == tx_mod.LegacyTransaction) break :blk 0;
        if (T == tx_mod.Eip1559Transaction) break :blk 0;
        if (T == tx_mod.Eip4844Transaction) break :blk 0;
        if (T == tx_mod.Eip7702Transaction) break :blk 0;
        @compileError("Unsupported transaction type for fits_size_limits: " ++ @typeName(T));
    };
    _ = encoded_len; // silence unused in comptime block

    const allocator = std.heap.page_allocator;

    var len: usize = 0;
    if (comptime T == tx_mod.LegacyTransaction) {
        // Chain ID is ignored for signed tx in encoder; use 1 as placeholder.
        const bytes = try tx_mod.encodeLegacyForSigning(allocator, tx, 1);
        defer allocator.free(bytes);
        len = bytes.len;
    } else if (comptime T == tx_mod.Eip1559Transaction) {
        const bytes = try tx_mod.encodeEip1559ForSigning(allocator, tx);
        defer allocator.free(bytes);
        len = bytes.len;
    } else if (comptime T == tx_mod.Eip4844Transaction) {
        const bytes = try tx_mod.encodeEip4844ForSigning(allocator, tx);
        defer allocator.free(bytes);
        len = bytes.len;
    } else if (comptime T == tx_mod.Eip7702Transaction) {
        const bytes = try tx_mod.encodeEip7702ForSigning(allocator, tx);
        defer allocator.free(bytes);
        len = bytes.len;
    }

    if (comptime T == tx_mod.Eip4844Transaction) {
        if (cfg.max_blob_tx_size) |max| {
            if (len > max) return error.MaxBlobTxSizeExceeded;
        }
        return;
    }

    if (cfg.max_tx_size) |max| {
        if (len > max) return error.MaxTxSizeExceeded;
    }
}

// =============================================================================
// Tests
// =============================================================================

test "fits_size_limits — legacy within and over limit" {
    const Address = primitives.Address;

    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 1,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x11} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 37,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    // Measure encoded size to craft thresholds deterministically
    const allocator = std.testing.allocator;
    const encoded = try tx_mod.encodeLegacyForSigning(allocator, tx, 1);
    defer allocator.free(encoded);

    var cfg_ok = TxPoolConfig{}; // defaults allow ample size
    cfg_ok.max_tx_size = encoded.len; // exactly fits
    try fits_size_limits(tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_tx_size = encoded.len - 1; // too small
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(tx, cfg_bad));
}

test "fits_size_limits — eip1559 within and over limit" {
    const Address = primitives.Address;

    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x22} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        // mark as signed to reflect network encoding size (include v,r,s)
        .y_parity = 1,
        .r = [_]u8{1} ** 32,
        .s = [_]u8{2} ** 32,
    };

    const allocator = std.testing.allocator;
    const encoded = try tx_mod.encodeEip1559ForSigning(allocator, tx);
    defer allocator.free(encoded);

    var cfg_ok = TxPoolConfig{};
    cfg_ok.max_tx_size = encoded.len;
    try fits_size_limits(tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_tx_size = encoded.len - 1;
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(tx, cfg_bad));
}

test "fits_size_limits — eip4844 (blob) within and over blob limit" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;

    const hashes = [_]VersionedHash{.{ .bytes = [_]u8{0xAA} ++ [_]u8{0} ** 31 }};

    const tx = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x33} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = &hashes,
        // mark as signed to reflect network encoding size (include v,r,s)
        .v = 37,
        .r = [_]u8{3} ** 32,
        .s = [_]u8{4} ** 32,
    };

    const allocator = std.testing.allocator;
    const encoded = try tx_mod.encodeEip4844ForSigning(allocator, tx);
    defer allocator.free(encoded);

    var cfg_ok = TxPoolConfig{};
    cfg_ok.max_blob_tx_size = encoded.len;
    try fits_size_limits(tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_blob_tx_size = encoded.len - 1;
    try std.testing.expectError(error.MaxBlobTxSizeExceeded, fits_size_limits(tx, cfg_bad));
}

