/// Storage Injector with LRU Cache for Async State Interface
/// Phase 2: Storage Injector with LRU Cache
const std = @import("std");
const primitives = @import("voltaire");
const Address = primitives.Address.Address;

/// Simple LRU cache.
///
/// When `V` is `[]const u8` the cache owns its values: `put` copies the slice
/// with the cache allocator and the copy is freed on replacement, eviction,
/// `clear` and `deinit`. A slice returned by `get` is borrowed and stays valid
/// only until the next mutation of the cache.
pub fn LruCache(comptime K: type, comptime V: type, comptime capacity: usize) type {
    return struct {
        const Self = @This();

        /// True when values are heap copies owned by this cache.
        pub const owns_values = V == []const u8;

        const Node = struct {
            key: K,
            value: V,
            prev: ?*Node,
            next: ?*Node,
        };

        map: std.AutoHashMap(K, *Node),
        head: ?*Node,
        tail: ?*Node,
        allocator: std.mem.Allocator,
        size: usize,

        // Statistics
        hits: u64,
        misses: u64,

        pub fn init(allocator: std.mem.Allocator) !Self {
            return Self{
                .map = std.AutoHashMap(K, *Node).init(allocator),
                .head = null,
                .tail = null,
                .allocator = allocator,
                .size = 0,
                .hits = 0,
                .misses = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.destroyNodes();
            self.map.deinit();
        }

        pub fn get(self: *Self, key: K) ?V {
            if (self.map.get(key)) |node| {
                self.hits += 1;
                self.moveToFront(node);
                return node.value;
            }
            self.misses += 1;
            return null;
        }

        /// Insert or replace a value. On error the cache is unchanged.
        pub fn put(self: *Self, key: K, value: V) !void {
            const stored: V = if (owns_values) try self.allocator.dupe(u8, value) else value;
            errdefer self.freeValue(stored);

            // Update existing entry
            if (self.map.get(key)) |node| {
                self.freeValue(node.value);
                node.value = stored;
                self.moveToFront(node);
                return;
            }

            // Acquire every resource before touching the list or evicting, so a
            // failed insertion cannot leave the map, list and size out of sync.
            try self.map.ensureUnusedCapacity(1);
            const node = try self.allocator.create(Node);

            if (self.size >= capacity) self.evictLru();

            node.* = .{
                .key = key,
                .value = stored,
                .prev = null,
                .next = self.head,
            };
            if (self.head) |h| h.prev = node;
            self.head = node;
            if (self.tail == null) self.tail = node;

            self.map.putAssumeCapacity(key, node);
            self.size += 1;
        }

        pub fn clear(self: *Self) void {
            self.destroyNodes();
            self.map.clearRetainingCapacity();
            self.head = null;
            self.tail = null;
            self.size = 0;
        }

        fn freeValue(self: *Self, value: V) void {
            if (owns_values) self.allocator.free(value);
        }

        fn destroyNodes(self: *Self) void {
            var current = self.head;
            while (current) |node| {
                const next = node.next;
                self.freeValue(node.value);
                self.allocator.destroy(node);
                current = next;
            }
        }

        fn moveToFront(self: *Self, node: *Node) void {
            if (node == self.head) return; // Already at front

            // Remove from current position
            if (node.prev) |p| {
                p.next = node.next;
            }

            if (node.next) |n| {
                n.prev = node.prev;
            } else {
                // This was the tail
                self.tail = node.prev;
            }

            // Move to front
            node.prev = null;
            node.next = self.head;

            if (self.head) |h| {
                h.prev = node;
            }

            self.head = node;
        }

        fn evictLru(self: *Self) void {
            const node = self.tail orelse return;
            _ = self.map.remove(node.key);

            if (node.prev) |p| {
                p.next = null;
                self.tail = p;
            } else {
                // This was the only node
                self.head = null;
                self.tail = null;
            }

            self.freeValue(node.value);
            self.allocator.destroy(node);
            self.size -= 1;
        }
    };
}

// Import StorageKey from evm.zig to avoid duplication
const evm_module = @import("evm.zig");
const StorageKey = evm_module.StorageKey;

/// Writer that discards its input and counts the bytes. Sizes a buffer for
/// `StorageInjector.writeChanges` without allocating.
pub const CountingWriter = struct {
    bytes_written: usize = 0,

    pub const Writer = std.io.GenericWriter(*CountingWriter, error{}, write);

    pub fn writer(self: *CountingWriter) Writer {
        return .{ .context = self };
    }

    fn write(self: *CountingWriter, bytes: []const u8) error{}!usize {
        self.bytes_written += bytes.len;
        return bytes.len;
    }
};

/// Writer into a caller-owned buffer. Never allocates; a write that does not
/// fit fails with `error.NoSpaceLeft` and leaves `len` unchanged.
pub const FixedWriter = struct {
    buffer: []u8,
    len: usize = 0,

    pub const Error = error{NoSpaceLeft};
    pub const Writer = std.io.GenericWriter(*FixedWriter, Error, write);

    pub fn writer(self: *FixedWriter) Writer {
        return .{ .context = self };
    }

    pub fn written(self: *const FixedWriter) []u8 {
        return self.buffer[0..self.len];
    }

    fn write(self: *FixedWriter, bytes: []const u8) Error!usize {
        if (bytes.len > self.buffer.len - self.len) return error.NoSpaceLeft;
        @memcpy(self.buffer[self.len..][0..bytes.len], bytes);
        self.len += bytes.len;
        return bytes.len;
    }
};

fn writeAddressHex(writer: anytype, bytes: []const u8) !void {
    for (bytes) |byte| {
        try std.fmt.format(writer, "{x:0>2}", .{byte});
    }
}

/// Storage Injector - manages LRU cache and dirty tracking for async storage
///
/// Ownership: every allocation (cache nodes, cached code copies, dirty sets,
/// baselines) uses `allocator`, and `deinit` frees only what the injector
/// allocated itself. Callers never hand over ownership of a code slice.
pub const StorageInjector = struct {
    allocator: std.mem.Allocator,

    // LRU cache (check before sending message).
    //
    // `storage_cache` holds only values the host holds: slots it supplied and
    // slots written by transactions that succeeded. A write in flight lives in
    // the EVM's storage overlay and `dirty_storage` and never reaches the
    // cache, so a reverted, halted or cancelled transaction leaves every
    // fetched original intact for the next transaction.
    storage_cache: LruCache(StorageKey, u256, 1024),
    balance_cache: LruCache(Address, u256, 256),
    code_cache: LruCache(Address, []const u8, 128),
    nonce_cache: LruCache(Address, u64, 256),

    // Dirty tracking (for change dump)
    dirty_storage: std.AutoHashMap(StorageKey, void),
    dirty_balances: std.AutoHashMap(Address, void),
    dirty_nonces: std.AutoHashMap(Address, void),
    dirty_codes: std.AutoHashMap(Address, void),

    // Account state the host already holds, captured at transaction start and
    // extended by continuation replies. dumpChanges() diffs the EVM account
    // maps against it, so balance/nonce/code mutations are reported even when
    // the mutating code path never called a mark*Dirty function.
    baseline_active: bool = false,
    baseline_balances: std.AutoHashMap(Address, u256),
    baseline_nonces: std.AutoHashMap(Address, u64),
    /// Address -> content hash of the code the host holds.
    baseline_codes: std.AutoHashMap(Address, u64),

    pub fn init(allocator: std.mem.Allocator) !StorageInjector {
        return StorageInjector{
            .allocator = allocator,
            .storage_cache = try LruCache(StorageKey, u256, 1024).init(allocator),
            .balance_cache = try LruCache(Address, u256, 256).init(allocator),
            .code_cache = try LruCache(Address, []const u8, 128).init(allocator),
            .nonce_cache = try LruCache(Address, u64, 256).init(allocator),
            .dirty_storage = std.AutoHashMap(StorageKey, void).init(allocator),
            .dirty_balances = std.AutoHashMap(Address, void).init(allocator),
            .dirty_nonces = std.AutoHashMap(Address, void).init(allocator),
            .dirty_codes = std.AutoHashMap(Address, void).init(allocator),
            .baseline_balances = std.AutoHashMap(Address, u256).init(allocator),
            .baseline_nonces = std.AutoHashMap(Address, u64).init(allocator),
            .baseline_codes = std.AutoHashMap(Address, u64).init(allocator),
        };
    }

    pub fn deinit(self: *StorageInjector) void {
        // code_cache owns its slices and frees them with the same allocator
        // that copied them.
        self.storage_cache.deinit();
        self.balance_cache.deinit();
        self.code_cache.deinit();
        self.nonce_cache.deinit();
        self.dirty_storage.deinit();
        self.dirty_balances.deinit();
        self.dirty_nonces.deinit();
        self.dirty_codes.deinit();
        self.baseline_balances.deinit();
        self.baseline_nonces.deinit();
        self.baseline_codes.deinit();
    }

    /// Mark a storage slot as written by the transaction in flight (called by
    /// `Storage.set`). The written value stays in the EVM's storage overlay.
    pub fn markStorageDirty(self: *StorageInjector, address: Address, slot: u256) !void {
        const key = StorageKey{ .address = address.bytes, .slot = slot };
        try self.dirty_storage.put(key, {});
    }

    /// Fold one committed storage write into the fetch cache, so a later
    /// transaction that reads the cache sees the value the host now holds.
    /// Called only when a transaction succeeds (`Storage.commitInjectorWrites`).
    ///
    /// Never fails: a cached slot is updated in place without allocating. A
    /// slot that is not cached and cannot be inserted stays uncached, which is
    /// safe because an uncached slot is fetched from the host again.
    pub fn commitStorageWrite(self: *StorageInjector, key: StorageKey, value: u256) void {
        self.storage_cache.put(key, value) catch return;
    }

    /// Mark balance as dirty
    pub fn markBalanceDirty(self: *StorageInjector, address: Address) !void {
        try self.dirty_balances.put(address, {});
    }

    /// Mark nonce as dirty
    pub fn markNonceDirty(self: *StorageInjector, address: Address) !void {
        try self.dirty_nonces.put(address, {});
    }

    /// Mark code as dirty
    pub fn markCodeDirty(self: *StorageInjector, address: Address) !void {
        try self.dirty_codes.put(address, {});
    }

    /// Forget every pending change without touching fetched values. Used when a
    /// transaction reverts or halts so nothing is offered for commit.
    pub fn clearDirty(self: *StorageInjector) void {
        self.dirty_storage.clearRetainingCapacity();
        self.dirty_balances.clearRetainingCapacity();
        self.dirty_nonces.clearRetainingCapacity();
        self.dirty_codes.clearRetainingCapacity();
    }

    /// Clear cache and dirty sets (called at start of new transaction)
    pub fn clearCache(self: *StorageInjector) void {
        self.storage_cache.clear();
        self.balance_cache.clear();
        self.code_cache.clear();
        self.nonce_cache.clear();
        self.clearDirty();
        self.baseline_active = false;
        self.baseline_balances.clearRetainingCapacity();
        self.baseline_nonces.clearRetainingCapacity();
        self.baseline_codes.clearRetainingCapacity();
    }

    // Cache read methods
    pub fn getStorageFromCache(self: *StorageInjector, address: Address, slot: u256) ?u256 {
        const key = StorageKey{ .address = address.bytes, .slot = slot };
        return self.storage_cache.get(key);
    }

    pub fn getBalanceFromCache(self: *StorageInjector, address: Address) ?u256 {
        return self.balance_cache.get(address);
    }

    /// Borrowed slice; valid until the code cache is next modified.
    pub fn getCodeFromCache(self: *StorageInjector, address: Address) ?[]const u8 {
        return self.code_cache.get(address);
    }

    pub fn getNonceFromCache(self: *StorageInjector, address: Address) ?u64 {
        return self.nonce_cache.get(address);
    }

    // Cache write methods
    pub fn cacheStorage(self: *StorageInjector, address: Address, slot: u256, value: u256) !void {
        const key = StorageKey{ .address = address.bytes, .slot = slot };
        try self.storage_cache.put(key, value);
    }

    pub fn cacheBalance(self: *StorageInjector, address: Address, balance: u256) !void {
        try self.balance_cache.put(address, balance);
    }

    /// Cache account code. The cache stores its own copy; `code` stays owned by
    /// the caller and may come from any allocator.
    pub fn cacheCode(self: *StorageInjector, address: Address, code: []const u8) !void {
        try self.code_cache.put(address, code);
    }

    pub fn cacheNonce(self: *StorageInjector, address: Address, nonce: u64) !void {
        try self.nonce_cache.put(address, nonce);
    }

    // ---- Account baseline (what the host already holds) ----

    fn codeHash(code: []const u8) u64 {
        return std.hash.Wyhash.hash(code.len, code);
    }

    /// Record the account state present before execution so dumpChanges() can
    /// report exactly the balances, nonces and code the transaction changed.
    /// Call once per transaction, after the EVM account maps are initialized.
    pub fn captureBaseline(self: *StorageInjector, evm: anytype) !void {
        self.baseline_balances.clearRetainingCapacity();
        self.baseline_nonces.clearRetainingCapacity();
        self.baseline_codes.clearRetainingCapacity();

        var balance_it = evm.balances.iterator();
        while (balance_it.next()) |entry| try self.baseline_balances.put(entry.key_ptr.*, entry.value_ptr.*);
        var nonce_it = evm.nonces.iterator();
        while (nonce_it.next()) |entry| try self.baseline_nonces.put(entry.key_ptr.*, entry.value_ptr.*);
        var code_it = evm.code.iterator();
        while (code_it.next()) |entry| try self.baseline_codes.put(entry.key_ptr.*, codeHash(entry.value_ptr.*));

        self.baseline_active = true;
    }

    /// Record a host-supplied balance (continuation reply) as already committed.
    pub fn noteBaselineBalance(self: *StorageInjector, address: Address, balance: u256) !void {
        try self.baseline_balances.put(address, balance);
    }

    /// Record a host-supplied nonce (continuation reply) as already committed.
    pub fn noteBaselineNonce(self: *StorageInjector, address: Address, nonce: u64) !void {
        try self.baseline_nonces.put(address, nonce);
    }

    /// Record host-supplied code (continuation reply) as already committed.
    pub fn noteBaselineCode(self: *StorageInjector, address: Address, code: []const u8) !void {
        try self.baseline_codes.put(address, codeHash(code));
    }

    /// True when the account is scheduled for deletion at the end of the
    /// transaction. Such accounts are reported once, through "selfDestructs".
    fn isSelfDestructed(evm: anytype, address: Address) bool {
        const Info = @typeInfo(@TypeOf(evm));
        const EvmType = if (Info == .pointer) @TypeOf(evm.*) else @TypeOf(evm);
        if (!@hasField(EvmType, "selfdestructed_accounts")) return false;
        return evm.selfdestructed_accounts.contains(address);
    }

    /// Mark every account whose balance, nonce or code differs from the
    /// baseline. A missing entry, in the baseline or in the live maps, means
    /// zero balance, zero nonce and empty code, so a value cleared to zero or
    /// empty is reported too. Accounts scheduled for deletion are left to
    /// "selfDestructs".
    ///
    /// End-of-transaction deletions do not change the result: an account deleted
    /// as touched-and-empty already differs from (or equals) its baseline in the
    /// same way before the deletion. A caller can therefore mark before applying
    /// them and serialize afterwards with `writeChanges`, which never allocates.
    pub fn markChangedAccounts(self: *StorageInjector, evm: anytype) !void {
        if (!self.baseline_active) return;

        var balance_it = evm.balances.iterator();
        while (balance_it.next()) |entry| {
            if (isSelfDestructed(evm, entry.key_ptr.*)) continue;
            const before = self.baseline_balances.get(entry.key_ptr.*) orelse 0;
            if (before != entry.value_ptr.*) try self.markBalanceDirty(entry.key_ptr.*);
        }

        var nonce_it = evm.nonces.iterator();
        while (nonce_it.next()) |entry| {
            if (isSelfDestructed(evm, entry.key_ptr.*)) continue;
            const before = self.baseline_nonces.get(entry.key_ptr.*) orelse 0;
            if (before != entry.value_ptr.*) try self.markNonceDirty(entry.key_ptr.*);
        }

        var code_it = evm.code.iterator();
        while (code_it.next()) |entry| {
            if (isSelfDestructed(evm, entry.key_ptr.*)) continue;
            const code = entry.value_ptr.*;
            const changed = if (self.baseline_codes.get(entry.key_ptr.*)) |before|
                before != codeHash(code)
            else
                code.len != 0;
            if (changed) try self.markCodeDirty(entry.key_ptr.*);
        }

        // The EVM removes a map entry when a nonce returns to zero, when code is
        // cleared (for example an EIP-7702 delegation reset) and when an account
        // is deleted. Such an account is absent from the live maps above, so walk
        // the baseline for values that are now gone.
        var baseline_balance_it = self.baseline_balances.iterator();
        while (baseline_balance_it.next()) |entry| {
            if (entry.value_ptr.* == 0 or evm.balances.contains(entry.key_ptr.*)) continue;
            if (isSelfDestructed(evm, entry.key_ptr.*)) continue;
            try self.markBalanceDirty(entry.key_ptr.*);
        }

        var baseline_nonce_it = self.baseline_nonces.iterator();
        while (baseline_nonce_it.next()) |entry| {
            if (entry.value_ptr.* == 0 or evm.nonces.contains(entry.key_ptr.*)) continue;
            if (isSelfDestructed(evm, entry.key_ptr.*)) continue;
            try self.markNonceDirty(entry.key_ptr.*);
        }

        const empty_code_hash = codeHash(&.{});
        var baseline_code_it = self.baseline_codes.iterator();
        while (baseline_code_it.next()) |entry| {
            if (entry.value_ptr.* == empty_code_hash or evm.code.contains(entry.key_ptr.*)) continue;
            if (isSelfDestructed(evm, entry.key_ptr.*)) continue;
            try self.markCodeDirty(entry.key_ptr.*);
        }
    }

    /// Dump all state changes as JSON for commit.
    ///
    /// Storage entries carry the value written by the transaction ("newValue"),
    /// read from the EVM's authoritative storage, never from a fetch cache.
    /// Returns a JSON string owned by the caller (free with `self.allocator`).
    pub fn dumpChanges(self: *StorageInjector, evm: anytype) ![]const u8 {
        // Fold account mutations into the dirty sets before serializing.
        try self.markChangedAccounts(evm);

        var buffer: std.ArrayList(u8) = .{};
        defer buffer.deinit(self.allocator);
        try self.writeChanges(evm, buffer.writer(self.allocator));
        return buffer.toOwnedSlice(self.allocator);
    }

    /// Serialize the dirty sets as the commit JSON. Allocates nothing itself and
    /// fails only when `writer` does, so it can run past a commit point into a
    /// buffer sized beforehand. Does not mark account changes: call
    /// `markChangedAccounts` first (`dumpChanges` does both).
    pub fn writeChanges(self: *StorageInjector, evm: anytype, writer: anytype) !void {
        // Determine EVM type (mock vs real) once at the beginning
        const EvmTypeInfo = @typeInfo(@TypeOf(evm));
        const EvmType = if (EvmTypeInfo == .pointer) @TypeOf(evm.*) else @TypeOf(evm);

        // Start JSON object
        try writer.writeAll("{\"storage\":[");

        // Dump storage changes
        var storage_iter = self.dirty_storage.keyIterator();
        var first_storage = true;
        while (storage_iter.next()) |key| {
            if (!first_storage) try writer.writeAll(",");
            first_storage = false;

            // Get original and current values
            // Support both mock EVM (with HashMap) and real EVM (with Storage struct)
            const is_mock = @hasField(EvmType, "original_storage");

            const original = if (is_mock)
                evm.original_storage.get(key.*) orelse 0
            else
                evm.storage.get_original(primitives.Address{ .bytes = key.address }, key.slot);

            const current = if (is_mock)
                evm.storage.get(key.*) orelse 0
            else
                evm.storage.peek(primitives.Address{ .bytes = key.address }, key.slot);

            // Format: {"address":"0x...","slot":"0x...","originalValue":"0x...","newValue":"0x..."}
            try writer.writeAll("{\"address\":\"0x");
            try writeAddressHex(writer, &key.address);
            try writer.writeAll("\",\"slot\":\"0x");
            try std.fmt.format(writer, "{x}", .{key.slot});
            try writer.writeAll("\",\"originalValue\":\"0x");
            try std.fmt.format(writer, "{x}", .{original});
            try writer.writeAll("\",\"newValue\":\"0x");
            try std.fmt.format(writer, "{x}", .{current});
            try writer.writeAll("\"}");
        }

        try writer.writeAll("],\"balances\":[");

        // Dump balance changes
        var balance_iter = self.dirty_balances.keyIterator();
        var first_balance = true;
        while (balance_iter.next()) |address| {
            if (!first_balance) try writer.writeAll(",");
            first_balance = false;

            const balance = if (evm.balances.get(address.*)) |b| b else 0;

            // Format: {"address":"0x...","balance":"0x..."}
            try writer.writeAll("{\"address\":\"0x");
            try writeAddressHex(writer, &address.bytes);
            try writer.writeAll("\",\"balance\":\"0x");
            try std.fmt.format(writer, "{x}", .{balance});
            try writer.writeAll("\"}");
        }

        try writer.writeAll("],\"nonces\":[");

        // Dump nonce changes
        var nonce_iter = self.dirty_nonces.keyIterator();
        var first_nonce = true;
        while (nonce_iter.next()) |address| {
            if (!first_nonce) try writer.writeAll(",");
            first_nonce = false;

            const nonce = if (@hasField(EvmType, "nonces"))
                evm.nonces.get(address.*) orelse 0
            else
                evm.getNonce(address.*);

            // Format: {"address":"0x...","nonce":"0x..."}
            try writer.writeAll("{\"address\":\"0x");
            try writeAddressHex(writer, &address.bytes);
            try writer.writeAll("\",\"nonce\":\"0x");
            try std.fmt.format(writer, "{x}", .{nonce});
            try writer.writeAll("\"}");
        }

        try writer.writeAll("],\"codes\":[");

        // Dump code changes
        var code_iter = self.dirty_codes.keyIterator();
        var first_code = true;
        while (code_iter.next()) |address| {
            if (!first_code) try writer.writeAll(",");
            first_code = false;

            const code = if (evm.code.get(address.*)) |c| c else &[_]u8{};

            // Format: {"address":"0x...","code":"0x..."}
            try writer.writeAll("{\"address\":\"0x");
            try writeAddressHex(writer, &address.bytes);
            try writer.writeAll("\",\"code\":\"0x");
            try writeAddressHex(writer, code);
            try writer.writeAll("\"}");
        }

        try writer.writeAll("],\"selfDestructs\":[");

        // Dump self-destructs if tracked
        if (@hasField(EvmType, "selfdestructed_accounts")) {
            var selfdestruct_iter = evm.selfdestructed_accounts.keyIterator();
            var first_sd = true;
            while (selfdestruct_iter.next()) |address| {
                if (!first_sd) try writer.writeAll(",");
                first_sd = false;

                try writer.writeAll("\"0x");
                try writeAddressHex(writer, &address.bytes);
                try writer.writeAll("\"");
            }
        }

        try writer.writeAll("]}");
    }
};

// ============================================================================
// Tests for Phase 2: Storage Injector with LRU Cache
// ============================================================================

test "StorageInjector - init and deinit" {
    const testing = std.testing;

    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();

    // Verify empty state
    try testing.expectEqual(@as(usize, 0), injector.storage_cache.size);
    try testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());
}

