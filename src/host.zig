/// Host interface and implementations for Evm
const std = @import("std");
const primitives = @import("primitives");
const Address = primitives.Address.Address;

/// Host interface for system operations
pub const HostInterface = struct {
    ptr: *anyopaque,
    vtable: *const VTable,

    pub const VTable = struct {
        innerCall: *const fn (ptr: *anyopaque, gas: u64, address: Address, value: u256, input: []const u8, call_type: CallType) CallResult,
        getBalance: *const fn (ptr: *anyopaque, address: Address) u256,
        setBalance: *const fn (ptr: *anyopaque, address: Address, balance: u256) void,
        getCode: *const fn (ptr: *anyopaque, address: Address) []const u8,
        getStorage: *const fn (ptr: *anyopaque, address: Address, slot: u256) u256,
        setStorage: *const fn (ptr: *anyopaque, address: Address, slot: u256, value: u256) void,
        getNonce: *const fn (ptr: *anyopaque, address: Address) u64,
        setNonce: *const fn (ptr: *anyopaque, address: Address, nonce: u64) void,
    };

    pub const CallType = enum {
        Call,
        CallCode,
        DelegateCall,
        StaticCall,
        Create,
        Create2,
    };

    pub fn innerCall(self: HostInterface, gas: u64, address: Address, value: u256, input: []const u8, call_type: CallType) CallResult {
        return self.vtable.innerCall(self.ptr, gas, address, value, input, call_type);
    }

    pub fn getBalance(self: HostInterface, address: Address) u256 {
        return self.vtable.getBalance(self.ptr, address);
    }

    pub fn setBalance(self: HostInterface, address: Address, balance: u256) void {
        self.vtable.setBalance(self.ptr, address, balance);
    }

    pub fn getCode(self: HostInterface, address: Address) []const u8 {
        return self.vtable.getCode(self.ptr, address);
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
};

/// Call result type
pub const CallResult = struct {
    success: bool,
    gas_left: u64,
    output: []const u8,
};

/// Host implementation that reads from real EVM
pub const Host = struct {
    const Self = @This();
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{ .allocator = allocator };
    }

    pub fn hostInterface(self: *Self) HostInterface {
        return .{
            .ptr = self,
            .vtable = &.{
                .innerCall = innerCall,
                .getBalance = getBalance,
                .setBalance = setBalance,
                .getCode = getCode,
                .getStorage = getStorage,
                .setStorage = setStorage,
                .getNonce = getNonce,
                .setNonce = setNonce,
            },
        };
    }

    fn innerCall(ptr: *anyopaque, gas: u64, address: Address, value: u256, input: []const u8, call_type: HostInterface.CallType) CallResult {
        _ = ptr;
        _ = address;
        _ = value;
        _ = input;
        _ = call_type;
        // For now, just return success (this would normally delegate to the real EVM)
        return .{
            .success = true,
            .gas_left = gas,
            .output = &[_]u8{},
        };
    }

    fn getBalance(ptr: *anyopaque, address: Address) u256 {
        _ = ptr;
        _ = address;
        return 0;
    }

    fn setBalance(ptr: *anyopaque, address: Address, balance: u256) void {
        _ = ptr;
        _ = address;
        _ = balance;
    }

    fn getCode(ptr: *anyopaque, address: Address) []const u8 {
        _ = ptr;
        _ = address;
        return &[_]u8{};
    }

    fn getStorage(ptr: *anyopaque, address: Address, slot: u256) u256 {
        _ = ptr;
        _ = address;
        _ = slot;
        return 0;
    }

    fn setStorage(ptr: *anyopaque, address: Address, slot: u256, value: u256) void {
        _ = ptr;
        _ = address;
        _ = slot;
        _ = value;
    }

    fn getNonce(ptr: *anyopaque, address: Address) u64 {
        _ = ptr;
        _ = address;
        return 0;
    }

    fn setNonce(ptr: *anyopaque, address: Address, nonce: u64) void {
        _ = ptr;
        _ = address;
        _ = nonce;
    }
};
