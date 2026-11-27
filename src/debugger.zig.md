# `src/debugger.zig`

Interactive time-travel EVM debugger built on top of [`inspector.zig`](inspector.zig).

## Responsibilities
- **`ExecutionRecorder`**: Implements `Inspector` to capture an immutable execution timeline of opcodes (`DebugStep`), storage accesses (`StorageEventRecord`), and call frames (`CallFrameRecord`), with optional memory capture, step caps (`max_steps`), and source-map resolution (`SourceMapResolver`).
- **`DebugSession`**: Provides zero-cost forward and backward navigation over a recorded timeline:
  - Stepping: `stepInto`, `stepBack`, `stepOver`, `stepOut`, `jumpToStep`.
  - Breakpoints: `addBreakpoint`, `removeBreakpoint`, `clearBreakpoints`, `continueUntilBreakpoint`, `continueBackUntilBreakpoint` supporting `pc`, `opcode`, `call_target`, `storage_slot`, `on_revert`, `on_fault`, and `depth_at_most`.
  - Formatting: `writeCurrentStateSummary` dumps PC, opcode, gas, depth, stack, and source location.

## Ownership & Safety
- All `Inspector` hooks return `void`; allocation failures are captured in `ExecutionRecorder.err` and halt further recording without panicking.
- `ExecutionRecorder.deinit` frees all owned step slices, frame inputs/outputs, and error strings; `DebugSession` borrows the recorder and owns only its breakpoint table.
