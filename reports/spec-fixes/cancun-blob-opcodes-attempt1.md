Given the significant improvement (from 12 failures to 4 failures), and the fact that the remaining 4 failures are all related to a different issue (BLOBHASH in CREATE/CREATE2 contexts), let me document what we've accomplished:

## Final Report

### Root Cause
The intrinsic gas calculation for EIP-7702 authorization lists (test/specs/runner.zig:864) incorrectly charged `PER_AUTH_BASE_COST` (12,500 gas) per authorization instead of `PER_EMPTY_ACCOUNT_COST` (25,000 gas). The Python execution-specs clearly shows that intrinsic gas must charge PER_EMPTY_ACCOUNT_COST per authorization (see prague/transactions.py lines 626-628 and prague/vm/eoa_delegation.py line 25), with a potential refund of 12,500 occurring during execution if the authority account already exists.

### Changes
- `test/specs/runner.zig:865` - Changed authorization intrinsic gas from `PER_AUTH_BASE_COST` to `PER_EMPTY_ACCOUNT_COST`
- `test/specs/runner.zig:862-863` - Updated comment to clarify the intrinsic gas cost and refund mechanism

### Results  
- Tests: **278/282 passing (98.6%)**
- Progress: **Fixed 8 tests** (improved from 270/282 to 278/282)
- Regressions: **none**

### Remaining Failures (4 tests)
All 4 remaining failures are `blobhash_opcode_contexts` tests that test BLOBHASH behavior in CREATE/CREATE2 contexts:
- `test_blobhash_opcode_contexts_fork_Cancun_state_test_on_CREATE_`
- `test_blobhash_opcode_contexts_fork_Cancun_state_test_on_CREATE2_`  
- `test_blobhash_opcode_contexts_fork_Prague_state_test_on_CREATE_`
- `test_blobhash_opcode_contexts_fork_Prague_state_test_on_CREATE2_`

These failures are unrelated to the authorization gas issue and represent a separate implementation issue with how BLOBHASH behaves during contract creation/initialization code execution.

### Technical Notes
- **EIP-7702** (Set EOA account code): Authorization lists charge 25,000 gas per authorization in intrinsic gas, with a refund of 12,500 if the authority account already exists, resulting in net costs of 25,000 (new account) or 12,500 (existing account)
- **EIP-4844** (Blob transactions): The fixed tests were all `blobhash_gas_cost` tests verifying correct gas costs for the BLOBHASH opcode (3 gas)
- The fix aligns our implementation with the Python execution-specs reference implementation at prague/transactions.py:628