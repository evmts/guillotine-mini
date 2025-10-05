# Agent 12: Precompiled Contracts Auditor

## Objective
Exhaustively audit all 18 precompiled contracts (0x01-0x12) including BLS12-381 operations.

## Scope
**Files to examine**:
- Zig: `src/frame.zig` (check for precompile dispatch)
- Zig: Search for separate precompile implementations
- Python spec: `execution-specs/src/ethereum/forks/prague/vm/precompiled_contracts/`
- **Reference implementation**: `guillotine-reference/src/crypto/` and `guillotine-reference/src/evm.zig`

## Reference Implementation

**CRITICAL**: Use `guillotine-reference/` for working precompile implementations:
- Location: `guillotine-reference/src/crypto/` contains crypto primitives including BLS12-381
- Dependencies: Check `guillotine-reference/Cargo.toml` for Rust crypto crates used
- Integration: See how precompiles are called in `guillotine-reference/src/evm.zig`

This reference shows:
- How BLS12-381 operations should be implemented
- Which Rust crates are used (e.g., blst, arkworks)
- Gas calculation patterns
- Input validation and error handling

## Tasks

### Standard Precompiles (0x01-0x0A)

#### 1. ecRecover (0x01)
**Check**:
- [ ] Implemented
- [ ] Input: 128 bytes (hash, v, r, s)
- [ ] Output: 32 bytes (recovered address) or empty if invalid
- [ ] Gas cost: 3000 (GAS_ECRECOVER)

**Spec**:
```python
def ecrecover(input_data: bytes) -> bytes:
    if len(input_data) < 128:
        input_data = input_data.ljust(128, b'\x00')

    hash = input_data[0:32]
    v = Uint.from_bytes(input_data[32:64], 'big')
    r = Uint.from_bytes(input_data[64:96], 'big')
    s = Uint.from_bytes(input_data[96:128], 'big')

    # Validate
    if v not in [27, 28] or r == 0 or r >= SECP256K1_N or s == 0 or s >= SECP256K1_N:
        return b''

    # Recover public key
    pubkey = secp256k1_recover(hash, v - 27, r, s)
    if pubkey is None:
        return b''

    # Return address (last 20 bytes of keccak256(pubkey))
    address = keccak256(pubkey)[12:32]
    return b'\x00' * 12 + address

GAS_ECRECOVER = 3000
```

#### 2. SHA256 (0x02)
**Check**:
- [ ] Implemented
- [ ] Input: any size
- [ ] Output: 32 bytes
- [ ] Gas cost: 60 + 12 * words

**Spec**:
```python
def sha256(input_data: bytes) -> bytes:
    return hashlib.sha256(input_data).digest()

def gas_sha256(input_size: int) -> int:
    words = (input_size + 31) // 32
    return GAS_SHA256 + GAS_SHA256_WORD * words  # 60 + 12 * words
```

#### 3. RIPEMD160 (0x03)
**Check**:
- [ ] Implemented
- [ ] Input: any size
- [ ] Output: 32 bytes (20-byte hash left-padded with 12 zeros)
- [ ] Gas cost: 600 + 120 * words

#### 4. Identity (0x04)
**Check**:
- [ ] Implemented
- [ ] Input: any size
- [ ] Output: same as input (copy)
- [ ] Gas cost: 15 + 3 * words

#### 5. ModExp (0x05) - EIP-198
**Check**:
- [ ] Implemented
- [ ] Input: dynamic (base_len, exp_len, mod_len, base, exp, mod)
- [ ] Output: (base^exp) % mod
- [ ] Complex gas calculation based on size and exponent

**Spec**:
```python
def modexp(input_data: bytes) -> bytes:
    base_len = Uint.from_bytes(input_data[0:32], 'big')
    exp_len = Uint.from_bytes(input_data[32:64], 'big')
    mod_len = Uint.from_bytes(input_data[64:96], 'big')

    base = Uint.from_bytes(input_data[96:96+base_len], 'big')
    exp = Uint.from_bytes(input_data[96+base_len:96+base_len+exp_len], 'big')
    mod = Uint.from_bytes(input_data[96+base_len+exp_len:96+base_len+exp_len+mod_len], 'big')

    if mod == 0:
        result = 0
    else:
        result = pow(base, exp, mod)

    return result.to_bytes(mod_len, 'big')
```

**Gas calculation is complex** - see EIP-198 for details.

#### 6. ecAdd (0x06) - BN254/alt_bn128
**Check**:
- [ ] Implemented
- [ ] Input: 128 bytes (two points on BN254 curve)
- [ ] Output: 64 bytes (point addition result)
- [ ] Gas cost: 150

