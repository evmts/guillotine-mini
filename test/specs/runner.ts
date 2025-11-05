/**
 * Spec Test Runner
 *
 * Executes ethereum/tests JSON fixtures against the TypeScript EVM implementation.
 * Handles pre-state setup, transaction execution, and post-state validation.
 *
 * Port of test/specs/runner.zig
 */

import { Evm, type BlockContext } from '../../src/evm';
import { TestHost } from './test-host';
import { Hardfork } from '../../src/frame';
import type { Address } from '../../src/host';
import type { CallParamsUnion } from '../../src/call-params';
import { hexToBytes, bytesToHex, hexToBigInt, bigIntToHex } from './utils';

/**
 * Parse hardfork name from string
 */
function parseHardfork(name: string): Hardfork {
  const normalized = name.toLowerCase();

  if (normalized.includes('frontier')) return Hardfork.FRONTIER;
  if (normalized.includes('homestead')) return Hardfork.HOMESTEAD;
  if (normalized.includes('tangerine')) return Hardfork.TANGERINE;
  if (normalized.includes('spurious')) return Hardfork.SPURIOUS;
  if (normalized.includes('byzantium')) return Hardfork.BYZANTIUM;
  if (normalized.includes('constantinople')) return Hardfork.CONSTANTINOPLE;
  if (normalized.includes('istanbul')) return Hardfork.ISTANBUL;
  if (normalized.includes('berlin')) return Hardfork.BERLIN;
  if (normalized.includes('london')) return Hardfork.LONDON;
  if (normalized.includes('merge') || normalized.includes('paris')) return Hardfork.MERGE;
  if (normalized.includes('shanghai')) return Hardfork.SHANGHAI;
  if (normalized.includes('cancun')) return Hardfork.CANCUN;
  if (normalized.includes('prague')) return Hardfork.PRAGUE;
  if (normalized.includes('osaka')) return Hardfork.OSAKA;

  // Default to Cancun if unknown
  console.warn(`Unknown hardfork: ${name}, defaulting to Cancun`);
  return Hardfork.CANCUN;
}

/**
 * Run a single JSON test case
 *
 * @param fixture - JSON test fixture
 * @param testName - Name of the specific test case within the fixture
 */