test "StorageInjector - markStorageDirty adds to dirty set" {
    const testing = std.testing;

    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    const key = StorageKey{ .address = addr.bytes, .slot = 42 };

    try injector.markStorageDirty(addr, 42);

    try testing.expect(injector.dirty_storage.contains(key));
}

test "StorageInjector - multiple marks for same slot (idempotent)" {
    const testing = std.testing;

    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;

    try injector.markStorageDirty(addr, 42);
    try injector.markStorageDirty(addr, 42);
    try injector.markStorageDirty(addr, 42);

    // Should only have one entry
    try testing.expectEqual(@as(usize, 1), injector.dirty_storage.count());
}

test "StorageInjector - clearCache clears all state" {
    const testing = std.testing;

    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    const key = StorageKey{ .address = addr.bytes, .slot = 42 };

    // Add some data
    try injector.storage_cache.put(key, 100);
    try injector.markStorageDirty(addr, 42);

    // Clear
    injector.clearCache();

    // Verify everything is cleared
    try testing.expectEqual(@as(usize, 0), injector.storage_cache.size);
    try testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());
}

test "LruCache - init and deinit" {
    const testing = std.testing;
    const Cache = LruCache(u32, u32, 10);

    var cache = try Cache.init(testing.allocator);
    defer cache.deinit();

    try testing.expectEqual(@as(usize, 0), cache.size);
}

