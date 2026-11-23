# PR and issue triage, and the v0.1.0 release plan

Status as of 2026-11-22, against `main` at `edafd394`
(`fix(wasm): build and execute the WASI reactor with linked crypto`).

This document gives one disposition for every open pull request and issue in
`evmts/guillotine-mini`, the comment to post for each, and the checklist that
gates `v0.1.0`. Nothing here has been posted or merged. A maintainer runs the
steps.

```
PRs                                  Issues
#20  close                           #15  close (won't fix: WASI reactor is the target)
#22  close, salvage 3 files later    #23  keep, re-scope to a CI size budget
#39  split: land docs, drop the rest #24  close when #39-docs + #40 land
#40  rebase onto main, then merge    #25  keep, re-scope to Zig examples
                                     #27  close (not planned for 0.1.0)
                                     #28  close (not planned for 0.1.0)
                                     #33  close (fixed)
                                     #34  close after a clean-clone check
                                     #37  close (fixed by edafd394)
```

## 1. Evidence

Commit graph, read with `jj log` in the maintenance workspace:

```
main  edafd394  fix(wasm): build and execute the WASI reactor ...
  |   677c7d46  fix(build): pin the corrected native crypto target resolver
  |   ...       (5 commits)
  |
  |   5e9de6f2  PR #40  quality/ui-guillotine-mini      (docs theme, logos, stepper)
  |   34ddfe09  PR #39  prod/guillotine-mini-readiness  (vocs docs site)
  |   17a2b11c  PR #39                                  (release prep 0.1.0)
  | /
b368da47  Use package-manager Voltaire dependency   <- merge base of #39/#40 with main
  :
c496276f  2025-10-06                                 <- merge base of #22 with main
acd72e6f  2025-10-06                                 <- merge base of #20 with main
```

| PR | Head | Base | Size | GitHub mergeable | Checks |
|---|---|---|---|---|---|
| #20 | `worktreeleft2` `717dacd6` | `main` | +335,060 / -2,469, 814 files | CONFLICTING | none current |
| #22 | `feat/fork-state-host` `afd892a7` | `main` | +225,836 / -30,062, 1,002 files | CONFLICTING | none current |
| #39 | `prod/guillotine-mini-readiness` `34ddfe09` | `main` | +15,176 / -137, 41 files | CONFLICTING | `lint` fails; `build-test` and docs build pass |
| #40 | `quality/ui-guillotine-mini` `5e9de6f2` | PR #39 branch | +1,321 / -5, 9 files | MERGEABLE (into #39) | `lint` fails; `build-test` and docs build pass |

`fix/evm-spec-bugs` (`42daa463`) is already an ancestor of `main`. It needs no
action beyond deleting the remote branch.

## 2. Pull requests

### #20 "Major EVM hardfork fixes and comprehensive test analysis": close

The branch forked on 2025-10-06 and adds 335,060 lines across 814 files, most
of them generated analysis reports. `main` has since replaced the `primitives`
import with `voltaire`, split opcode handlers into `src/instructions/`, and
removed the report files in `d3fee069`. The hardfork fixes the PR describes
reached `main` through later commits. No file in the branch is worth porting.

Steps:

1. Post the comment below and close the PR.
2. Delete the remote branch `worktreeleft2`. Delete `worktree2`,
   `worktree2cancun`, `ui`, and `native-ffi-build` in the same pass. They are
   unreferenced branches from the same period.

Comment:

> Closing. This branch forked from `main` on 2025-10-06 and conflicts across
> 814 files. The hardfork fixes it describes have since landed on `main`
> through smaller commits, and the generated analysis reports were removed
> from the repository on purpose in `d3fee069`. Nothing here remains to port.
> If a specific fix from this branch is missing on `main`, open an issue that
> names the failing spec test.

### #22 "Add fork-state host with RPC integration and 3-tier caching": close, salvage later

The tip commit `afd892a7` is the only commit with feature content. It adds
three files and edits three:

```
A src/host/fork_host.zig     3-tier cache: local -> fork cache -> RPC
A src/host/json_rpc.zig      eth_getStorageAt / getBalance / getCode / getTransactionCount codecs
A src/host/test_host.zig     moved from test/specs/
M src/root.zig  src/root_c.zig  CLAUDE.md
```

The other 999 changed files are the 13-month divergence from `main`. The PR
cannot be rebased as a unit. The feature also overlaps with
`src/storage_injector.zig` and `src/async_executor.zig`, which `main` now uses
for the same job (state supplied lazily by the embedder), and ZEVM owns fork
state for the native integration.

