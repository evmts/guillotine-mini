# Guillotine Mini examples

## Quick Start

Set up Zig 0.15.2, Cargo and the pinned sibling Voltaire checkout using the [native build instructions](../README.md#install). Run these commands from the Guillotine Mini repository root.

```sh
zig build run-simple-call
zig build run-example            # list example names
zig build run-example -- tracing # emit EIP-3155 JSON Lines to stdout
```

Each `zig build run-<name>` target runs one example through the same executable. The examples use deterministic local state. Run the CI smoke test with `sh test/examples.sh`.

| Example | What it shows |
| --- | --- |
| [simple-call](simple-call/README.md) | Value transfer and contract output |
| [access-list](access-list/README.md) | Warm and cold access |
| [call-types](call-types/README.md) | Message calls and deployment |
| [direct-frame](direct-frame/README.md) | Step through a frame |
| [nested-calls](nested-calls/README.md) | Nested calls and failure propagation |
| [precompiles](precompiles/README.md) | Call the first nine precompiles |
| [tracing](tracing/README.md) | Export an EIP-3155 trace |
| [transient-storage](transient-storage/README.md) | Transaction-scoped storage |
| [hardfork-features](hardfork-features/README.md) | Compare hardfork rules |
| [host-interface](host-interface/README.md) | Supply a custom state backend |

The [TypeScript examples](typescript/README.md) and [Node WASM example](wasm.mjs) cover the other interfaces.
