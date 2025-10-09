After extensive investigation, I've identified and fixed one issue (warm set snapshotting), but a 3-gas discrepancy remains. Let me document my findings:

## Root Cause (Partial)
The warm address/storage set isolation between parent and failed child calls wasn't being handled correctly. Python's `incorporate_child_on_error` doesn't merge `accessed_addresses` or `accessed_storage_keys`, but our shared HashMap approach meant failed calls incorrectly kept their warm state.

**Fix Applied:** Added snapshot/restore logic for `warm_addresses` and `warm_storage_slots` in `inner_call`, matching the existing transient_storage pattern.

## Remaining Issue  
The test still fails with a 3-gas unit (30 wei) over-charge. After investigation:
- Transient storage restoration: ✓ Working correctly  
- Warm set restoration: ✓ Now spec-compliant
- INVALID opcode: ✓ Consumes all gas correctly
- CALL gas calculation: ✓ EIP-150 formula correct
- Refund logic: ✓ Matches Python spec
- Gas constants: ✓ MSTORE=3, PUSH=3, etc. correct

The 3-gas precision suggests a specific operation miscalculation, but the root cause remains elusive. **408 of 410 tests pass (99.5%)**.

## Changes
- `src/evm.zig:506-521` - Added warm set snapshots before calls
- `src/evm.zig:684-698` - Restore warm sets on exceptional halt  
- `src/evm.zig:740-754` - Restore warm sets on revert

## Results
Tests: 408/410 passing (unchanged from before fix)
Regressions: None
Improvement: Warm set handling now matches Python spec, though it doesn't resolve this specific test

## Technical Notes
- EIP-2929: Warm/cold tracking must be isolated per-call to match `incorporate_child_on_error` behavior
- The warm set fix is architecturally correct but doesn't address the 3-gas discrepancy in this test
- Further investigation needed: The 3-gas difference likely involves a subtle operation counting or gas calculation edge case in the complex nested call + INVALID scenario