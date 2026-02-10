const std = @import("std");
const primitives = @import("primitives");

const tx_mod = primitives.Transaction;
const TxPoolConfig = @import("pool.zig").TxPoolConfig;
const U256 = primitives.Denomination.U256;
const GasLimit = primitives.Gas.GasLimit;

/// Validate a transaction's `gas_limit` against optional pool cap.
///
/// - If `cfg.gas_limit` is `null`, this check is a no-op.
/// - Otherwise returns `error.TxGasLimitExceeded` when `tx.gas_limit > cfg.gas_limit`.
///
/// Uses Voltaire primitives exclusively. Applies uniformly to all canonical
/// transaction types (legacy, 2930, 1559, 4844, 7702).
pub fn fits_gas_limit(tx: anytype, cfg: TxPoolConfig) error{TxGasLimitExceeded}!void {
    const T = @TypeOf(tx);
    comptime {
        if (!(T == tx_mod.LegacyTransaction or
            T == tx_mod.Eip2930Transaction or
            T == tx_mod.Eip1559Transaction or
            T == tx_mod.Eip4844Transaction or
            T == tx_mod.Eip7702Transaction))
        {
            @compileError("Unsupported transaction type for fits_gas_limit: " ++ @typeName(T));
        }
    }

    const cap_opt = cfg.gas_limit;
    if (cap_opt) |cap| {
        // Compare using Voltaire GasLimit semantics without lossy casts.
        // Convert tx.gas_limit (u64) into a GasLimit and compare underlying Uint.
        const tx_limit_gl = GasLimit.from_u64(@intCast(tx.gas_limit));
        if (tx_limit_gl.value.gt(cap.value)) return error.TxGasLimitExceeded;
    }
}

/// Enforce that a transaction's nonce is not too far in the future
/// relative to the sender's current account nonce and the number of
/// already-pending transactions from that sender.
///
/// Mirrors Nethermind's GapNonceFilter core predicate:
///   next_nonce_in_order = current_nonce + pending_sender_txs
///   accept if tx_nonce <= next_nonce_in_order
///
/// Notes:
/// - This helper ONLY checks for a future gap; it does not reject stale
///   (too-low) nonces. Other admission stages should handle stale/replacement.
/// - Uses difference arithmetic to avoid `u64` overflow on addition.
pub fn enforce_nonce_gap(
    tx_nonce: u64,
    current_nonce: u64,
    pending_sender_txs: usize,
) error{NonceGap}!void {
    // If tx is not ahead of current nonce, gap filter is satisfied.
    if (tx_nonce <= current_nonce) return;

    // Compute forward distance using subtraction to avoid overflow.
    const forward: u64 = tx_nonce - current_nonce;

    // Accept if tx is within the allowed window: distance ≤ pending count.
    if (forward <= @as(u64, @intCast(pending_sender_txs))) return;

    return error.NonceGap;
}

test "enforce_nonce_gap — accepts when nonce <= current" {
    try enforce_nonce_gap(7, 8, 0);
}

test "enforce_nonce_gap — accepts when within pending window" {
    // current=10, pending=3 allows up to nonce=13
    try enforce_nonce_gap(11, 10, 3);
    try enforce_nonce_gap(13, 10, 3);
}

