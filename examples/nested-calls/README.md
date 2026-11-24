# Nested calls and failure propagation

A forwards one wei to B, and B forwards it to C. The call tracer records the parent and child of each frame. With the root at depth zero, C runs at depth two, sees B as its caller and receives one wei. The default EVM message-call depth limit is 1024.

On the second run C reverts, B propagates the revert, and A returns the failed CALL’s zero status. A completes successfully in both runs.

Run [the example](main.zig) from the repository root.

```sh
zig build run-nested-calls
```

**Expected output**

```text
A -> B -> C: leaf depth=2 caller=0x300 value=1 reverted=false A returned 1
A -> B -> C: leaf depth=2 caller=0x300 value=1 reverted=true A returned 0
```
