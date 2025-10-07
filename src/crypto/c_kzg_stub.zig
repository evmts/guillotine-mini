// Stub implementation of c-kzg for when the C library is not available
// This allows the code to compile for testing hardforks that don't use KZG (pre-Cancun)

pub const BYTES_PER_BLOB = 131072;
pub const BYTES_PER_CELL = 2048;
pub const BYTES_PER_COMMITMENT = 48;
pub const BYTES_PER_FIELD_ELEMENT = 32;
pub const BYTES_PER_PROOF = 48;
pub const CELLS_PER_EXT_BLOB = 128;
pub const FIELD_ELEMENTS_PER_BLOB = 4096;
pub const FIELD_ELEMENTS_PER_CELL = 64;

pub const Bytes32 = [32]u8;
pub const Bytes48 = [48]u8;
pub const KZGCommitment = Bytes48;
pub const KZGProof = Bytes48;
pub const Blob = [BYTES_PER_BLOB]u8;
pub const Cell = [BYTES_PER_CELL]u8;
pub const KZGSettings = opaque {};

pub const KZGError = error{
    BadArgs,
    InternalError,
    MallocError,
    UnknownError,
};

pub fn loadTrustedSetupFromText(
    settings: *KZGSettings,
    text: [:0]const u8,
) KZGError!void {
    _ = settings;
    _ = text;
    return error.UnknownError;
}

pub fn freeTrustedSetup(settings: *KZGSettings) void {
    _ = settings;
}

pub fn verifyKzgProof(
    commitment: *const KZGCommitment,
    z: *const Bytes32,
    y: *const Bytes32,
    proof: *const KZGProof,
    settings: *const KZGSettings,
) KZGError!bool {
    _ = commitment;
    _ = z;
    _ = y;
    _ = proof;
    _ = settings;
    return error.UnknownError;
}

pub fn blobToKzgCommitment(
    commitment: *KZGCommitment,
    blob: *const Blob,
    settings: *const KZGSettings,
) KZGError!void {
    _ = commitment;
    _ = blob;
    _ = settings;
    return error.UnknownError;
}

pub fn computeKzgProof(
    proof: *KZGProof,
    y: *Bytes32,
    blob: *const Blob,
    z: *const Bytes32,
    settings: *const KZGSettings,
) KZGError!void {
    _ = proof;
    _ = y;
    _ = blob;
    _ = z;
    _ = settings;
    return error.UnknownError;
}

pub fn verifyBlobKzgProofBatch(
    blobs: []const Blob,
    commitments: []const KZGCommitment,
    proofs: []const KZGProof,
    settings: *const KZGSettings,
) KZGError!bool {
    _ = blobs;
    _ = commitments;
    _ = proofs;
    _ = settings;
    return error.UnknownError;
}