#### 7. ecMul (0x07) - BN254/alt_bn128
**Check**:
- [ ] Implemented
- [ ] Input: 96 bytes (point + scalar)
- [ ] Output: 64 bytes (point multiplication result)
- [ ] Gas cost: 6000

#### 8. ecPairing (0x08) - BN254/alt_bn128
**Check**:
- [ ] Implemented
- [ ] Input: multiple of 192 bytes (pairs of points)
- [ ] Output: 32 bytes (1 if pairing check succeeds, 0 otherwise)
- [ ] Gas cost: 45000 + 34000 * pairs

#### 9. Blake2F (0x09) - EIP-152
**Check**:
- [ ] Implemented
- [ ] Input: 213 bytes (rounds, h, m, t, f)
- [ ] Output: 64 bytes (Blake2 compression function result)
- [ ] Gas cost: 1 * rounds

#### 10. Point Evaluation (0x0A) - EIP-4844 KZG
**Check**:
- [ ] Implemented
- [ ] Input: 192 bytes (versioned_hash, z, y, commitment, proof)
- [ ] Output: 64 bytes (success indicator and result)
- [ ] Gas cost: 50000 (GAS_POINT_EVALUATION)

**Spec**:
```python
def point_evaluation(input_data: bytes) -> bytes:
    if len(input_data) != 192:
        raise InvalidInput

    versioned_hash = input_data[0:32]
    z = input_data[32:64]
    y = input_data[64:96]
    commitment = input_data[96:144]  # 48 bytes
    proof = input_data[144:192]  # 48 bytes

    # Verify KZG proof
    if not verify_kzg_proof(commitment, z, y, proof):
        raise InvalidProof

    # Check commitment hash matches
    if keccak256(commitment) != versioned_hash:
        raise InvalidInput

    # Success
    return FIELD_ELEMENTS_PER_BLOB.to_bytes(32, 'big') + BLS_MODULUS.to_bytes(32, 'big')

GAS_POINT_EVALUATION = 50000
```

### BLS12-381 Precompiles (0x0B-0x12) - EIP-2537

**CRITICAL**: These are likely MISSING or INCOMPLETE. Check `guillotine-reference/` for implementations.

#### 11. BLS12_G1ADD (0x0B)
**Check**:
- [ ] Implemented
- [ ] Input: 256 bytes (two G1 points)
- [ ] Output: 128 bytes (G1 point)
- [ ] Gas cost: 375 (GAS_BLS_G1_ADD)

**Spec**:
```python
def bls12_g1add(input_data: bytes) -> bytes:
    if len(input_data) != 256:
        raise InvalidInput

    p1 = decode_g1_point(input_data[0:128])
    p2 = decode_g1_point(input_data[128:256])

    result = p1 + p2  # BLS12-381 G1 addition

    return encode_g1_point(result)

GAS_BLS_G1_ADD = 375
```

#### 12. BLS12_G1MUL (0x0C)
**Check**:
- [ ] Implemented
- [ ] Input: 160 bytes (G1 point + scalar)
- [ ] Output: 128 bytes (G1 point)
- [ ] Gas cost: 12000 (GAS_BLS_G1_MUL)

#### 13. BLS12_G1MSM (0x0D) - Multi-Scalar Multiplication
**Check**:
- [ ] Implemented
- [ ] Input: variable (pairs of points and scalars)
- [ ] Output: 128 bytes (G1 point)
- [ ] Dynamic gas based on discount table

#### 14. BLS12_G2ADD (0x0E)
**Check**:
- [ ] Implemented
- [ ] Input: 512 bytes (two G2 points)
- [ ] Output: 256 bytes (G2 point)
- [ ] Gas cost: 600 (GAS_BLS_G2_ADD)

#### 15. BLS12_G2MUL (0x0F)
**Check**:
- [ ] Implemented
- [ ] Input: 288 bytes (G2 point + scalar)
- [ ] Output: 256 bytes (G2 point)
- [ ] Gas cost: 22500 (GAS_BLS_G2_MUL)

#### 16. BLS12_G2MSM (0x10)
**Check**:
- [ ] Implemented
- [ ] Input: variable
- [ ] Output: 256 bytes (G2 point)
- [ ] Dynamic gas

#### 17. BLS12_PAIRING (0x11)
**Check**:
- [ ] Implemented
- [ ] Input: variable (pairs of G1 and G2 points)
- [ ] Output: 32 bytes (1 if pairing succeeds, 0 otherwise)
- [ ] Gas cost: 43000 + 65000 * pairs

