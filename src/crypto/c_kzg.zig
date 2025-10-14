/// C-KZG bindings for EIP-4844 support
const std = @import("std");
const trusted_setup = @import("../kzg/trusted_setup.zig");

// Import the official zig bindings
const ckzg = @import("c_kzg");

// Re-export types from the official bindings
pub const KZGSettings = ckzg.KZGSettings;
pub const Blob = ckzg.Blob;
pub const KZGCommitment = ckzg.KZGCommitment;
pub const KZGProof = ckzg.KZGProof;
pub const Bytes32 = ckzg.Bytes32;
pub const Bytes48 = ckzg.Bytes48;

// Re-export constants
pub const BYTES_PER_BLOB = ckzg.BYTES_PER_BLOB;
pub const BYTES_PER_COMMITMENT = ckzg.BYTES_PER_COMMITMENT;
pub const BYTES_PER_PROOF = ckzg.BYTES_PER_PROOF;
pub const BYTES_PER_FIELD_ELEMENT = ckzg.BYTES_PER_FIELD_ELEMENT;
pub const FIELD_ELEMENTS_PER_BLOB = ckzg.FIELD_ELEMENTS_PER_BLOB;

// Re-export error type
pub const KZGError = ckzg.KZGError;

// Re-export core functions
pub const loadTrustedSetupFromText = ckzg.loadTrustedSetupFromText;
pub const loadTrustedSetupFile = ckzg.loadTrustedSetupFile;

/// Free the trusted setup
pub fn freeTrustedSetup() KZGError!void {
    try ckzg.freeTrustedSetup();
}

/// Blob to KZG commitment
pub fn blobToKzgCommitment(blob: *const Blob) KZGError!KZGCommitment {
    return try ckzg.blobToKZGCommitment(blob);
}

/// Compute KZG proof
pub fn computeKZGProof(blob: *const Blob, z: *const Bytes32) KZGError!struct { proof: KZGProof, y: Bytes32 } {
    return try ckzg.computeKZGProof(blob, z);
}

/// Re-export the verifyKZGProof function from ckzg
pub const verifyKZGProof = ckzg.verifyKZGProof;

test "c_kzg basic functionality" {
    // Load the trusted setup from embedded data
    try loadTrustedSetupFromText(trusted_setup.data, 0);
    defer freeTrustedSetup() catch |err| {
        // Only acceptable error is TrustedSetupNotLoaded (already freed)
        if (err != error.TrustedSetupNotLoaded) {
            @panic("Unexpected error during KZG trusted setup cleanup in test");
        }
    };

    // If we get here without error, the trusted setup loaded successfully
}
