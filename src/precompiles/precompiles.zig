/// Ethereum precompiled contracts implementation
///
/// Precompiles are special contracts with addresses 0x01-0x0A (and beyond) that provide
/// cryptographic functions and other utilities natively implemented for efficiency:
/// - 0x01: ecRecover - ECDSA signature recovery
/// - 0x02: sha256 - SHA-256 hash function
/// - 0x03: ripemd160 - RIPEMD-160 hash function
/// - 0x04: identity - data copy function
/// - 0x05: modexp - modular exponentiation
/// - 0x06: ecAdd - BN254 elliptic curve addition
/// - 0x07: ecMul - BN254 elliptic curve multiplication
/// - 0x08: ecPairing - BN254 pairing check
/// - 0x09: blake2f - BLAKE2F compression function
/// - 0x0A: pointEvaluation - KZG point evaluation (EIP-4844)
///
/// These contracts have deterministic gas costs and behavior across all EVM implementations.
const std = @import("std");
const primitives = @import("primitives");
const Address = primitives.Address;
// Use the real crypto and build_options modules
const crypto = @import("crypto");
const build_options = @import("build_options");

/// Re-export KZG setup module for test initialization
pub const kzg_setup = @import("kzg_setup.zig");

/// Precompile addresses (Ethereum mainnet)
pub const ECRECOVER_ADDRESS = primitives.Address.from_u256(1);
pub const SHA256_ADDRESS = primitives.Address.from_u256(2);
pub const RIPEMD160_ADDRESS = primitives.Address.from_u256(3);
pub const IDENTITY_ADDRESS = primitives.Address.from_u256(4);
pub const MODEXP_ADDRESS = primitives.Address.from_u256(5);
pub const ECADD_ADDRESS = primitives.Address.from_u256(6);
pub const ECMUL_ADDRESS = primitives.Address.from_u256(7);
pub const ECPAIRING_ADDRESS = primitives.Address.from_u256(8);
pub const BLAKE2F_ADDRESS = primitives.Address.from_u256(9);
pub const POINT_EVALUATION_ADDRESS = primitives.Address.from_u256(10);

/// BLS12-381 precompile addresses (EIP-2537)
pub const BLS12_381_G1_ADD_ADDRESS = primitives.Address.from_u256(0x0B);
pub const BLS12_381_G1_MUL_ADDRESS = primitives.Address.from_u256(0x0C);
pub const BLS12_381_G1_MULTIEXP_ADDRESS = primitives.Address.from_u256(0x0D);
pub const BLS12_381_G2_ADD_ADDRESS = primitives.Address.from_u256(0x0E);
pub const BLS12_381_G2_MUL_ADDRESS = primitives.Address.from_u256(0x0F);
pub const BLS12_381_G2_MULTIEXP_ADDRESS = primitives.Address.from_u256(0x10);
pub const BLS12_381_PAIRING_ADDRESS = primitives.Address.from_u256(0x11);
pub const BLS12_381_MAP_FP_TO_G1_ADDRESS = primitives.Address.from_u256(0x12);

/// Precompile error types
pub const PrecompileError = error{
    InvalidInput,
    OutOfGas,
    ExecutionError,
    OutOfMemory,
    NoSpaceLeft,
    DivisionByZero,
    AllocationFailed,
    NotImplemented,
    InvalidBase,
    InvalidCharacter,
    InvalidLength,
};

/// Precompile output result
pub const PrecompileOutput = struct {
    /// Output data from the precompile
    output: []const u8,
    /// Gas consumed by the precompile
    gas_used: u64,
    /// Whether the precompile succeeded
    success: bool,
};

/// Check if an address is a precompile for the given hardfork
/// Precompiles were introduced in different hardforks:
/// - Frontier/Homestead (0x01-0x04): ECRECOVER, SHA256, RIPEMD160, IDENTITY
/// - Byzantium (0x05-0x08): MODEXP, ECADD, ECMUL, ECPAIRING
/// - Istanbul (0x09): BLAKE2F
/// - Cancun (0x0A): POINT_EVALUATION
/// - Prague (0x0B-0x12): BLS12-381 precompiles
pub fn is_precompile(address: Address, hardfork: @import("../hardfork.zig").Hardfork) bool {
    // Check if all bytes except the last one are zero
    for (address.bytes[0..19]) |byte| {
        if (byte != 0) return false;
    }

    const precompile_id = address.bytes[19];

    // Check precompile availability based on hardfork
    return switch (precompile_id) {
        // Frontier/Homestead precompiles (always available)
        1, 2, 3, 4 => true,
        // Byzantium precompiles (EIP-196, EIP-197, EIP-198)
        5, 6, 7, 8 => hardfork.isAtLeast(.BYZANTIUM),
        // Istanbul precompiles (EIP-152)
        9 => hardfork.isAtLeast(.ISTANBUL),
        // Cancun precompiles (EIP-4844)
        10 => hardfork.isAtLeast(.CANCUN),
        // Prague precompiles (EIP-2537)
        0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12 => hardfork.isAtLeast(.PRAGUE),
        else => false,
    };
}

/// Execute a precompile based on its address
/// Not safe to call without checking is_precompile first
/// Note: This function assumes the caller has already verified the precompile is available
/// for the current hardfork using is_precompile()
pub fn execute_precompile(
    allocator: std.mem.Allocator,
    address: Address,
    input: []const u8,
    gas_limit: u64,
    hardfork: @import("../hardfork.zig").Hardfork,
) PrecompileError!PrecompileOutput {
    // Check if address is a precompile address (address must be 0x00...00XX where XX is 1-18)
    for (address.bytes[0..19]) |byte| {
        std.debug.assert(byte == 0);
    }
    const precompile_id = address.bytes[19];
    std.debug.assert(precompile_id >= 1 and precompile_id <= 0x12);

    // Validate input size based on precompile type to prevent DoS
    const max_input_size: usize = switch (precompile_id) {
        1 => 128, // ECRECOVER has fixed input size
        2, 3 => InputLimits.MAX_HASH_INPUT, // SHA256, RIPEMD160
        4 => InputLimits.MAX_IDENTITY_INPUT, // IDENTITY
        5 => InputLimits.MAX_MODEXP_INPUT, // MODEXP
        6, 7, 8 => InputLimits.MAX_EC_INPUT, // BN254 operations
        9 => InputLimits.MAX_BLAKE2F_INPUT, // BLAKE2F (fixed at 213)
        10 => InputLimits.MAX_POINT_EVAL_INPUT, // Point evaluation (fixed at 192)
        0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11, 0x12 => InputLimits.MAX_EC_INPUT, // BLS12-381
        else => InputLimits.MAX_HASH_INPUT, // Default fallback
    };

    if (input.len > max_input_size) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit, // Consume all gas on invalid input
            .success = false,
        };
    }

    return switch (precompile_id) {
        1 => execute_ecrecover(allocator, input, gas_limit),
        2 => execute_sha256(allocator, input, gas_limit),
        3 => execute_ripemd160(allocator, input, gas_limit),
        4 => execute_identity(allocator, input, gas_limit),
        5 => execute_modexp(allocator, input, gas_limit, hardfork),
        6 => execute_ecadd(allocator, input, gas_limit, hardfork),
        7 => execute_ecmul(allocator, input, gas_limit, hardfork),
        8 => execute_ecpairing(allocator, input, gas_limit, hardfork),
        9 => execute_blake2f(allocator, input, gas_limit),
        10 => execute_point_evaluation(allocator, input, gas_limit),
        0x0B => execute_bls12_381_g1_add(allocator, input, gas_limit),
        0x0C => execute_bls12_381_g1_mul(allocator, input, gas_limit),
        0x0D => execute_bls12_381_g1_multiexp(allocator, input, gas_limit),
        0x0E => execute_bls12_381_g2_add(allocator, input, gas_limit),
        0x0F => execute_bls12_381_g2_mul(allocator, input, gas_limit),
        0x10 => execute_bls12_381_g2_multiexp(allocator, input, gas_limit),
        0x11 => execute_bls12_381_pairing(allocator, input, gas_limit),
        0x12 => execute_bls12_381_map_fp_to_g1(allocator, input, gas_limit),
        else => PrecompileOutput{
            .output = &.{},
            .gas_used = 0,
            .success = false,
        },
    };
}

