<div align="center">
  <h1>
    Minimal, spec-compliant EVM in Zig.
    <br/>
    <br/>
  </h1>
  <sup>
    <a href="https://github.com/evmts/guillotine-mini">
       <img src="https://img.shields.io/badge/zig-0.15.1+-orange.svg" alt="zig version" />
    </a>
    <a href="https://github.com/evmts/guillotine-mini/actions">
      <img src="https://img.shields.io/badge/build-passing-brightgreen.svg" alt="build status" />
    </a>
    <a href="https://github.com/evmts/guillotine-mini">
      <img src="https://img.shields.io/badge/tests-all%20hardforks%20passing-brightgreen.svg" alt="tests" />
    </a>
  </sup>
</div>

> We are actively building a full Ethereum execution client (Guillotine) on top of this EVM. Guillotine-mini remains the core execution engine.

## Requirements

- Zig 0.15.1+
- Cargo (for Rust crypto deps)
- Python 3.8+ (optional, test generation)

## Install

**Use as a Zig dependency (recommended)**

```bash
zig fetch --save https://github.com/evmts/guillotine-mini/archive/main.tar.gz
```

```zig
const guillotine_dep = b.dependency("guillotine_mini", .{
    .target = target,
    .optimize = optimize,
});
const guillotine_mod = guillotine_dep.module("guillotine_mini");
exe.root_module.addImport("guillotine_mini", guillotine_mod);

const primitives_dep = b.dependency("guillotine_primitives", .{
    .target = target,
    .optimize = optimize,
});
exe.linkLibrary(primitives_dep.artifact("blst"));
exe.linkLibrary(primitives_dep.artifact("keccak-asm"));
exe.linkLibrary(primitives_dep.artifact("sha3-asm"));
exe.linkLibrary(primitives_dep.artifact("crypto_wrappers"));
```

**Build from source**

```bash
git clone https://github.com/evmts/guillotine-mini.git --recurse-submodules
cd guillotine-mini
zig build
```

> The primitives library is fetched automatically during build. Downstream consumers must link the crypto artifacts from `guillotine_primitives` (see snippet above).

## Quick Start

```bash
zig build
zig build test
zig build specs
zig build wasm
zig build test-wasm
```

```bash
TEST_FILTER="push0" zig build specs
```

## WebAssembly

The WASM build uses the adjacent `../voltaire` checkout and requires Zig 0.15.2,
Rust/Cargo, and Python 3. Install Rust's WASM standard library once:

```bash
rustup target add wasm32-unknown-unknown
zig build wasm
zig build test-wasm
node examples/wasm.mjs
```

`zig build wasm` builds the Rust crypto archive automatically and writes
`zig-out/bin/guillotine_mini.wasm`. The example returns a 32-byte word containing
42 and reports 18 gas used. The test and example require Node 22 or newer and
have no npm dependencies.

The artifact is a **WASI Preview 1 reactor**. Supply a WASI implementation and
call `_initialize` once before using the C API; Node's `WASI.initialize(instance)`
does this. Browser hosts need a WASI Preview 1 adapter. Crypto precompiles are
linked into the module, including BN254 and BLS12-381; no JavaScript crypto
callbacks are required. The two `env` imports, `js_opcode_callback` and
`js_precompile_callback`, select the built-in implementation when they return 0.

Use `evm_alloc(length)` and `evm_free(pointer, length)` for host transfer buffers.
Zero-length allocation returns 0; freeing a null pointer is a no-op. Input setters
copy buffers, so the host can release them after the call. Recreate typed-array
views after allocations or EVM calls because WebAssembly memory may grow.
Call `evm_destroy(handle)` when finished with an instance. See the complete
[Node example](examples/wasm.mjs) and [execution regression tests](test/wasm.test.mjs).

## Docs

- `CLAUDE.md` — project guide for devs and AI assistants
- `CONTRIBUTING.md` — setup and contribution workflow
- `src/precompiles/CLAUDE.md` — precompile docs

## Highlights

- Full hardfork support (Frontier → Osaka)
- 20+ EIPs implemented
- EIP-3155 tracing
- WASM target with linked crypto precompiles (WASI Preview 1)
- 100% ethereum/tests coverage

## More

- Primitives library: https://github.com/evmts/primitives
- Guillotine (full client): https://github.com/evmts/guillotine

## License

See `LICENSE`.
