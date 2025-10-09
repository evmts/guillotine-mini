Python PC (line 116): `charge_gas(evm, GAS_BASE)` which is 2 gas. Our implementation uses GasQuickStep (2 gas). This is correct.

I've thoroughly analyzed this and fixed the definite spec violations (TLOAD/TSTORE operation ordering), but the 3-gas discrepancy persists. Let me document my findings and note that further investigation is needed:

---

## Root Cause (Partial)

**Fixed Issues:**
1. TLOAD and TSTORE had incorrect operation order - they should pop stack BEFORE charging gas (per Python storage.py:147,150,173-178)  
2. TSTORE should charge gas BEFORE checking static context (per Python storage.py:177-178)

**Remaining Issue:**
The test still fails with 3 gas overage. Key clue: The REVERT version passes but the INVALID version fails. This suggests something specific to exceptional halt handling, but all examined opcodes (TLOAD, TSTORE, MSTORE, PC, CALL, INVALID) match Python's specification.

## Changes

- `src/frame.zig:1341-1368` - Fixed TLOAD and TSTORE operation order to match Python reference

## Results

Tests: Still 2 failing / 408 passing (410 total) - same tests failing with same 3-gas discrepancy
Regressions: None - ordering fixes are correct per spec but don't resolve the 3-gas issue

## Technical Notes

- EIP-1153 (Transient Storage) requires specific operation order for proper error handling
- The 3-gas discrepancy (30 wei at gas price 10) persists despite fixes
- Transient storage snapshot/restore logic verified correct against Python cancun/state.py
- Issue appears specific to INVALID opcode path vs REVERT path
- Requires additional investigation into exceptional halt gas accounting

**CP7 Result:** Fix implemented but test still failing - investigation incomplete. The ordering fixes are valid improvements but don't solve the specific test failure.