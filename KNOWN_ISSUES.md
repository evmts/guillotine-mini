# Known Issues

## EIP-4844 Point Evaluation Tests Performance

The Cancun EIP-4844 blob precompile tests (specs-cancun-blob-precompile-basic) run slowly due to the C-KZG library's lack of thread safety. To ensure correctness when running tests in parallel, KZG proof verification operations are serialized using a global mutex, which limits concurrency and increases test duration.

### Root Cause
The underlying C-KZG library (`c-kzg-4844`) maintains global state and is not thread-safe for concurrent verification operations. When multiple tests attempt to verify KZG proofs simultaneously, it can lead to race conditions and test failures.

### Solution
A global mutex (`verify_mutex`) in `src/precompiles/kzg_setup.zig` serializes all KZG proof verification calls to ensure thread safety and test correctness.

### Impact
- Tests pass reliably but run slower than ideal
- Test execution time increases proportionally with the number of tests
- Individual tests still pass quickly when run in isolation

### Future Improvements
- Investigate if the C-KZG library can be updated to support concurrent operations
- Consider using a thread-local KZG setup per worker
- Evaluate alternative KZG implementations with better concurrency support