test "enforce_nonce_gap — rejects when beyond pending window" {
    try std.testing.expectError(error.NonceGap, enforce_nonce_gap(14, 10, 3));
}
/// Validate the RLP-encoded size of a transaction against pool limits.
///
/// - Uses Voltaire Transaction encoders to compute raw network bytes:
///   - Legacy: RLP(list [...])
///   - EIP-1559 / EIP-7702: 1-byte type prefix + RLP(list [...])
///   - EIP-4844: 1-byte type prefix + RLP(list [...]) — blobs not included
/// - Applies `cfg.max_blob_tx_size` to blob txs (EIP-4844), else `cfg.max_tx_size`.
/// - Returns an error when the encoded size exceeds the configured limit.
pub fn fits_size_limits(
    allocator: std.mem.Allocator,
    tx: anytype,
    cfg: TxPoolConfig,
) (error{ MaxTxSizeExceeded, MaxBlobTxSizeExceeded } || std.mem.Allocator.Error)!void {
    const T = @TypeOf(tx);
    comptime {
        if (!(T == tx_mod.LegacyTransaction or
            T == tx_mod.Eip1559Transaction or
            T == tx_mod.Eip4844Transaction or
            T == tx_mod.Eip7702Transaction or
            T == tx_mod.Eip2930Transaction))
        {
            @compileError("Unsupported transaction type for fits_size_limits: " ++ @typeName(T));
        }
    }

    // Use caller-provided allocator to avoid page allocator churn on hot path

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
    } else if (comptime T == tx_mod.Eip2930Transaction) {
        // Construct EIP-2930 list per spec and encode via RLP
        const rlp = primitives.Rlp;
        var list = std.array_list.AlignedManaged(u8, null).init(allocator);
        defer list.deinit();

        // chain_id, nonce, gas_price, gas_limit
        {
            const enc = try rlp.encode(allocator, tx.chain_id);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        {
            const enc = try rlp.encode(allocator, tx.nonce);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        {
            const enc = try rlp.encode(allocator, tx.gas_price);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        {
            const enc = try rlp.encode(allocator, tx.gas_limit);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }

        // to (nullable)
        if (tx.to) |to_addr| {
            const enc = try rlp.encodeBytes(allocator, &to_addr.bytes);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        } else {
            try list.append(0x80);
        }

        // value, data
        {
            const enc = try rlp.encode(allocator, tx.value);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        {
            const enc = try rlp.encodeBytes(allocator, tx.data);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }

        // access_list
        {
            const enc = try tx_mod.encodeAccessList(allocator, tx.access_list);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }

        // Optional signature: y_parity, r, s if present
        const zeros = [_]u8{0} ** 32;
        if (!(tx.y_parity == 0 and std.mem.eql(u8, &tx.r, &zeros) and std.mem.eql(u8, &tx.s, &zeros))) {
            {
                const enc = try rlp.encode(allocator, tx.y_parity);
                defer allocator.free(enc);
                try list.appendSlice(enc);
            }
            {
                const enc = try rlp.encodeBytes(allocator, &tx.r);
                defer allocator.free(enc);
                try list.appendSlice(enc);
            }
            {
                const enc = try rlp.encodeBytes(allocator, &tx.s);
                defer allocator.free(enc);
                try list.appendSlice(enc);
            }
        }

        // Wrap list and add type byte 0x01
        const list_len_2930 = list.items.len;
        const header_len_2930: usize = if (list_len_2930 <= 55) 1 else blk: {
            var tmp = list_len_2930;
            var n: usize = 0;
            while (tmp > 0) : (tmp >>= 8) n += 1;
            break :blk 1 + n;
        };
        len = 1 + header_len_2930 + list_len_2930;
    } else if (comptime T == tx_mod.Eip4844Transaction) {
        // Length-only sizing for EIP-4844 to minimize allocations.
        var payload_len: usize = 0;
        payload_len += rlpLenOfUInt(tx.chain_id);
        payload_len += rlpLenOfUInt(tx.nonce);
        payload_len += rlpLenOfUInt(tx.max_priority_fee_per_gas);
        payload_len += rlpLenOfUInt(tx.max_fee_per_gas);
        payload_len += rlpLenOfUInt(tx.gas_limit);
        // to (20 bytes)
        payload_len += rlpLenOfBytes(20, null);
        // value
        payload_len += rlpLenOfUInt(tx.value);
        // data
        const first: ?u8 = if (tx.data.len == 1) tx.data[0] else null;
        payload_len += rlpLenOfBytes(tx.data.len, first);
        // access_list (compute once via encoder)
        {
            const enc = try tx_mod.encodeAccessList(allocator, tx.access_list);
            defer allocator.free(enc);
            payload_len += enc.len;
        }
        // max_fee_per_blob_gas
        payload_len += rlpLenOfUInt(tx.max_fee_per_blob_gas);
        // blob_versioned_hashes: each hash is 32 bytes → RLP item length fixed
        const per_hash_len: usize = rlpLenOfBytes(32, null);
        const hashes_items_len: usize = tx.blob_versioned_hashes.len * per_hash_len;
        payload_len += rlpLenOfList(hashes_items_len);

        // Optional signature: y_parity, r, s
        const zeros = [_]u8{0} ** 32;
        if (!(tx.y_parity == 0 and std.mem.eql(u8, &tx.r, &zeros) and std.mem.eql(u8, &tx.s, &zeros))) {
            payload_len += rlpLenOfUInt(tx.y_parity);
            payload_len += rlpLenOfBytes(32, null);
            payload_len += rlpLenOfBytes(32, null);
        }

        // Type prefix (0x03) + RLP(list header+payload)
        len = 1 + rlpLenOfList(payload_len);
    } else if (comptime T == tx_mod.Eip7702Transaction) {
        // Length-only sizing for EIP-7702 (typed-4) to minimize allocations.
        var payload_len: usize = 0;
        // chain_id, nonce, fees, gas_limit
        payload_len += rlpLenOfUInt(tx.chain_id);
        payload_len += rlpLenOfUInt(tx.nonce);
        payload_len += rlpLenOfUInt(tx.max_priority_fee_per_gas);
        payload_len += rlpLenOfUInt(tx.max_fee_per_gas);
        payload_len += rlpLenOfUInt(tx.gas_limit);

        // to (nullable)
        if (tx.to) |_| {
            payload_len += rlpLenOfBytes(20, null);
        } else {
            payload_len += rlpLenOfBytes(0, null);
        }

        // value, data
        payload_len += rlpLenOfUInt(tx.value);
        const first7702: ?u8 = if (tx.data.len == 1) tx.data[0] else null;
        payload_len += rlpLenOfBytes(tx.data.len, first7702);

        // access_list (compute once via encoder)
        {
            const enc = try tx_mod.encodeAccessList(allocator, tx.access_list);
            defer allocator.free(enc);
            payload_len += enc.len;
        }

        // authorization_list — compute length-only with y_parity derived from v
        var auth_items_encoded_total: usize = 0;
        for (tx.authorization_list) |auth| {
            var auth_payload: usize = 0;
            auth_payload += rlpLenOfUInt(auth.chain_id);
            auth_payload += rlpLenOfBytes(20, null);
            auth_payload += rlpLenOfUInt(auth.nonce);
            const y_parity: u8 = if (auth.v == 27) 0 else if (auth.v == 28) 1 else @as(u8, @intCast(auth.v & 1));
            auth_payload += rlpLenOfUInt(y_parity);
            auth_payload += rlpLenOfBytes(32, null); // r
            auth_payload += rlpLenOfBytes(32, null); // s
            auth_items_encoded_total += rlpLenOfList(auth_payload);
        }
        payload_len += rlpLenOfList(auth_items_encoded_total);

        // Optional transaction signature (y_parity, r, s)
        const zeros = [_]u8{0} ** 32;
        if (!(tx.y_parity == 0 and std.mem.eql(u8, &tx.r, &zeros) and std.mem.eql(u8, &tx.s, &zeros))) {
            payload_len += rlpLenOfUInt(tx.y_parity);
            payload_len += rlpLenOfBytes(32, null);
            payload_len += rlpLenOfBytes(32, null);
        }

        // Final typed envelope size
        len = 1 + rlpLenOfList(payload_len);
    }
    // EIP-4844: Prefer specific blob-envelope limit when configured;
    // otherwise, fall back to the generic `max_tx_size` check below.
    if (comptime T == tx_mod.Eip4844Transaction) {
        if (cfg.max_blob_tx_size) |max| {
            if (len > max) return error.MaxBlobTxSizeExceeded;
            // When a blob-specific cap exists, do not apply the generic cap.
            return;
        }
        // No blob cap configured — intentionally fall through to generic cap.
    }

    if (cfg.max_tx_size) |max| {
        if (len > max) return error.MaxTxSizeExceeded;
    }
}
/// - If the transaction is not an EIP-4844 blob transaction, this is a no-op.
/// - When `cfg.min_blob_tx_priority_fee > 0`, require
///   `tx.max_priority_fee_per_gas >= cfg.min_blob_tx_priority_fee`.
/// - When `cfg.current_blob_base_fee_required` is true, require
///   `tx.max_fee_per_blob_gas >= current_blob_base_fee`.
///
/// Uses only Voltaire primitives. This helper is intentionally strict and
/// does not attempt to coerce types beyond primitives' own conversions.
pub fn enforce_min_priority_fee_for_blobs(
    tx: anytype,
    cfg: TxPoolConfig,
    current_blob_base_fee: U256,
) error{ BlobPriorityFeeTooLow, InsufficientMaxFeePerBlobGas }!void {
    const T = @TypeOf(tx);
    comptime {
        if (!(T == tx_mod.LegacyTransaction or
            T == tx_mod.Eip2930Transaction or
            T == tx_mod.Eip1559Transaction or
            T == tx_mod.Eip4844Transaction or
            T == tx_mod.Eip7702Transaction))
        {
            @compileError("Unsupported transaction type for enforce_min_priority_fee_for_blobs: " ++ @typeName(T));
        }
    }

    // Only applies to blob transactions (EIP-4844, type-3)
    if (comptime T != tx_mod.Eip4844Transaction) return;

    // Check min priority fee for blob txs (if configured > 0)
    if (!cfg.min_blob_tx_priority_fee.isZero()) {
        // Compare in wei space using primitives types.
        const tx_tip_wei: U256 = U256.from_u256(tx.max_priority_fee_per_gas);
        const min_tip_wei: U256 = cfg.min_blob_tx_priority_fee.toWei();
        if (tx_tip_wei.cmp(min_tip_wei) == .lt) {
            return error.BlobPriorityFeeTooLow;
        }
    }

    // Require max_fee_per_blob_gas ≥ current blob base fee if enabled.
    if (cfg.current_blob_base_fee_required) {
        const tx_blob_max_wei: U256 = U256.from_u256(tx.max_fee_per_blob_gas);
        if (tx_blob_max_wei.cmp(current_blob_base_fee) == .lt) {
            return error.InsufficientMaxFeePerBlobGas;
        }
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
    try fits_size_limits(std.testing.allocator, tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_tx_size = encoded.len - 1; // too small
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(std.testing.allocator, tx, cfg_bad));
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
    try fits_size_limits(std.testing.allocator, tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_tx_size = encoded.len - 1;
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(std.testing.allocator, tx, cfg_bad));
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
        // mark as signed to reflect network encoding size (include y_parity,r,s)
        .y_parity = 1,
        .r = [_]u8{3} ** 32,
        .s = [_]u8{4} ** 32,
    };

    const allocator = std.testing.allocator;
    // Compute encoded length using the same manual RLP path as implementation
    const rlp = primitives.Rlp;
    var list = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer list.deinit();
    {
        const enc = try rlp.encode(allocator, tx.chain_id);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.nonce);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.max_priority_fee_per_gas);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.max_fee_per_gas);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.gas_limit);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, &tx.to.bytes);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.value);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, tx.data);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try tx_mod.encodeAccessList(allocator, tx.access_list);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.max_fee_per_blob_gas);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        var hashes_list = std.array_list.AlignedManaged(u8, null).init(allocator);
        defer hashes_list.deinit();
        for (tx.blob_versioned_hashes) |vh| {
            const enc = try rlp.encodeBytes(allocator, &vh.bytes);
            defer allocator.free(enc);
            try hashes_list.appendSlice(enc);
        }
        if (hashes_list.items.len <= 55) {
            try list.append(@as(u8, @intCast(0xc0 + hashes_list.items.len)));
        } else {
            const len_bytes = try rlp.encodeLength(allocator, hashes_list.items.len);
            defer allocator.free(len_bytes);
            try list.append(@as(u8, @intCast(0xf7 + len_bytes.len)));
            try list.appendSlice(len_bytes);
        }
        try list.appendSlice(hashes_list.items);
    }
    {
        const enc = try rlp.encode(allocator, tx.y_parity);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, &tx.r);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, &tx.s);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }

    var wrapped = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer wrapped.deinit();
    if (list.items.len <= 55) {
        try wrapped.append(@as(u8, @intCast(0xc0 + list.items.len)));
    } else {
        const len_bytes = try rlp.encodeLength(allocator, list.items.len);
        defer allocator.free(len_bytes);
        try wrapped.append(@as(u8, @intCast(0xf7 + len_bytes.len)));
        try wrapped.appendSlice(len_bytes);
    }
    try wrapped.appendSlice(list.items);

    const encoded = try allocator.alloc(u8, 1 + wrapped.items.len);
    encoded[0] = 0x03;
    @memcpy(encoded[1..], wrapped.items);
    defer allocator.free(encoded);

    var cfg_ok = TxPoolConfig{};
    cfg_ok.max_blob_tx_size = encoded.len;
    try fits_size_limits(std.testing.allocator, tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_blob_tx_size = encoded.len - 1;
    try std.testing.expectError(error.MaxBlobTxSizeExceeded, fits_size_limits(std.testing.allocator, tx, cfg_bad));
}

