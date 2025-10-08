# Custom Opcode and Precompile Handlers

This document describes how to use custom handlers in the Guillotine Mini EVM TypeScript SDK.

## Overview

The EVM supports two types of custom handlers:

1. **Opcode Overrides**: Replace or augment built-in opcode implementations
2. **Precompile Overrides**: Add custom precompiles or override existing ones

## Type Definitions

```typescript
// Custom opcode handler (receives frame pointer, returns success)
type OpcodeHandler = (framePtr: number) => boolean;

interface OpcodeOverride {
  opcode: number;        // 0x00-0xFF
  handler: OpcodeHandler;
}

// Custom precompile handler
type PrecompileHandler = (
  input: Bytes,
  gasLimit: bigint
) => Promise<PrecompileResult> | PrecompileResult;

interface PrecompileOverride {
  address: Address;      // 20-byte address
  execute: PrecompileHandler;
}

interface PrecompileResult {
  success: boolean;
  gasUsed: bigint;
  output: Bytes;
}
```

## Example: Custom Opcode

```typescript
import { createEvm } from '@guillotine/evm';

// Override ADD (0x01) to multiply instead
const customMultiply: OpcodeHandler = (framePtr) => {
  // Access frame via FFI
  // Pop two values, multiply them, push result
  // Return true for success, false for error
  return true;
};

const evm = await createEvm({
  hardfork: 'CANCUN',
  opcodeOverrides: [
    {
      opcode: 0x01, // ADD
      handler: customMultiply
    }
  ]
});

// Now when bytecode executes ADD, it will use customMultiply
```

## Example: Custom Precompile

```typescript
import { createEvm } from '@guillotine/evm';

// Custom precompile at address 0x99
const customPrecompile: PrecompileHandler = async (input, gasLimit) => {
  // Implement custom logic
  const output = new Uint8Array(32);
  // ... process input, generate output ...

  return {
    success: true,
    gasUsed: 5000n,
    output
  };
};

const evm = await createEvm({
  hardfork: 'CANCUN',
  precompileOverrides: [
    {
      address: new Uint8Array([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x99]),
      execute: customPrecompile
    }
  ]
});

// Calls to address 0x99 will use customPrecompile
```

## Use Cases

### 1. Testing Alternative Implementations

```typescript
// Test different gas cost models
const lowGasAdd: OpcodeHandler = (framePtr) => {
  // Implementation that uses less gas
  return true;
};
```

### 2. Instrumentation and Logging

```typescript
// Log every SSTORE operation
const instrumentedSstore: OpcodeHandler = (framePtr) => {
  console.log('SSTORE called at PC:', getCurrentPC(framePtr));
  return defaultSstoreHandler(framePtr);
};
```

### 3. Custom Layer 2 Features

```typescript
// Custom precompile for L2-specific operations
const l2StateRoot: PrecompileHandler = async (input) => {
  const stateRoot = await getL2StateRoot();
  return {
    success: true,
    gasUsed: 2000n,
    output: stateRoot
  };
};
```

### 4. Educational Tools

```typescript
// Step-by-step debugger
const debugAdd: OpcodeHandler = (framePtr) => {
  const a = popStack(framePtr);
  const b = popStack(framePtr);
  console.log(`ADD: ${a} + ${b}`);
  pushStack(framePtr, a + b);
  return true;
};
```

## Configuration Options

All configuration options available in `EvmOptions`:

```typescript
interface EvmOptions {
  // Core options
  hardfork?: Hardfork;

  // Custom handlers
  opcodeOverrides?: OpcodeOverride[];
  precompileOverrides?: PrecompileOverride[];

  // Performance/safety
  loopQuota?: number | null;

  // System contracts (EIP-4788, EIP-2935)
  enableBeaconRoots?: boolean;
  enableHistoricalBlockHashes?: boolean;
  enableValidatorDeposits?: boolean;
  enableValidatorWithdrawals?: boolean;
}
```

## Implementation Status

**Current Status**: Type definitions complete, C API implementation in progress.

**Roadmap**:
- [x] Add config options to Zig EVM
- [x] Implement opcode override lookup in Frame
- [x] Implement precompile override lookup in EVM
- [x] Add TypeScript type definitions
- [ ] Add C API functions for registering handlers
- [ ] Add FFI bindings in TypeScript
- [ ] Add comprehensive tests

## C API (Planned)

```c
// Register custom opcode handler
bool evm_register_opcode_handler(
    EvmHandle* handle,
    uint8_t opcode,
    OpcodeHandlerFn handler
);

// Register custom precompile
bool evm_register_precompile(
    EvmHandle* handle,
    const uint8_t* address,
    PrecompileHandlerFn handler
);
```

## Testing

Once C API support is complete, test with:

```bash
cd sdks/typescript
bun run examples/custom-handlers.ts
```

## Performance Considerations

- Custom handlers add runtime overhead (function pointer indirection)
- For performance-critical applications, consider:
  - Keeping handlers simple and fast
  - Minimizing FFI boundary crossings
  - Using batch operations when possible

## Security Considerations

- Custom handlers run with full EVM access
- Validate all inputs in custom precompiles
- Ensure gas accounting is correct
- Test thoroughly before production use
