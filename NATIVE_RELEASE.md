# Native ZEVM integration

This revision supplies bounded pre-op opcode traces, preserves execution error
names, and repairs the native unit fixtures for registered parent frames and
Ethereum truncated-PUSH zero padding. Unit and trace regressions pass on Zig
0.15.2. Execution uses the sibling Voltaire checkout at the revision recorded in
`native-dependencies.json`; CI materializes that exact source.

The native TEVM/ZEVM integration consumes this Zig source directly. It does not
require the legacy TypeScript client packages.
