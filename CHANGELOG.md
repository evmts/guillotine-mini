# Changelog

## Unreleased

- Build WASM as a WASI Preview 1 reactor with its Rust cryptography linked in.
- Build the Voltaire crypto dependency automatically for WASM consumers.
- Export host transfer-buffer allocation and the existing nonce, log, refund,
  and storage-change APIs to WASM.
- Execute supplied bytecode through the synchronous C API and release copied
  input buffers when an instance is destroyed.
- Add `zig build test-wasm` and CI coverage for the actual WASM artifact.
