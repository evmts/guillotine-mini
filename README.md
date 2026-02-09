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
```

```bash
TEST_FILTER="push0" zig build specs
```

## Docs

- `CLAUDE.md` — project guide for devs and AI assistants
- `CONTRIBUTING.md` — setup and contribution workflow
- `src/precompiles/CLAUDE.md` — precompile docs

## Highlights

- Full hardfork support (Frontier → Osaka)
- 20+ EIPs implemented
- EIP-3155 tracing
- WASM target (~193 KB optimized)
- 100% ethereum/tests coverage

## More

- Primitives library: https://github.com/evmts/primitives
- Guillotine (full client): https://github.com/evmts/guillotine

## License

See `LICENSE`.
