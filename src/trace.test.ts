/**
 * Tests for EIP-3155 trace generation
 */

import { describe, it, expect, beforeEach } from 'bun:test';
import { Tracer, compareTraces, formatTraceDiff, type TraceEntry } from './trace';

describe('Tracer', () => {
  let tracer: Tracer;

  beforeEach(() => {
    tracer = new Tracer();
  });

  describe('enable/disable', () => {
    it('should start disabled', () => {
      expect(tracer.enabled).toBe(false);
    });

    it('should enable tracing', () => {
      tracer.enable();
      expect(tracer.enabled).toBe(true);
    });

    it('should disable tracing', () => {
      tracer.enable();
      tracer.disable();
      expect(tracer.enabled).toBe(false);
    });

    it('should not capture when disabled', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
      expect(tracer.getEntries().length).toBe(0);
    });
  });

  describe('captureState', () => {
    beforeEach(() => {
      tracer.enable();
    });

    it('should capture basic state', () => {
      tracer.captureState(
        0, // pc
        0x60, // op (PUSH1)
        1000n, // gas
        3n, // gasCost
        null, // memory
        [], // stack
        null, // returnData
        0, // depth
        0n, // refund
        'PUSH1'
      );

      const entries = tracer.getEntries();
      expect(entries.length).toBe(1);

      const entry = entries[0];
      expect(entry.pc).toBe(0);
      expect(entry.op).toBe(0x60);
      expect(entry.gas).toBe(1000n);
      expect(entry.gasCost).toBe(3n);
      expect(entry.memory).toBeNull();
      expect(entry.memSize).toBe(0);
      expect(entry.stack).toEqual([]);
      expect(entry.returnData).toBeNull();
      expect(entry.depth).toBe(0);
      expect(entry.refund).toBe(0n);
      expect(entry.opName).toBe('PUSH1');
    });

    it('should auto-generate opcode name if not provided', () => {
      tracer.captureState(0, 0x01, 1000n, 3n, null, [], null, 0, 0n);
      expect(tracer.getEntries()[0].opName).toBe('ADD');
    });

    it('should capture stack state', () => {
      const stack = [1n, 2n, 3n, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn];
      tracer.captureState(0, 0x01, 1000n, 3n, null, stack, null, 0, 0n, 'ADD');

      const captured = tracer.getEntries()[0].stack;
      expect(captured).toEqual(stack);
      // Verify it's a copy, not a reference
      expect(captured).not.toBe(stack);
    });

    it('should capture memory state', () => {
      const memory = new Uint8Array([0x60, 0x40, 0x52]);
      tracer.captureState(0, 0x52, 1000n, 3n, memory, [], null, 0, 0n, 'MSTORE');

      const entry = tracer.getEntries()[0];
      expect(entry.memory).toEqual(memory);
      expect(entry.memSize).toBe(3);
      // Verify it's a copy
      expect(entry.memory).not.toBe(memory);
    });

    it('should capture return data', () => {
      const returnData = new Uint8Array([0x00, 0x01, 0x02, 0x03]);
      tracer.captureState(0, 0xf1, 1000n, 3n, null, [], returnData, 0, 0n, 'CALL');

      const entry = tracer.getEntries()[0];
      expect(entry.returnData).toEqual(returnData);
      // Verify it's a copy
      expect(entry.returnData).not.toBe(returnData);
    });

    it('should capture nested call depth', () => {
      tracer.captureState(0, 0xf1, 1000n, 100n, null, [], null, 2, 0n, 'CALL');
      expect(tracer.getEntries()[0].depth).toBe(2);
    });

    it('should capture negative refund', () => {
      tracer.captureState(0, 0x55, 1000n, 100n, null, [], null, 0, -5000n, 'SSTORE');
      expect(tracer.getEntries()[0].refund).toBe(-5000n);
    });

    it('should capture multiple entries in sequence', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
      tracer.captureState(2, 0x60, 997n, 3n, null, [1n], null, 0, 0n, 'PUSH1');
      tracer.captureState(4, 0x01, 994n, 3n, null, [1n, 2n], null, 0, 0n, 'ADD');

      const entries = tracer.getEntries();
      expect(entries.length).toBe(3);
      expect(entries[0].pc).toBe(0);
      expect(entries[1].pc).toBe(2);
      expect(entries[2].pc).toBe(4);
    });
  });

  describe('captureError', () => {
    beforeEach(() => {
      tracer.enable();
    });

    it('should capture error on last entry', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
      tracer.captureError('Stack underflow');

      const entry = tracer.getEntries()[0];
      expect(entry.error).toBe('Stack underflow');
    });

    it('should do nothing if no entries', () => {
      tracer.captureError('Error');
      expect(tracer.getEntries().length).toBe(0);
    });
  });

  describe('clear', () => {
    beforeEach(() => {
      tracer.enable();
    });

    it('should clear all entries', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
      tracer.captureState(2, 0x60, 997n, 3n, null, [1n], null, 0, 0n, 'PUSH1');
      expect(tracer.getEntries().length).toBe(2);

      tracer.clear();
      expect(tracer.getEntries().length).toBe(0);
    });
  });

  describe('toJSON', () => {
    beforeEach(() => {
      tracer.enable();
    });

    it('should convert to EIP-3155 JSON format', () => {
      tracer.captureState(
        0,
        0x60,
        1000n,
        3n,
        new Uint8Array([0x01, 0x02]),
        [42n, 0xffn],
        null,
        0,
        0n,
        'PUSH1'
      );

      const json = tracer.toJSON();
      expect(json.length).toBe(1);

      const entry = json[0];
      expect(entry.pc).toBe(0);
      expect(entry.op).toBe(0x60);
      expect(entry.gas).toBe('0x3e8'); // 1000 in hex
      expect(entry.gasCost).toBe('0x3'); // 3 in hex
      expect(entry.memory).toBe('0x0102');
      expect(entry.memSize).toBe(2);
      expect(entry.stack).toEqual(['0x2a', '0xff']); // 42 and 255 in hex
      expect(entry.returnData).toBeNull();
      expect(entry.depth).toBe(0);
      expect(entry.refund).toBe('0x0');
      expect(entry.opName).toBe('PUSH1');
    });

    it('should handle null memory and return data', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');

      const json = tracer.toJSON();
      expect(json[0].memory).toBeNull();
      expect(json[0].returnData).toBeNull();
    });

    it('should handle negative refund', () => {
      tracer.captureState(0, 0x55, 1000n, 100n, null, [], null, 0, -5000n, 'SSTORE');

      const json = tracer.toJSON();
      expect(json[0].refund).toBe('-0x1388'); // -5000 in hex
    });

    it('should handle large stack values', () => {
      const largeValue = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffn;
      tracer.captureState(0, 0x60, 1000n, 3n, null, [largeValue], null, 0, 0n, 'PUSH32');

      const json = tracer.toJSON();
      expect(json[0].stack[0]).toBe('0x' + largeValue.toString(16));
    });

    it('should include error if present', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
      tracer.captureError('Stack overflow');

      const json = tracer.toJSON();
      expect(json[0].error).toBe('Stack overflow');
    });

    it('should not include error if not present', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');

      const json = tracer.toJSON();
      expect(json[0].error).toBeUndefined();
    });
  });

  describe('toString', () => {
    beforeEach(() => {
      tracer.enable();
    });

    it('should produce valid JSON string', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [42n], null, 0, 0n, 'PUSH1');
      tracer.captureState(2, 0x01, 997n, 3n, null, [42n, 10n], null, 0, 0n, 'ADD');

      const str = tracer.toString();
      const parsed = JSON.parse(str);

      expect(Array.isArray(parsed)).toBe(true);
      expect(parsed.length).toBe(2);
      expect(parsed[0].opName).toBe('PUSH1');
      expect(parsed[1].opName).toBe('ADD');
    });

    it('should be pretty-printed', () => {
      tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');

      const str = tracer.toString();
      // Pretty-printed JSON should have newlines and indentation
      expect(str).toContain('\n');
      expect(str).toContain('  '); // Indentation
    });
  });
});

