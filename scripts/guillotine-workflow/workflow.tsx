import { smithers, Workflow, Task, Sequence, Ralph } from "smithers";
import { db, schema } from "./db";
import { claude, codex } from "./agents";
import { render } from "./steps/render";
import { phases } from "./phases";
import type { ContextRow, ImplementRow, TestRow, ReviewRow, ReviewFixRow, BenchmarkRow, FinalReviewRow, OutputRow } from "./steps/types";
import ContextPrompt from "./steps/0_context.mdx";
import ImplementPrompt from "./steps/1_implement.mdx";
import TestPrompt from "./steps/2_test.mdx";
import ReviewPrompt from "./steps/3_review.mdx";
import ReviewFixPrompt from "./steps/4_review-fix.mdx";
import RefactorPrompt from "./steps/5_refactor.mdx";
import BenchmarkPrompt from "./steps/6_benchmark.mdx";
import FinalReviewPrompt from "./steps/7_final-review.mdx";

const MAX_PASSES = 5;
const MAX_ITERATIONS_PER_PASS = phases.length * 50;

export default smithers(db, (ctx) => {
  const passTracker = ctx.outputMaybe(schema.output, { nodeId: "pass-tracker" }) as OutputRow | undefined;
  const currentPass = passTracker?.totalIterations ?? 0;

  const allPhasesComplete = phases.every(({ id }) => {
    const review = ctx.outputMaybe(schema.final_review, { nodeId: `${id}:final-review` }) as FinalReviewRow | undefined;
    return review?.readyToMoveOn ?? false;
  });

  const done = currentPass >= MAX_PASSES && allPhasesComplete;

  return (
    <Workflow name="guillotine-build">
      <Ralph until={done} maxIterations={MAX_PASSES * MAX_ITERATIONS_PER_PASS} onMaxReached="return-last">
        <Sequence>
          {phases.map(({ id, name }) => {
            const phase = `[pass ${currentPass + 1}/${MAX_PASSES}] ${id} (${name})`;

            const latestFinalReview = ctx.outputMaybe(schema.final_review, { nodeId: `${id}:final-review` }) as FinalReviewRow | undefined;
            const latestContext = ctx.outputMaybe(schema.context, { nodeId: `${id}:context` }) as ContextRow | undefined;
            const latestImplement = ctx.outputMaybe(schema.implement, { nodeId: `${id}:implement` }) as ImplementRow | undefined;
            const latestTest = ctx.outputMaybe(schema.test_results, { nodeId: `${id}:test` }) as TestRow | undefined;
            const latestReview = ctx.outputMaybe(schema.review, { nodeId: `${id}:review` }) as ReviewRow | undefined;
            const latestReviewFix = ctx.outputMaybe(schema.review_fix, { nodeId: `${id}:review-fix` }) as ReviewFixRow | undefined;
            const latestBenchmark = ctx.outputMaybe(schema.benchmark, { nodeId: `${id}:benchmark` }) as BenchmarkRow | undefined;

            const isPhaseComplete = latestFinalReview?.readyToMoveOn ?? false;

            return (
              <Sequence skipIf={isPhaseComplete}>
                <Task id={`${id}:context`} output={schema.context} agent={claude}>
                  {render(ContextPrompt, {
                    phase,
                    previousFeedback: latestFinalReview ?? null,
                    reviewFeedback: latestReview ?? null,
                    failingTests: latestTest && !latestTest.unitTestsPassed ? latestTest.failingSummary : null,
                  })}
                </Task>

                <Task id={`${id}:implement`} output={schema.implement} agent={claude}>
                  {render(ImplementPrompt, {
                    phase,
                    contextFilePath: latestContext?.contextFilePath ?? `docs/context/${id}.md`,
                    previousWork: latestImplement ?? null,
                    failingTests: latestTest?.failingSummary ?? null,
                    reviewFixes: latestReviewFix?.summary ?? null,
                  })}
                </Task>

                <Task id={`${id}:test`} output={schema.test_results} agent={claude}>
                  {render(TestPrompt, { phase })}
                </Task>

                <Task id={`${id}:review`} output={schema.review} agent={codex}>
                  {render(ReviewPrompt, {
                    phase,
                    filesCreated: latestImplement?.filesCreated ?? [],
                    filesModified: latestImplement?.filesModified ?? [],
                    unitTests: latestTest?.unitTestsPassed ? "PASS" : "FAIL",
                    specTests: latestTest?.specTestsPassed ? "PASS" : "FAIL",
                    integrationTests: latestTest?.integrationTestsPassed ? "PASS" : "FAIL",
                    nethermindDiff: latestTest?.nethermindDiffPassed ? "PASS" : "FAIL",
                    failingSummary: latestTest?.failingSummary ?? null,
                  })}
                </Task>

                <Task id={`${id}:review-fix`} output={schema.review_fix} agent={claude} skipIf={latestReview?.severity === "none"}>
                  {render(ReviewFixPrompt, {
                    phase,
                    severity: latestReview?.severity ?? "",
                    feedback: latestReview?.feedback ?? "",
                    issues: latestReview?.issues ?? [],
                  })}
                </Task>

                <Task id={`${id}:refactor`} output={schema.refactor} agent={claude}>
                  {render(RefactorPrompt, { phase })}
                </Task>

                <Task id={`${id}:benchmark`} output={schema.benchmark} agent={claude}>
                  {render(BenchmarkPrompt, { phase })}
                </Task>

                <Task id={`${id}:final-review`} output={schema.final_review} agent={codex}>
                  {render(FinalReviewPrompt, {
                    phase,
                    unitTests: latestTest?.unitTestsPassed ? "PASS" : "FAIL",
                    specTests: latestTest?.specTestsPassed ? "PASS" : "FAIL",
                    integrationTests: latestTest?.integrationTestsPassed ? "PASS" : "FAIL",
                    nethermindDiff: latestTest?.nethermindDiffPassed ? "PASS" : "FAIL",
                    benchmarkStatus: latestBenchmark?.meetsTargets ? "MEETS TARGETS" : "BELOW TARGETS",
                  })}
                </Task>
              </Sequence>
            );
          })}

          {/* After all phases complete a pass, record it and reset for next pass */}
          <Task id="pass-tracker" output={schema.output}>
            {{
              phasesCompleted: phases.map(({ id }) => id),
              totalIterations: currentPass + 1,
              summary: `Pass ${currentPass + 1} of ${MAX_PASSES} complete. ${currentPass + 1 < MAX_PASSES ? "Resetting all phases for next refinement pass." : "All passes complete."}`,
            }}
          </Task>
        </Sequence>
      </Ralph>
    </Workflow>
  );
});