test "LruCache - put and get" {
    const testing = std.testing;
    const Cache = LruCache(u32, u32, 10);

    var cache = try Cache.init(testing.allocator);
    defer cache.deinit();

    try cache.put(1, 100);
    try testing.expectEqual(@as(u32, 100), cache.get(1).?);
    try testing.expectEqual(@as(usize, 1), cache.size);
}

test "LruCache - cache miss" {
    const testing = std.testing;
    const Cache = LruCache(u32, u32, 10);

    var cache = try Cache.init(testing.allocator);
    defer cache.deinit();

    try testing.expect(cache.get(99) == null);
}

test "LruCache - update existing" {
    const testing = std.testing;
    const Cache = LruCache(u32, u32, 10);

    var cache = try Cache.init(testing.allocator);
    defer cache.deinit();

    try cache.put(1, 100);
    try cache.put(1, 200);

    try testing.expectEqual(@as(u32, 200), cache.get(1).?);
    try testing.expectEqual(@as(usize, 1), cache.size);
}

test "LruCache - eviction at capacity" {
    const testing = std.testing;
    const Cache = LruCache(u32, u32, 2);

    var cache = try Cache.init(testing.allocator);
    defer cache.deinit();

    try cache.put(1, 100);
    try cache.put(2, 200);
    try testing.expectEqual(@as(usize, 2), cache.size);

    // Adding third item should evict first
    try cache.put(3, 300);

    try testing.expect(cache.get(1) == null); // Evicted
    try testing.expectEqual(@as(u32, 200), cache.get(2).?);
    try testing.expectEqual(@as(u32, 300), cache.get(3).?);
    try testing.expectEqual(@as(usize, 2), cache.size);
}

