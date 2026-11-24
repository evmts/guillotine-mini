# Transaction-scoped storage

The Cancun guard reads transient slot zero and reverts if it is already locked. It sets the lock on entry, reads it inside the guarded section, then releases it. A separate TSTORE deliberately leaves a value in that slot. A later message reads zero with TLOAD while the same slot written by SSTORE retains one. Gas figures include the instructions that push the value and key.

Run [the example](main.zig) from the repository root.

```sh
zig build run-transient-storage
```

**Expected output**

```text
inside guard=1
TSTORE gas=105; SSTORE gas=22105
later TLOAD=0; SLOAD=1
```
