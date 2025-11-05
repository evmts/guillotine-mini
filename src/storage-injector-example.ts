/**
 * Storage Injector Usage Examples
 *
 * Demonstrates integration patterns for async storage with caching
 */

import { StorageInjector, type EvmLike } from './storage-injector';

// ============================================================================
// Example 1: Basic Usage with Mock EVM
// ============================================================================

function basicUsageExample() {
  console.log('=== Example 1: Basic Usage ===\n');

  const injector = new StorageInjector();

  // Simulate EVM state
  const mockEvm: EvmLike = {
    storage: new Map(),
    original_storage: new Map(),
    balances: new Map(),
    nonces: new Map(),
    code: new Map(),
  };

  const address = '0x1234567890123456789012345678901234567890';
  const slot = 42n;

  // 1. Check cache (miss on first access)
  let cached = injector.getStorageFromCache(address, slot);
  console.log(`Cache lookup: ${cached ?? 'MISS'}`);

  // 2. Simulate async fetch from external storage
  const fetchedValue = 100n; // Would be: await externalStorage.get(address, slot)

  // 3. Cache the fetched value
  injector.cacheStorage(address, slot, fetchedValue);
  console.log(`Cached value: ${fetchedValue}`);

  // 4. Subsequent reads hit cache
  cached = injector.getStorageFromCache(address, slot);
  console.log(`Cache lookup: ${cached} (HIT)`);

  // 5. Mark as dirty when modified
  injector.markStorageDirty(address, slot);
  mockEvm.storage!.set(`${address.toLowerCase()}:2a`, 200n);
  mockEvm.original_storage!.set(`${address.toLowerCase()}:2a`, 100n);

  // 6. Dump changes for commit
  const changes = injector.dumpChanges(mockEvm);
  console.log('\nState changes:', JSON.stringify(changes, null, 2));

  // 7. Cache stats
  const stats = injector.getCacheStats();
  console.log('\nCache stats:', stats.storage);
}

// ============================================================================
// Example 2: Transaction Flow with Cache Clearing
// ============================================================================

function transactionFlowExample() {
  console.log('\n=== Example 2: Transaction Flow ===\n');

  const injector = new StorageInjector();

  const sender = '0x1111111111111111111111111111111111111111';
  const recipient = '0x2222222222222222222222222222222222222222';

  // Transaction 1: Transfer
  console.log('Transaction 1: Transfer 100 wei');

  const evm1: EvmLike = {
    storage: new Map(),
    balances: new Map([
      [sender, 900n],
      [recipient, 100n],
    ]),
    nonces: new Map([[sender, 1n]]),
    code: new Map(),
  };

  injector.markBalanceDirty(sender);
  injector.markBalanceDirty(recipient);
  injector.markNonceDirty(sender);

  const changes1 = injector.dumpChanges(evm1);
  console.log(`Changes: ${changes1.balances.length} balances, ${changes1.nonces.length} nonces`);

  // Clear cache for next transaction
  injector.clearCache();
  console.log('\nCache cleared for next transaction');

  // Transaction 2: Another transfer (clean state)
  console.log('Transaction 2: Transfer 50 wei');

  const evm2: EvmLike = {
    storage: new Map(),
    balances: new Map([
      [sender, 850n],
      [recipient, 150n],
    ]),
    nonces: new Map([[sender, 2n]]),
    code: new Map(),
  };

  injector.markBalanceDirty(sender);
  injector.markBalanceDirty(recipient);
  injector.markNonceDirty(sender);

  const changes2 = injector.dumpChanges(evm2);
  console.log(`Changes: ${changes2.balances.length} balances, ${changes2.nonces.length} nonces`);
}

// ============================================================================
// Example 3: Contract Deployment with Code
// ============================================================================

function contractDeploymentExample() {
  console.log('\n=== Example 3: Contract Deployment ===\n');

  const injector = new StorageInjector();

  const deployer = '0x1111111111111111111111111111111111111111';
  const contract = '0x2222222222222222222222222222222222222222';

  // Contract bytecode (simple PUSH1 80 PUSH1 40 MSTORE)
  const code = new Uint8Array([0x60, 0x80, 0x60, 0x40, 0x52]);

  const evm: EvmLike = {
    storage: new Map(),
    balances: new Map([
      [deployer, 900n], // Paid gas
    ]),
    nonces: new Map([
      [deployer, 1n], // Incremented
      [contract, 1n], // Contract nonce = 1
    ]),
    code: new Map([[contract, code]]),
  };

  // Track changes
  injector.markBalanceDirty(deployer);
  injector.markNonceDirty(deployer);
  injector.markNonceDirty(contract);
  injector.markCodeDirty(contract);

  const changes = injector.dumpChanges(evm);

  console.log('Deployer balance:', changes.balances[0].balance);
  console.log('Deployer nonce:', changes.nonces[0].nonce);
  console.log('Contract nonce:', changes.nonces[1].nonce);
  console.log('Contract code:', changes.codes[0].code);
}

