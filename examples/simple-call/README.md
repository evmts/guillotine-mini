# Value transfer and contract output

Give Alice 100 wei in a `StateOverlayHost` and send 7 wei to bytecode that adds 40 and 2. The call returns a big-endian 32-byte word. Subtract remaining gas from the message budget with `gasConsumed`. A second call supplies only one gas and checks the rollback and `error_info`.

The EVM owns the call's output buffer. Read it while the EVM is alive, or use `toOwnedResult` to copy the result to a caller-owned allocator.

Run [the example](main.zig) from the repository root.

```sh
zig build run-simple-call
```

**Expected output**

```text
output=42 gas_used=22 balances=93/7
failure=OutOfGas
```