export async function runJsonTest(fixture: any, testName: string): Promise<void> {
  // Get the specific test case
  const testCase = fixture[testName];
  if (!testCase) {
    throw new Error(`Test case "${testName}" not found in fixture`);
  }

  // Extract test components
  const preState = testCase.pre;
  const transaction = testCase.transaction;
  const env = testCase.env;
  const postState = testCase.post;
  const expect = testCase.expect;

  // Determine hardfork
  let hardfork: Hardfork = Hardfork.CANCUN;
  if (postState) {
    // State test format: post contains hardfork-specific expectations
    const hardforks = Object.keys(postState);
    if (hardforks.length > 0) {
      hardfork = parseHardfork(hardforks[0]!);
    }
  } else if (expect && expect.length > 0) {
    // Blockchain test format: expect contains network field
    const networkStr = expect[0].network?.[0] || 'Cancun';
    hardfork = parseHardfork(networkStr);
  }

  // Create test host
  const host = new TestHost();

  // Set up pre-state
  for (const [addressStr, account] of Object.entries(preState) as [string, any][]) {
    const address = hexToBytes(addressStr);

    // Set balance
    if (account.balance) {
      const balance = hexToBigInt(account.balance);
      host.setBalance(address, balance);
    }

    // Set nonce
    if (account.nonce) {
      const nonce = hexToBigInt(account.nonce);
      host.setNonce(address, nonce);
    }

    // Set code
    if (account.code) {
      const code = hexToBytes(account.code);
      host.setCode(address, code);
    }

    // Set storage
    if (account.storage) {
      for (const [slotStr, valueStr] of Object.entries(account.storage) as [string, string][]) {
        const slot = hexToBigInt(slotStr);
        const value = hexToBigInt(valueStr);
        host.setStorage(address, slot, value);
      }
    }
  }

  // Create block context
  const blockContext: BlockContext = {
    chain_id: env.currentChainId ? hexToBigInt(env.currentChainId) : 1n,
    block_number: hexToBigInt(env.currentNumber || '0x0'),
    block_timestamp: hexToBigInt(env.currentTimestamp || '0x0'),
    block_difficulty: hexToBigInt(env.currentDifficulty || '0x0'),
    block_prevrandao: hexToBigInt(env.currentRandom || env.currentDifficulty || '0x0'),
    block_coinbase: hexToBytes(env.currentCoinbase || '0x0000000000000000000000000000000000000000'),
    block_gas_limit: hexToBigInt(env.currentGasLimit || '0x989680'), // 10M default
    block_base_fee: hexToBigInt(env.currentBaseFee || '0x0'),
    blob_base_fee: hexToBigInt(env.currentBlobBaseFee || '0x1'), // Default to 1
    block_hashes: [],
  };

  // Create EVM
  const evm = new Evm(host, hardfork, blockContext);

  // Parse transaction
  const sender = hexToBytes(transaction.sender || transaction.secretKey); // Some tests use secretKey
  const to = transaction.to ? hexToBytes(transaction.to) : new Uint8Array(20);
  const value = hexToBigInt(transaction.value?.[0] || '0x0');
  const data = hexToBytes(transaction.data?.[0] || '0x');
  const gasLimit = hexToBigInt(transaction.gasLimit?.[0] || '0x989680');

  // Build call params
  const isCreate = to.every((b) => b === 0);
  const callParams: CallParamsUnion = isCreate
    ? {
        type: 'create',
        caller: sender,
        value,
        initCode: data,
        gas: gasLimit,
      }
    : {
        type: 'call',
        caller: sender,
        to,
        value,
        input: data,
        gas: gasLimit,
      };

  // Execute transaction
  const result = evm.call(callParams);

  // Validate post-state
  if (postState) {
    // State test format
    const hardforkResults = postState[Object.keys(postState)[0]!];
    if (hardforkResults && hardforkResults.length > 0) {
      const expectedResult = hardforkResults[0];

      // Check success/failure
      if (expectedResult.expectException) {
        if (result.success) {
          throw new Error(`Expected exception but transaction succeeded`);
        }
      } else {
        if (!result.success) {
          throw new Error(`Transaction failed: ${result.error_info || 'Unknown error'}`);
        }
      }

      // Validate post-state accounts
      if (expectedResult.post) {
        for (const [addressStr, expectedAccount] of Object.entries(expectedResult.post) as [string, any][]) {
          const address = hexToBytes(addressStr);

          // Check balance
          if (expectedAccount.balance !== undefined) {
            const expectedBalance = hexToBigInt(expectedAccount.balance);
            const actualBalance = host.getBalance(address);
            if (actualBalance !== expectedBalance) {
              throw new Error(
                `Balance mismatch for ${addressStr}: expected ${expectedBalance}, got ${actualBalance}`
              );
            }
          }

          // Check nonce
          if (expectedAccount.nonce !== undefined) {
            const expectedNonce = hexToBigInt(expectedAccount.nonce);
            const actualNonce = host.getNonce(address);
            if (actualNonce !== expectedNonce) {
              throw new Error(
                `Nonce mismatch for ${addressStr}: expected ${expectedNonce}, got ${actualNonce}`
              );
            }
          }

          // Check storage
          if (expectedAccount.storage) {
            for (const [slotStr, expectedValueStr] of Object.entries(expectedAccount.storage) as [
              string,
              string
            ][]) {
              const slot = hexToBigInt(slotStr);
              const expectedValue = hexToBigInt(expectedValueStr);
              const actualValue = host.getStorage(address, slot);
              if (actualValue !== expectedValue) {
                throw new Error(
                  `Storage mismatch for ${addressStr}[${slot}]: expected ${expectedValue}, got ${actualValue}`
                );
              }
            }
          }
        }
      }
    }
  } else if (expect) {
    // Blockchain test format
    const expectedResult = expect[0];

    // Validate result
    if (expectedResult.result) {
      for (const [addressStr, expectedAccount] of Object.entries(expectedResult.result) as [string, any][]) {
        const address = hexToBytes(addressStr);

        // Check balance
        if (expectedAccount.balance !== undefined) {
          const expectedBalance = hexToBigInt(expectedAccount.balance);
          const actualBalance = host.getBalance(address);
          if (actualBalance !== expectedBalance) {
            throw new Error(
              `Balance mismatch for ${addressStr}: expected ${expectedBalance}, got ${actualBalance}`
            );
          }
        }

        // Check nonce
        if (expectedAccount.nonce !== undefined) {
          const expectedNonce = hexToBigInt(expectedAccount.nonce);
          const actualNonce = host.getNonce(address);
          if (actualNonce !== expectedNonce) {
            throw new Error(
              `Nonce mismatch for ${addressStr}: expected ${expectedNonce}, got ${actualNonce}`
            );
          }
        }

        // Check storage
        if (expectedAccount.storage) {
          for (const [slotStr, expectedValueStr] of Object.entries(expectedAccount.storage) as [
            string,
            string
          ][]) {
            const slot = hexToBigInt(slotStr);
            const expectedValue = hexToBigInt(expectedValueStr);
            const actualValue = host.getStorage(address, slot);
            if (actualValue !== expectedValue) {
              throw new Error(
                `Storage mismatch for ${addressStr}[${slot}]: expected ${expectedValue}, got ${actualValue}`
              );
            }
          }
        }
      }
    }
  }
}