test "LruCache - clear" {
    const testing = std.testing;
    const Cache = LruCache(u32, u32, 10);

    var cache = try Cache.init(testing.allocator);
    defer cache.deinit();

    try cache.put(1, 100);
    try cache.put(2, 200);

    cache.clear();

    try testing.expectEqual(@as(usize, 0), cache.size);
    try testing.expect(cache.get(1) == null);
    try testing.expect(cache.get(2) == null);
}

test "LruCache - hit/miss tracking" {
    const testing = std.testing;
    const Cache = LruCache(u32, u32, 10);

    var cache = try Cache.init(testing.allocator);
    defer cache.deinit();

    try cache.put(1, 100);

    _ = cache.get(1); // Hit
    _ = cache.get(1); // Hit
    _ = cache.get(2); // Miss
    _ = cache.get(3); // Miss

    try testing.expectEqual(@as(u64, 2), cache.hits);
    try testing.expectEqual(@as(u64, 2), cache.misses);
}

// ============================================================================
// Tests for Phase 6: dumpChanges() and JSON Serialization
// ============================================================================

test "StorageInjector - dumpChanges with empty dirty sets" {
    const testing = std.testing;

    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();

    // Create minimal mock EVM for testing
    const MockEvm = struct {
        original_storage: std.AutoHashMap(StorageKey, u256),
        storage: std.AutoHashMap(StorageKey, u256),
        balances: std.AutoHashMap(Address, u256),
        nonces: std.AutoHashMap(Address, u64),
        code: std.AutoHashMap(Address, []const u8),
    };

    var mock_evm = MockEvm{
        .original_storage = std.AutoHashMap(StorageKey, u256).init(testing.allocator),
        .storage = std.AutoHashMap(StorageKey, u256).init(testing.allocator),
        .balances = std.AutoHashMap(Address, u256).init(testing.allocator),
        .nonces = std.AutoHashMap(Address, u64).init(testing.allocator),
        .code = std.AutoHashMap(Address, []const u8).init(testing.allocator),
    };
    defer mock_evm.original_storage.deinit();
    defer mock_evm.storage.deinit();
    defer mock_evm.balances.deinit();
    defer mock_evm.nonces.deinit();
    defer mock_evm.code.deinit();

    const json = try injector.dumpChanges(mock_evm);
    defer testing.allocator.free(json);

    // Should return empty arrays
    try testing.expectEqualStrings("{\"storage\":[],\"balances\":[],\"nonces\":[],\"codes\":[],\"selfDestructs\":[]}", json);
}

