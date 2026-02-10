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
        // Manual EIP-4844 encoding using primitives.Rlp to avoid
        // upstream encoder inconsistency (tx.v vs y_parity).
        // This matches the field order in the spec and Voltaire's encoder.
        const rlp = primitives.Rlp;

        var list = std.array_list.AlignedManaged(u8, null).init(allocator);
        defer list.deinit();

        // chain_id
        {
            const enc = try rlp.encode(allocator, tx.chain_id);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        // nonce
        {
            const enc = try rlp.encode(allocator, tx.nonce);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        // max_priority_fee_per_gas
        {
            const enc = try rlp.encode(allocator, tx.max_priority_fee_per_gas);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        // max_fee_per_gas
        {
            const enc = try rlp.encode(allocator, tx.max_fee_per_gas);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        // gas_limit
        {
            const enc = try rlp.encode(allocator, tx.gas_limit);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        // to
        {
            const enc = try rlp.encodeBytes(allocator, &tx.to.bytes);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        // value
        {
            const enc = try rlp.encode(allocator, tx.value);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        // data
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
        // max_fee_per_blob_gas
        {
            const enc = try rlp.encode(allocator, tx.max_fee_per_blob_gas);
            defer allocator.free(enc);
            try list.appendSlice(enc);
        }
        // blob_versioned_hashes
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
        // signature fields when present (y_parity, r, s)
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

        // Wrap as RLP list
        // Compute final size without allocating final buffer
        const list_len_4844 = list.items.len;
        const header_len_4844: usize = if (list_len_4844 <= 55) 1 else blk: {
            var tmp = list_len_4844;
            var n: usize = 0;
            while (tmp > 0) : (tmp >>= 8) n += 1;
            break :blk 1 + n;
        };
        // Type prefix (0x03) + RLP(list header) + items
        len = 1 + header_len_4844 + list_len_4844;
    } else if (comptime T == tx_mod.Eip7702Transaction) {
        // Manual EIP-7702 encoding: 1-byte type + RLP(list[...])
        // to avoid upstream y_parity/v inconsistency
        const rlp = primitives.Rlp;
        var list = std.array_list.AlignedManaged(u8, null).init(allocator);
        defer list.deinit();

        // chain_id, nonce, max_priority_fee_per_gas, max_fee_per_gas, gas_limit
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

        // authorization_list — manual RLP to avoid upstream helper bug
        {
            var auths = std.array_list.AlignedManaged(u8, null).init(allocator);
            defer auths.deinit();

            for (tx.authorization_list) |auth| {
                var fields = std.array_list.AlignedManaged(u8, null).init(allocator);
                defer fields.deinit();

                // [chain_id, address, nonce, v, r, s]
                {
                    const enc = try rlp.encode(allocator, auth.chain_id);
                    defer allocator.free(enc);
                    try fields.appendSlice(enc);
                }
                {
                    const enc = try rlp.encodeBytes(allocator, &auth.address.bytes);
                    defer allocator.free(enc);
                    try fields.appendSlice(enc);
                }
                {
                    const enc = try rlp.encode(allocator, auth.nonce);
                    defer allocator.free(enc);
                    try fields.appendSlice(enc);
                }
                {
                    const enc = try rlp.encode(allocator, auth.v);
                    defer allocator.free(enc);
                    try fields.appendSlice(enc);
                }
                {
                    const enc = try rlp.encodeBytes(allocator, &auth.r);
                    defer allocator.free(enc);
                    try fields.appendSlice(enc);
                }
                {
                    const enc = try rlp.encodeBytes(allocator, &auth.s);
                    defer allocator.free(enc);
                    try fields.appendSlice(enc);
                }

                if (fields.items.len <= 55) {
                    try auths.append(@as(u8, @intCast(0xc0 + fields.items.len)));
                } else {
                    const len_bytes = try rlp.encodeLength(allocator, fields.items.len);
                    defer allocator.free(len_bytes);
                    try auths.append(@as(u8, @intCast(0xf7 + len_bytes.len)));
                    try auths.appendSlice(len_bytes);
                }
                try auths.appendSlice(fields.items);
            }

            if (auths.items.len <= 55) {
                try list.append(@as(u8, @intCast(0xc0 + auths.items.len)));
            } else {
                const len_bytes = try rlp.encodeLength(allocator, auths.items.len);
                defer allocator.free(len_bytes);
                try list.append(@as(u8, @intCast(0xf7 + len_bytes.len)));
                try list.appendSlice(len_bytes);
            }
            try list.appendSlice(auths.items);
        }

        // Optional signature: y_parity, r, s if present (typed txs use y_parity)
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

        // Compute final size: 1-byte type + RLP(list ...)
        const list_len = list.items.len;
        const header_len: usize = if (list_len <= 55) 1 else blk: {
            // number of bytes required to encode list_len
            var tmp = list_len;
            var n: usize = 0;
            while (tmp > 0) : (tmp >>= 8) n += 1;
            break :blk 1 + n; // 0xf7 + len_of_len + len_bytes
        };
        len = 1 + header_len + list_len;
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

/// Enforce EIP-4844-specific fee admission rules.
///
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
    if (!cfg.min_blob_tx_priority_fee.eq(U256.ZERO)) {
        // Convert native u256 tip into Voltaire U256 for comparison.
        const tx_tip_wei: U256 = U256.from_u256(tx.max_priority_fee_per_gas);
        if (tx_tip_wei.cmp(cfg.min_blob_tx_priority_fee) == .lt) {
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
    cfg.min_blob_tx_priority_fee = MaxPriorityFeePerGas.from(3).toWei();

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
