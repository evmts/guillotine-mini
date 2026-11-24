# Message calls and deployment

CALL transfers one wei. STATICCALL reads the library’s caller and rejects a storage write. The proxy then invokes that library with DELEGATECALL and CALLCODE. Both use the proxy’s storage context. The returned `CALLER` identifies Alice for DELEGATECALL and the proxy for CALLCODE.

Finally, the same initcode deploys a one-byte STOP contract with CREATE and CREATE2. The example checks the CREATE2 address against the prediction computed from the sender, salt and initcode.

Inside an opcode handler, the proxy frame supplies these two nested messages to `evm.inner_call`. Here `library` is the address of the code to execute and `gas` is the forwarded budget.

```zig
const delegate: Evm.CallParams = .{ .delegatecall = .{
    .caller = frame.caller, .to = library, .input = &.{}, .gas = gas,
} };
const legacy: Evm.CallParams = .{ .callcode = .{
    .caller = frame.address, .to = library, .value = 0, .input = &.{}, .gas = gas,
} };
```

Run [the example](main.zig) from the repository root.

```sh
zig build run-call-types
```

**Expected output**

```text
CALL transferred=1; STATICCALL rejected SSTORE
DELEGATECALL caller=0x100; CALLCODE caller=0x200
CREATE runtime=0x00; CREATE2 predicted=0x6bfdf46ee91a8d433715ecada5c8a2d56ae78166
```