test "fits_size_limits — eip7702 within and over limit (unsigned)" {
    const Address = primitives.Address;
    const Authorization = primitives.Authorization.Authorization;
    const tx = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x44} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = &[_]Authorization{},
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
        .y_parity = 0,
    };

    const allocator = std.testing.allocator;
    // Mirror manual encoding used in implementation to compute expected length
    const rlp = primitives.Rlp;
    var list = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer list.deinit();
    {
        const enc = try rlp.encode(allocator, tx.chain_id);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.nonce);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.max_priority_fee_per_gas);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.max_fee_per_gas);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.gas_limit);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    if (tx.to) |to_addr| {
        const enc = try rlp.encodeBytes(allocator, &to_addr.bytes);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    } else {
        try list.append(0x80);
    }
    {
        const enc = try rlp.encode(allocator, tx.value);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, tx.data);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try tx_mod.encodeAccessList(allocator, tx.access_list);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try primitives.Authorization.encodeAuthorizationList(allocator, tx.authorization_list);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    var wrapped = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer wrapped.deinit();
    if (list.items.len <= 55) {
        try wrapped.append(@as(u8, @intCast(0xc0 + list.items.len)));
    } else {
        const len_bytes = try rlp.encodeLength(allocator, list.items.len);
        defer allocator.free(len_bytes);
        try wrapped.append(@as(u8, @intCast(0xf7 + len_bytes.len)));
        try wrapped.appendSlice(len_bytes);
    }
    try wrapped.appendSlice(list.items);
    const encoded = try allocator.alloc(u8, 1 + wrapped.items.len);
    encoded[0] = 0x04;
    @memcpy(encoded[1..], wrapped.items);
    defer allocator.free(encoded);

    var cfg_ok = TxPoolConfig{};
    cfg_ok.max_tx_size = encoded.len;
    try fits_size_limits(allocator, tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_tx_size = encoded.len - 1;
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(allocator, tx, cfg_bad));
}

