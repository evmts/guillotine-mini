#!/usr/bin/env bun
/**
 * Debug Test Script
 * Debug a specific test with trace output
 *
 * Usage: bun scripts/debug-test.ts <test_name>
 *
 * Examples:
 *   bun scripts/debug-test.ts push0Gas
 *   bun scripts/debug-test.ts transStorageOK
 *   bun scripts/debug-test.ts "add"
 */

const args = process.argv.slice(2);
const testName = args[0];

if (!testName) {
  console.log('Usage: bun scripts/debug-test.ts <test_name>\n');
  console.log('Examples:');
  console.log('  bun scripts/debug-test.ts push0Gas           # Debug the push0Gas test');
  console.log('  bun scripts/debug-test.ts transStorageOK     # Debug transStorageOK test');
  console.log('  bun scripts/debug-test.ts "add"              # Debug the "add" test\n');
  console.log('This will:');
  console.log('  1. Run only the specified test');
  console.log('  2. Show trace divergence if test fails');
  console.log('  3. Compare with reference implementation');
  process.exit(1);
}

console.log(`Debugging test: ${testName}`);
console.log('='.repeat(60));
console.log();

// Run the specific test with full output
const proc = Bun.spawn([
  'zig', 'test', 'test/specs/root.zig',
  '--test-runner', 'test_runner.zig',
  '--deps', 'evm,primitives',
  '--mod', 'evm::src/evm.zig',
  '--mod', 'primitives::src/primitives.zig',
  '--test-filter', testName,
], {
  stdout: 'inherit',
  stderr: 'inherit',
});

const exitCode = await proc.exited;

console.log();
console.log('='.repeat(60));
console.log(`Debug run complete for: ${testName}`);

process.exit(exitCode);
