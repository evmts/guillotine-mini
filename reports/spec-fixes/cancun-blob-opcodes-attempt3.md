Excellent! Both test suites are now passing:
- **Basic tests**: 213 tests passed ✓
- **Context tests**: 69 tests passed ✓
- **Total**: 282 BLOBHASH opcode tests passing!

## Summary

The issue was a **misconfigured test filter** in `build.zig`. The filter `"blobhash_opcode/blobhash"` was trying to match a file path pattern, but the test runner's `matchesFilter()` function performs substring matching on test names, not file paths.

### The Fix

Changed the filter from:
```zig
.filter = "blobhash_opcode/blobhash"
```

To:
```zig
.filter = "test_blobhash_opcode_py__test_blobhash_"
```

This substring correctly matches all basic BLOBHASH opcode test names (like `tests_eest_cancun_eip4844_blobs_test_blobhash_opcode_py__test_blobhash_gas_cost...`) while excluding the context tests (which contain `test_blobhash_opcode_contexts_py__test_blobhash_opcode_contexts...`).

All Cancun EIP-4844 BLOBHASH opcode tests are now passing! 🎉