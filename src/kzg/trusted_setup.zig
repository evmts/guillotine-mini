/// KZG trusted setup data wrapper
///
/// This module provides access to the embedded trusted setup file used for
/// EIP-4844 blob verification. The trusted setup is embedded at compile time
/// to avoid runtime file I/O dependencies.

/// Embedded trusted setup data from the KZG ceremony
/// Format: Text file with G1 and G2 points in hex format
/// Size: ~4096 G1 points + 65 G2 points
pub const data = @embedFile("trusted_setup.txt");
