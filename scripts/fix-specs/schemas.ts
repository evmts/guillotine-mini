import { z } from "zod";

export const testResultSchema = z.object({
  passed: z.boolean().describe("Whether all tests in the suite passed"),
  output: z.string().describe("Test command output (stdout + stderr)"),
  passedCount: z.number().describe("Number of tests that passed"),
  failedCount: z.number().describe("Number of tests that failed"),
});

export const fixResultSchema = z.object({
  success: z.boolean().describe("Whether the fix attempt was successful"),
  whatWasFixed: z.string().describe("Description of what was fixed"),
  filesModified: z.array(z.string()).nullable().describe("List of files that were modified"),
});

export const commitResultSchema = z.object({
  committed: z.boolean().describe("Whether a commit was created"),
  commitMessage: z.string().describe("The commit message used"),
});

export const summarySchema = z.object({
  totalSuites: z.number().describe("Total number of test suites processed"),
  totalPassed: z.number().describe("Number of suites that passed"),
  totalFailed: z.number().describe("Number of suites that failed"),
  narrative: z.string().describe("3-4 paragraph narrative summary of the run"),
});