/// Maximum input size limits for precompiles to prevent DoS attacks
/// These limits ensure that even with maximum input sizes, gas costs remain reasonable
/// and memory allocations don't cause system issues
pub const InputLimits = struct {
    /// Maximum input size for hash precompiles (SHA256, RIPEMD160)
    /// At 1MB, SHA256 costs ~384k gas, well within block gas limits
    pub const MAX_HASH_INPUT: usize = 1024 * 1024; // 1 MB

    /// Maximum input size for IDENTITY precompile
    /// At 1MB, costs ~96k gas
    pub const MAX_IDENTITY_INPUT: usize = 1024 * 1024; // 1 MB

    /// Maximum input size for MODEXP precompile
    /// MODEXP has its own dynamic gas calculation, but cap to prevent extreme cases
    pub const MAX_MODEXP_INPUT: usize = 64 * 1024; // 64 KB

    /// Maximum input size for elliptic curve precompiles
    /// These have fixed input sizes but validate against this for safety
    pub const MAX_EC_INPUT: usize = 32 * 1024; // 32 KB

    /// Maximum input size for BLAKE2F (fixed at 213 bytes but kept for consistency)
    pub const MAX_BLAKE2F_INPUT: usize = 213;

    /// Maximum input size for KZG point evaluation (fixed but kept for consistency)
    pub const MAX_POINT_EVAL_INPUT: usize = 192;
};

/// Gas costs for precompiles (in gas units)
pub const GasCosts = struct {
    pub const ECRECOVER = 3000;
    pub const SHA256_BASE = 60;
    pub const SHA256_PER_WORD = 12;
    pub const RIPEMD160_BASE = 600;
    pub const RIPEMD160_PER_WORD = 120;
    pub const IDENTITY_BASE = 15;
    pub const IDENTITY_PER_WORD = 3;
    pub const MODEXP_MIN = 200;
    pub const ECADD = 150;
    pub const ECMUL = 6000;
    pub const ECPAIRING_BASE = 45000;
    pub const ECPAIRING_PER_PAIR = 34000;
    pub const BLAKE2F_PER_ROUND = 1;
    pub const POINT_EVALUATION = 50000;

    // BLS12-381 gas costs (EIP-2537)
    pub const BLS12_381_G1_ADD = 500;
    pub const BLS12_381_G1_MUL = 12000;
    pub const BLS12_381_G1_MULTIEXP_BASE = 12000;
    pub const BLS12_381_G2_ADD = 800;
    pub const BLS12_381_G2_MUL = 45000;
    pub const BLS12_381_G2_MULTIEXP_BASE = 55000;
    pub const BLS12_381_PAIRING_BASE = 65000;
    pub const BLS12_381_PAIRING_PER_PAIR = 43000;
    pub const BLS12_381_MAP_FP_TO_G1 = 5500;
};

