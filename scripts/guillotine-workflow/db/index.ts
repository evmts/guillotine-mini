import { drizzle } from "drizzle-orm/bun-sqlite";
import { inputTable } from "./input";
import { contextTable } from "./context";
import { implementTable } from "./implement";
import { testTable } from "./test-results";
import { reviewTable } from "./review";
import { reviewFixTable } from "./review-fix";
import { reviewResponseTable } from "./review-response";
import { refactorTable } from "./refactor";
import { benchmarkTable } from "./benchmark";
import { finalReviewTable } from "./final-review";
import { outputTable } from "./output";

export {
  inputTable,
  contextTable,
  implementTable,
  testTable,
  reviewTable,
  reviewFixTable,
  reviewResponseTable,
  refactorTable,
  benchmarkTable,
  finalReviewTable,
  outputTable,
};

export const schema = {
  input: inputTable,
  output: outputTable,
  context: contextTable,
  implement: implementTable,
  test_results: testTable,
  review: reviewTable,
  review_fix: reviewFixTable,
  review_response: reviewResponseTable,
  refactor: refactorTable,
  benchmark: benchmarkTable,
  final_review: finalReviewTable,
};

const dbTarget = process.env.WORKFLOW_TARGET ?? "zig";
export const db = drizzle(`./${dbTarget}-guillotine.db`, { schema });

(db as any).$client.exec(`
  CREATE TABLE IF NOT EXISTS input (
    run_id TEXT PRIMARY KEY,
    phase TEXT NOT NULL
  );
  CREATE TABLE IF NOT EXISTS context (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    context_file_path TEXT NOT NULL,
    nethermind_files TEXT,
    spec_files TEXT,
    voltaire_apis TEXT,
    existing_zig_files TEXT,
    test_fixtures TEXT,
    summary TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS implement (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    files_created TEXT,
    files_modified TEXT,
    commit_message TEXT NOT NULL,
    what_was_done TEXT NOT NULL,
    next_smallest_unit TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS test_results (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    unit_tests_passed INTEGER NOT NULL,
    spec_tests_passed INTEGER NOT NULL,
    integration_tests_passed INTEGER NOT NULL,
    nethermind_diff_passed INTEGER NOT NULL,
    failing_summary TEXT,
    test_output TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS review (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    issues TEXT,
    severity TEXT NOT NULL,
    feedback TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS review_fix (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    fixes_made TEXT,
    commit_message TEXT NOT NULL,
    summary TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS review_response (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    fixes_accepted INTEGER NOT NULL,
    remaining_issues TEXT,
    feedback TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS refactor (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    changes_description TEXT NOT NULL,
    commit_message TEXT NOT NULL,
    files_changed TEXT,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS benchmark (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    results TEXT NOT NULL,
    meets_targets INTEGER NOT NULL,
    suggestions TEXT,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS final_review (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    ready_to_move_on INTEGER NOT NULL,
    remaining_issues TEXT,
    reasoning TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS output (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    phases_completed TEXT,
    total_iterations INTEGER NOT NULL,
    summary TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id)
  );
`);
