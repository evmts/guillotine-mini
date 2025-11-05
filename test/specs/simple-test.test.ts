/**
 * Simple manual test to validate the setup
 */

import { test, expect } from 'bun:test';
import { Evm } from '../../src/evm';
import { TestHost } from './test-host';
import { Hardfork } from '../../src/frame';
import { hexToBytes } from './utils';

test('simple STOP test', () => {
  const host = new TestHost();
  const evm = new Evm(host, Hardfork.CANCUN);

  // Simple bytecode: STOP (0x00)
  const bytecode = new Uint8Array([0x00]);

  const caller = hexToBytes('0x1000000000000000000000000000000000000000');
  const address = hexToBytes('0x2000000000000000000000000000000000000000');

  // Set up code
  host.setCode(address, bytecode);

  // Call
  const result = evm.call({
    type: 'call',
    caller,
    to: address,
    value: 0n,
    input: new Uint8Array(0),
    gas: 100000n,
  });

  expect(result.success).toBe(true);
  expect(result.output.length).toBe(0);
});

test('simple PUSH1 PUSH1 ADD test', () => {
  const host = new TestHost();
  const evm = new Evm(host, Hardfork.CANCUN);

  // Bytecode: PUSH1 0x02, PUSH1 0x03, ADD, STOP
  // Should compute 2 + 3 = 5
  const bytecode = new Uint8Array([
    0x60, 0x02,  // PUSH1 2
    0x60, 0x03,  // PUSH1 3
    0x01,        // ADD
    0x00,        // STOP
  ]);

  const caller = hexToBytes('0x1000000000000000000000000000000000000000');
  const address = hexToBytes('0x2000000000000000000000000000000000000000');

  host.setCode(address, bytecode);

  const result = evm.call({
    type: 'call',
    caller,
    to: address,
    value: 0n,
    input: new Uint8Array(0),
    gas: 100000n,
  });

  expect(result.success).toBe(true);
});