describe('compareTraces', () => {
  let ourTrace: Tracer;
  let refTrace: Tracer;

  beforeEach(() => {
    ourTrace = new Tracer();
    refTrace = new Tracer();
    ourTrace.enable();
    refTrace.enable();
  });

  it('should match identical traces', () => {
    ourTrace.captureState(0, 0x60, 1000n, 3n, null, [42n], null, 0, 0n, 'PUSH1');
    refTrace.captureState(0, 0x60, 1000n, 3n, null, [42n], null, 0, 0n, 'PUSH1');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBeNull();
    expect(diff.ourEntry).toBeNull();
    expect(diff.refEntry).toBeNull();
    expect(diff.diffField).toBeNull();
  });

  it('should detect PC divergence', () => {
    ourTrace.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
    refTrace.captureState(2, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(0);
    expect(diff.diffField).toBe('pc');
    expect(diff.ourEntry?.pc).toBe(0);
    expect(diff.refEntry?.pc).toBe(2);
  });

  it('should detect opcode divergence', () => {
    ourTrace.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
    refTrace.captureState(0, 0x01, 1000n, 3n, null, [], null, 0, 0n, 'ADD');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(0);
    expect(diff.diffField).toBe('op');
    expect(diff.ourEntry?.op).toBe(0x60);
    expect(diff.refEntry?.op).toBe(0x01);
  });

  it('should detect gas divergence', () => {
    ourTrace.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
    refTrace.captureState(0, 0x60, 900n, 3n, null, [], null, 0, 0n, 'PUSH1');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(0);
    expect(diff.diffField).toBe('gas');
    expect(diff.ourEntry?.gas).toBe(1000n);
    expect(diff.refEntry?.gas).toBe(900n);
  });

  it('should detect stack length divergence', () => {
    ourTrace.captureState(0, 0x60, 1000n, 3n, null, [42n], null, 0, 0n, 'PUSH1');
    refTrace.captureState(0, 0x60, 1000n, 3n, null, [42n, 10n], null, 0, 0n, 'PUSH1');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(0);
    expect(diff.diffField).toBe('stack_length');
  });

  it('should detect stack value divergence', () => {
    ourTrace.captureState(0, 0x60, 1000n, 3n, null, [42n], null, 0, 0n, 'PUSH1');
    refTrace.captureState(0, 0x60, 1000n, 3n, null, [43n], null, 0, 0n, 'PUSH1');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(0);
    expect(diff.diffField).toBe('stack_value');
  });

  it('should detect memory size divergence', () => {
    ourTrace.captureState(0, 0x52, 1000n, 3n, new Uint8Array(32), [], null, 0, 0n, 'MSTORE');
    refTrace.captureState(0, 0x52, 1000n, 3n, new Uint8Array(64), [], null, 0, 0n, 'MSTORE');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(0);
    expect(diff.diffField).toBe('memSize');
  });

  it('should detect memory content divergence', () => {
    ourTrace.captureState(0, 0x52, 1000n, 3n, new Uint8Array([1, 2, 3]), [], null, 0, 0n, 'MSTORE');
    refTrace.captureState(0, 0x52, 1000n, 3n, new Uint8Array([1, 2, 4]), [], null, 0, 0n, 'MSTORE');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(0);
    expect(diff.diffField).toBe('memory_value');
  });

  it('should detect memory null divergence', () => {
    // Use same size memory to test null vs non-null specifically
    const memory = new Uint8Array(0); // Empty but not null
    ourTrace.captureState(0, 0x52, 1000n, 3n, memory, [], null, 0, 0n, 'MSTORE');
    refTrace.captureState(0, 0x52, 1000n, 3n, null, [], null, 0, 0n, 'MSTORE');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(0);
    expect(diff.diffField).toBe('memory_null');
  });

  it('should detect trace length divergence', () => {
    ourTrace.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
    ourTrace.captureState(2, 0x60, 997n, 3n, null, [42n], null, 0, 0n, 'PUSH1');
    refTrace.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(1);
    expect(diff.diffField).toBe('trace_length');
    expect(diff.ourEntry?.pc).toBe(2);
    expect(diff.refEntry).toBeNull();
  });

  it('should detect divergence at second step', () => {
    ourTrace.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
    ourTrace.captureState(2, 0x60, 997n, 3n, null, [42n], null, 0, 0n, 'PUSH1');
    refTrace.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');
    refTrace.captureState(2, 0x01, 997n, 3n, null, [42n, 10n], null, 0, 0n, 'ADD');

    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBe(1);
    expect(diff.diffField).toBe('op');
  });

  it('should match empty traces', () => {
    const diff = compareTraces(ourTrace, refTrace);
    expect(diff.divergenceIndex).toBeNull();
  });
});

describe('formatTraceDiff', () => {
  it('should format matching traces', () => {
    const diff = {
      divergenceIndex: null,
      ourEntry: null,
      refEntry: null,
      diffField: null,
    };

    const formatted = formatTraceDiff(diff);
    expect(formatted).toContain('✓ Traces match perfectly!');
  });

  it('should format divergence with both entries', () => {
    const ourEntry: TraceEntry = {
      pc: 0,
      op: 0x60,
      gas: 1000n,
      gasCost: 3n,
      memory: null,
      memSize: 0,
      stack: [42n],
      returnData: null,
      depth: 0,
      refund: 0n,
      opName: 'PUSH1',
    };

    const refEntry: TraceEntry = {
      pc: 2,
      op: 0x01,
      gas: 900n,
      gasCost: 3n,
      memory: null,
      memSize: 0,
      stack: [42n, 10n],
      returnData: null,
      depth: 0,
      refund: 0n,
      opName: 'ADD',
    };

    const diff = {
      divergenceIndex: 1,
      ourEntry,
      refEntry,
      diffField: 'op',
    };

    const formatted = formatTraceDiff(diff);
    expect(formatted).toContain('⚠ Trace Divergence at step 1');
    expect(formatted).toContain('Difference in: op');
    expect(formatted).toContain('Our EVM:');
    expect(formatted).toContain('PUSH1');
    expect(formatted).toContain('Reference:');
    expect(formatted).toContain('ADD');
    expect(formatted).toContain('Stack depth: 1');
    expect(formatted).toContain('Stack depth: 2');
  });

  it('should format divergence with empty stack', () => {
    const ourEntry: TraceEntry = {
      pc: 0,
      op: 0x00,
      gas: 1000n,
      gasCost: 0n,
      memory: null,
      memSize: 0,
      stack: [],
      returnData: null,
      depth: 0,
      refund: 0n,
      opName: 'STOP',
    };

    const diff = {
      divergenceIndex: 0,
      ourEntry,
      refEntry: null,
      diffField: 'trace_length',
    };

    const formatted = formatTraceDiff(diff);
    expect(formatted).toContain('⚠ Trace Divergence at step 0');
    expect(formatted).toContain('Stack depth: 0');
    expect(formatted).not.toContain('Stack top:');
  });

  it('should include ANSI color codes', () => {
    const diff = {
      divergenceIndex: 0,
      ourEntry: null,
      refEntry: null,
      diffField: 'gas',
    };

    const formatted = formatTraceDiff(diff);
    expect(formatted).toContain('\x1b['); // ANSI escape sequence
  });
});

describe('Integration: Complete execution trace', () => {
  it('should capture complete execution sequence', () => {
    const tracer = new Tracer();
    tracer.enable();

    // PUSH1 0x2a (42)
    tracer.captureState(0, 0x60, 1000n, 3n, null, [], null, 0, 0n, 'PUSH1');

    // PUSH1 0x0a (10)
    tracer.captureState(2, 0x60, 997n, 3n, null, [42n], null, 0, 0n, 'PUSH1');

    // ADD
    tracer.captureState(4, 0x01, 994n, 3n, null, [42n, 10n], null, 0, 0n, 'ADD');

    // Result on stack
    const memory = new Uint8Array(64);
    memory[31] = 52; // 42 + 10 = 52
    tracer.captureState(5, 0x52, 991n, 6n, memory, [52n], null, 0, 0n, 'MSTORE');

    const entries = tracer.getEntries();
    expect(entries.length).toBe(4);

    // Verify execution sequence
    expect(entries[0].opName).toBe('PUSH1');
    expect(entries[0].stack.length).toBe(0);

    expect(entries[1].opName).toBe('PUSH1');
    expect(entries[1].stack.length).toBe(1);
    expect(entries[1].stack[0]).toBe(42n);

    expect(entries[2].opName).toBe('ADD');
    expect(entries[2].stack.length).toBe(2);

    expect(entries[3].opName).toBe('MSTORE');
    expect(entries[3].stack.length).toBe(1);
    expect(entries[3].stack[0]).toBe(52n);
    expect(entries[3].memSize).toBe(64);

    // Verify JSON serialization works
    const json = tracer.toJSON();
    expect(json.length).toBe(4);
    expect(json[0].gas).toBe('0x3e8'); // 1000
  });
});