/// 0x01: ecRecover - ECDSA signature recovery
/// Recovers the public key from ECDSA signature and message hash
/// Input: 32 bytes hash + 32 bytes v + 32 bytes r + 32 bytes s (128 bytes total)
/// Output: 32 bytes (20-byte address + 12 zero bytes padding)
pub fn execute_ecrecover(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    const required_gas = GasCosts.ECRECOVER;
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    var padded_input: [128]u8 = [_]u8{0} ** 128;
    const copy_len = @min(input.len, 128);
    @memcpy(padded_input[0..copy_len], input[0..copy_len]);

    // Parse input: hash(32) + v(32) + r(32) + s(32)
    const hash = padded_input[0..32];
    const v_bytes = padded_input[32..64];
    const r_bytes = padded_input[64..96];
    const s_bytes = padded_input[96..128];

    // Parse v - must be 27 or 28
    var v: u8 = 0;
    for (v_bytes) |byte| {
        if (byte != 0) {
            if (v != 0) {
                // Multiple non-zero bytes in v, invalid
                const empty_output = try allocator.alloc(u8, 32);
                @memset(empty_output, 0);
                return PrecompileOutput{
                    .output = empty_output,
                    .gas_used = required_gas,
                    .success = true,
                };
            }
            v = byte;
        }
    }

    if (v != 27 and v != 28) {
        const empty_output = try allocator.alloc(u8, 32);
        @memset(empty_output, 0);
        return PrecompileOutput{
            .output = empty_output,
            .gas_used = required_gas,
            .success = true,
        };
    }

    // Parse r and s as u256
    const r = bytesToU256(r_bytes);
    const s = bytesToU256(s_bytes);

    // Convert v to recovery_id (0 or 1)
    const recovery_id = v - 27;

    // Use the actual secp256k1 implementation from crypto module
    const address = crypto.secp256k1.unaudited_recover_address(hash, recovery_id, r, s) catch {
        // Return zero address on recovery failure
        const empty_output = try allocator.alloc(u8, 32);
        @memset(empty_output, 0);
        return PrecompileOutput{
            .output = empty_output,
            .gas_used = required_gas,
            .success = true,
        };
    };

    // Format output: 20-byte address + 12 zero bytes padding
    const output = try allocator.alloc(u8, 32);
    @memset(output, 0);
    @memcpy(output[12..32], &address.bytes);

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x02: sha256 - SHA-256 hash function
/// Input: arbitrary bytes
/// Output: 32-byte SHA-256 hash
pub fn execute_sha256(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    const word_count = (input.len + 31) / 32;
    const required_gas = GasCosts.SHA256_BASE + word_count * GasCosts.SHA256_PER_WORD;

    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    // Compute SHA-256 hash using SIMD-accelerated implementation
    const output = try allocator.alloc(u8, 32);
    var hash: [32]u8 = undefined;
    
    // Get vector size from build options or default to auto-detect
    const vector_size = if (@hasDecl(build_options, "vector_length"))
        build_options.vector_length
    else
        comptime std.simd.suggestVectorLengthForCpu(u8, @import("builtin").target.cpu) orelse 1;
    
    const SHA256 = crypto.SHA256_Accel.SHA256_Accel(vector_size);
    SHA256.hash(input, &hash);
    @memcpy(output, &hash);

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x03: ripemd160 - RIPEMD-160 hash function
/// Input: arbitrary bytes
/// Output: 32-byte result (20-byte RIPEMD-160 hash + 12 zero bytes padding)
pub fn execute_ripemd160(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    const word_count = (input.len + 31) / 32;
    const required_gas = GasCosts.RIPEMD160_BASE + word_count * GasCosts.RIPEMD160_PER_WORD;

    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    const output = try allocator.alloc(u8, 32);
    @memset(output, 0);

    // Use the actual RIPEMD160 implementation from crypto module
    var hasher = crypto.Ripemd160.RIPEMD160.init();
    hasher.update(input);
    const hash = hasher.final();

    // Copy the 20-byte hash to the output with 12 bytes of padding at the front
    @memcpy(output[12..32], &hash);

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x04: identity - Data copy function
/// Input: arbitrary bytes
/// Output: exact copy of input
pub fn execute_identity(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    const word_count = (input.len + 31) / 32;
    const required_gas = GasCosts.IDENTITY_BASE + word_count * GasCosts.IDENTITY_PER_WORD;

    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    const output = try allocator.dupe(u8, input);
    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x05: modexp - Modular exponentiation
/// Input: base_len(32) + exp_len(32) + mod_len(32) + base + exp + mod
/// Output: result of (base^exp) % mod
pub fn execute_modexp(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64, hardfork: @import("../hardfork.zig").Hardfork) PrecompileError!PrecompileOutput {
    // EIP-2565 (Berlin): Minimum gas cost of 200 introduced
    // EIP-7883 (Osaka): Minimum gas cost increased from 200 to 500
    const min_gas: u64 = if (hardfork.isAtLeast(.OSAKA))
        500
    else if (hardfork.isAtLeast(.BERLIN))
        GasCosts.MODEXP_MIN
    else
        0; // No minimum before Berlin

    // Parse lengths (zero-pad if input is too short, matching Python buffer_read behavior)
    var padded_header: [96]u8 = [_]u8{0} ** 96;
    const header_copy_len = @min(input.len, 96);
    if (header_copy_len > 0) {
        @memcpy(padded_header[0..header_copy_len], input[0..header_copy_len]);
    }

    const base_len = bytesToU32(padded_header[0..32]);
    const exp_len = bytesToU32(padded_header[32..64]);
    const mod_len = bytesToU32(padded_header[64..96]);

    // EIP-7823: Upper bounds check (Prague+)
    // If any of base_len, exp_len, or mod_len exceeds 1024 bytes, the call fails
    const MAX_LENGTH_BYTES: u32 = 1024;
    if (hardfork.isAtLeast(.PRAGUE)) {
        if (base_len > MAX_LENGTH_BYTES or exp_len > MAX_LENGTH_BYTES or mod_len > MAX_LENGTH_BYTES) {
            // Return failure with empty output
            return PrecompileOutput{
                .output = &.{},
                .gas_used = gas_limit,
                .success = false,
            };
        }
    }

    // Calculate gas cost FIRST (before any validation), matching Python spec behavior
    // Read first 32 bytes of exponent from input (zero-pad if reading past end)
    const exp_start: usize = 96 + base_len;
    const exp_head_len = @min(exp_len, 32);

    // Read exp_head, zero-padding if we go past the input length
    var exp_head_bytes_buf: [32]u8 = [_]u8{0} ** 32;
    if (exp_start < input.len) {
        const available = input.len - exp_start;
        const to_copy = @min(exp_head_len, @as(u32, @intCast(available)));
        if (to_copy > 0) {
            @memcpy(exp_head_bytes_buf[0..to_copy], input[exp_start .. exp_start + to_copy]);
        }
    }
    const exp_head_bytes = exp_head_bytes_buf[0..exp_head_len];
    const exp_head_u256 = bytesToU256(exp_head_bytes);

    // Calculate multiplication complexity
    // EIP-198 (Byzantium): Three-tier formula based on max_length
    // EIP-2565 (Berlin): Simplified formula ((max_length + 7) / 8)^2
    // EIP-7883 (Osaka): Different thresholds and multipliers
    const max_len = @max(base_len, mod_len);
    const complexity = if (hardfork.isAtLeast(.OSAKA))
        calculateMultiplicationComplexityOsaka(max_len)
    else if (hardfork.isAtLeast(.BERLIN))
        calculateMultiplicationComplexityBerlin(max_len)
    else
        crypto.ModExp.unaudited_calculateMultiplicationComplexity(max_len);

    // Calculate iteration count based on adjusted exponent length
    // EIP-198 (Byzantium): Uses < 32 comparison
    // EIP-2565 (Berlin): Uses <= 32 comparison and special handling for zero exponent
    // EIP-7883 (Osaka): Same as Berlin but different byte multiplier
    const iteration_count = if (hardfork.isAtLeast(.OSAKA))
        calculateIterationCountOsaka(exp_len, exp_head_u256)
    else if (hardfork.isAtLeast(.BERLIN))
        calculateIterationCountBerlin(exp_len, exp_head_u256)
    else
        calculateIterationCount(exp_len, exp_head_u256);

    // Final gas cost calculation
    // EIP-198 (Byzantium): (complexity * iteration_count) / 20, no minimum
    // EIP-2565 (Berlin): (complexity * iteration_count) / 3, minimum of 200
    // EIP-7883 (Osaka): (complexity * iteration_count) / 1, minimum of 500
    const gas_divisor: u64 = if (hardfork.isAtLeast(.OSAKA))
        1
    else if (hardfork.isAtLeast(.BERLIN))
        3
    else
        20;
    // Use u128 for intermediate calculation to prevent overflow
    const complexity_u128 = @as(u128, complexity);
    const iteration_count_u128 = @as(u128, iteration_count);
    const product = complexity_u128 * iteration_count_u128;
    const cost_u128 = product / @as(u128, gas_divisor);
    // Clamp to u64::MAX if the result exceeds u64
    const cost = if (cost_u128 > std.math.maxInt(u64)) std.math.maxInt(u64) else @as(u64, @intCast(cost_u128));
    const required_gas = if (min_gas > 0) @max(min_gas, cost) else cost;

    // Check gas limit AFTER calculating gas cost (matching Python: charge_gas happens before operation)
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    // Now validate input and perform the operation
    // Handle special case: base_length == 0 and modulus_length == 0 (Python line 48)
    if (base_len == 0 and mod_len == 0) {
        const empty_output = try allocator.alloc(u8, 0);
        return PrecompileOutput{
            .output = empty_output,
            .gas_used = required_gas,
            .success = true,
        };
    }

    // Extract base, exp, mod (zero-pad if reading past input)
    // Apply reasonable memory limits to prevent DoS
    // Use the same limit as EIP-7823 (Prague) for safety across all forks
    const MAX_SAFE_LENGTH: u32 = 10 * 1024; // 10 KB - reasonable for test scenarios
    if (base_len > MAX_SAFE_LENGTH or exp_len > MAX_SAFE_LENGTH or mod_len > MAX_SAFE_LENGTH) {
        // Input lengths too large for allocation, but gas was already charged
        // Return error consuming all remaining gas
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    // Allocate and zero-initialize buffers for base, exp, mod
    const base = try allocator.alloc(u8, base_len);
    defer allocator.free(base);
    if (base.len > 0) @memset(base, 0);

    const exp = try allocator.alloc(u8, exp_len);
    defer allocator.free(exp);
    if (exp.len > 0) @memset(exp, 0);

    const mod = try allocator.alloc(u8, mod_len);
    defer allocator.free(mod);
    if (mod.len > 0) @memset(mod, 0);

    // Copy from input, handling cases where input is shorter than expected
    var offset: usize = 96;
    if (base.len > 0 and offset < input.len) {
        const base_copy_len = @min(base_len, @as(u32, @intCast(input.len - offset)));
        if (base_copy_len > 0) {
            @memcpy(base[0..base_copy_len], input[offset .. offset + base_copy_len]);
        }
    }
    offset += base_len;
    if (exp.len > 0 and offset < input.len) {
        const exp_copy_len = @min(exp_len, @as(u32, @intCast(input.len - offset)));
        if (exp_copy_len > 0) {
            @memcpy(exp[0..exp_copy_len], input[offset .. offset + exp_copy_len]);
        }
    }
    offset += exp_len;
    if (mod.len > 0 and offset < input.len) {
        const mod_copy_len = @min(mod_len, @as(u32, @intCast(input.len - offset)));
        if (mod_copy_len > 0) {
            @memcpy(mod[0..mod_copy_len], input[offset .. offset + mod_copy_len]);
        }
    }

    // Perform modular exponentiation
    const output = try allocator.alloc(u8, mod_len);

    // Check if modulus VALUE is zero (Python line 60)
    // If modulus is 0, return zeros without calling modexp
    var mod_is_zero = true;
    for (mod) |byte| {
        if (byte != 0) {
            mod_is_zero = false;
            break;
        }
    }

    if (mod_is_zero) {
        @memset(output, 0);
        return PrecompileOutput{
            .output = output,
            .gas_used = required_gas,
            .success = true,
        };
    }

    // Use the actual modexp implementation from crypto module
    crypto.ModExp.unaudited_modexp(allocator, base, exp, mod, output) catch {
        // On error, return zeros (following EVM spec)
        @memset(output, 0);
        return PrecompileOutput{
            .output = output,
            .gas_used = required_gas,
            .success = true,
        };
    };

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// Calculate iteration count for modexp gas calculation (EIP-198 - Byzantium)
/// Based on the adjusted exponent length
/// Note: Byzantium uses strictly less than 32, not less than or equal to
fn calculateIterationCount(exp_len: u32, exp_head: u256) u64 {
    const adjusted_exp_length: u64 = if (exp_len < 32) blk: {
        // For exp_len < 32, adjusted length is based on bit length of exp_head
        if (exp_head == 0) break :blk 0;
        const bit_length = 256 - @clz(exp_head);
        break :blk if (bit_length > 0) bit_length - 1 else 0;
    } else blk: {
        // For exp_len >= 32, adjusted length = 8 * (exp_len - 32) + bit_length_of_first_32_bytes - 1
        const bit_length = if (exp_head == 0) 0 else 256 - @clz(exp_head);
        const extra_bytes: u64 = exp_len - 32;
        break :blk 8 * extra_bytes + if (bit_length > 0) bit_length - 1 else 0;
    };

    // Return at least 1
    return @max(adjusted_exp_length, 1);
}

/// Calculate multiplication complexity for EIP-2565 (Berlin)
/// Simplified formula: ((max_length + 7) / 8)^2
fn calculateMultiplicationComplexityBerlin(max_len: u32) u64 {
    // Cast to u64 first to prevent overflow when max_len is close to u32::MAX
    const words: u64 = (@as(u64, max_len) + 7) / 8;
    return words * words;
}

/// Calculate iteration count for EIP-2565 (Berlin)
/// Uses <= 32 comparison and special handling for zero exponent
fn calculateIterationCountBerlin(exp_len: u32, exp_head: u256) u64 {
    // Special case: if exp_len <= 32 and exp_head == 0, return 0
    if (exp_len <= 32 and exp_head == 0) {
        return 1; // Still return at least 1 due to max at the end
    }

    const count: u64 = if (exp_len <= 32) blk: {
        // For exp_len <= 32, use bit length of exp_head
        if (exp_head == 0) break :blk 0;
        const bit_length = 256 - @clz(exp_head);
        break :blk if (bit_length > 0) bit_length - 1 else 0;
    } else blk: {
        // For exp_len > 32: 8 * (exp_len - 32) + bit_length - 1
        const bit_length = if (exp_head == 0) 0 else 256 - @clz(exp_head);
        const extra_bytes: u64 = exp_len - 32;
        break :blk 8 * extra_bytes + if (bit_length > 0) bit_length - 1 else 0;
    };

    // Return at least 1
    return @max(count, 1);
}

/// Calculate multiplication complexity for EIP-7883 (Osaka+)
/// Based on EIP-7883 spec with new constants
fn calculateMultiplicationComplexityOsaka(max_len: u32) u64 {
    // EIP-7883 constants
    const WORD_SIZE: u64 = 8;
    const MAX_LENGTH_THRESHOLD: u32 = 32;
    const LARGE_BASE_MODULUS_MULTIPLIER: u64 = 2;

    // Ceiling division: (max_len + WORD_SIZE - 1) / WORD_SIZE
    // Cast to u64 first to prevent overflow when max_len is close to u32::MAX
    const words: u64 = (@as(u64, max_len) + WORD_SIZE - 1) / WORD_SIZE;

    if (max_len <= MAX_LENGTH_THRESHOLD) {
        // For small inputs (<= 32 bytes): fixed cost of 16
        return 16;
    } else {
        // For large inputs (> 32 bytes): 2 * words^2
        return LARGE_BASE_MODULUS_MULTIPLIER * words * words;
    }
}

/// Calculate iteration count for EIP-7883 (Osaka+)
/// Based on EIP-7883 spec with new EXPONENT_BYTE_MULTIPLIER
fn calculateIterationCountOsaka(exp_len: u32, exp_head: u256) u64 {
    // EIP-7883 constants
    const EXPONENT_THRESHOLD: u32 = 32;
    const EXPONENT_BYTE_MULTIPLIER: u64 = 16; // Changed from 8 to 16

    const adjusted_exp_length: u64 = if (exp_len <= EXPONENT_THRESHOLD) blk: {
        // For exp_len <= 32, adjusted length is based on bit length of exp_head
        if (exp_head == 0) break :blk 0;
        const bit_length = 256 - @clz(exp_head);
        break :blk if (bit_length > 0) bit_length - 1 else 0;
    } else blk: {
        // For exp_len > 32: 16 * (exp_len - 32) + bit_length - 1
        const bit_length = if (exp_head == 0) 0 else 256 - @clz(exp_head);
        const extra_bytes: u64 = exp_len - 32;
        break :blk EXPONENT_BYTE_MULTIPLIER * extra_bytes + if (bit_length > 0) bit_length - 1 else 0;
    };

    // Return at least 1
    return @max(adjusted_exp_length, 1);
}

/// 0x06: ecAdd - BN254 elliptic curve addition
/// Input: 128 bytes (x1, y1, x2, y2 as 32-byte big-endian)
/// Output: 64 bytes (x, y coordinates of sum)
pub fn execute_ecadd(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64, hardfork: @import("../hardfork.zig").Hardfork) PrecompileError!PrecompileOutput {
    // EIP-1108 (Istanbul): Reduced from 500 to 150 gas
    const required_gas: u64 = if (hardfork.isAtLeast(.ISTANBUL)) GasCosts.ECADD else 500;
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    // Pad input to 128 bytes
    var padded_input: [128]u8 = [_]u8{0} ** 128;
    const copy_len = @min(input.len, 128);
    @memcpy(padded_input[0..copy_len], input[0..copy_len]);


    // Parse points
    const x1 = bytesToU256(padded_input[0..32]);
    const y1 = bytesToU256(padded_input[32..64]);
    const x2 = bytesToU256(padded_input[64..96]);
    const y2 = bytesToU256(padded_input[96..128]);

    const output = try allocator.alloc(u8, 64);

    // Handle identity shortcuts per EVM spec behavior expectations in tests:
    // If one operand is the point at infinity (encoded as all zeros), return the other point.
    if (x2 == 0 and y2 == 0) {
        u256ToBytes(x1, output[0..32]);
        u256ToBytes(y1, output[32..64]);
        return PrecompileOutput{ .output = output, .gas_used = required_gas, .success = true };
    }
    if (x1 == 0 and y1 == 0) {
        u256ToBytes(x2, output[0..32]);
        u256ToBytes(y2, output[32..64]);
        return PrecompileOutput{ .output = output, .gas_used = required_gas, .success = true };
    }

    // Use the actual BN254 implementation from crypto module
    const g1_x1 = crypto.bn254.FpMont.init(x1);
    const g1_y1 = crypto.bn254.FpMont.init(y1);
    const g1_x2 = crypto.bn254.FpMont.init(x2);
    const g1_y2 = crypto.bn254.FpMont.init(y2);

    // Create G1 points
    const point1 = crypto.bn254.G1{ .x = g1_x1, .y = g1_y1, .z = crypto.bn254.FpMont.ONE };
    const point2 = crypto.bn254.G1{ .x = g1_x2, .y = g1_y2, .z = crypto.bn254.FpMont.ONE };

    // Check if points are on curve
    if (!point1.isOnCurve() or !point2.isOnCurve()) {
        @memset(output, 0);
        return PrecompileOutput{
            .output = output,
            .gas_used = required_gas,
            .success = true,
        };
    }

    // Perform addition
    const result = point1.add(&point2);

    // Convert back to affine coordinates and bytes
    const result_affine = result.toAffine();
    const result_x = result_affine.x.toStandardRepresentation();
    const result_y = result_affine.y.toStandardRepresentation();

    u256ToBytes(result_x, output[0..32]);
    u256ToBytes(result_y, output[32..64]);

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x07: ecMul - BN254 elliptic curve multiplication
/// Input: 96 bytes (x, y, scalar as 32-byte big-endian)
/// Output: 64 bytes (x, y coordinates of product)
pub fn execute_ecmul(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64, hardfork: @import("../hardfork.zig").Hardfork) PrecompileError!PrecompileOutput {
    // EIP-1108 (Istanbul): Reduced from 40000 to 6000 gas
    const required_gas: u64 = if (hardfork.isAtLeast(.ISTANBUL)) GasCosts.ECMUL else 40000;
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    // Pad input to 96 bytes
    var padded_input: [96]u8 = [_]u8{0} ** 96;
    const copy_len = @min(input.len, 96);
    @memcpy(padded_input[0..copy_len], input[0..copy_len]);


    // Parse point and scalar
    const x = bytesToU256(padded_input[0..32]);
    const y = bytesToU256(padded_input[32..64]);
    const scalar = bytesToU256(padded_input[64..96]);

    const output = try allocator.alloc(u8, 64);

    // Handle scalar or point identity edge cases explicitly
    if (scalar == 0 or (x == 0 and y == 0)) {
        @memset(output, 0);
        return PrecompileOutput{ .output = output, .gas_used = required_gas, .success = true };
    }

    // Use the actual BN254 implementation from crypto module
    const g1_x = crypto.bn254.FpMont.init(x);
    const g1_y = crypto.bn254.FpMont.init(y);

    // Create G1 point
    const point = crypto.bn254.G1{ .x = g1_x, .y = g1_y, .z = crypto.bn254.FpMont.ONE };

    // Check if point is on curve
    if (!point.isOnCurve()) {
        @memset(output, 0);
        return PrecompileOutput{
            .output = output,
            .gas_used = required_gas,
            .success = true,
        };
    }

    // Perform scalar multiplication
    const result = point.mul_by_int(scalar);

    // Convert back to affine coordinates and bytes
    const result_affine = result.toAffine();
    const result_x = result_affine.x.toStandardRepresentation();
    const result_y = result_affine.y.toStandardRepresentation();

    u256ToBytes(result_x, output[0..32]);
    u256ToBytes(result_y, output[32..64]);

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x08: ecPairing - BN254 pairing check
/// Input: pairs of G1 and G2 points (192 bytes per pair)
/// Output: 32 bytes (1 if pairing is valid, 0 otherwise)
pub fn execute_ecpairing(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64, hardfork: @import("../hardfork.zig").Hardfork) PrecompileError!PrecompileOutput {
    // EIP-1108 (Istanbul): Reduced base cost from 100000 to 45000, per-pair from 80000 to 34000
    const base_cost: u64 = if (hardfork.isAtLeast(.ISTANBUL)) GasCosts.ECPAIRING_BASE else 100000;
    const per_pair_cost: u64 = if (hardfork.isAtLeast(.ISTANBUL)) GasCosts.ECPAIRING_PER_PAIR else 80000;

    if (input.len % 192 != 0) {
        const output = try allocator.alloc(u8, 32);
        @memset(output, 0);
        return PrecompileOutput{
            .output = output,
            .gas_used = base_cost,
            .success = true,
        };
    }

    const pair_count = input.len / 192;
    const required_gas = base_cost + pair_count * per_pair_cost;

    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }


    const output = try allocator.alloc(u8, 32);
    @memset(output, 0);

    if (pair_count == 0) {
        // Empty input means pairing is valid
        output[31] = 1;
        return PrecompileOutput{
            .output = output,
            .gas_used = required_gas,
            .success = true,
        };
    }

    // Declare the external C function from bn254_wrapper
    const c = struct {
        extern fn bn254_ecpairing(
            input: [*]const u8,
            input_len: c_uint,
            output: [*]u8,
            output_len: c_uint,
        ) callconv(.c) c_int;

        const BN254_SUCCESS = 0;
    };

    // Call the Rust BN254 implementation
    const result = c.bn254_ecpairing(input.ptr, @intCast(input.len), output.ptr, @intCast(output.len));

    if (result != c.BN254_SUCCESS) {
        // Invalid input or computation failed
        @memset(output, 0);
        return PrecompileOutput{
            .output = output,
            .gas_used = required_gas,
            .success = false,
        };
    }

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x09: blake2f - BLAKE2F compression function
/// Input: rounds(4) + h(64) + m(128) + t(16) + f(1) = 213 bytes
/// Output: 64 bytes (BLAKE2b state)
pub fn execute_blake2f(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    // Per EIP-152: Invalid input should consume all gas (ExceptionalHalt behavior)
    if (input.len != 213) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    // Parse rounds from first 4 bytes (big-endian)
    const rounds = std.math.shl(u32, @as(u32, input[0]), 24) |
        std.math.shl(u32, @as(u32, input[1]), 16) |
        std.math.shl(u32, @as(u32, input[2]), 8) |
        @as(u32, input[3]);

    // Calculate required gas (rounds * 1), explicitly as u64
    const required_gas: u64 = @as(u64, rounds) * @as(u64, GasCosts.BLAKE2F_PER_ROUND);
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    // Validate final block indicator (must be 0 or 1)
    // Per EIP-152: Invalid final flag should consume all gas (ExceptionalHalt behavior)
    const f = input[212];
    if (f != 0 and f != 1) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    const output = try allocator.alloc(u8, 64);

    // Parse input components
    const h_bytes = input[4..68]; // 64 bytes state (8 x u64)
    const m_bytes = input[68..196]; // 128 bytes message (16 x u64)
    const t_bytes = input[196..212]; // 16 bytes counter (2 x u64)

    // Convert bytes to u64 arrays (little-endian as per spec)
    var h: [8]u64 = undefined;
    var m: [16]u64 = undefined;
    var t: [2]u64 = undefined;

    for (0..8) |i| {
        h[i] = std.mem.readInt(u64, h_bytes[i * 8 ..][0..8], .little);
    }
    for (0..16) |i| {
        m[i] = std.mem.readInt(u64, m_bytes[i * 8 ..][0..8], .little);
    }
    t[0] = std.mem.readInt(u64, t_bytes[0..8], .little);
    t[1] = std.mem.readInt(u64, t_bytes[8..16], .little);

    // Use the actual blake2f implementation from crypto module
    crypto.Blake2.unaudited_blake2f_compress(&h, &m, t, f != 0, rounds);

    // Convert result back to bytes (little-endian)
    for (0..8) |i| {
        std.mem.writeInt(u64, output[i * 8 ..][0..8], h[i], .little);
    }

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x0A: pointEvaluation - KZG point evaluation (EIP-4844)
/// Input: 192 bytes (versioned_hash + z + y + commitment + proof)
/// Output: 64 bytes (FIELD_ELEMENTS_PER_BLOB + BLS_MODULUS)
pub fn execute_point_evaluation(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    // Per Python spec (point_evaluation.py:44-45), invalid input length check happens FIRST
    // (before gas charge). KZGProofError is an ExceptionalHalt which consumes ALL gas.
    if (input.len != 192) {
        return PrecompileOutput{ .output = &.{}, .gas_used = gas_limit, .success = false };
    }

    // Now check if we have enough gas (per Python spec line 54)
    const required_gas = GasCosts.POINT_EVALUATION;
    if (gas_limit < required_gas) {
        return PrecompileOutput{ .output = &.{}, .gas_used = gas_limit, .success = false };
    }

    // Parse input: versioned_hash(32) + z(32) + y(32) + commitment(48) + proof(48)
    const versioned_hash = input[0..32];
    const z_bytes = input[32..64];
    const y_bytes = input[64..96];
    const commitment_bytes = input[96..144];
    const proof_bytes = input[144..192];

    // Validate versioned hash corresponds to the commitment
    // Per Python spec (point_evaluation.py:55-56), this check happens AFTER charging gas
    // But failure raises KZGProofError (ExceptionalHalt) which consumes ALL gas
    const primitives_mod = primitives; // alias
    const Blob = primitives_mod.Blob;
    var commitment_arr: Blob.BlobCommitment = undefined;
    @memcpy(commitment_arr[0..], commitment_bytes);
    const expected_vh = Blob.commitment_to_versioned_hash(commitment_arr);
    if (!std.mem.eql(u8, expected_vh.bytes[0..], versioned_hash)) {
        return PrecompileOutput{ .output = &.{}, .gas_used = gas_limit, .success = false };
    }

    // Ensure KZG settings are initialized; try lazy init from embedded data if not
    // Failure raises KZGProofError (ExceptionalHalt) which consumes ALL gas
    if (!kzg_setup.isInitialized()) {
        kzg_setup.init() catch {
            return PrecompileOutput{ .output = &.{}, .gas_used = gas_limit, .success = false };
        };
    }

    // Perform KZG verification

    // Convert inputs to c_kzg types
    var z: crypto.c_kzg.Bytes32 = undefined;
    var y: crypto.c_kzg.Bytes32 = undefined;
    var commitment: crypto.c_kzg.KZGCommitment = undefined;
    var proof: crypto.c_kzg.KZGProof = undefined;

    @memcpy(&z, z_bytes);
    @memcpy(&y, y_bytes);
    @memcpy(&commitment, commitment_bytes);
    @memcpy(&proof, proof_bytes);

    // Verify the KZG proof
    // Per Python spec (lines 59-65), verification failure raises KZGProofError (ExceptionalHalt) which consumes ALL gas
    const valid = crypto.c_kzg.verifyKZGProof(&commitment, &z, &y, &proof) catch {
        return PrecompileOutput{ .output = &.{}, .gas_used = gas_limit, .success = false };
    };

    if (!valid) {
        return PrecompileOutput{ .output = &.{}, .gas_used = gas_limit, .success = false };
    }

    // Success - return FIELD_ELEMENTS_PER_BLOB and BLS_MODULUS as 32-byte big-endian values
    // Per EIP-4844 spec and execution-specs/src/ethereum/forks/cancun/vm/precompiled_contracts/point_evaluation.py
    const FIELD_ELEMENTS_PER_BLOB: u256 = 4096;
    const BLS_MODULUS: u256 = 52435875175126190479447740508185965837690552500527637822603658699938581184513;

    const output = try allocator.alloc(u8, 64);
    u256ToBytes(FIELD_ELEMENTS_PER_BLOB, output[0..32]);
    u256ToBytes(BLS_MODULUS, output[32..64]);

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true
    };
}

// Utility functions for byte manipulation
/// 0x0B: BLS12-381 G1 addition
pub fn execute_bls12_381_g1_add(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    const required_gas = GasCosts.BLS12_381_G1_ADD;
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    const output = try allocator.alloc(u8, 128);
    errdefer allocator.free(output);

    crypto.bls12_381.g1_add(input, output) catch {
        allocator.free(output);
        return PrecompileOutput{
            .output = &.{},
            .gas_used = required_gas,
            .success = false,
        };
    };

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x0C: BLS12-381 G1 scalar multiplication
pub fn execute_bls12_381_g1_mul(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    const required_gas = GasCosts.BLS12_381_G1_MUL;
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    const output = try allocator.alloc(u8, 128);
    errdefer allocator.free(output);

    crypto.bls12_381.g1_mul(input, output) catch {
        allocator.free(output);
        return PrecompileOutput{
            .output = &.{},
            .gas_used = required_gas,
            .success = false,
        };
    };

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x0D: BLS12-381 G1 multi-exponentiation
pub fn execute_bls12_381_g1_multiexp(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    // Dynamic gas based on number of pairs
    const num_pairs = input.len / 160;
    const required_gas = GasCosts.BLS12_381_G1_MULTIEXP_BASE * num_pairs;
    
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    const output = try allocator.alloc(u8, 128);
    errdefer allocator.free(output);

    crypto.bls12_381.g1_multiexp(input, output) catch {
        allocator.free(output);
        return PrecompileOutput{
            .output = &.{},
            .gas_used = required_gas,
            .success = false,
        };
    };

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x0E: BLS12-381 G2 addition (not implemented in Rust wrapper yet)
pub fn execute_bls12_381_g2_add(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    _ = allocator;
    _ = input;
    _ = gas_limit;
    return PrecompileError.NotImplemented;
}

/// 0x0F: BLS12-381 G2 scalar multiplication (not implemented in Rust wrapper yet)
pub fn execute_bls12_381_g2_mul(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    _ = allocator;
    _ = input;
    _ = gas_limit;
    return PrecompileError.NotImplemented;
}

/// 0x10: BLS12-381 G2 multi-exponentiation (not implemented in Rust wrapper yet)
pub fn execute_bls12_381_g2_multiexp(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    _ = allocator;
    _ = input;
    _ = gas_limit;
    return PrecompileError.NotImplemented;
}

/// 0x11: BLS12-381 pairing
pub fn execute_bls12_381_pairing(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    // Dynamic gas based on number of pairs
    const num_pairs = input.len / 384;
    const required_gas = GasCosts.BLS12_381_PAIRING_BASE + GasCosts.BLS12_381_PAIRING_PER_PAIR * num_pairs;
    
    if (gas_limit < required_gas) {
        return PrecompileOutput{
            .output = &.{},
            .gas_used = gas_limit,
            .success = false,
        };
    }

    const output = try allocator.alloc(u8, 32);
    errdefer allocator.free(output);

    crypto.bls12_381.pairing(input, output) catch {
        allocator.free(output);
        return PrecompileOutput{
            .output = &.{},
            .gas_used = required_gas,
            .success = false,
        };
    };

    return PrecompileOutput{
        .output = output,
        .gas_used = required_gas,
        .success = true,
    };
}

/// 0x12: BLS12-381 map field element to G1 (not implemented in Rust wrapper yet)
pub fn execute_bls12_381_map_fp_to_g1(allocator: std.mem.Allocator, input: []const u8, gas_limit: u64) PrecompileError!PrecompileOutput {
    _ = allocator;
    _ = input;
    _ = gas_limit;
    return PrecompileError.NotImplemented;
}

fn bytesToU256(bytes: []const u8) u256 {
    // Ensure we have exactly 32 bytes, padding with zeros if necessary
    var padded: [32]u8 = [_]u8{0} ** 32;
    const copy_len = @min(bytes.len, 32);
    @memcpy(padded[32 - copy_len..], bytes[0..copy_len]);
    return std.mem.readInt(u256, &padded, .big);
}

fn bytesToU32(bytes: []const u8) u32 {
    // Read a big-endian 32-byte field as u32, clamping to u32::MAX if value exceeds 2^32-1
    // Per EIP-198: Length fields are 32 bytes but should be capped at practical limits

    // Check if any of the first bytes (beyond what fits in u32) are non-zero
    // If so, the value exceeds u32::MAX and should be clamped
    if (bytes.len > 4) {
        for (bytes[0 .. bytes.len - 4]) |byte| {
            if (byte != 0) {
                return std.math.maxInt(u32); // Clamp to 2^32 - 1
            }
        }
    }

    // Read the last 4 bytes (or fewer) as big-endian u32
    var result: u32 = 0;
    const start_idx = if (bytes.len >= 4) bytes.len - 4 else 0;
    for (bytes[start_idx..]) |byte| {
        result = (result << 8) | byte;
    }
    return result;
}

fn u256ToBytes(value: u256, output: []u8) void {
    // Write the u256 as big-endian bytes
    var temp: [32]u8 = undefined;
    std.mem.writeInt(u256, &temp, value, .big);
    // Copy only the required bytes to output (handles output.len < 32)
    const offset = if (output.len < 32) 32 - output.len else 0;
    @memcpy(output, temp[offset..][0..output.len]);
}

test "is_precompile detects valid precompile addresses with hardfork awareness" {
    const testing = std.testing;

    // Test Frontier/Homestead precompiles (always available)
    try testing.expect(is_precompile(ECRECOVER_ADDRESS, .FRONTIER));
    try testing.expect(is_precompile(SHA256_ADDRESS, .HOMESTEAD));
    try testing.expect(is_precompile(RIPEMD160_ADDRESS, .HOMESTEAD));
    try testing.expect(is_precompile(IDENTITY_ADDRESS, .HOMESTEAD));

    // Test Byzantium precompiles (not available before Byzantium)
    try testing.expect(!is_precompile(MODEXP_ADDRESS, .HOMESTEAD));
    try testing.expect(is_precompile(MODEXP_ADDRESS, .BYZANTIUM));
    try testing.expect(is_precompile(ECADD_ADDRESS, .BYZANTIUM));
    try testing.expect(is_precompile(ECMUL_ADDRESS, .BYZANTIUM));
    try testing.expect(is_precompile(ECPAIRING_ADDRESS, .BYZANTIUM));

    // Test Istanbul precompiles (not available before Istanbul)
    try testing.expect(!is_precompile(BLAKE2F_ADDRESS, .BYZANTIUM));
    try testing.expect(!is_precompile(BLAKE2F_ADDRESS, .CONSTANTINOPLE));
    try testing.expect(is_precompile(BLAKE2F_ADDRESS, .ISTANBUL));

    // Test Cancun precompiles (not available before Cancun)
    try testing.expect(!is_precompile(POINT_EVALUATION_ADDRESS, .ISTANBUL));
    try testing.expect(is_precompile(POINT_EVALUATION_ADDRESS, .CANCUN));

    // Test BLS12-381 precompile addresses (EIP-2537, Prague)
    try testing.expect(!is_precompile(BLS12_381_G1_ADD_ADDRESS, .CANCUN));
    try testing.expect(is_precompile(BLS12_381_G1_ADD_ADDRESS, .PRAGUE));
    try testing.expect(is_precompile(BLS12_381_G1_MUL_ADDRESS, .PRAGUE));
    try testing.expect(is_precompile(BLS12_381_G1_MULTIEXP_ADDRESS, .PRAGUE));
    try testing.expect(is_precompile(BLS12_381_G2_ADD_ADDRESS, .PRAGUE));
    try testing.expect(is_precompile(BLS12_381_G2_MUL_ADDRESS, .PRAGUE));
    try testing.expect(is_precompile(BLS12_381_G2_MULTIEXP_ADDRESS, .PRAGUE));
    try testing.expect(is_precompile(BLS12_381_PAIRING_ADDRESS, .PRAGUE));
    try testing.expect(is_precompile(BLS12_381_MAP_FP_TO_G1_ADDRESS, .PRAGUE));

    // Test invalid addresses
    try testing.expect(!is_precompile(primitives.Address.from_u256(0), .PRAGUE));
    try testing.expect(!is_precompile(primitives.Address.from_u256(0x13), .PRAGUE)); // Beyond BLS12-381
    try testing.expect(!is_precompile(primitives.Address.from_u256(100), .PRAGUE));
}

test "execute_identity precompile" {
    const testing = std.testing;

    const input = "Hello, World!";
    const result = try execute_identity(testing.allocator, input, 1000);
    defer testing.allocator.free(result.output);

    try testing.expect(result.success);
    try testing.expectEqualSlices(u8, input, result.output);
    try testing.expect(result.gas_used == GasCosts.IDENTITY_BASE + GasCosts.IDENTITY_PER_WORD);
}

test "execute_sha256 precompile" {
    const testing = std.testing;

    const input = "abc";
    const result = try execute_sha256(testing.allocator, input, 1000);
    defer testing.allocator.free(result.output);

    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 32), result.output.len);

    // Expected SHA-256 hash of "abc"
    const expected = [_]u8{
        0xba, 0x78, 0x16, 0xbf, 0x8f, 0x01, 0xcf, 0xea, 0x41, 0x41, 0x40, 0xde, 0x5d, 0xae, 0x22, 0x23,
        0xb0, 0x03, 0x61, 0xa3, 0x96, 0x17, 0x7a, 0x9c, 0xb4, 0x10, 0xff, 0x61, 0xf2, 0x00, 0x15, 0xad,
    };
    try testing.expectEqualSlices(u8, &expected, result.output);
}

test "execute_ecrecover invalid signature" {
    const testing = std.testing;

    // Invalid input (all zeros)
    const input = [_]u8{0} ** 128;
    const result = try execute_ecrecover(testing.allocator, &input, GasCosts.ECRECOVER + 100);
    defer testing.allocator.free(result.output);

    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 32), result.output.len);
    // Should return all zeros for invalid signature
    for (result.output) |byte| {
        try testing.expectEqual(@as(u8, 0), byte);
    }
}

test "execute_modexp simple case" {
    const testing = std.testing;

    // 3^4 mod 5 = 81 mod 5 = 1
    var input: [128]u8 = [_]u8{0} ** 128;

    // base_len = 1 (32 bytes, big-endian)
    input[31] = 1;
    // exp_len = 1 (32 bytes, big-endian)
    input[63] = 1;
    // mod_len = 1 (32 bytes, big-endian)
    input[95] = 1;
    // base = 3
    input[96] = 3;
    // exp = 4
    input[97] = 4;
    // mod = 5
    input[98] = 5;

    const result = try execute_modexp(testing.allocator, input[0..99], 1000, @import("../hardfork.zig").Hardfork.CANCUN);
    defer testing.allocator.free(result.output);

    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 1), result.output.len);
    try testing.expectEqual(@as(u8, 1), result.output[0]);
}

test "execute_blake2f invalid input length" {
    const testing = std.testing;

    const input = [_]u8{0} ** 100; // Wrong length
    const result = try execute_blake2f(testing.allocator, &input, 1000);

    try testing.expect(!result.success);
    try testing.expectEqual(@as(usize, 0), result.output.len);
}

test "precompile gas cost calculations" {
    const testing = std.testing;

    // Test SHA256 gas cost scaling
    const small_input = "a";
    const large_input = "a" ** 100;

    const small_result = try execute_sha256(testing.allocator, small_input, 10000);
    defer testing.allocator.free(small_result.output);

    const large_result = try execute_sha256(testing.allocator, large_input, 10000);
    defer testing.allocator.free(large_result.output);

    // Large input should cost more gas
    try testing.expect(large_result.gas_used > small_result.gas_used);
}

test "precompile insufficient gas" {
    const testing = std.testing;

    const input = "test";

    // Test with insufficient gas
    const result = try execute_identity(testing.allocator, input, 5); // Too little gas

    try testing.expect(!result.success);
    try testing.expectEqual(@as(usize, 0), result.output.len);
}

test "execute_ripemd160 precompile" {
    const testing = std.testing;

    const input = "abc";
    const result = try execute_ripemd160(testing.allocator, input, 1000);
    defer testing.allocator.free(result.output);

    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 32), result.output.len);
    
    // Expected RIPEMD-160 hash of "abc" (20 bytes hash + 12 zero padding)
    const expected = [_]u8{
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x8e, 0xb2, 0x08, 0xf7, 0xe0, 0x5d, 0x98, 0x7a, 0x9b, 0x04,
        0x4a, 0x8e, 0x98, 0xc6, 0xb0, 0x87, 0xf1, 0x5a, 0x0b, 0xfc,
    };
    try testing.expectEqualSlices(u8, &expected, result.output);
}

test "execute_ecadd precompile" {
    const testing = std.testing;

    // Test: identity + identity = identity
    var input = [_]u8{0} ** 128;
    // Both points are identity (all zeros)

    const result = try execute_ecadd(testing.allocator, &input, GasCosts.ECADD + 100, .ISTANBUL);
    defer testing.allocator.free(result.output);
    
    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 64), result.output.len);
    // Result should be identity (all zeros)
    for (result.output) |byte| {
        try testing.expectEqual(@as(u8, 0), byte);
    }
}

test "execute_ecmul precompile" {
    const testing = std.testing;

    // Test: identity * 5 = identity
    var input = [_]u8{0} ** 96;
    // Point is identity (first 64 bytes all zeros)
    // Scalar is 5 (last 32 bytes)
    input[95] = 5;

    const result = try execute_ecmul(testing.allocator, &input, GasCosts.ECMUL + 100, .ISTANBUL);
    defer testing.allocator.free(result.output);
    
    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 64), result.output.len);
    // Result should be identity (all zeros)
    for (result.output) |byte| {
        try testing.expectEqual(@as(u8, 0), byte);
    }
}

