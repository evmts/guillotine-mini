/**
 * Guillotine Mini - TypeScript EVM Library
 *
 * Minimal, correct, and well-tested Ethereum Virtual Machine implementation.
 * Prioritizes specification compliance, clarity, and hardfork support.
 *
 * @packageDocumentation
 */

/**
 * Library version
 */
export const VERSION = '0.1.0';

// ============================================================================
// Core Exports
// ============================================================================

// Core Classes and Types
export * from './evm';
export * from './frame';
export * from './storage';
export * from './access-list-manager';
export * from './bytecode';

// Types and Interfaces
export * from './call-params';
export * from './call-result';
export * from './host';
export * from './evm-config';

// Error Types
export * from './errors';

// Utilities
export * from './utils/bigint';
export * from './utils/memory';
export * from './opcode';

// ============================================================================
// Default Export
// ============================================================================

import { Evm } from './evm';
import { Frame } from './frame';
import { Storage } from './storage';
import { AccessListManager } from './access-list-manager';
import { Bytecode } from './bytecode';
import { Hardfork } from './evm-config';
import { CallError, EvmError } from './errors';

/**
 * Default export with all core classes
 */
export default {
  VERSION,
  Evm,
  Frame,
  Storage,
  AccessListManager,
  Bytecode,
  Hardfork,
  CallError,
  EvmError,
};