Decision: close. Do not port for `v0.1.0`. Salvage only if a consumer asks for
a Zig-side fork host, and then port `fork_host.zig` and `json_rpc.zig` as a
new PR on current `main`:

1. `jj new main`, then
   `jj restore --from afd892a7 src/host/fork_host.zig src/host/json_rpc.zig`.
2. Replace `@import("primitives")` with `@import("voltaire")`.
3. Implement against the current `HostInterface` in `src/host.zig` and the
   storage injector, not the October 2025 vtable.
4. Leave `src/root_c.zig` out. Its ownership and export list changed in
   `edafd394`.

Comment:

> Closing as unmergeable: the branch forked on 2025-10-06 and now conflicts
> across 1,002 files, while the feature itself is three new files in the tip
> commit `afd892a7` (`src/host/fork_host.zig`, `src/host/json_rpc.zig`,
> `src/host/test_host.zig`). Since then `main` gained `storage_injector.zig`
> and `async_executor.zig`, which cover lazy state loading from the embedder,
> and ZEVM owns fork state for the native integration. Fork state in
> guillotine-mini is not planned for 0.1.0. The commit stays reachable by
> hash. If you need a Zig-side fork host, open an issue with the use case and
> we will port the two host files onto current `main`.

### #39 "prepare guillotine-mini 0.1.0": split. Land the docs commit, supersede the release commit

The PR holds two unrelated commits.

| Commit | Content | Disposition |
|---|---|---|
| `17a2b11c` release prep | `build.zig`, `build.zig.zon`, `package.json`, `README.md`, `LICENSE`, `CONTRIBUTING.md`, `ci.yml`, new `release.yml`, `rust-toolchain.toml`, 4 source files | Superseded by `main`. Do not rebase. Salvage 3 items by hand. |
| `34ddfe09` docs site | 27 new files, all under `docs/` plus `.github/workflows/docs.yml` | Rebase onto `main` and merge. It touches no file that exists on `main`. |

Why `17a2b11c` is superseded: it was written against `b368da47`, when
Voltaire was a URL dependency. `main` then went a different way in six
commits: a sibling `../voltaire` checkout pinned by
`native-dependencies.json`, a rewritten `ci.yml`, a WASI reactor build, and
`wasm.yml`. A diff of `main` against `17a2b11c` deletes `CHANGELOG.md`,
`NATIVE_RELEASE.md`, `native-dependencies.json`, `wasm.yml`,
`test/wasm.test.mjs`, and `examples/wasm.mjs`. Rebasing would fight every one
of those.

Salvage from `17a2b11c` into the release work in section 4:

1. `.github/workflows/release.yml`: copy, then change Zig to 0.15.2, check out
   Voltaire the way `ci.yml` does, and add the WASM steps.
2. `package.json`: the `files` allowlist, `publishConfig`, `engines`, and the
   `@tevm/guillotine-mini` name. Change `homepage` from
   `https://guillotine-mini.tevm.sh` to `https://mini.tevm.sh`. The docs
   config and Vercel deploy use `mini.tevm.sh`.
3. `rust-toolchain.toml`: copy if `ci.yml` on `main` does not already pin Rust.

Steps:

1. `jj rebase -r 34ddfe09 -d main`. Expect no conflicts.
2. Rebase #40 on top (see below).
3. Fix the `lint` check. It fails on both PRs. Read the failing job log first;
   the likely cause is the commit-lint rule on the emoji-prefixed subject.
4. Retarget PR #39 to the rebased docs commit, or open a new docs-only PR and
   close #39. Prefer the new PR: the title "prepare guillotine-mini 0.1.0" no
   longer describes the content.

Comment:

> Splitting this PR. Commit `34ddfe09` (the vocs docs site, 27 new files under
> `docs/` plus `docs.yml`) has no overlap with `main` and moves to a
> docs-only PR together with #40. Commit `17a2b11c` (release prep) is
> superseded: it was written when Voltaire was a URL dependency, and `main`
> has since moved to the pinned sibling checkout in
> `native-dependencies.json`, a rewritten CI, and the WASI reactor build. The
> pieces of it that still apply (`release.yml`, the npm `files` allowlist and
> `publishConfig`, `rust-toolchain.toml`) are tracked in
> `docs/pr-triage-and-release-plan.md` and will land with the v0.1.0 release
> change. Closing this PR once the docs-only PR is open.

### #40 "tevm.sh theme, hero, logo assets and an opcode stepper": rebase onto main

