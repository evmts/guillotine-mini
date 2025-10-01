# Execution Specs Test Runner

This directory contains infrastructure for running Ethereum execution-specs tests against the Guillotine EVM.

## Structure

- `runner.zig` - Test runner that executes JSON test cases
- `assembler.zig` - Assembly code compiler for test bytecode
- `root.zig` - Root test file that imports all generated tests
- `generated/` - Auto-generated test files (created by scripts)

## Generating Tests

Tests are automatically generated from the `execution-specs` repository:

```bash
# Generate all test files (2208 tests across 52 categories)
python3 scripts/generate_spec_tests.py

# Update root.zig to import generated tests
python3 scripts/update_spec_root.py
```

## Running Tests

```bash
# Run all spec tests
zig build test-specs

# Run all tests (includes spec tests)
zig build test
```

## Current Status

✅ **2208 tests generated** across 52 categories
✅ All tests compile and run
⏳ All tests currently return `TestTodo`

The infrastructure is in place but the test runner currently returns `TestTodo` for all tests.

## Why Tests Return TODO

The execution-specs tests expect a **stateful EVM with multi-account support**, but the current Guillotine EVM (`src/evm.zig`) has a different design:

### Current EVM API
```zig
pub fn call(
    self: *Self,
    bytecode: []const u8,
    gas: i64,
    caller: Address,
    address: Address,
    value: u256,
    calldata: []const u8,
) CallError!CallResult
```

This API:
- ✅ Executes a single contract's bytecode
- ❌ Doesn't expose pre-state setup (storage/balances/code for multiple accounts)
- ❌ Doesn't expose post-state validation access
- ❌ Designed for single-contract execution, not multi-account state tests

### What Execution-Specs Tests Need
1. **Pre-state setup**: Multiple accounts with different balances, code, and storage
2. **Transaction execution**: Execute transactions that may touch multiple contracts
3. **Post-state validation**: Check final balances, storage, and code across all accounts
4. **Assembly compilation**: Handle `:raw`, `:yul`, and other bytecode formats

### Implementation Options

**Option 1: Add a Host/Database Interface**
Add a `HostInterface` that the EVM uses for state access:
```zig
pub const HostInterface = struct {
    getBalance: fn(address: Address) u256,
    getCode: fn(address: Address) []const u8,
    getStorage: fn(address: Address, key: u256) u256,
    setStorage: fn(address: Address, key: u256, value: u256) void,
    // ...
};
```

**Option 2: Expose EVM State HashMaps**
Make the storage/balances/code HashMaps public and allow external setup/validation.

**Option 3: Create a Test Harness**
Build a test-specific EVM wrapper that maintains state and delegates to the core EVM.

## Test Format

Tests are in JSON format with this structure:

```json
{
  "test_name": {
    "env": {
      "currentCoinbase": "<contract:0x...>",
      "currentNumber": "1",
      "currentTimestamp": "1000",
      ...
    },
    "pre": {
      "<contract:0x...>": {
        "balance": "1000000000000000000",
        "code": ":raw 0x...",
        "storage": { "0x00": "0x01" }
      }
    },
    "transaction": {
      "to": "<contract:0x...>",
      "data": ":raw 0x...",
      "gasLimit": "100000",
      "value": "0"
    },
    "expect": [
      {
        "result": {
          "<contract:0x...>": {
            "balance": "...",
            "storage": { "0x00": "0x02" }
          }
        }
      }
    ]
  }
}
```

## Next Steps

1. Implement the EVM integration in `runner.zig`
2. Add support for different assembly formats in `assembler.zig`
3. Handle placeholder addresses (`<contract:...>`, `<eoa:...>`)
4. Validate post-state (balances, storage, code)
5. Generate all 2208 test files