// ============================================================================
// Example 4: Storage Writes During Execution
// ============================================================================

function storageWritesExample() {
  console.log('\n=== Example 4: Storage Writes ===\n');

  const injector = new StorageInjector();

  const contract = '0x1234567890123456789012345678901234567890';

  const evm: EvmLike = {
    storage: new Map([
      [`${contract.toLowerCase()}:0`, 100n],
      [`${contract.toLowerCase()}:1`, 200n],
      [`${contract.toLowerCase()}:5`, 500n],
    ]),
    original_storage: new Map([
      [`${contract.toLowerCase()}:0`, 0n], // New
      [`${contract.toLowerCase()}:1`, 150n], // Updated
      [`${contract.toLowerCase()}:5`, 500n], // Unchanged
    ]),
    balances: new Map(),
    nonces: new Map(),
    code: new Map(),
  };

  // Mark slots as dirty (EVM would do this on SSTORE)
  injector.markStorageDirty(contract, 0n); // New
  injector.markStorageDirty(contract, 1n); // Updated
  injector.markStorageDirty(contract, 5n); // Unchanged (but marked)

  const changes = injector.dumpChanges(evm);

  console.log('Storage changes:');
  for (const change of changes.storage) {
    console.log(
      `  Slot ${change.slot}: ${change.originalValue} → ${change.newValue}`
    );
  }
}

// ============================================================================
// Example 5: Cache Statistics and Performance
// ============================================================================

function cacheStatisticsExample() {
  console.log('\n=== Example 5: Cache Statistics ===\n');

  const injector = new StorageInjector();

  const address = '0x1234567890123456789012345678901234567890';

  // Populate cache
  injector.cacheStorage(address, 1n, 100n);
  injector.cacheStorage(address, 2n, 200n);
  injector.cacheStorage(address, 3n, 300n);

  // Generate mixed hits/misses
  injector.getStorageFromCache(address, 1n); // Hit
  injector.getStorageFromCache(address, 1n); // Hit
  injector.getStorageFromCache(address, 2n); // Hit
  injector.getStorageFromCache(address, 99n); // Miss
  injector.getStorageFromCache(address, 100n); // Miss

  const stats = injector.getCacheStats();

  console.log('Storage cache:');
  console.log(`  Size: ${stats.storage.size}`);
  console.log(`  Hits: ${stats.storage.hits}`);
  console.log(`  Misses: ${stats.storage.misses}`);
  console.log(
    `  Hit rate: ${((stats.storage.hits / (stats.storage.hits + stats.storage.misses)) * 100).toFixed(1)}%`
  );
}

// ============================================================================
// Example 6: Integration Pattern with Async Backend
// ============================================================================

async function asyncIntegrationExample() {
  console.log('\n=== Example 6: Async Integration Pattern ===\n');

  const injector = new StorageInjector();

  // Simulated async backend
  const asyncBackend = {
    async getStorage(address: string, slot: bigint): Promise<bigint> {
      // Simulate network delay
      await new Promise((resolve) => setTimeout(resolve, 10));
      console.log(`  [Backend] Fetching ${address}:${slot}`);
      return 42n;
    },
  };

  const address = '0x1234567890123456789012345678901234567890';
  const slot = 5n;

  // Helper: Get with cache-first fallback
  async function getStorageWithCache(
    address: string,
    slot: bigint
  ): Promise<bigint> {
    // 1. Check cache first
    const cached = injector.getStorageFromCache(address, slot);
    if (cached !== undefined) {
      console.log(`  [Cache] Hit: ${cached}`);
      return cached;
    }

    // 2. Cache miss - fetch from backend
    console.log('  [Cache] Miss - fetching from backend');
    const value = await asyncBackend.getStorage(address, slot);

    // 3. Cache for future use
    injector.cacheStorage(address, slot, value);

    return value;
  }

  // First access: cache miss
  console.log('First access:');
  const value1 = await getStorageWithCache(address, slot);
  console.log(`Result: ${value1}\n`);

  // Second access: cache hit
  console.log('Second access:');
  const value2 = await getStorageWithCache(address, slot);
  console.log(`Result: ${value2}\n`);

  const stats = injector.getCacheStats();
  console.log(`Cache stats: ${stats.storage.hits} hits, ${stats.storage.misses} misses`);
}

// ============================================================================
// Run Examples
// ============================================================================

async function main() {
  console.log('Storage Injector Examples\n');
  console.log('='.repeat(60) + '\n');

  basicUsageExample();
  transactionFlowExample();
  contractDeploymentExample();
  storageWritesExample();
  cacheStatisticsExample();
  await asyncIntegrationExample();

  console.log('\n' + '='.repeat(60));
  console.log('All examples completed!');
}

// Run if executed directly
if (import.meta.main) {
  main().catch(console.error);
}