The PR is one commit, `5e9de6f2`, stacked on the #39 docs commit. It changes
nine files, all under `docs/`:

```
M docs/.gitignore                        A docs/public/favicon.svg
M docs/vocs.config.ts                    A docs/public/logo-light.svg
M docs/src/pages/index.mdx               A docs/public/logo-dark.svg
A docs/src/pages/_root.css               A docs/src/components/OpcodeStepper.tsx
A docs/src/pages/opcode-explorer.mdx
```

Steps:

1. After `34ddfe09` sits on `main`: `jj rebase -r 5e9de6f2 -d <rebased 34ddfe09>`.
2. The three SVGs already exist on `main` from this change (section 3) with
   identical bytes, so the rebase resolves them as no-ops.
3. Fix one palette mismatch before merge. `docs/vocs.config.ts` sets
   `accentColor: 'light-dark(#0588f0, #3b9eff)'`, while `_root.css` and the
   logos use `#0085ff` / `#4da6ff`. Set `accentColor` to
   `'light-dark(#0085ff, #4da6ff)'`.
4. Change the PR base to `main`, wait for the docs build, merge.
5. Verify in production: `curl -sI https://mini.tevm.sh/logo-light.svg`,
   `/logo-dark.svg`, and `/favicon.svg` each return 200. They return 404 today.

Comment:

> Rebasing this onto `main` on top of the docs-site commit split out of #39,
> and changing the base branch to `main`. The three brand SVGs landed on
> `main` ahead of this PR, byte-identical, so they drop out of the diff. One
> change requested before merge: `vocs.config.ts` uses
> `light-dark(#0588f0, #3b9eff)` for `accentColor`, but `_root.css` and the
> logos use `#0085ff` / `#4da6ff`. Use the latter in both places.

## 3. Brand assets

`docs/public/logo-light.svg`, `docs/public/logo-dark.svg`, and
`docs/public/favicon.svg` are restored byte-for-byte from PR #40 commit
`5e9de6f2`. No redesign was needed.

| File | Canvas | Mark fill | Blade and frame | Wordmark |
|---|---|---|---|---|
| `logo-light.svg` | 240 x 40 | `#0085ff` | `#ffffff` | `guillotine` `#101828`, mono `mini` `#0085ff` |
| `logo-dark.svg` | 240 x 40 | `#4da6ff` | `#0b0e14` | `guillotine` `#e6e9ee`, mono `mini` `#4da6ff` |
| `favicon.svg` | 32 x 32 | `#0085ff` | `#ffffff` | none |

The mark is a rounded square holding two uprights, an angled blade, and a
crossbar. The wordmark uses system font stacks in `<text>` elements, so glyph
shapes vary by platform. Convert the text to paths only if a pixel-exact
wordmark is needed outside the docs site.

## 4. Issues

### #15 "WASM build uses wasi instead of freestanding due to C library dependencies": close as not planned

`edafd394` makes WASI Preview 1 reactor the supported WASM target, with the
Rust cryptography linked in. The crypto libraries need libc, and a
freestanding build would drop BN254 and KZG precompiles.

> Closing as not planned. As of `edafd394` the supported WASM artifact is a
> WASI Preview 1 reactor (`zig build wasm`) with the Rust cryptography linked
> in, and `zig build test-wasm` executes it in CI. The crypto dependencies
> need libc, so a `wasm32-freestanding` build would have to drop the BN254 and
> KZG precompiles. The WASI imports the reactor needs are small enough to
> shim in a browser. Bundle size is tracked in #23. If you have an embedder
> that cannot provide WASI imports, open a new issue that names the runtime.

### #23 "Guillotine-mini should guarantee a small bundle size": keep open, re-scope

The issue has three asks. Only the CI budget is concrete and cheap.

Actions:

1. Record the current `zig-out/bin/guillotine_mini.wasm` size from the
   `wasm.yml` artifact.
2. Add a step to `wasm.yml` that fails when the size exceeds the recorded
   value plus 5%.
3. Treat separate per-precompile builds as a follow-up, not a 0.1.0 gate.

> Re-scoping. The WASM artifact now links the Rust cryptography
> (`edafd394`), so the old size expectation no longer applies. Plan: (1)
> record the size of `guillotine_mini.wasm` from the current `wasm.yml`
> artifact as the baseline, (2) add a CI step that fails when the artifact
> grows more than 5% over the baseline, (3) evaluate a build option that
> omits precompile crypto as a separate follow-up issue. Item 2 closes this
> issue. Item 3 is not a 0.1.0 gate.