test "StorageInjector - dumpChanges with storage change" {
    const testing = std.testing;

    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    const slot: u256 = 42;
    const key = StorageKey{ .address = addr.bytes, .slot = slot };

    // Mock EVM
    const MockEvm = struct {
        original_storage: std.AutoHashMap(StorageKey, u256),
        storage: std.AutoHashMap(StorageKey, u256),
        balances: std.AutoHashMap(Address, u256),
        nonces: std.AutoHashMap(Address, u64),
        code: std.AutoHashMap(Address, []const u8),
    };

    var mock_evm = MockEvm{
        .original_storage = std.AutoHashMap(StorageKey, u256).init(testing.allocator),
        .storage = std.AutoHashMap(StorageKey, u256).init(testing.allocator),
        .balances = std.AutoHashMap(Address, u256).init(testing.allocator),
        .nonces = std.AutoHashMap(Address, u64).init(testing.allocator),
        .code = std.AutoHashMap(Address, []const u8).init(testing.allocator),
    };
    defer mock_evm.original_storage.deinit();
    defer mock_evm.storage.deinit();
    defer mock_evm.balances.deinit();
    defer mock_evm.nonces.deinit();
    defer mock_evm.code.deinit();

    // Set up state
    try mock_evm.original_storage.put(key, 0);
    try mock_evm.storage.put(key, 100);
    try injector.markStorageDirty(addr, slot);

    const json = try injector.dumpChanges(mock_evm);
    defer testing.allocator.free(json);

    // Verify JSON contains the change
    try testing.expect(std.mem.indexOf(u8, json, "\"address\":\"0x1234567890123456789012345678901234567890\"") != null);
    try testing.expect(std.mem.indexOf(u8, json, "\"storage\":[") != null);
}

