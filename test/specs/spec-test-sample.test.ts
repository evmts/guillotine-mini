/**
 * Sample spec test using a real fixture
 */

import { test } from 'bun:test';
import { runJsonTest } from './runner';

const TEST_FILE = '/Users/williamcory/guillotine-mini/execution-specs/tests/eest/static/state_tests/stTimeConsuming/sstore_combinations_initial20_2_ParisFiller.json';

test('sstore_combinations_initial20_2_Paris', async () => {
  const fixture = await Bun.file(TEST_FILE).json();
  await runJsonTest(fixture, 'sstore_combinations_initial20_2_Paris');
});
