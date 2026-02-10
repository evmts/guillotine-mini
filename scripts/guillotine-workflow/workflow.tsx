import { smithers, Workflow, Task, Sequence, Ralph } from "smithers";
import { db, schema } from "./db";
import { makeCodex } from "./agents/codex";
import { render } from "./steps/render";
import { phases } from "./phases";
import { getTarget } from "./targets";
import type { ContextRow, ImplementRow, TestRow, ReviewRow, ReviewFixRow, ReviewResponseRow, BenchmarkRow, FinalReviewRow, OutputRow } from "./steps/types";
import {
  contextOutputSchema,
  implementOutputSchema,
  testOutputSchema,
  reviewOutputSchema,
  reviewFixOutputSchema,
  reviewResponseOutputSchema,
  refactorOutputSchema,
  benchmarkOutputSchema,
  finalReviewOutputSchema,
} from "./db/schemas";
import ContextPrompt from "./steps/0_context.mdx";
import ZigImplementPrompt from "./steps/1_implement.mdx";
import ZigTestPrompt from "./steps/2_test.mdx";
import ReviewPrompt from "./steps/3_review.mdx";
import ReviewFixPrompt from "./steps/4_review-fix.mdx";
import ReviewResponsePrompt from "./steps/4.5_review-response.mdx";
import ZigRefactorPrompt from "./steps/5_refactor.mdx";
import BenchmarkPrompt from "./steps/6_benchmark.mdx";
import FinalReviewPrompt from "./steps/7_final-review.mdx";
import EffectImplementPrompt from "./steps/effect/1_implement";
import EffectTestPrompt from "./steps/effect/2_test";
import EffectRefactorPrompt from "./steps/effect/5_refactor";

const MAX_PASSES = 5;
const MAX_ITERATIONS_PER_PASS = phases.length * 50;

const skipPhases = new Set(
  (process.env.SKIP_PHASES ?? "").split(",").map((s) => s.trim()).filter(Boolean)
);

