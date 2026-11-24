# Contributing to Guillotine Mini

Thanks for helping improve Guillotine Mini. This guide covers setup, workflows, and conventions so you can be productive quickly.

## Prerequisites

- Zig `0.15.1` or later (CI uses `0.15.2`)
- Cargo (Rust build tool), required for Voltaire's cryptographic archive
- A `../voltaire` checkout at the revision pinned in `native-dependencies.json` (see the README "Build from source" section)
- Python 3 and uv (`brew install uv`); execution-specs fills fixtures with Python `3.11+`, which uv can install
- Bun (TypeScript scripts/agents and `client-ts`): `brew install bun`
- Node 22+ and `rustup target add wasm32-unknown-unknown` for the WASM build and tests
- macOS or Linux (CI runs on macOS)

## One‑Time Setup

```bash
# Fetch the fixture submodules read by `zig build test` and `zig build specs`
git submodule update --init execution-specs ethereum-tests

# Ensure Python deps and virtualenv for execution-specs are created on first fill
uv --version  # should print a version

# Scripts/agents dependencies
cd scripts && bun install && cd -
```

## Build And Test

```bash
# Configure the build (plain `zig build` installs no artifacts; see `native` and `wasm` below)
zig build

# Run unit tests and trace regression
zig build unit
zig build test-trace

# Run all tests (unit + spec tests)
zig build test

# Run execution-spec tests (generation happens automatically)
zig build specs

# Build native static library for C FFI
zig build native

# Build and exercise the WASM artifact (Node 22+ for tests)
rustup target add wasm32-unknown-unknown
npm install --global --ignore-scripts binaryen@132.0.0
zig build wasm
zig build test-wasm test-wasm-size

# Build the documentation site (Vocs)
cd docs && npm ci && npm run build && cd -
```

## Running Spec Subsets (fast iteration)

`build.zig` defines a `specs-<fork>` step per hardfork and finer `specs-<fork>-<area>`
sub-steps. List them all with:

```bash
zig build -l | grep specs-
```

Examples:

```bash
zig build specs-shanghai-push0
zig build specs-cancun-tstore-basic
zig build specs-cancun-selfdestruct-basic
zig build specs-cancun-blob-precompile-gas
zig build specs-byzantium-modexp
zig build specs-istanbul-blake2
```

> **Known issue:** the Berlin, Frontier, Prague and Osaka sub-steps (and the
> `specs-berlin`, `specs-frontier`, `specs-prague` and `specs-osaka` steps that
> aggregate them) declare regex-style filters such as `berlin.*acl.*`, but the
> runner matches `TEST_FILTER` as a plain substring (`test/utils.zig`
> `matchesFilter`). Those steps currently select no tests. Use `TEST_FILTER`
> with a literal substring for those forks instead.

You can also filter tests with an environment variable:

```bash
TEST_FILTER="transStorageReset" zig build specs
TEST_FILTER="vmIOandFlowOperations" zig build specs
```

## Diff + Trace (E2E)

On spec failures, the runner automatically:
- Captures an EIP‑3155 trace from our EVM
- Generates a reference trace using the Python `ethereum-spec-evm`
- Compares them and prints the divergence point

Capture an end‑to‑end divergence log to a file:

```bash
# Example: run a likely-failing VM test and tee output
TEST_SEQUENTIAL=1 TEST_FILTER="vmIOandFlowOperations" \
  zig build specs | tee reports/divergence_example.log

# Search the log for divergence prints
rg -n "Trace Divergence|Difference in|Our EVM|Reference" reports/divergence_example.log
```

You can also validate tracing independently. `zig build test-trace` runs a
deterministic native trace regression (`test_trace.zig`) that exits non-zero on
mismatch; it writes no output file:

```bash
zig build test-trace
```

Tip: Generation prints are verbose. Using `TEST_FILTER` to reduce to a few tests keeps logs manageable.

## AI-Assisted Fixer (Optional)

```bash
cd scripts && bun install
export ANTHROPIC_API_KEY=sk-ant-…

# Run a single suite (recommended)
bun run ../scripts/fix-specs.ts suite shanghai-push0

# Or run all suites (long)
bun run ../scripts/fix-specs.ts
```

If `ANTHROPIC_API_KEY` is not set, the script still runs tests but skips auto‑fix attempts with a clear notice.

## Conventions

- Keep changes minimal and focused; avoid drive‑by refactors
- Preserve behavior across hardforks; gate with `hardfork.isAtLeast()`
- Prefer fixing root causes (gas constants, warm/cold access) over patching symptoms
- Use `scripts/test-subset.sh` while iterating; run full `zig build specs` before PRs
- Commit messages: `EMOJI type(scope): description` with one of `🐛 fix`, `♻️ refactor`, `🧪 test` or `⚡ perf` (e.g., `🐛 fix(frame): correct CALL memory expansion for Cancun`). The `commit-lint` workflow rejects other subjects; enable the local hook with `git config core.hooksPath .githooks`

## Known Status

Not every execution-spec state test passes yet, so `zig build test` can fail on `main`. The CI badge in the README shows the current result. Fix failures against the Python execution-specs, which are authoritative for gas order, hardfork guards and error mapping.

