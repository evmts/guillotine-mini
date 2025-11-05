/**
 * EIP-3155 compatible trace generation for EVM execution
 *
 * This module provides:
 * - TraceEntry: Per-step execution state snapshot
 * - Tracer: Captures execution traces for debugging and validation
 * - TraceDiff: Compares traces and finds divergences
 *
 * EIP-3155 specification: https://eips.ethereum.org/EIPS/eip-3155
 */

import { getOpName } from './opcode';

/**
 * EIP-3155 compatible trace entry representing a single execution step
 */
export interface TraceEntry {
  /** Program counter (instruction pointer) */
  pc: number;

  /** Opcode byte value */
  op: number;

  /** Gas remaining before execution */
  gas: bigint;

  /** Gas consumed by this operation */
  gasCost: bigint;

  /** Memory contents (null if empty) */
  memory: Uint8Array | null;

  /** Memory size in bytes */
  memSize: number;

  /** Stack state before operation (top of stack is last element) */
  stack: bigint[];

  /** Return data from previous call (null if none) */
  returnData: Uint8Array | null;

  /** Call depth (0 = top-level) */
  depth: number;

  /** Gas refund counter */
  refund: bigint;

  /** Human-readable opcode name */
  opName: string;

  /** Error message if operation failed */
  error?: string;
}

/**
 * JSON representation of a trace entry (EIP-3155 format)
 */
export interface TraceEntryJSON {
  pc: number;
  op: number;
  gas: string; // Hex string
  gasCost: string; // Hex string
  memory: string | null; // Hex string or null
  memSize: number;
  stack: string[]; // Array of hex strings
  returnData: string | null; // Hex string or null
  depth: number;
  refund: string; // Hex string (can be negative)
  opName: string;
  error?: string;
}

/**
 * Tracer that captures EIP-3155 compatible execution traces
 */
export class Tracer {
  private entries: TraceEntry[] = [];
  private _enabled: boolean = false;

  constructor() {}

  /**
   * Enable trace capture
   */
  enable(): void {
    this._enabled = true;
  }

  /**
   * Disable trace capture
   */
  disable(): void {
    this._enabled = false;
  }

  /**
   * Check if tracing is enabled
   */
  get enabled(): boolean {
    return this._enabled;
  }

  /**
   * Get all captured trace entries
   */
  getEntries(): readonly TraceEntry[] {
    return this.entries;
  }

  /**
   * Capture current execution state
   *
   * @param pc - Program counter
   * @param op - Opcode byte
   * @param gas - Gas remaining before operation
   * @param gasCost - Gas consumed by operation
   * @param memory - Memory contents (will be copied)
   * @param stack - Stack state (will be copied)
   * @param returnData - Return data from previous call (will be copied)
   * @param depth - Call depth
   * @param refund - Gas refund counter
   * @param opName - Optional opcode name (auto-generated if not provided)
   */
  captureState(
    pc: number,
    op: number,
    gas: bigint,
    gasCost: bigint,
    memory: Uint8Array | null,
    stack: readonly bigint[],
    returnData: Uint8Array | null,
    depth: number,
    refund: bigint,
    opName?: string
  ): void {
    if (!this._enabled) return;

    const entry: TraceEntry = {
      pc,
      op,
      gas,
      gasCost,
      memory: memory ? new Uint8Array(memory) : null,
      memSize: memory ? memory.length : 0,
      stack: [...stack],
      returnData: returnData ? new Uint8Array(returnData) : null,
      depth,
      refund,
      opName: opName || getOpName(op),
    };

    this.entries.push(entry);
  }

  /**
   * Capture error during execution
   *
   * @param error - Error message
   */
  captureError(error: string): void {
    if (!this._enabled) return;
    if (this.entries.length > 0) {
      this.entries[this.entries.length - 1].error = error;
    }
  }

  /**
   * Clear all captured entries
   */
  clear(): void {
    this.entries = [];
  }

  /**
   * Convert trace to EIP-3155 JSON format
   */
  toJSON(): TraceEntryJSON[] {
    return this.entries.map(entry => this.entryToJSON(entry));
  }

  /**
   * Convert single entry to JSON
   */
  private entryToJSON(entry: TraceEntry): TraceEntryJSON {
    const json: TraceEntryJSON = {
      pc: entry.pc,
      op: entry.op,
      gas: '0x' + entry.gas.toString(16),
      gasCost: '0x' + entry.gasCost.toString(16),
      memory: entry.memory ? '0x' + Buffer.from(entry.memory).toString('hex') : null,
      memSize: entry.memSize,
      stack: entry.stack.map(val => '0x' + val.toString(16)),
      returnData: entry.returnData ? '0x' + Buffer.from(entry.returnData).toString('hex') : null,
      depth: entry.depth,
      refund: entry.refund < 0n ? '-0x' + (-entry.refund).toString(16) : '0x' + entry.refund.toString(16),
      opName: entry.opName,
    };

    if (entry.error) {
      json.error = entry.error;
    }

    return json;
  }

  /**
   * Write trace to JSON string (pretty-printed)
   */
  toString(): string {
    return JSON.stringify(this.toJSON(), null, 2);
  }
}

/**
 * Result of comparing two traces
 */
export interface TraceDiff {
  /** Index where traces diverge (null if they match) */
  divergenceIndex: number | null;

