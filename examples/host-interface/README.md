# Supply a custom state backend

The [in-memory host](custom-host.zig) implements the `HostInterface` vtable over account and storage maps. It owns its bytecode and records allocation errors because the setter callbacks return `void`. The backend lives longer than either EVM.

One call increments a stored counter from 40 to 41. A second EVM reads through a `StateOverlayHost` and increments the counter to 42 in its own overlay. The underlying host still reads 41.

Run [the example](main.zig) from the repository root.

```sh
zig build run-host-interface
```

**Expected output**

```text
initial=40 committed=41 simulated=42
```
