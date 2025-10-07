Perfect! **All 200 tests passed!** Let me create a summary of what was fixed:

## Summary of Fixes

The Shanghai EIP-3651 warm coinbase tests were failing due to **two separate issues**:

### Issue 1: Missing "Paris" hardfork support
The test JSON files used "Paris" as the hardfork name for The Merge, but the codebase only recognized "Merge".

**Fix**: Added "Paris" as an alias for the MERGE hardfork in:
- `src/hardfork.zig`: Added Paris → MERGE mapping in `fromString()` function
- `test/specs/runner.zig`: Added "Paris" to the hardfork detection lists in `runJsonTest()` and `extractHardfork()`

### Issue 2: Incorrect post-state validation for non-Cancun/Prague forks
The state test validation code was hardcoded to only look for "Cancun" or "Prague" keys in the post section, ignoring all other hardforks (Berlin, London, Paris/Merge, Shanghai).

**Fix**: Updated the fork_data switch statement in `test/specs/runner.zig` (lines 1031-1042) to handle all hardforks properly:
- PRAGUE → looks for "Prague"
- CANCUN → looks for "Cancun"
- SHANGHAI → looks for "Shanghai"
- MERGE → looks for "Paris" or "Merge"
- LONDON → looks for "London"
- BERLIN → looks for "Berlin"
- Plus other older forks (Istanbul, Constantinople, Byzantium)

The EIP-3651 warm coinbase implementation itself was already correct - it properly warms the coinbase address at transaction start for Shanghai+ forks. The issues were entirely in the test infrastructure's hardfork recognition and validation logic.