### #24 "Guillotine should have simple functional docs": close when the docs PRs merge

The docs site in `34ddfe09` uses vocs, not Starlight, and `docs.yml` builds
and deploys it to `mini.tevm.sh`. The LLM freshness cron job is dropped.

> The docs site lands with the docs-only PR split from #39, plus #40: a vocs
> site under `docs/` with getting-started, nine guides, and seven reference
> pages, built on every PR and deployed to https://mini.tevm.sh by
> `.github/workflows/docs.yml`. It uses vocs instead of Starlight to match
> the other tevm.sh sites. The scheduled LLM freshness check is not planned;
> `checkDeadlinks` and the docs build in CI cover the mechanical part. This
> issue closes when those PRs merge.

### #25 "Guillotine should have a useful examples/ folder": keep open, re-scope

`examples/` on `main` holds `wasm.mjs`, `bytecode-validation.ts`, and five
TypeScript examples. It has no Zig examples and no `examples/main.zig`. Lane
S4 of the current maintenance pass owns `examples/*.zig`.

> Partly done. `examples/` has a runnable WASM example (`wasm.mjs`) and five
> TypeScript examples (basic usage, tracing, async execution, custom
> precompiles, advanced patterns). Still missing: Zig examples. Narrowing
> this issue to four Zig files wired into `zig build`: `simple-call`,
> `call-types`, `tracing`, and `custom-host`. The access-list, direct-frame,
> and benchmark examples in the original list are dropped until someone asks
> for them.

### #27 "Guillotine-mini should share its public interface with guillotine-performance": close as not planned

No consumer depends on a shared interface. ZEVM, the one native consumer,
embeds guillotine-mini directly.

> Closing as not planned for 0.1.0. The one native consumer today, ZEVM,
> embeds guillotine-mini directly through `src/root.zig`, and nothing
> consumes both engines behind one interface. The 0.1.0 public surface is
> what `src/root.zig` exports: `Evm`, `Frame`, `HostInterface`, `EvmConfig`,
> `Tracer`, `Dispatcher`, `CallParams`, and `CallResult`. Reopen with the
> consumer that needs to swap engines, and we will design the shared surface
> against that code.

### #28 "export low level opcode handlers that can be reused by guillotine-performance": close as not planned

The first half is done: handlers live in `src/instructions/handlers_*.zig`,
are generic over the frame type, and `root.zig` exports `Dispatcher`. The
second half (rewrite handlers for peak performance, comptime-checked frame
interface, comptime gas toggle) contradicts the project goal of a minimal,
readable reference EVM.

> Closing. The structural half is done: opcode handlers live in
> `src/instructions/handlers_*.zig`, are generic over the frame type, and
> `root.zig` exports `Dispatcher`. The remaining requests (rewrite handlers
> for peak performance, a `checkFrameInterface` comptime contract, a comptime
> switch to disable gas accounting) trade readability for speed, and
> guillotine-mini is the readable reference implementation. Reopen if
> guillotine-performance starts importing these handlers and hits a specific
> missing frame method.

### #33 "bug: zig build": close as fixed

The reported failure is `wasm-ld: undefined symbol: main` from the default
install step. The default `zig build` no longer builds WASM, and `edafd394`
builds the WASM artifact as a WASI reactor, which needs no `main`.

> Fixed. The error was `wasm-ld: undefined symbol: main` from the WASM
> artifact in the default install step. The default `zig build` no longer
> builds WASM, and since `edafd394` `zig build wasm` produces a WASI reactor
> (`wasi_exec_model = .reactor`), which needs no `main`. CI builds and
> executes the artifact in `wasm.yml`. Note that building now needs a sibling
> `../voltaire` checkout at the revision in `native-dependencies.json`; the
> README covers setup. Reopen with the full log if a clean clone on Zig
> 0.15.2 still fails.

### #34 "bug: zig build test": close after one clean-clone check

The report is from 2025-11-07: 61 failed tests, 19 leaks, and one compile
error. CI on `main` runs the unit suite, but the reporter's setup was a plain
clone on macOS. Before closing, run the check in section 5, step 2. If it
passes, post:

> Fixed on `main`. The 61 failures and 19 leaks in this report date from
> 2025-11-07, before the Voltaire migration and the fixture repairs in
> `d431ff6a`. `zig build test` now passes in CI on Linux and macOS, and a
> clean clone at `<commit>` passes locally: `<paste Build Summary line>`. The
> build needs Zig 0.15.2 and a sibling `../voltaire` checkout at the revision
> in `native-dependencies.json`. Reopen with the full output if it still
> fails for you.

