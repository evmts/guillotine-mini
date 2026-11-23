<div align="center">
  <h1>
    Minimal EVM in Zig.
    <br/>
    <br/>
  </h1>
  <sup>
    <a href="https://github.com/evmts/guillotine-mini">
       <img src="https://img.shields.io/badge/zig-0.15.2-orange.svg" alt="zig version" />
    </a>
  </sup>
</div>

> We are actively building a full Ethereum execution client (Guillotine) on top of this EVM. Guillotine-mini remains the core execution engine.

## Requirements

- Zig 0.15.2, the version used in CI
- Rust and Cargo for Voltaire's crypto libraries
- Python 3 and uv to generate execution-spec fixtures

## Build from source

Guillotine-mini uses a sibling `../voltaire` checkout. Check out the revision in
[native-dependencies.json](native-dependencies.json). These commands use `jq`
to read the pin.

```bash
git clone https://github.com/evmts/guillotine-mini.git
git clone https://github.com/evmts/voltaire.git
git -C voltaire checkout "$(jq -r '.voltaire.revision' guillotine-mini/native-dependencies.json)"
git -C voltaire submodule update --init --recursive
cd guillotine-mini
zig build
zig build native
```

To use the Zig module in another project, add the Guillotine-mini checkout to
that project's `build.zig.zon` as a local path dependency named
`guillotine_mini`. Import its `guillotine_mini` module in `build.zig`.

```zig
const guillotine_dep = b.dependency("guillotine_mini", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("guillotine_mini", guillotine_dep.module("guillotine_mini"));
```

## Tests

Initialize the ethereum-tests submodule for the trie fixtures used by the unit suite.

```bash
git submodule update --init --recursive ethereum-tests
zig build unit
```

Initialize the execution-specs submodule to generate and run the state and
blockchain fixtures.

```bash
git submodule update --init --recursive execution-specs
zig build specs
zig build specs-blockchain
TEST_FILTER="push0" zig build specs
```

Run `zig build test -Dnethermind-diff=false` for the combined native suite.
The Nethermind trie comparison requires a separate `nethermind/` checkout and
the .NET 8 SDK.

The spec runner has hardfork targets from Frontier through Osaka. Osaka
implementation and fixture coverage are partial.

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

## Highlights

- 20+ EIPs implemented
- EIP-3155 tracing
- WASM target with linked crypto precompiles (WASI Preview 1)

## More

- [Voltaire primitives and crypto](https://github.com/evmts/voltaire)
- Guillotine (full client): https://github.com/evmts/guillotine

## License

See `LICENSE`.
