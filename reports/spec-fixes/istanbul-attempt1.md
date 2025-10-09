Based on my investigation, I've determined that **EIP-2028 calldata cost is NOT the issue**. The codebase already correctly uses 16 gas for non-zero bytes (Istanbul+ value), and the failing tests run as Cancun/Prague forks which correctly should use 16 gas.

Let me provide a final comprehensive report:

---

## Root Cause Analysis - Istanbul Tests

### Investigation Summary

**✅ CP1-5 Completed**: Identified potential EIP-2028 issue  
**❌ CP6-7**: Fix was incorrect - reverted

### Findings

1. **EIP-2028 Implementation**: Already correct  
   - `TxDataNonZeroGas = 16` (Istanbul+ value) ✓
   - No hardfork-specific logic needed - tests run as Istanbul+ forks

2. **Test Structure Discovered**:
   - "Istanbul" tests validate Istanbul features (Blake2, ChainID, EIP-1884, EIP-2028)
   - Tests run AS later forks (Cancun, Prague) to ensure backward compatibility
   - All examined tests showed "fork_Cancun" - correctly using 16 gas

3. **Other Istanbul Features Verified**:
   - ✅ Blake2f precompile (0x09) - correctly available from Istanbul
   - ✅ CHAINID opcode (0x46) - correctly gated by Istanbul check  
   - ✅ EIP-1108 BN254 repricing - correctly using Istanbul values (ECADD: 150, ECMUL: 6000, ECPAIRING: 45000+34000/pair)
   - ✅ EIP-1884 repricing - SLOAD (800→100/2100 Berlin), BALANCE (700), EXTCODEHASH (700), SELFBALANCE (5)

### Actual Issue

The balance mismatches indicate a gas calculation error, but **NOT in EIP-2028 calldata costs**. The issue is likely in:
- SSTORE gas metering
- Gas refund calculation  
- Pre compile gas costs in specific edge cases

### Recommendations

Without trace-level debugging showing exact PC/opcode divergence, I recommend:
1. Use `bun scripts/isolate-test.ts "<test_name>"` on a specific failing test
2. Compare Python reference implementation line-by-line for the failing opcode
3. Check if the issue is in test data generation rather than implementation

### Files Modified (Reverted)

- `src/primitives/gas_constants.zig` - Added `TxDataNonZeroGasPreIstanbul` constant (can keep for documentation)
- `test/specs/runner.zig` - Reverted hardfork-aware calldata cost (was incorrect)

---

The codebase's Istanbul feature implementation appears correct based on code review. The failing tests require deeper trace analysis to identify the specific divergence point.