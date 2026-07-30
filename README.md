# Guillotine Mini

A small, embeddable Ethereum Virtual Machine written in Zig. Guillotine Mini
provides a configurable EVM library with hardfork support, precompiles,
transaction-scoped state, and EIP-3155 tracing.

The project is pre-1.0. Public APIs may change between minor releases.

## Requirements

- Zig 0.15.1
- Rust/Cargo 1.89.0 (builds the cryptographic FFI dependency)
- Node.js 24.4.1 and npm 11.4.2 only for the npm release workflow
- macOS or Linux

Python, uv, Bun, and the reference-repository submodules are optional and are
only needed for spec generation, TypeScript tooling, and differential tests.

## Install

For Zig projects, fetch the tagged source archive:

```sh
zig fetch --save https://github.com/evmts/guillotine-mini/archive/refs/tags/v0.1.0.tar.gz
```

The same Zig source is published to npm for projects that manage source
dependencies there:

```sh
npm install @tevm/guillotine-mini
```

Point a Zig dependency at the installed package when using npm:

```zig
.dependencies = .{
    .guillotine_mini = .{
        .path = "node_modules/@tevm/guillotine-mini",
    },
},
```

Add the module to an executable in `build.zig`:

```zig
const guillotine = b.dependency("guillotine_mini", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport(
    "guillotine_mini",
    guillotine.module("guillotine_mini"),
);
```

## Usage

The following initializes the Cancun EVM, installs a `STOP` program at an
address, and executes it:

```zig
const std = @import("std");
const guillotine = @import("guillotine_mini");

pub fn main() !void {
    const Evm = guillotine.Evm(guillotine.EvmConfig{});
    var instance: Evm = undefined;
    try instance.init(
        std.heap.page_allocator,
        null,
        .CANCUN,
        null,
        guillotine.ZERO_ADDRESS,
        0,
        null,
    );
    defer instance.deinit();

    const target = try guillotine.Address.fromHex(
        "0x0000000000000000000000000000000000000010",
    );
    try instance.code.put(target, &.{0x00});

    const result = instance.call(.{ .call = .{
        .caller = guillotine.ZERO_ADDRESS,
        .to = target,
        .value = 0,
        .input = &.{},
        .gas = 100_000,
    } });
    if (!result.success) return error.ExecutionFailed;
}
```

## Develop

Start from a normal clone; reference submodules are not required for the
default build or test suite:

```sh
git clone https://github.com/evmts/guillotine-mini
cd guillotine-mini
zig build
zig build test --summary all
```

Tests backed by the optional `ethereum-tests` checkout skip when its fixtures
are absent. To run them, initialize that submodule first:

```sh
git submodule update --init ethereum-tests
zig build test --summary all
```

Execution-spec tests use a separate toolchain and command:

```sh
git submodule update --init execution-specs
zig build specs
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the extended development workflow.

## Documentation

Project documentation lives in [`docs/`](docs/). The public documentation
home is <https://guillotine-mini.tevm.sh>.

## License

[MIT](LICENSE)