test "execute_ecpairing precompile - empty input" {
    const testing = std.testing;

    // Empty input should return success with 1 (true)
    const input = &[_]u8{};
    const result = try execute_ecpairing(testing.allocator, input, GasCosts.ECPAIRING_BASE, .ISTANBUL);
    defer testing.allocator.free(result.output);
    
    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 32), result.output.len);
    // Should return 1 (true) for empty pairing
    try testing.expectEqual(@as(u8, 1), result.output[31]);
    for (result.output[0..31]) |byte| {
        try testing.expectEqual(@as(u8, 0), byte);
    }
}

test "execute_blake2f precompile" {
    const testing = std.testing;
    
    // Valid blake2f input (213 bytes)
    var input = [_]u8{0} ** 213;
    // rounds (4 bytes)
    input[3] = 12; // 12 rounds
    // h (64 bytes) - initial hash values
    // m (128 bytes) - message block
    // t (16 bytes) - offset counters
    // f (1 byte) - final block flag
    input[212] = 1; // final block
    
    const result = try execute_blake2f(testing.allocator, &input, 1000);
    defer testing.allocator.free(result.output);
    
    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 64), result.output.len);
    try testing.expectEqual(@as(u64, 12), result.gas_used); // 12 rounds * 1 gas per round
}

test "execute_modexp edge cases" {
    const testing = std.testing;
    
    // Test: 0^0 mod 5 = 1 (by convention)
    var input: [128]u8 = [_]u8{0} ** 128;
    
    // base_len = 1
    input[31] = 1;
    // exp_len = 1
    input[63] = 1;
    // mod_len = 1
    input[95] = 1;
    // base = 0 (already zero)
    // exp = 0 (already zero)
    // mod = 5
    input[98] = 5;
    
    const result = try execute_modexp(testing.allocator, &input, 10000, @import("../hardfork.zig").Hardfork.CANCUN);
    defer testing.allocator.free(result.output);
    
    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 1), result.output.len);
    // 0^0 mod 5 = 1
    try testing.expectEqual(@as(u8, 1), result.output[0]);
}

