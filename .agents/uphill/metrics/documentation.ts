import { Glob } from "bun";
import { appendFileSync, existsSync, readFileSync } from "fs";
import { dirname, resolve } from "path";

const out = process.env.UPHILL_METRICS;
if (!out) {
  console.error("UPHILL_METRICS is not set");
  process.exit(1);
}

const lines: string[] = [];
const q = (s: string) => JSON.stringify(s);

// 1. Broken local links in root *.md and docs/**/*.md
const mdFiles = [
  ...new Glob("*.md").scanSync("."),
  ...new Glob("docs/**/*.md").scanSync("."),
].sort();

for (const file of mdFiles) {
  const stripped = readFileSync(file, "utf8").replace(/```[\s\S]*?```/g, "");
  let broken: string | null = null;
  for (const m of stripped.matchAll(/!?\[[^\]]*\]\(([^)]+)\)/g)) {
    const target = m[1]!.trim().split(/\s+/)[0]!;
    if (
      !target ||
      target.startsWith("http://") ||
      target.startsWith("https://") ||
      target.startsWith("mailto:") ||
      target.startsWith("#") ||
      target.startsWith("data:")
    ) {
      continue;
    }
    const clean = target.split("#")[0]!.split("?")[0]!;
    if (!clean) continue;
    const candidate = clean.startsWith("/")
      ? resolve(".", clean.slice(1))
      : resolve(dirname(file), clean);
    if (
      !existsSync(candidate) &&
      !existsSync(`${candidate}.md`) &&
      !existsSync(`${candidate}.mdx`)
    ) {
      broken = `broken link: ${target}`;
      break;
    }
  }
  const item = /\s/.test(file) ? q(file) : file;
  lines.push(
    broken
      ? `broken-links ${item} fail note ${q(broken)}`
      : `broken-links ${item} pass`,
  );
}

// 2. Companion *.zig.md doc coverage for top-level production src/*.zig modules
const topSrcZig = [...new Glob("src/*.zig").scanSync(".")]
  .sort()
  .filter((f) => !f.endsWith("_test.zig") && !f.endsWith("_tests.zig") && !f.startsWith("src/bench_"));

let documented = 0;
for (const file of topSrcZig) {
  if (existsSync(`${file}.md`)) documented++;
}
const pct = topSrcZig.length > 0 ? Math.round((documented * 1000) / topSrcZig.length) / 10 : 0;
lines.push(`companion-doc-coverage ${pct}`);

appendFileSync(out, lines.join("\n") + "\n");