// ============================================================================
// Round 1 fixes: code-cache ownership, LRU failure atomicity, dirty tracking
// ============================================================================

const TestAccounts = struct {
    original_storage: std.AutoHashMap(StorageKey, u256),
    storage: std.AutoHashMap(StorageKey, u256),
    balances: std.AutoHashMap(Address, u256),
    nonces: std.AutoHashMap(Address, u64),
    code: std.AutoHashMap(Address, []const u8),

    fn init(allocator: std.mem.Allocator) TestAccounts {
        return .{
            .original_storage = std.AutoHashMap(StorageKey, u256).init(allocator),
            .storage = std.AutoHashMap(StorageKey, u256).init(allocator),
            .balances = std.AutoHashMap(Address, u256).init(allocator),
            .nonces = std.AutoHashMap(Address, u64).init(allocator),
            .code = std.AutoHashMap(Address, []const u8).init(allocator),
        };
    }

    fn deinit(self: *TestAccounts) void {
        self.original_storage.deinit();
        self.storage.deinit();
        self.balances.deinit();
        self.nonces.deinit();
        self.code.deinit();
    }
};

test "StorageInjector - code cache copies with its own allocator and frees every copy" {
    const testing = std.testing;

    // The caller's code lives in a different allocator (an arena, like the EVM's).
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const arena_code = try arena.allocator().dupe(u8, &[_]u8{ 0x60, 0x00, 0x00 });

    var injector = try StorageInjector.init(testing.allocator);
    // testing.allocator panics on a foreign free and reports leaks, so deinit
    // proves the cache frees exactly the copies it made.
    defer injector.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    try injector.cacheCode(addr, arena_code);
    try injector.cacheCode(addr, &[_]u8{ 0x01, 0x02 }); // replacement frees the first copy
    try injector.code_cache.put(addr, arena_code); // direct put copies too

    const cached = injector.getCodeFromCache(addr).?;
    try testing.expectEqualSlices(u8, arena_code, cached);
    try testing.expect(cached.ptr != arena_code.ptr);

    // Evictions free their copies.
    var i: u16 = 0;
    while (i < 300) : (i += 1) {
        var other = addr;
        other.bytes[0] = @truncate(i);
        other.bytes[1] = @truncate(i >> 8);
        other.bytes[2] = 0xEE;
        try injector.cacheCode(other, &[_]u8{ 0xAA, 0xBB, 0xCC });
    }
    try testing.expectEqual(@as(usize, 128), injector.code_cache.size);

    // clearCache frees the rest; the injector stays usable.
    injector.clearCache();
    try testing.expectEqual(@as(usize, 0), injector.code_cache.size);
    try injector.cacheCode(addr, &[_]u8{0xFE});
}

