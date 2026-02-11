const std = @import("std");
const primitives = @import("primitives");
// Import HostInterface from the core guillotine module exposed in build.zig
const HostInterface = @import("guillotine").HostInterface;

const tx_mod = primitives.Transaction;
const TxPoolConfig = @import("pool.zig").TxPoolConfig;
const TxPool = @import("pool.zig").TxPool;
const U256 = primitives.Denomination.U256;
const GasLimit = primitives.Gas.GasLimit;
const Address = primitives.Address;
// -----------------------------------------------------------------------------
// Internal helpers (no allocations)
// -----------------------------------------------------------------------------
/// Return true when a typed transaction contains a signature (y_parity,r,s).
inline fn has_signature(y_parity: anytype, r: [32]u8, s: [32]u8) bool {
    comptime {
        if (!(@typeInfo(@TypeOf(y_parity)) == .int and @typeInfo(@TypeOf(y_parity)).int.signedness == .unsigned))
            @compileError("has_signature expects an unsigned integer y_parity");
    }
    const zeros = [_]u8{0} ** 32;
    return !(y_parity == 0 and std.mem.eql(u8, &r, &zeros) and std.mem.eql(u8, &s, &zeros));
}

/// Compute RLP-encoded length of an AccessList without allocations.
inline fn rlpLenOfAccessList(list: []const tx_mod.AccessListItem) usize {
    var items_total: usize = 0;
    for (list) |it| {
        // AccessListItem = [ address: B_20, storage_keys: [B_32, ...] ]
        const addr_len = rlpLenOfBytes(20, null);

        var keys_items_total: usize = 0;
        for (it.storage_keys) |_| {
            keys_items_total += rlpLenOfBytes(32, null);
        }
        const keys_list_len = rlpLenOfList(keys_items_total);

        const item_payload = addr_len + keys_list_len;
        items_total += rlpLenOfList(item_payload);
    }
    return rlpLenOfList(items_total);
}

// -----------------------------------------------------------------------------
// Public helpers (no allocations)
// -----------------------------------------------------------------------------
/// Compute the furthest in-order nonce the pool should accept without a gap
/// given the current account nonce and the number of already-pending
/// transactions from the same sender.
///
/// Mirrors Nethermind's GapNonceFilter notion of
///   next_nonce_in_order = current_nonce + pending_sender_txs
///
/// Saturates on u64 overflow (returns `maxInt(u64)`). No allocations.
pub fn next_nonce_in_order(current_nonce: u64, pending_sender_txs: u32) u64 {
    const sum128: u128 = @as(u128, current_nonce) + @as(u128, pending_sender_txs);
    const max = std.math.maxInt(u64);
    return if (sum128 > max) max else @intCast(sum128);
}

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
    pending_sender_txs: u32,
) error{NonceGap}!void {
    // If tx is not ahead of current nonce, gap filter is satisfied.
    if (tx_nonce <= current_nonce) return;

    // Compute forward distance using subtraction to avoid overflow.
    const forward: u64 = tx_nonce - current_nonce;

    // Accept if tx is within the allowed window: distance ≤ pending count.
    if (forward <= @as(u64, @intCast(pending_sender_txs))) return;

    return error.NonceGap;
}

