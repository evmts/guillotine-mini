# Export an EIP-3155 trace

Enable `Tracer`, attach it to the EVM and execute `PUSH1 42; POP; STOP` with 100,000 gas. `writeEip3155Jsonl` emits one JSON object per opcode followed by a summary. The POP entry sees `0x2a` on the stack. Its gas cost is two.

The [sample output](trace-output.jsonl) contains the full four-line stream. To reproduce the comparison with geth's `evm` tool (v1.15.11), run the same bytecode and gas budget and project both streams onto the common opcode fields. The diff should be empty.

```sh
evm run --trace --gas 100000 602a5000 2>geth.jsonl
fields='select(has("pc")) | [.pc, .op, .gas, .gasCost, .stack, .depth]'
jq -c "$fields" geth.jsonl >geth-steps.jsonl
zig build run-tracing | jq -c "$fields" | diff -u geth-steps.jsonl -
```

Run [the example](main.zig) from the repository root.

```sh
zig build run-tracing
```

**Expected summary (last line)**

```text
{"output":"0x","gasUsed":"0x5","pass":true}
```
