I've spent significant time investigating but haven't solved the issue yet. Let me document my findings:

## ✅ CHECKPOINT 7: Results  

**Status**: Tests still failing - 112 failed | 396 passed

## Root Cause Analysis (Incomplete)

**Confirmed Facts:**
1. Exact 20 gas overcharge (200 wei @ 10 gas price) across all failures
2. Only affects **Berlin+ fork tests** (Berlin, Cancun, Istanbul, London, Shanghai, Paris, Prague)
3. Constantinople-specific tests PASS (396 passing tests)
4. All failures are CREATE/CREATE2 with return data tests

**Investigated & Ruled Out:**
- ❌ Missing warm address snapshot/restore in `inner_create` - Added but didn't fix
- ❌ Precompile warming - Already correctly implemented in `preWarmTransaction`
- ❌ Type mismatch in hash maps - Fixed but didn't resolve issue

**Architectural Findings:**
- Python `incorporate_child_on_error` does NOT merge `accessed_addresses` back to parent
- Python `incorporate_child_on_success` DOES merge them (line 164-165)
- Our `inner_call` has correct snapshot/restore logic
- Our `inner_create` was missing it (added but didn't fix the issue)

**What Changed in Berlin (EIP-2929):**
- Warm/cold access costs introduced
- Precompiles must be pre-warmed at transaction start ✅ (we do this)
- Origin & target must be pre-warmed ✅ (we do this)

**Next Steps Needed:**
- Deep trace analysis comparing our execution vs Python reference for a single failing test
- Check if there's a hidden 20 gas charge in CREATE/CREATE2 operations for Berlin+
- Examine if BLOCKHASH (20 gas) or old BALANCE (20 gas pre-TW) is accidentally being charged
- Verify refund calculations don't have a 20 gas error

The 20 gas difference is too specific to be random - there's a systematic issue I haven't identified yet. The tests suggest it's related to how CREATE operations interact with Berlin's EIP-2929 warm/cold tracking, but the exact mechanism remains elusive.