test "execute_ecrecover valid signature" {
    const testing = std.testing;
    
    // This is a real signature from Ethereum mainnet
    // Message hash, v, r, s values from a known transaction
    var input = [_]u8{0} ** 128;
    
    // Message hash (32 bytes)
    const hash = [_]u8{
        0x7c, 0x80, 0xc6, 0x8e, 0x60, 0x3b, 0xf0, 0x9a,
        0xca, 0x17, 0xa5, 0x73, 0xe2, 0xb2, 0x11, 0x42,
        0xed, 0xfb, 0x8e, 0x8d, 0xed, 0x9b, 0xea, 0xb6,
        0x6e, 0x0a, 0x23, 0xbe, 0xbd, 0x02, 0x3c, 0x23,
    };
    @memcpy(input[0..32], &hash);
    
    // v = 27 (recovery id)
    input[63] = 27;
    
    // r (32 bytes) 
    const r = [_]u8{
        0xa8, 0x89, 0xc0, 0xea, 0x64, 0xd6, 0xb8, 0xef,
        0x9a, 0x8a, 0x01, 0x96, 0x4f, 0x2f, 0x20, 0x18,
        0x44, 0xfb, 0x60, 0x7f, 0xf0, 0x83, 0xb8, 0xc9,
        0x42, 0x50, 0x5f, 0xd1, 0xa8, 0xee, 0xa6, 0x60,
    };
    @memcpy(input[64..96], &r);
    
    // s (32 bytes)
    const s = [_]u8{
        0x2a, 0x55, 0x0e, 0x6f, 0x48, 0xfb, 0x9d, 0x95,
        0x92, 0xab, 0x48, 0xca, 0x80, 0xf6, 0x77, 0x64,
        0x6c, 0x7f, 0xe7, 0x5e, 0x86, 0x2a, 0xfa, 0xb8,
        0xd2, 0xbc, 0x2e, 0xc8, 0x07, 0x1f, 0xfb, 0x10,
    };
    @memcpy(input[96..128], &s);
    
    const result = try execute_ecrecover(testing.allocator, &input, GasCosts.ECRECOVER + 100);
    defer testing.allocator.free(result.output);
    
    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 32), result.output.len);
    // Should return a valid address (20 bytes) with 12 bytes of zero padding
    // We just check that it's not all zeros
    var all_zero = true;
    for (result.output[12..32]) |byte| {
        if (byte != 0) {
            all_zero = false;
            break;
        }
    }
    try testing.expect(!all_zero);
}

