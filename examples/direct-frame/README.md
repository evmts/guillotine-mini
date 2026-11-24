# Step through a frame

Initialize the EVM transaction state and give a `Frame` the bytecode and a 100-gas budget. For each opcode, print its starting program counter and the stack, allocated memory size and gas remaining after `step()`. MSTORE places 42 in byte 31 of the first memory word.

Run [the example](main.zig) from the repository root.

```sh
zig build run-direct-frame
```

**Expected output**

```text
pc=0 PUSH1 stack={ 42 } memory=0 gas=97
pc=2 PUSH0 stack={ 42, 0 } memory=0 gas=95
pc=3 MSTORE stack={  } memory=32 gas=89
pc=4 STOP stack={  } memory=32 gas=89
```
