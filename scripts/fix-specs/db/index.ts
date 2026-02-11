import { drizzle } from "drizzle-orm/bun-sqlite";
import { testResultTable } from "./test-result";
import { fixResultTable } from "./fix-result";
import { commitResultTable } from "./commit-result";
import { summaryTable } from "./summary";

export const schema = {
  test_result: testResultTable,
  fix_result: fixResultTable,
  commit_result: commitResultTable,
  summary: summaryTable,
};

export const db = drizzle(`./spec-fixer.db`, { schema });

(db as any).$client.exec(`
  CREATE TABLE IF NOT EXISTS test_result (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    passed INTEGER NOT NULL,
    output TEXT NOT NULL,
    passed_count INTEGER NOT NULL,
    failed_count INTEGER NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS fix_result (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    success INTEGER NOT NULL,
    what_was_fixed TEXT NOT NULL,
    files_modified TEXT,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS commit_result (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    iteration INTEGER NOT NULL DEFAULT 0,
    committed INTEGER NOT NULL,
    commit_message TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id, iteration)
  );
  CREATE TABLE IF NOT EXISTS summary (
    run_id TEXT NOT NULL,
    node_id TEXT NOT NULL,
    total_suites INTEGER NOT NULL,
    total_passed INTEGER NOT NULL,
    total_failed INTEGER NOT NULL,
    narrative TEXT NOT NULL,
    PRIMARY KEY (run_id, node_id)
  );
`);
