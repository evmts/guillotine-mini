# `src/flamegraph.zig`

Gas flamegraph profiler and self-contained SVG visualizer built on [`inspector.zig`](inspector.zig).

## Responsibilities
- **`FlamegraphCollector`**: Implements `Inspector` to track active EVM call stacks and attribute exclusive gas per call path at both frame granularity and per-opcode granularity (including precompile calls).
- **`AddressLabeler`**: Optional vtable mapping `(address, selector)` to human-readable contract/function names with folded-stack syntax sanitization (`;`, whitespace).
- **Exports**:
  - `writeFoldedStacks`: Emits deterministically sorted Brendan Gregg / `inferno` / `speedscope` collapsed-stack lines (`frameA;frameB;SLOAD 2100`).
  - `writeSvg`: Renders a self-contained interactive SVG flamegraph with proportional bars, hover `<title>` tooltips, category color-coding, XML escaping (`writeXmlEscaped`), and compact integer fixed-point formatting (avoiding `std.fmt.float` tables in WASM builds).

## Integration
- Exposed over the C/WASM ABI in [`root_c.zig`](root_c.zig) via `evm_enable_flamegraph`, `evm_get_flamegraph_svg_len`, `evm_get_flamegraph_svg`, `evm_get_flamegraph_folded_len`, and `evm_get_flamegraph_folded`.
- Allocation errors inside callbacks are captured in `FlamegraphCollector.err` and surfaced by writers.