test "execute_ecadd invalid point" {
    const testing = std.testing;

    // Test with invalid point (not on curve)
    var input = [_]u8{0} ** 128;
    // Set x coordinate to 1, y coordinate to 1 (not on curve)
    input[31] = 1;
    input[63] = 1;

    const result = try execute_ecadd(testing.allocator, &input, GasCosts.ECADD + 100, .ISTANBUL);

    // Should fail with invalid point
    try testing.expect(!result.success);
}

test "execute_ecmul invalid scalar" {
    const testing = std.testing;

    // Test with scalar larger than curve order
    var input = [_]u8{0} ** 96;
    // Set all scalar bytes to 0xFF (larger than curve order)
    @memset(input[64..96], 0xFF);

    const result = try execute_ecmul(testing.allocator, &input, GasCosts.ECMUL + 100, .ISTANBUL);
    defer testing.allocator.free(result.output);

    // Should still work (scalar is reduced modulo curve order)
    try testing.expect(result.success);
}

test "execute_ecpairing wrong input length" {
    const testing = std.testing;

    // Input length must be multiple of 192 bytes
    var input = [_]u8{0} ** 100; // Invalid length

    const result = try execute_ecpairing(testing.allocator, &input, 100000, .ISTANBUL);

    try testing.expect(!result.success);
}

