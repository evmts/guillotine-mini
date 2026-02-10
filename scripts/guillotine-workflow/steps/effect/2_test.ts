export default function EffectTestPrompt(props: { phase: string }): string {
  return `TESTING PHASE: ${props.phase}

Run ALL of the following test categories and report results:

1. UNIT TESTS:
   Run: cd client-ts && bun test
   Check that all @effect/vitest it.effect() tests pass for the files we just created/modified.
   Verify:
   - All Effect.gen compositions resolve correctly
   - Layer composition works (services resolve their dependencies)
   - Error channels are properly typed and tested
   - Data.TaggedError instances are caught and matched correctly

2. SPEC TESTS (official Ethereum test vectors):
   Based on the phase:
   - Phase 1 (trie): Run tests against ethereum-tests/TrieTests/ data
   - Phase 3 (evm-state): Run against ethereum-tests/GeneralStateTests/ fixtures
   - Phase 4 (blockchain): Run against ethereum-tests/BlockchainTests/
   If no spec tests apply to this phase yet, note "N/A" but still run unit tests.

3. INTEGRATION TESTS:
   If there are integration tests that test this module with previous modules, run them.
   Verify Layer composition across module boundaries works correctly.

4. NETHERMIND DIFFERENTIAL TESTS:
   If applicable, verify our output matches Nethermind's for the same inputs.
   For trie: same inserts -> same root hash
   For state: same tx -> same post-state root
   For block processing: same block -> same receipts root

If any tests fail and you need to fix code to make them pass, commit each fix atomically:
- git add the specific files, then commit
- Format: "🐛 fix(SCOPE): what was fixed"

If you add new test files, commit them:
- Format: "🧪 test(SCOPE): what was tested"

Report each category: passed or failed with details.

IMPORTANT: After running all tests, you MUST output a JSON object:
\`\`\`json
{
  "unitTestsPassed": true,
  "specTestsPassed": true,
  "integrationTestsPassed": true,
  "nethermindDiffPassed": true,
  "failingSummary": null,
  "testOutput": "Full test output summary"
}
\`\`\`
Set boolean values to true/false based on test results. If any tests fail, put a summary of failures in failingSummary.`;
}
