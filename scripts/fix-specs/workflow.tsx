import { smithers, Workflow, Task, Sequence, Ralph } from "smithers";
import { db, schema } from "./db";
import { testRunner, fixer, committer, summaryAgent } from "./agents";
import { TEST_SUITES } from "./suites";
import { getKnownIssueContext } from "./known-issues";
import { buildTestPrompt } from "./prompts/test";
import { buildFixPrompt } from "./prompts/fix";
import { buildCommitPrompt } from "./prompts/commit";
import { buildSummaryPrompt } from "./prompts/summary";
import {
  testResultSchema,
  fixResultSchema,
  commitResultSchema,
  summarySchema,
} from "./schemas";

// Filter to single suite if specified via input
const suiteName = process.env.FIX_SPECS_SUITE ?? "";

const suites = suiteName
  ? TEST_SUITES.filter((s) => s.name === suiteName)
  : TEST_SUITES;

if (suiteName && suites.length === 0) {
  console.error(`Suite '${suiteName}' not found. Available: ${TEST_SUITES.map((s) => s.name).join(", ")}`);
  process.exit(1);
}

export default smithers(db, (ctx) => {
  // Collect results for summary
  const suiteResults = suites.map((suite) => {
    const latestTest = ctx.outputMaybe(schema.test_result, { nodeId: `${suite.name}:test` }) as any;
    const latestFix = ctx.outputMaybe(schema.fix_result, { nodeId: `${suite.name}:fix` }) as any;
    const testPassed = latestTest?.passed ?? false;
    const wasFixed = latestFix?.success && testPassed;
    return { name: suite.name, passed: testPassed, wasFixed: wasFixed ?? false };
  });

  return (
    <Workflow name="spec-fixer">
      <Sequence>
        {suites.map((suite) => {
          const latestTest = ctx.outputMaybe(schema.test_result, { nodeId: `${suite.name}:test` }) as any;
          const latestFix = ctx.outputMaybe(schema.fix_result, { nodeId: `${suite.name}:fix` }) as any;
          const testPassed = latestTest?.passed ?? false;
          const wasFixed = latestFix?.success && testPassed;

          return (
            <Sequence key={suite.name}>
              <Ralph id={suite.name} until={testPassed} maxIterations={2} onMaxReached="return-last">
                <Sequence>
                  <Task
                    id={`${suite.name}:test`}
                    output={schema.test_result}
                    outputSchema={testResultSchema}
                    agent={testRunner}
                  >
                    {buildTestPrompt(suite)}
                  </Task>
                  <Task
                    id={`${suite.name}:fix`}
                    output={schema.fix_result}
                    outputSchema={fixResultSchema}
                    agent={fixer}
                    skipIf={testPassed}
                  >
                    {buildFixPrompt({
                      suite,
                      testOutput: latestTest?.output ?? "",
                      knownIssueContext: getKnownIssueContext(suite.name),
                      previousFixAttempt: latestFix?.whatWasFixed ?? null,
                    })}
                  </Task>
                </Sequence>
              </Ralph>
              <Task
                id={`${suite.name}:commit`}
                output={schema.commit_result}
                outputSchema={commitResultSchema}
                agent={committer}
                skipIf={!wasFixed}
              >
                {buildCommitPrompt(suite)}
              </Task>
            </Sequence>
          );
        })}
        <Task
          id="summary"
          output={schema.summary}
          outputSchema={summarySchema}
          agent={summaryAgent}
        >
          {buildSummaryPrompt(suiteResults, suites.length)}
        </Task>
      </Sequence>
    </Workflow>
  );
});
