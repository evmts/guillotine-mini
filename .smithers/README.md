# guillotine-mini factory

Smithers workspace, incremental CI and agent flows for `evmts/guillotine-mini`.

- `WORKSPACE.ts`: workspace, host bins, local cache in `.smithers/cache`, remote cache at `https://build.smithers.sh` (used when `SMITHERS_CACHE_READ_TOKEN` and `SMITHERS_CACHE_WRITE_TOKEN` are set).
- `PACKAGE.ts`: `fmt-check`, `build` (native static library and WASI reactor), `factory-write`, `factory-check`. Source packages own their tests in `//PACKAGE.ts`, `//client/*`, `//client-ts/*` and `//src/utils`.
- `FACTORY.ts`: featured flows, GitHub policy and app home. Projected into `factory.json` and `home.json`.
- `flows/`: `checks/review`, `spec-fix`, `issue/repro`, `issue/poc`, `pr-triage`.
- `run-zig.sh`: serializes `zig` across targets. Voltaire's blst step runs `./build.sh` in its shared source tree on every build, so parallel builds corrupt each other.

## Prerequisites

- `../voltaire` checked out at the revision in `native-dependencies.json`, with `cargo build --release --lib` run.
- Git submodules initialized (`ethereum-tests`, `execution-specs`); Zig tests read fixtures from them.
- `bun install --frozen-lockfile` in `client-ts/`.

## Commands

```sh
smthrs ci '//...'                                   # everything except exclusive benchmarks
smthrs affected test '//...' --include-exclusive    # only what your diff touches, benchmarks included
smthrs test //:bench_opcodes                        # one benchmark, run alone
smthrs target //.smithers:factory-write --write     # regenerate factory.json and home.json
```
