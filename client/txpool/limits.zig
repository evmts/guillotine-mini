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

        // authorization_list
        {
            const enc = try primitives.Authorization.encodeAuthorizationList(allocator, tx.authorization_list);
            defer allocator.free(enc);
            try list.appendSlice(enc);
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
        .v = 0,
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
        .v = 27, // vendor currently models v for 7702
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