test "LruCache - failed insertion leaves map, list and size consistent" {
    const testing = std.testing;
    const Cache = LruCache(u32, []const u8, 2);

    const run = struct {
        fn run(allocator: std.mem.Allocator) !void {
            var cache = try Cache.init(allocator);
            defer cache.deinit();
            var key: u32 = 0;
            while (key < 5) : (key += 1) {
                cache.put(key, "value") catch |err| {
                    // Invariants hold after a failed put.
                    try testing.expectEqual(cache.size, cache.map.count());
                    var listed: usize = 0;
                    var node = cache.head;
                    while (node) |n| : (node = n.next) {
                        try testing.expect(cache.map.get(n.key).? == n);
                        listed += 1;
                    }
                    try testing.expectEqual(cache.size, listed);
                    return err;
                };
            }
            try cache.put(4, "replaced");
            try testing.expectEqual(@as(usize, 2), cache.size);
        }
    }.run;

    try testing.checkAllAllocationFailures(testing.allocator, run, .{});
}

test "StorageInjector - a write in flight never replaces the fetched value; a committed write does" {
    const testing = std.testing;
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    const key = StorageKey{ .address = addr.bytes, .slot = 1 };
    try injector.cacheStorage(addr, 1, 5);
    try injector.markStorageDirty(addr, 1);

    // R3-001: the speculative write is tracked, the fetched original is untouched.
    try testing.expect(injector.dirty_storage.contains(key));
    try testing.expectEqual(@as(u256, 5), injector.getStorageFromCache(addr, 1).?);

    // Rollback: the dirty mark goes, the original stays.
    injector.clearDirty();
    try testing.expectEqual(@as(u256, 5), injector.getStorageFromCache(addr, 1).?);

    // Commit: the cache follows the host.
    injector.commitStorageWrite(key, 7);
    try testing.expectEqual(@as(u256, 7), injector.getStorageFromCache(addr, 1).?);
}

test "StorageInjector - writeChanges serializes into a fixed buffer without allocating" {
    const testing = std.testing;
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    var accounts = TestAccounts.init(testing.allocator);
    defer accounts.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    const key = StorageKey{ .address = addr.bytes, .slot = 0x2a };
    try accounts.original_storage.put(key, 5);
    try accounts.storage.put(key, 7);
    try injector.markStorageDirty(addr, 0x2a);

    const expected = try injector.dumpChanges(accounts);
    defer testing.allocator.free(expected);

    var counter = CountingWriter{};
    try injector.writeChanges(accounts, counter.writer());
    try testing.expectEqual(expected.len, counter.bytes_written);

    var storage_buf: [512]u8 = undefined;
    var fixed = FixedWriter{ .buffer = &storage_buf };
    try injector.writeChanges(accounts, fixed.writer());
    try testing.expectEqualStrings(expected, fixed.written());

    // A buffer one byte short reports the overflow instead of truncating silently.
    var short = FixedWriter{ .buffer = storage_buf[0 .. expected.len - 1] };
    try testing.expectError(error.NoSpaceLeft, injector.writeChanges(accounts, short.writer()));
}

test "StorageInjector - dumpChanges reports the written storage value" {
    const testing = std.testing;
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    var accounts = TestAccounts.init(testing.allocator);
    defer accounts.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    const key = StorageKey{ .address = addr.bytes, .slot = 0x2a };
    try accounts.original_storage.put(key, 5);
    try accounts.storage.put(key, 7);
    try injector.markStorageDirty(addr, 0x2a);

    const json = try injector.dumpChanges(accounts);
    defer testing.allocator.free(json);

    try testing.expectEqualStrings(
        "{\"storage\":[{\"address\":\"0x1234567890123456789012345678901234567890\",\"slot\":\"0x2a\"," ++
            "\"originalValue\":\"0x5\",\"newValue\":\"0x7\"}],\"balances\":[],\"nonces\":[],\"codes\":[],\"selfDestructs\":[]}",
        json,
    );
}

test "StorageInjector - explicit balance, nonce and code marks are serialized" {
    const testing = std.testing;
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    var accounts = TestAccounts.init(testing.allocator);
    defer accounts.deinit();

    const addr = primitives.Address.fromHex("0x00000000000000000000000000000000000000aa") catch unreachable;
    try accounts.balances.put(addr, 0x10);
    try accounts.nonces.put(addr, 3);
    try accounts.code.put(addr, &[_]u8{ 0x60, 0x01 });
    try injector.markBalanceDirty(addr);
    try injector.markNonceDirty(addr);
    try injector.markCodeDirty(addr);

    const json = try injector.dumpChanges(accounts);
    defer testing.allocator.free(json);

    try testing.expectEqualStrings(
        "{\"storage\":[]," ++
            "\"balances\":[{\"address\":\"0x00000000000000000000000000000000000000aa\",\"balance\":\"0x10\"}]," ++
            "\"nonces\":[{\"address\":\"0x00000000000000000000000000000000000000aa\",\"nonce\":\"0x3\"}]," ++
            "\"codes\":[{\"address\":\"0x00000000000000000000000000000000000000aa\",\"code\":\"0x6001\"}]," ++
            "\"selfDestructs\":[]}",
        json,
    );
}

