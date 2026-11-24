const std = @import("std");
const ex = @import("../common.zig");
const Address = ex.Address;
const Host = ex.mini.HostInterface;

// Code and hash tables belong to the backend and outlive individual EVMs.
arena: std.heap.ArenaAllocator,
accounts: std.AutoHashMapUnmanaged(Address, Account) = .{},
slots: std.AutoHashMapUnmanaged(Slot, u256) = .{},
err: ?error{OutOfMemory} = null,

const Store = @This();
const Account = struct { balance: u256 = 0, nonce: u64 = 0, code: []const u8 = &.{} };
const Slot = struct { address: Address, key: u256 };

pub fn init(allocator: std.mem.Allocator) Store {
    return .{ .arena = std.heap.ArenaAllocator.init(allocator) };
}

pub fn deinit(self: *Store) void {
    self.arena.deinit();
}

pub fn host(self: *Store) Host {
    return .{ .ptr = self, .vtable = &.{
        .getBalance = getBalance,
        .setBalance = setBalance,
        .getCode = getCode,
        .setCode = setCode,
        .getStorage = getStorage,
        .setStorage = setStorage,
        .getNonce = getNonce,
        .setNonce = setNonce,
    } };
}

fn store(ptr: *anyopaque) *Store {
    return @ptrCast(@alignCast(ptr));
}

fn account(self: *Store, address: Address) Account {
    return self.accounts.get(address) orelse .{};
}

fn edit(self: *Store, address: Address) ?*Account {
    const entry = self.accounts.getOrPut(self.arena.allocator(), address) catch |err| {
        self.err = err;
        return null;
    };
    if (!entry.found_existing) entry.value_ptr.* = .{};
    return entry.value_ptr;
}

fn getBalance(ptr: *anyopaque, address: Address) u256 {
    return store(ptr).account(address).balance;
}
fn setBalance(ptr: *anyopaque, address: Address, value: u256) void {
    const entry = store(ptr).edit(address) orelse return;
    entry.balance = value;
}
fn getNonce(ptr: *anyopaque, address: Address) u64 {
    return store(ptr).account(address).nonce;
}
fn setNonce(ptr: *anyopaque, address: Address, value: u64) void {
    const entry = store(ptr).edit(address) orelse return;
    entry.nonce = value;
}
fn getCode(ptr: *anyopaque, address: Address) []const u8 {
    return store(ptr).account(address).code;
}
fn setCode(ptr: *anyopaque, address: Address, code: []const u8) void {
    const self = store(ptr);
    const entry = self.edit(address) orelse return;
    entry.code = self.arena.allocator().dupe(u8, code) catch |err| {
        self.err = err;
        return;
    };
}
fn getStorage(ptr: *anyopaque, address: Address, key: u256) u256 {
    return store(ptr).slots.get(.{ .address = address, .key = key }) orelse 0;
}
fn setStorage(ptr: *anyopaque, address: Address, key: u256, value: u256) void {
    const self = store(ptr);
    const slot: Slot = .{ .address = address, .key = key };
    if (value == 0) {
        _ = self.slots.remove(slot);
    } else {
        self.slots.put(self.arena.allocator(), slot, value) catch |err| {
            self.err = err;
        };
    }
}
