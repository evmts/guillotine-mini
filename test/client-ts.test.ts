import { expect, test } from "bun:test";

test("client-ts vitest suite", async () => {
  const proc = Bun.spawn(["bun", "run", "--cwd", "client-ts", "test"], {
    stdout: "inherit",
    stderr: "inherit",
  });

  const exitCode = await proc.exited;
  expect(exitCode).toBe(0);
});