test "StorageInjector - baseline diff tracks only accounts the transaction changed" {
    const testing = std.testing;
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    var accounts = TestAccounts.init(testing.allocator);
    defer accounts.deinit();

    const untouched = primitives.Address.fromHex("0x0000000000000000000000000000000000000001") catch unreachable;
    const changed = primitives.Address.fromHex("0x0000000000000000000000000000000000000002") catch unreachable;
    const created = primitives.Address.fromHex("0x0000000000000000000000000000000000000003") catch unreachable;
    const fetched = primitives.Address.fromHex("0x0000000000000000000000000000000000000004") catch unreachable;

    // Pre-state.
    try accounts.balances.put(untouched, 100);
    try accounts.nonces.put(untouched, 1);
    try accounts.code.put(untouched, &[_]u8{0x00});
    try accounts.balances.put(changed, 100);
    try accounts.nonces.put(changed, 1);
    try injector.captureBaseline(&accounts);

    // Execution: a transfer, a nonce bump, a deployment, and a host reply.
    try accounts.balances.put(changed, 60);
    try accounts.nonces.put(changed, 2);
    try accounts.balances.put(created, 40);
    try accounts.nonces.put(created, 1);
    try accounts.code.put(created, &[_]u8{ 0x60, 0x00 });
    try accounts.balances.put(fetched, 9);
    try injector.noteBaselineBalance(fetched, 9);

    const json = try injector.dumpChanges(&accounts);
    defer testing.allocator.free(json);

    try testing.expectEqual(@as(usize, 2), injector.dirty_balances.count());
    try testing.expect(injector.dirty_balances.contains(changed));
    try testing.expect(injector.dirty_balances.contains(created));
    try testing.expectEqual(@as(usize, 2), injector.dirty_nonces.count());
    try testing.expectEqual(@as(usize, 1), injector.dirty_codes.count());
    try testing.expect(injector.dirty_codes.contains(created));

    var parsed = try std.json.parseFromSlice(std.json.Value, testing.allocator, json, .{});
    defer parsed.deinit();
    try testing.expectEqual(@as(usize, 2), parsed.value.object.get("balances").?.array.items.len);
    try testing.expectEqual(@as(usize, 2), parsed.value.object.get("nonces").?.array.items.len);
    const codes = parsed.value.object.get("codes").?.array.items;
    try testing.expectEqual(@as(usize, 1), codes.len);
    try testing.expectEqualStrings("0x6000", codes[0].object.get("code").?.string);
}

test "StorageInjector - clearDirty drops pending changes and keeps fetched values" {
    const testing = std.testing;
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();

    const addr = primitives.Address.fromHex("0x1234567890123456789012345678901234567890") catch unreachable;
    try injector.cacheStorage(addr, 1, 7);
    try injector.markStorageDirty(addr, 1);
    try injector.markBalanceDirty(addr);
    try injector.markNonceDirty(addr);
    try injector.markCodeDirty(addr);

    injector.clearDirty();

    try testing.expectEqual(@as(usize, 0), injector.dirty_storage.count());
    try testing.expectEqual(@as(usize, 0), injector.dirty_balances.count());
    try testing.expectEqual(@as(usize, 0), injector.dirty_nonces.count());
    try testing.expectEqual(@as(usize, 0), injector.dirty_codes.count());
    try testing.expectEqual(@as(u256, 7), injector.getStorageFromCache(addr, 1).?);
}

test "StorageInjector - nonce, code and balance cleared to zero or empty are reported" {
    const testing = std.testing;
    var injector = try StorageInjector.init(testing.allocator);
    defer injector.deinit();
    var accounts = TestAccounts.init(testing.allocator);
    defer accounts.deinit();

    const cleared = primitives.Address.fromHex("0x00000000000000000000000000000000000000c1") catch unreachable;
    const kept = primitives.Address.fromHex("0x00000000000000000000000000000000000000c2") catch unreachable;
    const never_set = primitives.Address.fromHex("0x00000000000000000000000000000000000000c3") catch unreachable;

    // Pre-state: `cleared` holds a balance, a nonce and an EIP-7702 designator.
    const designator = [_]u8{ 0xef, 0x01, 0x00 } ++ [_]u8{0x11} ** 20;
    try accounts.balances.put(cleared, 9);
    try accounts.nonces.put(cleared, 4);
    try accounts.code.put(cleared, &designator);
    try accounts.nonces.put(kept, 1);
    try accounts.code.put(kept, &[_]u8{0x00});
    // A host reply of zero / empty is baseline too and is not a change.
    try injector.captureBaseline(&accounts);
    try injector.noteBaselineNonce(never_set, 0);
    try injector.noteBaselineCode(never_set, &.{});
    try injector.noteBaselineBalance(never_set, 0);

    // The EVM drops the map entry when a value returns to zero or empty.
    _ = accounts.balances.remove(cleared);
    _ = accounts.nonces.remove(cleared);
    _ = accounts.code.remove(cleared);

    const json = try injector.dumpChanges(&accounts);
    defer testing.allocator.free(json);

    try testing.expectEqualStrings(
        "{\"storage\":[]," ++
            "\"balances\":[{\"address\":\"0x00000000000000000000000000000000000000c1\",\"balance\":\"0x0\"}]," ++
            "\"nonces\":[{\"address\":\"0x00000000000000000000000000000000000000c1\",\"nonce\":\"0x0\"}]," ++
            "\"codes\":[{\"address\":\"0x00000000000000000000000000000000000000c1\",\"code\":\"0x\"}]," ++
            "\"selfDestructs\":[]}",
        json,
    );
}
