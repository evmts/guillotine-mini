import type { schema } from "../db";
import type { SmithersCtx, OutputKey } from "smithers";
import type { contextTable } from "../db/context";
import type { implementTable } from "../db/implement";
import type { testTable } from "../db/test-results";
import type { reviewTable } from "../db/review";
import type { reviewFixTable } from "../db/review-fix";
import type { reviewResponseTable } from "../db/review-response";
import type { benchmarkTable } from "../db/benchmark";
import type { finalReviewTable } from "../db/final-review";
import type { outputTable } from "../db/output";

export type Ctx = SmithersCtx<typeof schema>;

export type ContextRow = typeof contextTable.$inferSelect;
export type ImplementRow = typeof implementTable.$inferSelect;
export type TestRow = typeof testTable.$inferSelect;
export type ReviewRow = typeof reviewTable.$inferSelect;
export type ReviewFixRow = typeof reviewFixTable.$inferSelect;
export type ReviewResponseRow = typeof reviewResponseTable.$inferSelect;
export type BenchmarkRow = typeof benchmarkTable.$inferSelect;
export type FinalReviewRow = typeof finalReviewTable.$inferSelect;
export type OutputRow = typeof outputTable.$inferSelect;