test "execute_blake2f invalid final flag" {
    const testing = std.testing;
    
    // Valid length but invalid final flag
    var input = [_]u8{0} ** 213;
    input[212] = 2; // Invalid flag (must be 0 or 1)
    
    const result = try execute_blake2f(testing.allocator, &input, 1000);
    
    try testing.expect(!result.success);
}

test "execute_modexp with zero modulus" {
    const testing = std.testing;

    // Test: 5^3 mod 0 should fail
    var input: [128]u8 = [_]u8{0} ** 128;

    // base_len = 1
    input[31] = 1;
    // exp_len = 1
    input[63] = 1;
    // mod_len = 1
    input[95] = 1;
    // base = 5
    input[96] = 5;
    // exp = 3
    input[97] = 3;
    // mod = 0 (already zero)

    const result = try execute_modexp(testing.allocator, &input, 10000, @import("../hardfork.zig").Hardfork.CANCUN);
    defer testing.allocator.free(result.output);

    try testing.expect(result.success);
    // Result should be 0 when modulus is 0
    try testing.expectEqual(@as(usize, 1), result.output.len);
    try testing.expectEqual(@as(u8, 0), result.output[0]);
}

test "execute_blake2f with Istanbul test vector" {
    const testing = std.testing;

    // Test input from Istanbul test: 16 rounds with "abc" message
    const hex_input = "0000001048c9bdf267e6096a3ba7ca8485ae67bb2bf894fe72f36e3cf1361d5f3af54fa5d182e6ad7f520e511f6c3e2b8c68059b6bbd41fbabd9831f79217e1319cde05b61626300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000300000000000000000000000000000001";

    // Convert hex to bytes
    var input: [213]u8 = undefined;
    for (0..213) |i| {
        const hi = try std.fmt.charToDigit(hex_input[i * 2], 16);
        const lo = try std.fmt.charToDigit(hex_input[i * 2 + 1], 16);
        input[i] = (hi << 4) | lo;
    }

    // Call blake2f precompile
    const result = try execute_blake2f(testing.allocator, &input, 100000);
    defer testing.allocator.free(result.output);

    try testing.expect(result.success);
    try testing.expectEqual(@as(usize, 64), result.output.len);
    try testing.expectEqual(@as(u64, 16), result.gas_used);

    // Expected output (from test storage slots, in little-endian bytes):
    const expected_hex = "a8ef8236e5f48a74af375df15681d128457891c1cc4706f30747b2d40300b2f49d19f80fbd0945fd87736e1fc1ff10a80fd85a7aa5125154f3aaa3789ddff673";
    var expected: [64]u8 = undefined;
    for (0..64) |i| {
        const hi = try std.fmt.charToDigit(expected_hex[i * 2], 16);
        const lo = try std.fmt.charToDigit(expected_hex[i * 2 + 1], 16);
        expected[i] = (hi << 4) | lo;
    }

    // Compare outputs
    for (result.output, 0..) |byte, i| {
        if (byte != expected[i]) {
            std.debug.print("\nMismatch at byte {}: got 0x{x:0>2}, expected 0x{x:0>2}\n", .{i, byte, expected[i]});
        }
    }

    try testing.expectEqualSlices(u8, &expected, result.output);
}

