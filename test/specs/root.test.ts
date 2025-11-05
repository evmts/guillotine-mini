/**
 * Root test file for spec tests
 *
 * This file serves as an entry point for the spec test suite.
 * Individual test files are generated in the generated/ directory.
 */

import { test, expect } from 'bun:test';

test('spec test infrastructure', () => {
  // Basic sanity test to ensure test runner works
  expect(true).toBe(true);
});