export default smithers(db, (ctx) => {
  const targetId = (ctx as any).input?.target ?? process.env.WORKFLOW_TARGET ?? "zig";
  const target = getTarget(targetId);
  const codex = makeCodex(target);

  const ImplementPrompt = target.id === "effect" ? EffectImplementPrompt : ZigImplementPrompt;
  const TestPrompt = target.id === "effect" ? EffectTestPrompt : ZigTestPrompt;
  const RefactorPrompt = target.id === "effect" ? EffectRefactorPrompt : ZigRefactorPrompt;

  const passTracker = ctx.outputMaybe(schema.output, { nodeId: "pass-tracker" }) as OutputRow | undefined;
  const currentPass = passTracker?.totalIterations ?? 0;

  const allPhasesComplete = phases.every(({ id }) => {
    const review = ctx.outputMaybe(schema.final_review, { nodeId: `${id}:final-review` }) as FinalReviewRow | undefined;
    return review?.readyToMoveOn ?? false;
  });

  const done = currentPass >= MAX_PASSES && allPhasesComplete;

  return (
    <Workflow name={`guillotine-build-${target.id}`}>
      <Ralph until={done} maxIterations={MAX_PASSES * MAX_ITERATIONS_PER_PASS} onMaxReached="return-last">
        <Sequence>
          {phases.map(({ id, name }, idx) => {
            const phase = `[pass ${currentPass + 1}/${MAX_PASSES}] ${id} (${name})`;

            const latestFinalReview = ctx.outputMaybe(schema.final_review, { nodeId: `${id}:final-review` }) as FinalReviewRow | undefined;
            const latestContext = ctx.outputMaybe(schema.context, { nodeId: `${id}:context` }) as ContextRow | undefined;
            const latestImplement1 = ctx.outputMaybe(schema.implement, { nodeId: `${id}:implement-1` }) as ImplementRow | undefined;
            const latestImplement2 = ctx.outputMaybe(schema.implement, { nodeId: `${id}:implement-2` }) as ImplementRow | undefined;
            const latestImplement = latestImplement2 ?? latestImplement1;
            const latestTest = ctx.outputMaybe(schema.test_results, { nodeId: `${id}:test` }) as TestRow | undefined;
            const latestReview = ctx.outputMaybe(schema.review, { nodeId: `${id}:review` }) as ReviewRow | undefined;
            const latestReviewFix = ctx.outputMaybe(schema.review_fix, { nodeId: `${id}:review-fix` }) as ReviewFixRow | undefined;
            const latestReviewResponse = ctx.outputMaybe(schema.review_response, { nodeId: `${id}:review-response` }) as ReviewResponseRow | undefined;
            const latestBenchmark = ctx.outputMaybe(schema.benchmark, { nodeId: `${id}:benchmark` }) as BenchmarkRow | undefined;

            const isPhaseComplete = latestFinalReview?.readyToMoveOn ?? false;
            const isPhaseSkipped = skipPhases.has(id);

            return (
              <Sequence key={id} skipIf={isPhaseComplete || isPhaseSkipped}>
                <Task id={`${id}:context`} output={schema.context} outputSchema={contextOutputSchema} agent={codex}>
                  {render(ContextPrompt, {
                    phase,
                    target,
                    previousFeedback: latestFinalReview ?? null,
                    reviewFeedback: latestReview ?? null,
                    failingTests: latestTest && !latestTest.unitTestsPassed ? latestTest.failingSummary : null,
                  })}
                </Task>

                {/* Implement pass 1 */}
                <Task id={`${id}:implement-1`} output={schema.implement} outputSchema={implementOutputSchema} agent={codex}>
                  {render(ImplementPrompt, {
                    phase,
                    target,
                    contextFilePath: latestContext?.contextFilePath ?? `docs/context/${id}.md`,
                    previousWork: latestImplement1 ?? null,
                    failingTests: latestTest?.failingSummary ?? null,
                    reviewFixes: latestReviewFix?.summary ?? null,
                    implementPass: 1,
                  })}
                </Task>

                {/* Implement pass 2 — builds on pass 1 output */}
                <Task id={`${id}:implement-2`} output={schema.implement} outputSchema={implementOutputSchema} agent={codex}>
                  {render(ImplementPrompt, {
                    phase,
                    target,
                    contextFilePath: latestContext?.contextFilePath ?? `docs/context/${id}.md`,
                    previousWork: latestImplement1 ?? null,
                    failingTests: latestTest?.failingSummary ?? null,
                    reviewFixes: latestReviewFix?.summary ?? null,
                    implementPass: 2,
                  })}
                </Task>

                <Task id={`${id}:test`} output={schema.test_results} outputSchema={testOutputSchema} agent={codex}>
                  {render(TestPrompt, { phase, target })}
                </Task>

                <Task id={`${id}:review`} output={schema.review} outputSchema={reviewOutputSchema} agent={codex}>
                  {render(ReviewPrompt, {
                    phase,
                    target,
                    filesCreated: latestImplement?.filesCreated ?? [],
                    filesModified: latestImplement?.filesModified ?? [],
                    unitTests: latestTest?.unitTestsPassed ? "PASS" : "FAIL",
                    specTests: latestTest?.specTestsPassed ? "PASS" : "FAIL",
                    integrationTests: latestTest?.integrationTestsPassed ? "PASS" : "FAIL",
                    nethermindDiff: latestTest?.nethermindDiffPassed ? "PASS" : "FAIL",
                    failingSummary: latestTest?.failingSummary ?? null,
                  })}
                </Task>

                <Task id={`${id}:review-fix`} output={schema.review_fix} outputSchema={reviewFixOutputSchema} agent={codex} skipIf={latestReview?.severity === "none"}>
                  {render(ReviewFixPrompt, {
                    phase,
                    target,
                    severity: latestReview?.severity ?? "",
                    feedback: latestReview?.feedback ?? "",
                    issues: latestReview?.issues ?? [],
                  })}
                </Task>

                <Task id={`${id}:review-response`} output={schema.review_response} outputSchema={reviewResponseOutputSchema} agent={codex} skipIf={latestReview?.severity === "none"}>
                  {render(ReviewResponsePrompt, {
                    phase,
                    target,
                    originalSeverity: latestReview?.severity ?? "",
                    originalFeedback: latestReview?.feedback ?? "",
                    originalIssues: latestReview?.issues ?? [],
                    fixesMade: latestReviewFix?.fixesMade ?? [],
                    fixSummary: latestReviewFix?.summary ?? "",
                    fixCommitMessage: latestReviewFix?.commitMessage ?? "",
                  })}
                </Task>

                <Task id={`${id}:refactor`} output={schema.refactor} outputSchema={refactorOutputSchema} agent={codex}>
                  {render(RefactorPrompt, { phase, target })}
                </Task>

                <Task id={`${id}:benchmark`} output={schema.benchmark} outputSchema={benchmarkOutputSchema} agent={codex} retries={2}>
                  {render(BenchmarkPrompt, {
                    phase,
                    target,
                    filesCreated: latestImplement?.filesCreated ?? [],
                    filesModified: latestImplement?.filesModified ?? [],
                    whatWasDone: latestImplement?.whatWasDone ?? null,
                  })}
                </Task>

                <Task id={`${id}:final-review`} output={schema.final_review} outputSchema={finalReviewOutputSchema} agent={codex}>
                  {render(FinalReviewPrompt, {
                    phase,
                    target,
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