If it fails, keep the issue open and paste the failing summary instead.

### #37 "WASM build fails due to missing main symbol when linking C libraries": close as fixed

`edafd394` implements option 4 from the issue.

> Fixed in `edafd394` using option 4 from this issue: the artifact is a WASI
> reactor (`entry = .disabled`, `wasi_exec_model = .reactor`), so the linker
> no longer requires `main`. `zig build wasm` builds it with the Rust
> cryptography linked in, `zig build test-wasm` executes it under Node 22+,
> and `.github/workflows/wasm.yml` runs both on every push.

## 5. v0.1.0 release checklist

Three things block the release: external consumers cannot fetch the package,
the npm publish path does not exist on `main`, and downstream repositories
pin by sibling path.

### Step 1: make `zig fetch --save` work for external consumers

Problem: `build.zig.zon` on `main` declares

```zig
.voltaire = .{ .path = "../voltaire" },
.guillotine_primitives = .{ .path = "../voltaire" },
```

A consumer who runs `zig fetch --save` gets guillotine-mini unpacked into the
Zig package cache. `../voltaire` then points at a directory that does not
exist, and the build fails. The path dependency works only for a sibling
checkout.

Fix: pin Voltaire by URL and hash at the revision already recorded in
`native-dependencies.json`.

```zig
.dependencies = .{
    .voltaire = .{
        .url = "https://github.com/evmts/voltaire/archive/8b5136835ce40c887ad579ec07137c82199a7eeb.tar.gz",
        .hash = "primitives-0.1.0-9n3Nfc_Q9wAVZLnmBkCPuo6ZuvKRjV7icpUl206GkGwL",
    },
},
```

The hash above is the output of `zig fetch` on that URL with Zig 0.15.2, run
on 2026-11-22. `b368da47` used this same form at an older revision, so the
mechanism is proven for this repository.

- [ ] Replace both path entries with the single URL entry above. Lane S2
      removes the unused `guillotine_primitives` entry and `"lib"` from
      `.paths`.
- [ ] Set `.version = "0.1.0"`. `main` still says `0.0.0`.
- [ ] Trim `.paths` to files that exist. `interactive_test_runner.zig` is
      listed and absent from the repository root.
- [ ] Prove the tarball builds. Voltaire has git submodules
      (`vendor/execution-apis`, `packages/voltaire-zig/lib/libwally-core`,
      `skills`), and GitHub archive tarballs omit submodule contents. In an
      empty directory outside any checkout, run `zig init`, then
      `zig fetch --save` on the guillotine-mini tarball for the candidate
      commit, import the module, and run `zig build`. This is the release
      gate. If it fails on a missing submodule path, fix it in Voltaire and
      bump the pin; do not vendor around it here.
- [ ] Add that consumer smoke test as a CI job so the path cannot regress.
- [ ] Keep `native-dependencies.json` and the `build.zig.zon` URL on the same
      revision. Add a CI step that compares the two and fails on mismatch.
- [ ] Update `ci.yml` and `wasm.yml`: they check out Voltaire as a sibling
      directory. With a URL dependency, the sibling checkout is needed only
      for the Rust archive build step, if at all. Remove what becomes dead.
- [ ] Document local development against an unreleased Voltaire: edit the
      entry to `.path = "../voltaire"` locally and do not commit it.

### Step 2: verify the candidate commit

Run on a clean clone with Zig 0.15.2, Rust per `rust-toolchain.toml`, Node 22+:

- [ ] `zig build` exits 0.
- [ ] `zig build test --summary all` exits 0 with no leaks. Paste the
      `Build Summary` line into issue #34.
- [ ] `zig build wasm` and `zig build test-wasm` exit 0.
- [ ] `zig build specs` passes for Berlin through Prague. Record the counts
      in `CHANGELOG.md`.
- [ ] `zig fmt --check src test` exits 0.
- [ ] The WASM size check from issue #23 is in `wasm.yml` and passes.

### Step 3: npm release with provenance

`main` has no `release.yml`, and `package.json` is named `guillotine-mini`
with no `files` allowlist. Port both from `17a2b11c`.