test "fits_size_limits — eip7702 within and over limit (signed)" {
    const Address = primitives.Address;
    const Authorization = primitives.Authorization.Authorization;
    var tx = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x55} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = &[_]Authorization{},
        .y_parity = 1,
        .r = [_]u8{9} ** 32,
        .s = [_]u8{8} ** 32,
    };

    const allocator = std.testing.allocator;
    // Mirror manual encoding used in implementation to compute expected length (with signature)
    const rlp = primitives.Rlp;
    var list = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer list.deinit();
    {
        const enc = try rlp.encode(allocator, tx.chain_id);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.nonce);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.max_priority_fee_per_gas);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.max_fee_per_gas);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx.gas_limit);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    if (tx.to) |to_addr| {
        const enc = try rlp.encodeBytes(allocator, &to_addr.bytes);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    } else {
        try list.append(0x80);
    }
    {
        const enc = try rlp.encode(allocator, tx.value);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, tx.data);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try tx_mod.encodeAccessList(allocator, tx.access_list);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try primitives.Authorization.encodeAuthorizationList(allocator, tx.authorization_list);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    // include y_parity, r, s
    {
        const enc = try rlp.encode(allocator, tx.y_parity);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, &tx.r);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, &tx.s);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    var wrapped = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer wrapped.deinit();
    if (list.items.len <= 55) {
        try wrapped.append(@as(u8, @intCast(0xc0 + list.items.len)));
    } else {
        const len_bytes = try rlp.encodeLength(allocator, list.items.len);
        defer allocator.free(len_bytes);
        try wrapped.append(@as(u8, @intCast(0xf7 + len_bytes.len)));
        try wrapped.appendSlice(len_bytes);
    }
    try wrapped.appendSlice(list.items);
    const encoded = try allocator.alloc(u8, 1 + wrapped.items.len);
    encoded[0] = 0x04;
    @memcpy(encoded[1..], wrapped.items);
    defer allocator.free(encoded);

    var cfg_ok = TxPoolConfig{};
    cfg_ok.max_tx_size = encoded.len;
    try fits_size_limits(allocator, tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_tx_size = encoded.len - 1;
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(allocator, tx, cfg_bad));
}

