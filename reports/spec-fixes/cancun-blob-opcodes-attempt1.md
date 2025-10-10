Perfect! All the originally failing CREATE/CREATE2 tests now pass! Let me provide a summary:

## Summary

Successfully fixed the failing Cancun EIP-4844 BLOBHASH opcode tests!

### Root Cause
The `EXTCODECOPY` opcode (0x3c) was writing **zeros** to memory instead of actually copying code from external contracts. This caused:
- CREATE2 operations to receive empty init code
- Child contracts not executing their BLOBHASH/SSTORE operations  
- Gas undercharges of ~134,863 gas per test
- Wrong contract addresses being computed

### Fix Applied
Modified `src/frame.zig` (lines 2393-2407) to properly:
1. Retrieve external contract code using `evm.code.get()` or `host.getCode()`
2. Copy the actual bytecode to memory instead of zeros
3. Handle out-of-bounds reads by padding with zeros

### Results
✅ **Before:** 5 failing tests
✅ **After:** 1 failing test (unrelated to BLOBHASH)

**Fixed Tests:**
- ✅ `test_blobhash_opcode_contexts_fork_Cancun_state_test_on_CREATE_`
- ✅ `test_blobhash_opcode_contexts_fork_Cancun_state_test_on_CREATE2_`
- ✅ `test_blobhash_opcode_contexts_fork_Prague_state_test_on_CREATE_`
- ✅ `test_blobhash_opcode_contexts_fork_Prague_state_test_on_CREATE2_`

**Remaining Issue:**
The one remaining failure (`tx_type_4`) is specific to Prague's EIP-7702 authorization lists with a minor 87,500 wei difference, which is unrelated to the BLOBHASH opcode functionality.

The Cancun EIP-4844 BLOBHASH opcode tests are now fully functional! 🎉