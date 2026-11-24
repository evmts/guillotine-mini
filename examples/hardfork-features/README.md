# Compare hardfork rules

Each EVM starts with slot zero set to one. Clearing it exposes the London change to the raw storage refund counter. Reading the slot in a fresh transaction shows the Berlin cold-access price. Each fork then executes the same three opcode probes and checks either success or the explicit `InvalidOpcode` error.

Run [the example](main.zig) from the repository root.

```sh
zig build run-hardfork-features
```

**Expected output**

```text
ISTANBUL SLOAD=803 clear_refund=15000 PUSH0=off MCOPY=off TSTORE=off
BERLIN SLOAD=2103 clear_refund=15000 PUSH0=off MCOPY=off TSTORE=off
LONDON SLOAD=2103 clear_refund=4800 PUSH0=off MCOPY=off TSTORE=off
SHANGHAI SLOAD=2103 clear_refund=4800 PUSH0=on MCOPY=off TSTORE=off
CANCUN SLOAD=2103 clear_refund=4800 PUSH0=on MCOPY=on TSTORE=on
```