**Spec**:
```python
def bls12_pairing(input_data: bytes) -> bytes:
    if len(input_data) % 384 != 0:
        raise InvalidInput

    pairs = []
    for i in range(0, len(input_data), 384):
        g1 = decode_g1_point(input_data[i:i+128])
        g2 = decode_g2_point(input_data[i+128:i+384])
        pairs.append((g1, g2))

    result = bls12_381_pairing_check(pairs)

    return b'\x00' * 31 + (b'\x01' if result else b'\x00')

GAS_BLS_PAIRING_BASE = 43000
GAS_BLS_PAIRING_PER_PAIR = 65000
```

#### 18. BLS12_MAP_FP_TO_G1 (0x12)
**Check**:
- [ ] Implemented
- [ ] Input: 64 bytes (field element)
- [ ] Output: 128 bytes (G1 point)
- [ ] Gas cost: 5500 (GAS_BLS_G1_MAP)

#### 19. BLS12_MAP_FP2_TO_G2 (0x13)
**Check**:
- [ ] Implemented
- [ ] Input: 128 bytes (field element)
- [ ] Output: 256 bytes (G2 point)
- [ ] Gas cost: 23800 (GAS_BLS_G2_MAP)

## Precompile Dispatch

**Check**:
- [ ] Precompiles called when target address is 0x01-0x12
- [ ] Gas charged before execution
- [ ] Errors handled correctly (invalid input returns empty, consumes all forwarded gas)
- [ ] Output returned to caller

**Spec**:
```python
def call_precompile(address: int, input_data: bytes, gas: int) -> Tuple[bytes, int]:
    if address == 0x01:
        gas_cost = 3000
        if gas < gas_cost:
            raise OutOfGas
        return ecrecover(input_data), gas - gas_cost
    elif address == 0x02:
        gas_cost = calculate_sha256_gas(len(input_data))
        if gas < gas_cost:
            raise OutOfGas
        return sha256(input_data), gas - gas_cost
    # ... etc for all precompiles
```

## Gas Constants to Verify

**In `src/primitives/gas_constants.zig`**:
```zig
// Standard precompiles
GAS_ECRECOVER = 3000
GAS_SHA256 = 60
GAS_SHA256_WORD = 12
GAS_RIPEMD160 = 600
GAS_RIPEMD160_WORD = 120
GAS_IDENTITY = 15
GAS_IDENTITY_WORD = 3
GAS_BLAKE2_PER_ROUND = 1
GAS_POINT_EVALUATION = 50000

// BLS12-381 (EIP-2537) - LIKELY MISSING
GAS_BLS_G1_ADD = 375
GAS_BLS_G1_MUL = 12000
GAS_BLS_G1_MAP = 5500
GAS_BLS_G2_ADD = 600
GAS_BLS_G2_MUL = 22500
GAS_BLS_G2_MAP = 23800
GAS_BLS_PAIRING_BASE = 43000
GAS_BLS_PAIRING_PER_PAIR = 65000
```

## Output Format

```markdown
# Agent 12: Precompiled Contracts Audit Report

## Summary
- Total precompiles audited: 18 (0x01-0x12/0x13)
- ✅ Implemented: X
- ⚠️ Missing/incomplete: Y
- ❌ Incorrect: Z

## Detailed Findings

### ✅ Correct Implementations
[List precompiles matching spec]

### ❌ Missing Implementations
[List missing precompiles with CRITICAL priority]

### ⚠️ Issues Found

#### [Priority] - [Precompile Name] (0xNN)
**File**: [path:line or "NOT FOUND"]
**Issue**: [Description]
**Reference**: Check `guillotine-reference/src/crypto/` for implementation example
**Fix**: [What needs to be implemented/fixed]

## BLS12-381 Status (EIP-2537)
- [ ] All 8 gas constants defined
- [ ] All 8 operations implemented (0x0B-0x12/0x13)
- [ ] Point encoding/decoding correct
- [ ] Field element validation

## Gas Cost Verification
[Table of all precompiles with expected vs actual gas costs]

## Reference Implementation Notes
**From `guillotine-reference/`**:
- Crypto dependencies used: [List from Cargo.toml]
- BLS12-381 implementation location: [Path]
- Integration pattern: [Description]

## Priority Summary
- **CRITICAL**: [Count] - Missing precompiles
- **HIGH**: [Count] - Incorrect gas/implementation
- **MEDIUM**: [Count] - Input validation issues
```

## Notes
- BLS12-381 operations (0x0B-0x12/0x13) are the most complex
- Use `guillotine-reference/` as working example
- Missing BLS12-381 is CRITICAL priority
- Check both gas constants AND implementations