test "execute_point_evaluation without kzg setup" {
    const testing = std.testing;

    // Try to use point evaluation without KZG setup
    // Skip if already initialized
    if (kzg_setup.isInitialized()) {
        return;
    }
    
    var input = [_]u8{0} ** 192;
    const result = try execute_point_evaluation(testing.allocator, &input, GasCosts.POINT_EVALUATION + 100);
    
    // Should fail without KZG setup
    try testing.expect(!result.success);
}

test "precompile address boundary checks" {
    const testing = std.testing;

    // Test addresses at boundaries (using Prague which has all precompiles)
    try testing.expect(is_precompile(ECRECOVER_ADDRESS, .PRAGUE)); // 0x01
    try testing.expect(is_precompile(POINT_EVALUATION_ADDRESS, .PRAGUE)); // 0x0A

    // Test addresses outside range
    try testing.expect(!is_precompile(primitives.Address.ZERO, .PRAGUE));
    try testing.expect(is_precompile(Address{ .bytes = [_]u8{0} ** 19 ++ [_]u8{0x0B} }, .PRAGUE)); // 0x0B is a valid BLS12-381 precompile
    try testing.expect(!is_precompile(Address{ .bytes = [_]u8{0} ** 19 ++ [_]u8{0x13} }, .PRAGUE)); // 0x13 is beyond valid precompiles
    try testing.expect(!is_precompile(Address{ .bytes = [_]u8{0xFF} ** 20 }, .PRAGUE)); // Max address
}

test "execute_all_precompiles smoke test" {
    const testing = std.testing;
    
    // Test that execute function correctly dispatches to all precompiles
    const addresses = [_]primitives.Address.Address{
        ECRECOVER_ADDRESS,
        SHA256_ADDRESS,
        RIPEMD160_ADDRESS,
        IDENTITY_ADDRESS,
        MODEXP_ADDRESS,
        ECADD_ADDRESS,
        ECMUL_ADDRESS,
        ECPAIRING_ADDRESS,
        BLAKE2F_ADDRESS,
        POINT_EVALUATION_ADDRESS,
    };
    
    for (addresses) |addr| {
        const result = try execute_precompile(testing.allocator, addr, &[_]u8{}, 100000, .CANCUN);
        defer if (result.output.len > 0) testing.allocator.free(result.output);

        // All should at least not error (may fail due to invalid input)
        try testing.expect(result.gas_used <= 100000);
    }
}