test "fits_gas_limit — passes when under/equal, errors when over (legacy)" {
    const Address = primitives.Address;
    const tx = tx_mod.LegacyTransaction{
        .nonce = 0,
        .gas_price = 1,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0x99} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .v = 37,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    // No cap → always OK
    try fits_gas_limit(tx, TxPoolConfig{});

    var cfg = TxPoolConfig{};
    cfg.gas_limit = GasLimit.from_u64(21_000);
    try fits_gas_limit(tx, cfg); // equal → OK

    cfg.gas_limit = GasLimit.from_u64(20_999);
    try std.testing.expectError(error.TxGasLimitExceeded, fits_gas_limit(tx, cfg));
}

test "fits_gas_limit — works for typed txs (1559, 4844, 7702)" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;
    const Authorization = primitives.Authorization.Authorization;

    var cfg = TxPoolConfig{};
    cfg.gas_limit = GasLimit.from_u64(50_000);

    const tx1559 = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 30_000,
        .to = Address{ .bytes = [_]u8{0xA1} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try fits_gas_limit(tx1559, cfg);

    const hashes = [_]VersionedHash{.{ .bytes = [_]u8{0xAB} ++ [_]u8{0} ** 31 }};
    const tx4844 = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 60_000, // above cap
        .to = Address{ .bytes = [_]u8{0xA2} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = &hashes,
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try std.testing.expectError(error.TxGasLimitExceeded, fits_gas_limit(tx4844, cfg));

    const tx7702 = tx_mod.Eip7702Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 50_000, // equal to cap
        .to = Address{ .bytes = [_]u8{0xA3} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .authorization_list = &[_]Authorization{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };
    try fits_gas_limit(tx7702, cfg);
}

test "enforce_min_priority_fee_for_blobs — no-op for non-blob txs" {
    const Address = primitives.Address;
    const tx = tx_mod.Eip1559Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 0,
        .max_fee_per_gas = 0,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0xE1} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 0,
        .r = [_]u8{0} ** 32,
        .s = [_]u8{0} ** 32,
    };

    const cfg = TxPoolConfig{};
    try enforce_min_priority_fee_for_blobs(tx, cfg, U256.ZERO);
}