/// Check a transaction's nonce against the sender's current account nonce
/// and the number of already-pending transactions from that sender present
/// in the txpool. Rejects with `error.NonceGap` if the submitted nonce is
/// beyond the allowed in-order window.
///
/// Mirrors Nethermind's `GapNonceFilter` using the local vtable-based
/// `TxPool` + `HostInterface` dependencies.
pub fn check_nonce_gap_for_sender(
    pool: TxPool,
    host: HostInterface,
    sender: Address,
    tx_nonce: u64,
) error{NonceGap}!void {
    const current_nonce: u64 = host.getNonce(sender);
    const pending: u32 = pool.get_pending_count_for_sender(sender);
    return enforce_nonce_gap(tx_nonce, current_nonce, pending);
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

test "next_nonce_in_order — computes upper bound without overflow" {
    try std.testing.expectEqual(@as(u64, 13), next_nonce_in_order(10, 3));
    try std.testing.expectEqual(@as(u64, 10), next_nonce_in_order(10, 0));
}

test "next_nonce_in_order — saturates on u64 overflow" {
    const near_max: u64 = std.math.maxInt(u64) - 1;
    try std.testing.expectEqual(std.math.maxInt(u64), next_nonce_in_order(near_max, 3));
}

test "check_nonce_gap_for_sender — accepts when nonce <= current and within window" {
    const DummyPool = struct {
        count_for: u32,
        fn pending_count(_: *anyopaque) u32 {
            return 0;
        }
        fn pending_blob_count(_: *anyopaque) u32 {
            return 0;
        }
        fn get_pending_count_for_sender(ptr: *anyopaque, _: Address) u32 {
            const self: *const @This() = @ptrCast(@alignCast(ptr));
            return self.count_for;
        }
    };

    const DummyHost = struct {
        nonce: u64,
        fn getBalance(_: *anyopaque, _: Address) u256 {
            return 0;
        }
        fn setBalance(_: *anyopaque, _: Address, _: u256) void {}
        fn getCode(_: *anyopaque, _: Address) []const u8 {
            return &[_]u8{};
        }
        fn setCode(_: *anyopaque, _: Address, _: []const u8) void {}
        fn getStorage(_: *anyopaque, _: Address, _: u256) u256 {
            return 0;
        }
        fn setStorage(_: *anyopaque, _: Address, _: u256, _: u256) void {}
        fn getNonce(ptr: *anyopaque, _: Address) u64 {
            const self: *const @This() = @ptrCast(@alignCast(ptr));
            return self.nonce;
        }
        fn setNonce(_: *anyopaque, _: Address, _: u64) void {}
    };

    var pool_impl = DummyPool{ .count_for = 3 };
    const pool_vt = TxPool.VTable{
        .pending_count = DummyPool.pending_count,
        .pending_blob_count = DummyPool.pending_blob_count,
        .get_pending_count_for_sender = DummyPool.get_pending_count_for_sender,
    };
    const pool = TxPool{ .ptr = &pool_impl, .vtable = &pool_vt };

    var host_impl = DummyHost{ .nonce = 10 };
    const host_vt = HostInterface.VTable{
        .getBalance = DummyHost.getBalance,
        .setBalance = DummyHost.setBalance,
        .getCode = DummyHost.getCode,
        .setCode = DummyHost.setCode,
        .getStorage = DummyHost.getStorage,
        .setStorage = DummyHost.setStorage,
        .getNonce = DummyHost.getNonce,
        .setNonce = DummyHost.setNonce,
    };
    const host = HostInterface{ .ptr = &host_impl, .vtable = &host_vt };

    const sender = Address{ .bytes = [_]u8{0x01} ++ [_]u8{0} ** 19 };

    // tx_nonce <= current (10) → accept
    try check_nonce_gap_for_sender(pool, host, sender, 9);
    try check_nonce_gap_for_sender(pool, host, sender, 10);

    // Within pending window: current=10, pending=3 → up to 13 inclusive
    try check_nonce_gap_for_sender(pool, host, sender, 11);
    try check_nonce_gap_for_sender(pool, host, sender, 13);
}

test "check_nonce_gap_for_sender — rejects when beyond window and handles near-overflow" {
    const DummyPool = struct {
        count_for: u32,
        fn pending_count(_: *anyopaque) u32 {
            return 0;
        }
        fn pending_blob_count(_: *anyopaque) u32 {
            return 0;
        }
        fn get_pending_count_for_sender(ptr: *anyopaque, _: Address) u32 {
            const self: *const @This() = @ptrCast(@alignCast(ptr));
            return self.count_for;
        }
    };

    const DummyHost = struct {
        nonce: u64,
        fn getBalance(_: *anyopaque, _: Address) u256 {
            return 0;
        }
        fn setBalance(_: *anyopaque, _: Address, _: u256) void {}
        fn getCode(_: *anyopaque, _: Address) []const u8 {
            return &[_]u8{};
        }
        fn setCode(_: *anyopaque, _: Address, _: []const u8) void {}
        fn getStorage(_: *anyopaque, _: Address, _: u256) u256 {
            return 0;
        }
        fn setStorage(_: *anyopaque, _: Address, _: u256, _: u256) void {}
        fn getNonce(ptr: *anyopaque, _: Address) u64 {
            const self: *const @This() = @ptrCast(@alignCast(ptr));
            return self.nonce;
        }
        fn setNonce(_: *anyopaque, _: Address, _: u64) void {}
    };

    // Case 1: simple rejection (beyond window)
    var pool_impl = DummyPool{ .count_for = 3 };
    const pool_vt = TxPool.VTable{
        .pending_count = DummyPool.pending_count,
        .pending_blob_count = DummyPool.pending_blob_count,
        .get_pending_count_for_sender = DummyPool.get_pending_count_for_sender,
    };
    const pool = TxPool{ .ptr = &pool_impl, .vtable = &pool_vt };

    var host_impl = DummyHost{ .nonce = 10 };
    const host_vt = HostInterface.VTable{
        .getBalance = DummyHost.getBalance,
        .setBalance = DummyHost.setBalance,
        .getCode = DummyHost.getCode,
        .setCode = DummyHost.setCode,
        .getStorage = DummyHost.getStorage,
        .setStorage = DummyHost.setStorage,
        .getNonce = DummyHost.getNonce,
        .setNonce = DummyHost.setNonce,
    };
    const host = HostInterface{ .ptr = &host_impl, .vtable = &host_vt };

    const sender = Address{ .bytes = [_]u8{0x02} ++ [_]u8{0} ** 19 };
    try std.testing.expectError(error.NonceGap, check_nonce_gap_for_sender(pool, host, sender, 14));

    // Case 2: near-overflow safety — current near max, small pending count
    host_impl.nonce = std.math.maxInt(u64) - 1;
    pool_impl.count_for = 1;
    // tx_nonce = maxInt(u64) → within window (distance=1 <= pending=1)
    try check_nonce_gap_for_sender(pool, host, sender, std.math.maxInt(u64));
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

    // This function computes lengths without allocating; keep allocator in the
    // signature for API stability and future-proofing, but mark it used.
    _ = allocator;

    // Use caller-provided allocator to avoid page allocator churn on hot path

    var len: usize = 0;
    if (comptime T == tx_mod.LegacyTransaction) {
        // Allocation-free, wire-accurate legacy RLP sizing (always includes v,r,s)
        var payload_len: usize = 0;
        payload_len += rlpLenOfUInt(tx.nonce);
        payload_len += rlpLenOfUInt(tx.gas_price);
        payload_len += rlpLenOfUInt(tx.gas_limit);
        if (tx.to) |_| {
            payload_len += rlpLenOfBytes(20, null);
        } else {
            payload_len += rlpLenOfBytes(0, null);
        }
        payload_len += rlpLenOfUInt(tx.value);
        const first_legacy: ?u8 = if (tx.data.len == 1) tx.data[0] else null;
        payload_len += rlpLenOfBytes(tx.data.len, first_legacy);
        // Signature fields are part of the on-wire encoding
        payload_len += rlpLenOfUInt(tx.v);
        payload_len += rlpLenOfBytes(32, null); // r (encoded as bytes in primitives)
        payload_len += rlpLenOfBytes(32, null); // s (encoded as bytes in primitives)
        len = rlpLenOfList(payload_len);
    } else if (comptime T == tx_mod.Eip1559Transaction) {
        // Allocation-free, wire-accurate typed-2 sizing (always includes y_parity,r,s)
        var payload_len: usize = 0;
        payload_len += rlpLenOfUInt(tx.chain_id);
        payload_len += rlpLenOfUInt(tx.nonce);
        payload_len += rlpLenOfUInt(tx.max_priority_fee_per_gas);
        payload_len += rlpLenOfUInt(tx.max_fee_per_gas);
        payload_len += rlpLenOfUInt(tx.gas_limit);
        if (tx.to) |_| {
            payload_len += rlpLenOfBytes(20, null);
        } else {
            payload_len += rlpLenOfBytes(0, null);
        }
        payload_len += rlpLenOfUInt(tx.value);
        const first1559: ?u8 = if (tx.data.len == 1) tx.data[0] else null;
        payload_len += rlpLenOfBytes(tx.data.len, first1559);
        payload_len += rlpLenOfAccessList(tx.access_list);
        // Always account for signature triplet for on-wire size
        payload_len += rlpLenOfUInt(tx.y_parity);
        payload_len += rlpLenOfBytes(32, null); // r (encoded as bytes in primitives)
        payload_len += rlpLenOfBytes(32, null); // s (encoded as bytes in primitives)
        len = 1 + rlpLenOfList(payload_len);
    } else if (comptime T == tx_mod.Eip2930Transaction) {
        // Allocation-free length calculation for EIP-2930 typed transaction (0x01)
        var payload_len: usize = 0;
        payload_len += rlpLenOfUInt(tx.chain_id);
        payload_len += rlpLenOfUInt(tx.nonce);
        payload_len += rlpLenOfUInt(tx.gas_price);
        payload_len += rlpLenOfUInt(tx.gas_limit);

        // to (nullable)
        if (tx.to) |_| {
            payload_len += rlpLenOfBytes(20, null);
        } else {
            payload_len += rlpLenOfBytes(0, null);
        }

        payload_len += rlpLenOfUInt(tx.value);
        const first2930: ?u8 = if (tx.data.len == 1) tx.data[0] else null;
        payload_len += rlpLenOfBytes(tx.data.len, first2930);

        // access_list
        payload_len += rlpLenOfAccessList(tx.access_list);

        // Optional signature: y_parity, r, s
        if (has_signature(tx.y_parity, tx.r, tx.s)) {
            payload_len += rlpLenOfUInt(tx.y_parity);
            payload_len += rlpLenOfBytes(32, null);
            payload_len += rlpLenOfBytes(32, null);
        }

        // Typed envelope size = 1 (type) + rlp(list(payload))
        len = 1 + rlpLenOfList(payload_len);
    } else if (comptime T == tx_mod.Eip4844Transaction) {
        // Length-only sizing for EIP-4844 to minimize allocations.
        var payload_len: usize = 0;
        payload_len += rlpLenOfUInt(tx.chain_id);
        payload_len += rlpLenOfUInt(tx.nonce);
        payload_len += rlpLenOfUInt(tx.max_priority_fee_per_gas);
        payload_len += rlpLenOfUInt(tx.max_fee_per_gas);
        payload_len += rlpLenOfUInt(tx.gas_limit);
        // to (required by EIP-4844; MUST NOT be nil per EIP-4844)
        payload_len += rlpLenOfBytes(20, null);
        // value
        payload_len += rlpLenOfUInt(tx.value);
        // data
        const first: ?u8 = if (tx.data.len == 1) tx.data[0] else null;
        payload_len += rlpLenOfBytes(tx.data.len, first);
        // access_list (length-only)
        payload_len += rlpLenOfAccessList(tx.access_list);
        // max_fee_per_blob_gas
        payload_len += rlpLenOfUInt(tx.max_fee_per_blob_gas);
        // blob_versioned_hashes: each hash is 32 bytes → RLP item length fixed
        const per_hash_len: usize = rlpLenOfBytes(32, null);
        const hashes_items_len: usize = tx.blob_versioned_hashes.len * per_hash_len;
        payload_len += rlpLenOfList(hashes_items_len);

        // Optional signature: y_parity, r, s
        if (has_signature(tx.y_parity, tx.r, tx.s)) {
            payload_len += rlpLenOfUInt(tx.y_parity);
            payload_len += rlpLenOfBytes(32, null);
            payload_len += rlpLenOfBytes(32, null);
        }

        // Type prefix (0x03) + RLP(list header+payload). Blobs are NOT included.
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

        // access_list (length-only)
        payload_len += rlpLenOfAccessList(tx.access_list);

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
        if (has_signature(tx.y_parity, tx.r, tx.s)) {
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

test "fits_size_limits — legacy within and over limit (wire size incl. v,r,s)" {
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

    // Compute expected wire size manually: full signed legacy tx RLP
    const allocator = std.testing.allocator;
    const rlp = primitives.Rlp;
    var list = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer list.deinit();
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
    {
        const enc = try rlp.encodeBytes(allocator, &tx.to.?.bytes);
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
        const enc = try rlp.encode(allocator, tx.v);
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
    const encoded = wrapped.items;

    var cfg_ok = TxPoolConfig{}; // defaults allow ample size
    cfg_ok.max_tx_size = encoded.len; // exactly fits
    try fits_size_limits(std.testing.allocator, tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_tx_size = encoded.len - 1; // too small
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(std.testing.allocator, tx, cfg_bad));
}

test "fits_size_limits — eip1559 within and over limit (wire size incl. y_parity,r,s)" {
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
    // Build full typed-2 bytes manually to assert true wire size
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
        const enc = try rlp.encodeBytes(allocator, &tx.to.?.bytes);
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
    encoded[0] = 0x02;
    @memcpy(encoded[1..], wrapped.items);
    defer allocator.free(encoded);

    var cfg_ok = TxPoolConfig{};
    cfg_ok.max_tx_size = encoded.len;
    try fits_size_limits(std.testing.allocator, tx, cfg_ok);

    var cfg_bad = TxPoolConfig{};
    cfg_bad.max_tx_size = encoded.len - 1;
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(std.testing.allocator, tx, cfg_bad));
}

test "fits_size_limits — eip4844 (blob) within and over blob limit" {
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

test "fits_size_limits — eip2930 within and over limit (with/without signature)" {
    const rlp = primitives.Rlp;

    // Case A: with recipient and signature
    var tx_signed = tx_mod.Eip2930Transaction{
        .chain_id = 1,
        .nonce = 7,
        .gas_price = 3,
        .gas_limit = 25_000,
        .to = Address{ .bytes = [_]u8{0x66} ++ [_]u8{0} ** 19 },
        .value = 0,
        .data = &[_]u8{ 0x01, 0x02, 0x03 },
        .access_list = &[_]tx_mod.AccessListItem{},
        .y_parity = 1,
        .r = [_]u8{9} ** 32,
        .s = [_]u8{7} ** 32,
    };

    const allocator = std.testing.allocator;
    // Manually encode typed-1 payload for expected length
    var list = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer list.deinit();
    {
        const enc = try rlp.encode(allocator, tx_signed.chain_id);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx_signed.nonce);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx_signed.gas_price);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx_signed.gas_limit);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, &@as(Address, tx_signed.to.?).bytes);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx_signed.value);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, tx_signed.data);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try tx_mod.encodeAccessList(allocator, tx_signed.access_list);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx_signed.y_parity);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, &tx_signed.r);
        defer allocator.free(enc);
        try list.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, &tx_signed.s);
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
    const encoded_signed = try allocator.alloc(u8, 1 + wrapped.items.len);
    defer allocator.free(encoded_signed);
    encoded_signed[0] = 0x01;
    @memcpy(encoded_signed[1..], wrapped.items);

    var cfg = TxPoolConfig{};
    cfg.max_tx_size = encoded_signed.len;
    try fits_size_limits(allocator, tx_signed, cfg);
    cfg.max_tx_size = encoded_signed.len - 1;
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(allocator, tx_signed, cfg));

    // Case B: to = null, no signature
    var tx_unsigned = tx_signed;
    tx_unsigned.to = null;
    tx_unsigned.y_parity = 0;
    tx_unsigned.r = [_]u8{0} ** 32;
    tx_unsigned.s = [_]u8{0} ** 32;

    var list2 = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer list2.deinit();
    {
        const enc = try rlp.encode(allocator, tx_unsigned.chain_id);
        defer allocator.free(enc);
        try list2.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx_unsigned.nonce);
        defer allocator.free(enc);
        try list2.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx_unsigned.gas_price);
        defer allocator.free(enc);
        try list2.appendSlice(enc);
    }
    {
        const enc = try rlp.encode(allocator, tx_unsigned.gas_limit);
        defer allocator.free(enc);
        try list2.appendSlice(enc);
    }
    // to = null → empty RLP string
    try list2.append(0x80);
    {
        const enc = try rlp.encode(allocator, tx_unsigned.value);
        defer allocator.free(enc);
        try list2.appendSlice(enc);
    }
    {
        const enc = try rlp.encodeBytes(allocator, tx_unsigned.data);
        defer allocator.free(enc);
        try list2.appendSlice(enc);
    }
    {
        const enc = try tx_mod.encodeAccessList(allocator, tx_unsigned.access_list);
        defer allocator.free(enc);
        try list2.appendSlice(enc);
    }
    var wrapped2 = std.array_list.AlignedManaged(u8, null).init(allocator);
    defer wrapped2.deinit();
    if (list2.items.len <= 55) {
        try wrapped2.append(@as(u8, @intCast(0xc0 + list2.items.len)));
    } else {
        const len_bytes = try rlp.encodeLength(allocator, list2.items.len);
        defer allocator.free(len_bytes);
        try wrapped2.append(@as(u8, @intCast(0xf7 + len_bytes.len)));
        try wrapped2.appendSlice(len_bytes);
    }
    try wrapped2.appendSlice(list2.items);
    const encoded_unsigned = try allocator.alloc(u8, 1 + wrapped2.items.len);
    defer allocator.free(encoded_unsigned);
    encoded_unsigned[0] = 0x01;
    @memcpy(encoded_unsigned[1..], wrapped2.items);

    cfg.max_tx_size = encoded_unsigned.len;
    try fits_size_limits(allocator, tx_unsigned, cfg);
    cfg.max_tx_size = encoded_unsigned.len - 1;
    try std.testing.expectError(error.MaxTxSizeExceeded, fits_size_limits(allocator, tx_unsigned, cfg));
}

test "fits_gas_limit — passes when under/equal, errors when over (legacy)" {
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