  /** Our trace entry at divergence point */
  ourEntry: TraceEntry | null;

  /** Reference trace entry at divergence point */
  refEntry: TraceEntry | null;

  /** Field that differs */
  diffField: string | null;
}

/**
 * Compare two traces and find the first divergence
 *
 * @param ourTrace - Our EVM trace
 * @param refTrace - Reference trace to compare against
 * @returns Diff result with divergence information
 */
export function compareTraces(ourTrace: Tracer, refTrace: Tracer): TraceDiff {
  const ourEntries = ourTrace.getEntries();
  const refEntries = refTrace.getEntries();
  const minLen = Math.min(ourEntries.length, refEntries.length);

  // Compare entries step by step
  for (let i = 0; i < minLen; i++) {
    const our = ourEntries[i];
    const ref = refEntries[i];

    // Check PC
    if (our.pc !== ref.pc) {
      return {
        divergenceIndex: i,
        ourEntry: our,
        refEntry: ref,
        diffField: 'pc',
      };
    }

    // Check opcode
    if (our.op !== ref.op) {
      return {
        divergenceIndex: i,
        ourEntry: our,
        refEntry: ref,
        diffField: 'op',
      };
    }

    // Check gas
    if (our.gas !== ref.gas) {
      return {
        divergenceIndex: i,
        ourEntry: our,
        refEntry: ref,
        diffField: 'gas',
      };
    }

    // Check stack length
    if (our.stack.length !== ref.stack.length) {
      return {
        divergenceIndex: i,
        ourEntry: our,
        refEntry: ref,
        diffField: 'stack_length',
      };
    }

    // Check stack values
    for (let j = 0; j < our.stack.length; j++) {
      if (our.stack[j] !== ref.stack[j]) {
        return {
          divergenceIndex: i,
          ourEntry: our,
          refEntry: ref,
          diffField: 'stack_value',
        };
      }
    }

    // Check memory size
    if (our.memSize !== ref.memSize) {
      return {
        divergenceIndex: i,
        ourEntry: our,
        refEntry: ref,
        diffField: 'memSize',
      };
    }

    // Check memory contents
    if (our.memory && ref.memory) {
      if (our.memory.length !== ref.memory.length) {
        return {
          divergenceIndex: i,
          ourEntry: our,
          refEntry: ref,
          diffField: 'memory_length',
        };
      }
      for (let j = 0; j < our.memory.length; j++) {
        if (our.memory[j] !== ref.memory[j]) {
          return {
            divergenceIndex: i,
            ourEntry: our,
            refEntry: ref,
            diffField: 'memory_value',
          };
        }
      }
    } else if (our.memory || ref.memory) {
      return {
        divergenceIndex: i,
        ourEntry: our,
        refEntry: ref,
        diffField: 'memory_null',
      };
    }
  }

  // Check if one trace is longer
  if (ourEntries.length !== refEntries.length) {
    return {
      divergenceIndex: minLen,
      ourEntry: ourEntries.length > minLen ? ourEntries[minLen] : null,
      refEntry: refEntries.length > minLen ? refEntries[minLen] : null,
      diffField: 'trace_length',
    };
  }

  // Traces match perfectly
  return {
    divergenceIndex: null,
    ourEntry: null,
    refEntry: null,
    diffField: null,
  };
}

/**
 * Format trace diff for human-readable output
 *
 * @param diff - Trace diff result
 * @returns Formatted string with ANSI colors
 */
export function formatTraceDiff(diff: TraceDiff): string {
  if (diff.divergenceIndex === null) {
    return '✓ Traces match perfectly!\n';
  }

  const lines: string[] = [];

  // Yellow warning
  lines.push(`\x1b[33m⚠ Trace Divergence at step ${diff.divergenceIndex}\x1b[0m`);

  if (diff.diffField) {
    lines.push(`\x1b[1mDifference in: ${diff.diffField}\x1b[0m`);
  }

  if (diff.ourEntry) {
    lines.push('\n\x1b[36mOur EVM:\x1b[0m'); // Cyan
    lines.push(`  PC: 0x${diff.ourEntry.pc.toString(16).padStart(4, '0')}  Op: 0x${diff.ourEntry.op.toString(16).padStart(2, '0')} (${diff.ourEntry.opName})  Gas: ${diff.ourEntry.gas}`);
    lines.push(`  Stack depth: ${diff.ourEntry.stack.length}`);
    if (diff.ourEntry.stack.length > 0) {
      lines.push(`  Stack top: 0x${diff.ourEntry.stack[diff.ourEntry.stack.length - 1].toString(16)}`);
    }
  }

  if (diff.refEntry) {
    lines.push('\n\x1b[35mReference:\x1b[0m'); // Magenta
    lines.push(`  PC: 0x${diff.refEntry.pc.toString(16).padStart(4, '0')}  Op: 0x${diff.refEntry.op.toString(16).padStart(2, '0')} (${diff.refEntry.opName})  Gas: ${diff.refEntry.gas}`);
    lines.push(`  Stack depth: ${diff.refEntry.stack.length}`);
    if (diff.refEntry.stack.length > 0) {
      lines.push(`  Stack top: 0x${diff.refEntry.stack[diff.refEntry.stack.length - 1].toString(16)}`);
    }
  }

  return lines.join('\n');
}