test "enforce_min_priority_fee_for_blobs — blob base fee required enforced" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;
    const hashes = [_]VersionedHash{.{ .bytes = [_]u8{0xB1} ++ [_]u8{0} ** 31 }};

    // Tx with max_fee_per_blob_gas below the supplied base fee.
    var cfg = TxPoolConfig{};
    cfg.current_blob_base_fee_required = true;

    const tx_low = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0xE2} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 4,
        .blob_versioned_hashes = &hashes,
        .y_parity = 1,
        .r = [_]u8{3} ** 32,
        .s = [_]u8{4} ** 32,
    };

    const base_fee = U256.from_u64(5);
    try std.testing.expectError(error.InsufficientMaxFeePerBlobGas, enforce_min_priority_fee_for_blobs(tx_low, cfg, base_fee));

    const tx_ok = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 1,
        .max_fee_per_gas = 2,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0xE3} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 5,
        .blob_versioned_hashes = &hashes,
        .y_parity = 1,
        .r = [_]u8{5} ** 32,
        .s = [_]u8{6} ** 32,
    };
    try enforce_min_priority_fee_for_blobs(tx_ok, cfg, base_fee);
}

test "enforce_min_priority_fee_for_blobs — min priority tip enforced for blob txs" {
    const Address = primitives.Address;
    const VersionedHash = primitives.Blob.VersionedHash;
    const hashes = [_]VersionedHash{.{ .bytes = [_]u8{0xB2} ++ [_]u8{0} ** 31 }};

    var cfg = TxPoolConfig{};
    cfg.current_blob_base_fee_required = false; // isolate priority fee check
    const MaxPriorityFeePerGas = primitives.MaxPriorityFeePerGas;
    cfg.min_blob_tx_priority_fee = MaxPriorityFeePerGas.from(3);
    const tx_low = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 2, // below min (3)
        .max_fee_per_gas = 10,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0xE4} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = &hashes,
        .y_parity = 1,
        .r = [_]u8{7} ** 32,
        .s = [_]u8{8} ** 32,
    };
    try std.testing.expectError(error.BlobPriorityFeeTooLow, enforce_min_priority_fee_for_blobs(tx_low, cfg, U256.ZERO));

    const tx_ok = tx_mod.Eip4844Transaction{
        .chain_id = 1,
        .nonce = 0,
        .max_priority_fee_per_gas = 3, // equal to min
        .max_fee_per_gas = 10,
        .gas_limit = 21_000,
        .to = Address{ .bytes = [_]u8{0xE5} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{},
        .access_list = &[_]tx_mod.AccessListItem{},
        .max_fee_per_blob_gas = 1,
        .blob_versioned_hashes = &hashes,
        .y_parity = 1,
        .r = [_]u8{9} ** 32,
        .s = [_]u8{10} ** 32,
    };
    try enforce_min_priority_fee_for_blobs(tx_ok, cfg, U256.ZERO);
}