- [ ] `package.json`: name `@tevm/guillotine-mini`, version `0.1.0`,
      `publishConfig: { "access": "public", "provenance": true }`,
      `homepage: "https://mini.tevm.sh"`, and a `files` allowlist:
      `build.zig`, `build.zig.zon`, `src/**/*.zig`, `LICENSE`, `README.md`,
      `CHANGELOG.md`, plus `zig-out/bin/guillotine_mini.wasm` if the WASM
      artifact ships in the package. Decide that before the first publish: a
      later change to the file list is a breaking change for importers.
- [ ] Confirm the `@tevm` npm scope grants publish rights to the token owner.
- [ ] Create an npm granular access token limited to
      `@tevm/guillotine-mini`, read and write, and store it as the repository
      secret `NPM_TOKEN`. For the very first publish the package does not
      exist yet, so the token needs scope-level write; narrow it to the
      package after 0.1.0 is out.
- [ ] Add `.github/workflows/release.yml`, triggered by
      `release: published`, with `permissions: { contents: read, id-token: write }`.
      `id-token: write` is what lets npm attach the provenance attestation.
      Steps: check out, install Zig 0.15.2, Rust, and Node; assert that the
      tag without `v` equals `package.json` version and the `.version` in
      `build.zig.zon`; `zig build`; `zig build test`; `zig build wasm`;
      `npm pack --dry-run`; `npm publish --provenance --access public` with
      `NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}`.
- [ ] Run the publish job on a GitHub-hosted runner. npm rejects provenance
      from self-hosted runners.
- [ ] Dry run: trigger the workflow from a prerelease `v0.1.0-rc.1`
      published with `npm publish --tag rc`. Check that the package page
      shows the provenance badge and that `npm pack` output contains no
      `.md` sidecar files from `src/`.

### Step 4: cut the release

- [ ] Land in this order on `main`: lanes S1-S4, O1-O3, F1, P1 from the
      current maintenance pass; the docs-only PR and #40; the release change
      from steps 1 and 3.
- [ ] Move the `Unreleased` section of `CHANGELOG.md` under
      `## 0.1.0 - <date>`.
- [ ] Tag `v0.1.0` on `main` and publish a GitHub Release. Attach
      `guillotine_mini.wasm` and its SHA-256.
- [ ] Put the consumer install line in the release notes and README:
      `zig fetch --save https://github.com/evmts/guillotine-mini/archive/refs/tags/v0.1.0.tar.gz`
- [ ] Confirm the `release.yml` run is green and
      `npm view @tevm/guillotine-mini@0.1.0 dist.attestations` returns a
      provenance entry.
- [ ] Post the issue and PR comments from sections 2 and 4.

### Step 5: update downstream pins

`evmts/zevm`:

`build.zig.zon` on `main` declares both dependencies by sibling path:

```zig
.voltaire = .{ .path = "../voltaire" },
.@"guillotine-mini" = .{ .path = "../guillotine-mini", .lazy = true },
```

- [ ] Run `zig fetch --save=guillotine-mini` on the `v0.1.0` tarball URL in
      zevm. Keep `.lazy = true`.
- [ ] Pin zevm's `voltaire` to the same revision guillotine-mini uses
      (`8b513683`). Two different Voltaire revisions in one build produce
      two copies of the `primitives` types, and they do not unify.
- [ ] Update `tools/checkout-native.sh` and `tools/dependency_preflight.zig`,
      which reference the sibling layout, and the install pages under
      `docs/quickstart/`.
- [ ] Run zevm's full test suite against the pinned release before merging.

`evmts/tevm` (`tevm-monorepo`):

- [ ] Search the monorepo for `guillotine-mini` and `guillotine_mini`. A
      GitHub code search on 2026-11-22 did not establish where tevm pins it,
      so locate the pin before the release, not after.
- [ ] If tevm consumes the WASM artifact, replace the pinned file or commit
      with `@tevm/guillotine-mini@0.1.0` and load
      `guillotine_mini.wasm` from the package. The artifact is a WASI
      reactor since `edafd394`, so the loader must supply WASI Preview 1
      imports and call `_initialize` before any `evm_*` export.
- [ ] If tevm consumes guillotine-mini only through zevm, bump the zevm pin
      after the zevm change above merges, and do nothing else.
- [ ] Add a changeset in tevm that names the guillotine-mini version.

### Release is done when

1. A fresh directory with only Zig 0.15.2 installed can `zig fetch --save`
   the `v0.1.0` tarball and build against it.
2. `npm view @tevm/guillotine-mini@0.1.0` shows a provenance attestation.
3. zevm `main` builds from URL pins with no sibling checkouts.
4. The open PR count is zero, and the open issues are #23 and #25 only.
