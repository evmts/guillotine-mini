Perfect! Now I have enough information to compile the audit report. Let me create a comprehensive report:

# Agent 9: Keccak256 and Logging Opcodes Audit Report

## Summary
- Total opcodes audited: 6 (KECCAK256 + LOG0-LOG4)
- ✅ Correct: 2
- ⚠️ Issues found: 4

## Detailed Findings

### ✅ Correct Implementations

#### 1. KECCAK256 Gas Formula (Partial)
**File**: `src/frame.zig:315-318`
**Status**: ✅ Core formula correct
- Gas constants verified: `GAS_KECCAK256 = 30`, `GAS_KECCAK256_WORD = 6`
- Word count formula correct: `(size + 31) / 32`
- Base calculation: `30 + 6 * words`

#### 2. LOG Gas Formula Constants
**File**: `src/primitives/gas_constants.zig:116-124`
**Status**: ✅ All constants correct
- `LogGas = 375`
- `LogDataGas = 8`
- `LogTopicGas = 375`
- Gas calculation formula: `375 + (375 * topic_count) + (8 * size)`

### ⚠️ Issues Found

#### [CRITICAL] - KECCAK256: Missing Memory Expansion Cost
**File**: `src/frame.zig:646-689`
**Issue**: The KECCAK256 implementation does NOT include memory expansion cost in the gas calculation at line 652. It calculates the keccak256 gas cost (`30 + 6 * words`) but then charges memory expansion separately at line 666. However, this violates the spec requirement to calculate the total cost before charging.

**Current Implementation**:
```zig
// Line 652: Only charges keccak256 gas cost
const gas_cost = keccak256GasCost(size_u32);
try self.consumeGas(gas_cost);

// Lines 666-667: Memory expansion charged separately
const mem_cost = self.memoryExpansionCost(end_addr);
try self.consumeGas(mem_cost);
```

**Python Spec** (line 48-53):
```python
words = ceil32(Uint(size)) // Uint(32)
word_gas_cost = GAS_KECCAK256_WORD * words
extend_memory = calculate_gas_extend_memory(
    evm.memory, [(memory_start_index, size)]
)
charge_gas(evm, GAS_KECCAK256 + word_gas_cost + extend_memory.cost)
```

**Fix**: Calculate total gas cost (keccak256 + memory expansion) before charging:
```zig
// Calculate both costs first
const keccak_gas = keccak256GasCost(size_u32);
const offset_u32 = std.math.cast(u32, offset) orelse return error.OutOfBounds;
const end_addr = @as(u64, offset_u32) + @as(u64, size_u32);
const mem_cost = self.memoryExpansionCost(end_addr);

// Charge total cost once
try self.consumeGas(keccak_gas + mem_cost);

// Then expand memory
const aligned_size = wordAlignedSize(end_addr);
if (aligned_size > self.memory_size) self.memory_size = aligned_size;
```

**Impact**: Gas accounting is split across two consumeGas calls instead of one. While the total gas charged is correct, this doesn't match the spec's execution order and could potentially cause issues with out-of-gas errors occurring at the wrong point.

---

#### [CRITICAL] - LOG0-LOG4: Missing Memory Expansion Cost
**File**: `src/frame.zig:1237-1256`
**Issue**: The LOG implementation completely ignores memory expansion costs. It only charges the base LOG gas (`375 + 375*topics + 8*size`) but never charges for memory expansion, and never actually extends memory.

**Current Implementation**:
```zig
// Lines 1248-1251: Only charges LOG gas, no memory expansion
const length_u32 = std.math.cast(u32, length) orelse return error.OutOfBounds;
const log_cost = logGasCost(topic_count, length_u32);
try self.consumeGas(log_cost);

// Line 1254: Offset is discarded, memory never read or expanded
_ = offset;
```

**Python Spec** (lines 56-66):
```python
# GAS
extend_memory = calculate_gas_extend_memory(
    evm.memory, [(memory_start_index, size)]
)
charge_gas(
    evm,
    GAS_LOG
    + GAS_LOG_DATA * Uint(size)
    + GAS_LOG_TOPIC * Uint(num_topics)
    + extend_memory.cost,
)
```

**Fix**: Add memory expansion calculation and charging:
```zig
// Calculate memory expansion cost
const offset_u32 = std.math.cast(u32, offset) orelse return error.OutOfBounds;
const length_u32 = std.math.cast(u32, length) orelse return error.OutOfBounds;
const end_addr = @as(u64, offset_u32) + @as(u64, length_u32);
const mem_cost = self.memoryExpansionCost(end_addr);

// Calculate total gas cost including memory expansion
const log_cost = logGasCost(topic_count, length_u32);
try self.consumeGas(log_cost + mem_cost);

// Expand memory if needed
const aligned_size = wordAlignedSize(end_addr);
if (aligned_size > self.memory_size) self.memory_size = aligned_size;

// Read data from memory (even if not emitting logs)
// ... read memory[offset:offset+length] ...
```

**Impact**: HIGH - LOG operations cost significantly less gas than they should when accessing high memory addresses. This is a consensus-breaking bug that allows attackers to use arbitrarily large memory with LOG operations without paying the quadratic memory expansion cost.

---