// -----------------------------------------------------------------------------
// Lightweight RLP length helpers (no allocations)
// -----------------------------------------------------------------------------
inline fn rlpLenOfList(payload_len: usize) usize {
    // 0xC0 + len (<=55) OR 0xF7 + len_of_len + len
    if (payload_len <= 55) return 1 + payload_len;
    var tmp = payload_len;
    var n: usize = 0;
    while (tmp > 0) : (tmp >>= 8) n += 1;
    return 1 + n + payload_len;
}

inline fn rlpLenOfBytes(len: usize, first_byte_if_len1: ?u8) usize {
    // If a single byte less than 0x80, encoded as itself
    if (len == 1) {
        if (first_byte_if_len1) |b| if (b < 0x80) return 1;
        // Otherwise short string form (0x80 + 1 + byte)
        return 2;
    }
    if (len < 56) return 1 + len;
    var tmp = len;
    var n: usize = 0;
    while (tmp > 0) : (tmp >>= 8) n += 1;
    return 1 + n + len;
}

inline fn rlpLenOfUInt(x: anytype) usize {
    const T = @TypeOf(x);
    comptime {
        if (!(@typeInfo(T) == .int and @typeInfo(T).int.signedness == .unsigned))
            @compileError("rlpLenOfUInt expects an unsigned integer type");
    }
    if (x == 0) return 1; // encoded as empty string (0x80)
    // Determine minimal byte length via bit-length to avoid shifts on small ints.
    const bits: usize = @bitSizeOf(T);
    const used_bits: usize = bits - @clz(x);
    const bytes: usize = (used_bits + 7) / 8;
    if (bytes == 1 and (x & 0x7f) == x) return 1; // single byte < 0x80
    return 1 + bytes; // short string form
}
