/// Header validation interface (vtable) for block chain management.
///
/// Mirrors Nethermind's `IHeaderValidator` surface with:
/// - `validate` (header + parent + uncle flag)
/// - `validate_orphaned` (header without parent)
const std = @import("std");
const primitives = @import("primitives");
const BlockHeader = primitives.BlockHeader;

/// Type-erased header validator interface for dependency injection.
pub const HeaderValidator = struct {
    /// Pointer to the concrete validator implementation.
    ptr: *anyopaque,
    /// Pointer to the static vtable for the concrete validator implementation.
    vtable: *const VTable,

    /// Error set for header validation failures.
    pub const Error = error{
        InvalidHeaderHash,
        InvalidExtraData,
        InvalidGenesisBlock,
        InvalidParentHash,
        InvalidAncestor,
        InvalidTotalDifficulty,
        InvalidSealParameters,
        NegativeBlockNumber,
        NegativeGasLimit,
        NegativeGasUsed,
        ExceededGasLimit,
        InvalidGasLimit,
        InvalidBlockNumber,
        InvalidBaseFeePerGas,
        InvalidTimestamp,
        InvalidDifficulty,
        InvalidNonce,
        InvalidOmmersHash,
        MissingBlobGasUsed,
        MissingExcessBlobGas,
        IncorrectExcessBlobGas,
        NotAllowedBlobGasUsed,
        NotAllowedExcessBlobGas,
        MissingRequests,
        RequestsNotEnabled,
        InvalidRequestsHash,
    };

    /// Virtual function table for header validation operations.
    pub const VTable = struct {
        /// Validate a header against its parent.
        validate: *const fn (
            ptr: *anyopaque,
            header: *const BlockHeader.BlockHeader,
            parent: *const BlockHeader.BlockHeader,
            is_uncle: bool,
        ) Error!void,
        /// Validate a header without a parent (orphaned).
        validate_orphaned: *const fn (
            ptr: *anyopaque,
            header: *const BlockHeader.BlockHeader,
        ) Error!void,
    };

    /// Validate a header against its parent.
    pub fn validate(
        self: HeaderValidator,
        header: *const BlockHeader.BlockHeader,
        parent: *const BlockHeader.BlockHeader,
        is_uncle: bool,
    ) Error!void {
        return self.vtable.validate(self.ptr, header, parent, is_uncle);
    }

    /// Validate a header without a parent (orphaned).
    pub fn validate_orphaned(
        self: HeaderValidator,
        header: *const BlockHeader.BlockHeader,
    ) Error!void {
        return self.vtable.validate_orphaned(self.ptr, header);
    }
};

// =============================================================================
// Tests
// =============================================================================

test "HeaderValidator dispatches validate" {
    const Dummy = struct {
        const Self = @This();
        called: bool = false,
        saw_uncle: bool = false,

        fn validate(
            ptr: *anyopaque,
            header: *const BlockHeader.BlockHeader,
            parent: *const BlockHeader.BlockHeader,
            is_uncle: bool,
        ) HeaderValidator.Error!void {
            const self: *Self = @ptrCast(@alignCast(ptr));
            self.called = true;
            self.saw_uncle = is_uncle;
            _ = header;
            _ = parent;
        }

        fn validate_orphaned(
            ptr: *anyopaque,
            header: *const BlockHeader.BlockHeader,
        ) HeaderValidator.Error!void {
            const self: *Self = @ptrCast(@alignCast(ptr));
            self.called = true;
            _ = header;
        }
    };

    var dummy = Dummy{};
    const vtable = HeaderValidator.VTable{
        .validate = Dummy.validate,
        .validate_orphaned = Dummy.validate_orphaned,
    };

    const validator = HeaderValidator{ .ptr = &dummy, .vtable = &vtable };
    var header = BlockHeader.init();
    var parent = BlockHeader.init();

    try validator.validate(&header, &parent, true);
    try std.testing.expect(dummy.called);
    try std.testing.expect(dummy.saw_uncle);
}

test "HeaderValidator dispatches validate_orphaned" {
    const Dummy = struct {
        const Self = @This();
        orphaned_called: bool = false,

        fn validate(
            ptr: *anyopaque,
            header: *const BlockHeader.BlockHeader,
            parent: *const BlockHeader.BlockHeader,
            is_uncle: bool,
        ) HeaderValidator.Error!void {
            const self: *Self = @ptrCast(@alignCast(ptr));
            _ = header;
            _ = parent;
            _ = is_uncle;
            self.orphaned_called = false;
        }

        fn validate_orphaned(
            ptr: *anyopaque,
            header: *const BlockHeader.BlockHeader,
        ) HeaderValidator.Error!void {
            const self: *Self = @ptrCast(@alignCast(ptr));
            self.orphaned_called = true;
            _ = header;
        }
    };

    var dummy = Dummy{};
    const vtable = HeaderValidator.VTable{
        .validate = Dummy.validate,
        .validate_orphaned = Dummy.validate_orphaned,
    };

    const validator = HeaderValidator{ .ptr = &dummy, .vtable = &vtable };
    var header = BlockHeader.init();

    try validator.validate_orphaned(&header);
    try std.testing.expect(dummy.orphaned_called);
}