#### [HIGH] - LOG0-LOG4: Missing STATICCALL Context Check
**File**: `src/frame.zig:1237-1256`
**Issue**: The LOG implementation does NOT check if the call is in a static context. All LOG opcodes must revert with `WriteInStaticContext` error when executed inside a STATICCALL.

**Current Implementation**:
```zig
// No static context check anywhere in LOG implementation
0xa0...0xa4 => {
    const topic_count = opcode - 0xa0;
    const offset = try self.popStack();
    const length = try self.popStack();
    // ... no is_static check ...
}
```

**Python Spec** (lines 70-71):
```python
# OPERATION
evm.memory += b"\x00" * extend_memory.expand_by
if evm.message.is_static:
    raise WriteInStaticContext
```

**Note**: The Python spec checks `is_static` AFTER charging gas (line 70), which means gas should be consumed even if the operation will revert due to static context.

**Fix**: Add static context check. First, need to add `is_static` field to Frame structure or access it from EVM context:
```zig
// After charging gas but before emitting log:
try self.consumeGas(log_cost + mem_cost);

// Check static context
if (self.is_static) {
    return error.WriteInStaticContext;
}

// Continue with log emission...
```

**Impact**: HIGH - LOG operations can be executed in STATICCALL contexts, which violates the EVM spec. Static calls should not be able to modify state or emit logs. This is a consensus-breaking bug.

---

#### [MEDIUM] - LOG0-LOG4: Stack Order Inconsistency
**File**: `src/frame.zig:1242-1246`
**Issue**: Topics are popped from the stack but their order may not match the spec. The implementation pops topics but discards them immediately.

**Current Implementation**:
```zig
// Pop topics
var i: u8 = 0;
while (i < topic_count) : (i += 1) {
    _ = try self.popStack();  // Topics discarded
}
```

**Python Spec** (lines 52-54):
```python
topics = []
for _ in range(num_topics):
    topic = pop(evm.stack).to_be_bytes32()
    topics.append(topic)
```

**Fix**: While the current implementation correctly pops the right number of topics (consuming them from the stack), it should preserve them in proper order for potential log emission:
```zig
// Pop and store topics in correct order
var topics: [4]u256 = undefined;
var i: u8 = 0;
while (i < topic_count) : (i += 1) {
    topics[i] = try self.popStack();
}
// Note: topics[0] is the first topic popped (top of stack)
```

**Impact**: MEDIUM - Stack manipulation is correct, but topics are not preserved. Since logs are not actually emitted (comment on line 1253), this doesn't affect current functionality, but it's incorrect for a complete implementation.

---

## KECCAK256 Verification
- [✅] Gas constant: 30 ✓
- [✅] Word gas constant: 6 ✓
- [✅] Word count formula: `(size + 31) / 32` ✓
- [⚠️] Gas formula: `30 + 6 * words` - **Correct but memory expansion charged separately**
- [⚠️] Memory expansion cost - **Charged separately instead of together**
- [✅] Keccak256 implementation - Uses `std.crypto.hash.sha3.Keccak256` ✓
- [✅] Empty hash optimization - Correct hash value ✓

## LOG Verification
- [✅] All 5 variants (LOG0-LOG4) implemented
- [⚠️] **STATICCALL restriction NOT enforced**
- [⚠️] **Gas formula INCOMPLETE - missing memory expansion**
- [⚠️] Log structure - Not actually emitted (minimal implementation)
- [✅] Topics limited to 0-4 ✓
- [⚠️] Memory reading - **Not implemented**

## Gas Constants
- [✅] GAS_KECCAK256 = 30
- [✅] GAS_KECCAK256_WORD = 6
- [✅] GAS_LOG = 375
- [✅] GAS_LOG_DATA = 8
- [✅] GAS_LOG_TOPIC = 375

## Priority Summary
- **CRITICAL**: 2 issues
  1. LOG0-LOG4: Missing memory expansion cost
  2. KECCAK256: Memory expansion charged separately
- **HIGH**: 1 issue
  1. LOG0-LOG4: Missing STATICCALL context check
- **MEDIUM**: 1 issue
  1. LOG0-LOG4: Topics discarded instead of stored

## Additional Notes

1. **Minimal Implementation**: The code comment on line 1253 states "In minimal implementation, we don't actually emit logs". This explains why logs aren't emitted, but the implementation still needs to:
   - Charge correct gas (including memory expansion)
   - Check static context
   - Read memory to trigger expansion

2. **Word Count Formula**: The Zig implementation uses `(bytes + 31) / 32` which is mathematically equivalent to the Python spec's `ceil32(Uint(size)) // Uint(32)` formula.

3. **Gas Charging Order**: The Python spec shows that for LOG opcodes, gas should be charged BEFORE checking static context. This means:
   - Gas is consumed first
   - Then static check reverts if needed
   - This allows the operation to consume gas even when it will fail

4. **KECCAK256 Edge Case**: The implementation correctly handles the empty data case (size = 0) with the correct hash value `0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470`.

## Recommendations

1. **Immediate**: Fix LOG memory expansion (CRITICAL)
2. **Immediate**: Consolidate KECCAK256 gas charging into single call (CRITICAL)
3. **High Priority**: Add static context checking to LOG opcodes (HIGH)
4. **Medium Priority**: Preserve topic values for potential log emission (MEDIUM)
5. **Future**: Implement actual log emission when moving beyond minimal implementation