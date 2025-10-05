# EIP-3155 Trace Capture

This implementation includes EIP-3155 compatible trace capture functionality for debugging and validation of EVM execution.

## Overview

The tracing implementation captures detailed execution state at each opcode execution, including:
- Program counter (pc)
- Opcode value (op) and name (opName)
- Gas remaining (gas) and gas cost (gasCost)
- Memory state (memory) and size (memSize)
- Stack contents (stack)
- Return data (returnData)
- Call depth (depth)
- Gas refund counter (refund)

## Usage

### 1. Basic Setup

```zig
const std = @import("std");
const guillotine = @import("guillotine-mini");

// Initialize tracer
var tracer = guillotine.Tracer.init(allocator);
defer tracer.deinit();

// Enable tracing
tracer.enable();

// Create EVM and attach tracer
var evm = try guillotine.Evm.init(allocator, null, null, null);
defer evm.deinit();
evm.setTracer(&tracer);
```

### 2. Execute Code with Tracing

```zig
const bytecode = [_]u8{
    0x60, 0x01, // PUSH1 1
    0x60, 0x02, // PUSH1 2
    0x01,       // ADD
    0x00,       // STOP
};

const result = try evm.call(
    &bytecode,
    1_000_000,
    caller_address,
    contract_address,
    0,
    &[_]u8{},
    null,
);
```

### 3. Export Trace to JSON

```zig
// Save to file
try tracer.writeToFile("trace.json");

// Or get JSON value
const json_value = try tracer.toJson();
defer json_value.deinit();
```

## Trace Format

Each trace entry follows the EIP-3155 format:

```json
{
  "pc": 0,
  "op": 96,
  "gas": "0xf4240",
  "gasCost": "0x3",
  "memory": null,
  "memSize": 0,
  "stack": [],
  "returnData": null,
  "depth": 1,
  "refund": 0,
  "opName": "PUSH1"
}
```

## Controlling Tracing

### Enable/Disable at Runtime

```zig
// Enable tracing
tracer.enable();

// Disable tracing
tracer.disable();
```

### Environment Variable Control

You can also control tracing via environment variables in your application:

```zig
const enable_trace = std.os.getenv("EVM_TRACE") != null;
if (enable_trace) {
    tracer.enable();
}
```

## Example Output

For the simple bytecode `PUSH1 1, PUSH1 2, ADD, STOP`:

```json
[
  {
    "pc": 0,
    "op": 96,
    "gas": "0xf4240",
    "gasCost": "0x3",
    "memory": null,
    "memSize": 0,
    "stack": [],
    "returnData": null,
    "depth": 1,
    "refund": 0,
    "opName": "PUSH1"
  },
  {
    "pc": 2,
    "op": 96,
    "gas": "0xf423d",
    "gasCost": "0x3",
    "memory": null,
    "memSize": 0,
    "stack": ["0x1"],
    "returnData": null,
    "depth": 1,
    "refund": 0,
    "opName": "PUSH1"
  },
  {
    "pc": 4,
    "op": 1,
    "gas": "0xf423a",
    "gasCost": "0x3",
    "memory": null,
    "memSize": 0,
    "stack": ["0x1", "0x2"],
    "returnData": null,
    "depth": 1,
    "refund": 0,
    "opName": "ADD"
  },
  {
    "pc": 5,
    "op": 0,
    "gas": "0xf4237",
    "gasCost": "0x0",
    "memory": null,
    "memSize": 0,
    "stack": ["0x3"],
    "returnData": null,
    "depth": 1,
    "refund": 0,
    "opName": "STOP"
  }
]
```

## Performance Considerations

- Tracing adds overhead to execution. Only enable when needed for debugging/validation.
- Memory snapshots are captured at each step, which can be memory-intensive for large executions.
- The tracer uses the allocator provided during initialization for all allocations.

## Integration with Tests

To enable tracing in test execution:

```zig
// In test runner or test host
const enable_trace = std.os.getenv("TRACE_TESTS") != null;

if (enable_trace) {
    var tracer = guillotine.Tracer.init(allocator);
    defer tracer.deinit();
    tracer.enable();
    evm.setTracer(&tracer);

    // ... run test ...

    // Save trace with test name
    var buf: [256]u8 = undefined;
    const filename = try std.fmt.bufPrint(&buf, "traces/{s}.json", .{test_name});
    try tracer.writeToFile(filename);
}
```

## Trace Comparison

The trace module also includes utilities for comparing traces:

```zig
const diff = try guillotine.trace.TraceDiff.compare(allocator, &our_trace, &reference_trace);
defer if (diff.diff_field) |field| allocator.free(field);

try diff.printDiff(std.io.getStdOut().writer());
```

This is useful for:
- Validating against reference implementations
- Debugging divergences in execution
- Test case verification
