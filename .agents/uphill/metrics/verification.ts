import { Glob } from "bun";
import { appendFileSync, readFileSync } from "fs";

const out = process.env.UPHILL_METRICS;
if (!out) {
  console.error("UPHILL_METRICS is not set");
  process.exit(1);
}

const lines: string[] = [];
const q = (s: string) => JSON.stringify(s);

function isProdZig(path: string): boolean {
  return (
    !path.endsWith("_test.zig") &&
    !path.endsWith("_tests.zig") &&
    !path.startsWith("src/bench_") &&
    !path.endsWith("/bench.zig")
  );
}

// 1. Lean 4 reference specification in spec/lean/
const leanFiles = [...new Glob("spec/lean/**/*.lean").scanSync(".")].sort();
let totalTheorems = 0;

for (const file of leanFiles) {
  const fileLines = readFileSync(file, "utf8").split("\n");
  let sorryHit: string | null = null;
  for (let i = 0; i < fileLines.length; i++) {
    const code = fileLines[i]!.replace(/--.*$/, "");
    if (/^\s*(?:theorem|lemma)\s+/.test(code)) totalTheorems++;
    if (!sorryHit && /\bsorry\b/.test(code)) {
      sorryHit = `line ${i + 1}: unproved sorry in Lean spec`;
    } else if (!sorryHit && /^\s*axiom\s+/.test(code)) {
      sorryHit = `line ${i + 1}: unproved axiom in Lean spec`;
    }
  }
  lines.push(
    sorryHit
      ? `lean-no-sorry ${file} fail note ${q(sorryHit)}`
      : `lean-no-sorry ${file} pass`,
  );
}
lines.push(`lean-theorems ${totalTheorems}`);

// 2. Zig inline test coverage
const zigFiles = [
  ...new Glob("src/**/*.zig").scanSync("."),
  ...new Glob("client/**/*.zig").scanSync("."),
]
  .sort()
  .filter(isProdZig);

let zigWithTests = 0;
for (const file of zigFiles) {
  const txt = readFileSync(file, "utf8");
  if (/^\s*test\s*(?:"[^"]*")?\s*\{/m.test(txt)) zigWithTests++;
}
const zigPct = zigFiles.length > 0 ? Math.round((zigWithTests * 1000) / zigFiles.length) / 10 : 0;
lines.push(`zig-inline-test-coverage ${zigPct}`);

// 3. TypeScript test-to-source file ratio
const allTs = [
  ...new Glob("ts/**/*.ts").scanSync("."),
  ...new Glob("client-ts/**/*.ts").scanSync("."),
].filter((f) => !f.includes("node_modules/") && !f.endsWith(".d.ts"));

let tsProd = 0;
let tsTests = 0;
for (const f of allTs) {
  if (f.endsWith(".test.ts") || f.endsWith(".spec.ts")) tsTests++;
  else if (!f.endsWith(".bench.ts")) tsProd++;
}
const tsRatio = tsProd > 0 ? Math.min(100, Math.round((tsTests * 1000) / tsProd) / 10) : 0;
lines.push(`ts-test-ratio ${tsRatio}`);

appendFileSync(out, lines.join("\n") + "\n");
