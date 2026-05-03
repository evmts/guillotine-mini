/// Host interface and implementations for Evm
///
/// NOTE: This module provides a minimal host interface for testing purposes.
/// The EVM's inner_call method now uses CallParams/CallResult directly and does not
/// go through this host interface - it handles nested calls internally.
const std = @import("std");
const primitives = @import("voltaire");
const Address = primitives.Address.Address;

/// Minimal host interface for external state access (balances, storage, code, nonces)
/// NOTE: This is NOT used for nested calls - EVM.inner_call handles those directly
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        getBalance: *const fn (ptr: *anyopaque, address: Address) u256,
        setBalance: *const fn (ptr: *anyopaque, address: Address, balance: u256) void,
        getCode: *const fn (ptr: *anyopaque, address: Address) []const u8,
        setCode: *const fn (ptr: *anyopaque, address: Address, code: []const u8) void,
        getStorage: *const fn (ptr: *anyopaque, address: Address, slot: u256) u256,
        setStorage: *const fn (ptr: *anyopaque, address: Address, slot: u256, value: u256) void,
        getNonce: *const fn (ptr: *anyopaque, address: Address) u64,
        setNonce: *const fn (ptr: *anyopaque, address: Address, nonce: u64) void,
        accountExists: ?*const fn (ptr: *anyopaque, address: Address) bool = null,
        accountHasStorage: ?*const fn (ptr: *anyopaque, address: Address) bool = null,
        deleteAccount: ?*const fn (ptr: *anyopaque, address: Address) void = null,
    };

    pub fn getBalance(self: HostInterface, address: Address) u256 {
        return self.vtable.getBalance(self.ptr, address);
    }

    pub fn setBalance(self: HostInterface, address: Address, balance: u256) void {
        self.vtable.setBalance(self.ptr, address, balance);
    }

    pub fn getCode(self: HostInterface, address: Address) []const u8 {
        return self.vtable.getCode(self.ptr, address);
    }

    pub fn setCode(self: HostInterface, address: Address, code: []const u8) void {
        self.vtable.setCode(self.ptr, address, code);
    }

    pub fn getStorage(self: HostInterface, address: Address, slot: u256) u256 {
        return self.vtable.getStorage(self.ptr, address, slot);
    }

    pub fn setStorage(self: HostInterface, address: Address, slot: u256, value: u256) void {
        self.vtable.setStorage(self.ptr, address, slot, value);
    }

    pub fn getNonce(self: HostInterface, address: Address) u64 {
        return self.vtable.getNonce(self.ptr, address);
    }

    pub fn setNonce(self: HostInterface, address: Address, nonce: u64) void {
        self.vtable.setNonce(self.ptr, address, nonce);
    }

    pub fn accountExists(self: HostInterface, address: Address) bool {
        if (self.vtable.accountExists) |exists| {
            return exists(self.ptr, address);
        }
        return self.getBalance(address) != 0 or self.getNonce(address) != 0 or self.getCode(address).len != 0;
    }

    pub fn accountHasStorage(self: HostInterface, address: Address) bool {
        if (self.vtable.accountHasStorage) |has_storage| {
            return has_storage(self.ptr, address);
        }
        return false;
    }

    pub fn deleteAccount(self: HostInterface, address: Address) void {
        if (self.vtable.deleteAccount) |delete| {
            delete(self.ptr, address);
            return;
        }
        self.setBalance(address, 0);
        self.setCode(address, &[_]u8{});
        self.setNonce(address, 0);
    }
};
