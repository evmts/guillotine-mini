# Guillotine Mini examples

The Zig examples run against in-memory state using embedded bytecode. Use
Zig 0.15.2, Cargo for the Voltaire crypto dependency, and an adjacent Voltaire
checkout as described in the [root README](../README.md).

From the repository root, run all six or select a single example.

```sh
zig build run-examples
zig build run-example-simple-call
```

| Build step | Source | What it demonstrates |
| --- | --- | --- |
| `run-example-simple-call` | [simple_call.zig](simple_call.zig) | Pass calldata, return 42, and inspect success, output, and execution gas. |
| `run-example-access-list` | [access_list.zig](access_list.zig) | Compare cold and pre-warmed account and storage reads. The example reports the EIP-2930 intrinsic surcharge separately. |
| `run-example-precompiles` | [precompiles.zig](precompiles.zig) | Call SHA-256 and identity by address and verify the returned bytes. |
| `run-example-tracing` | [tracing.zig](tracing.zig) | Capture opcode, stack, memory, and gas data and optionally export a JSON trace. |
| `run-example-transient-storage` | [transient_storage.zig](transient_storage.zig) | Use TSTORE and TLOAD on Cancun and observe that the slot starts at zero in the next transaction. |
| `run-example-hardfork-features` | [hardfork_features.zig](hardfork_features.zig) | Check PUSH0 and MCOPY on Berlin, London, Shanghai, and Cancun. |

Pass an output path to the tracing example to write its EIP-3155 trace fields as a JSON array.

```sh
zig build run-example-tracing -- trace.json
```

The [WASM example](wasm.mjs) uses the C API through Node.js. See the
[root README](../README.md#webassembly) for its build and run commands.
