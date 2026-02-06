import { sqliteTable, text } from "drizzle-orm/sqlite-core";

export const inputTable = sqliteTable("input", {
  runId: text("run_id").primaryKey(),
  phase: text("phase").notNull(),
});
