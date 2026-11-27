# Rules

Uphill writes these rules from each metric's `description`. Write code that meets them. `uphill` scores each metric against its target, and `uphill --compare HEAD --compact` lists what a change made worse.

## Safety & TigerStyle

Crash-free EVM execution, error propagation, and type-safety across Zig and TypeScript.

- Never use @panic or unreachable in production src/ or client/ Zig code; validate and return typed errors.
- Replace std.debug.print in production src/ and client/ Zig modules with logger.zig.
- Never swallow errors with empty catch {} or leave error.NotImplemented stubs in production Zig code.
- Add invariant assertions to production Zig functions to raise assertion density toward TigerStyle targets. At least 20.
- Replace explicit `any` annotations and `as any` casts in ts/ and client-ts/ with narrow types.
- Fix underlying TypeScript errors instead of using @ts-ignore, @ts-expect-error, or @ts-nocheck.

## Style & Limits

TigerStyle structural bounds (70-line functions, 120-char lines) and canonical Zig formatting.

- Keep all Zig files in src/ and client/ formatted with `zig fmt`.
- Keep every production Zig runtime function at or below 70 lines (TigerStyle limit). At most 70.
- Keep production Zig lines at or below 120 characters (TigerStyle limit).
- Resolve TODO, FIXME, XXX, and HACK markers in production Zig and TypeScript modules.

## Footprint & Minimalism

Minimal EVM source footprint, WASM surface compactness, and module size budgets.

- Keep production Zig files concise (<=400 lines) to preserve guillotine-mini's minimal architecture. At most 400.
- Keep core EVM modules under src/ and wasm/ compact to protect the <=2.5 MiB WASM binary budget. At most 16 kB.
- Keep TypeScript modules under ts/ and client-ts/ concise (<=300 lines per file). At most 300.

## Verification & Tests

Lean 4 formal oracle proofs, Zig inline unit tests, and TypeScript test coverage.

- Never leave `sorry` or unproved `axiom` declarations in spec/lean/**/*.lean.
- Expand Lean 4 reference specification proofs in spec/lean/ toward complete opcode/fork coverage. At least 120.
- Include inline `test` blocks inside production src/ and client/ Zig modules. At least 95.
- Pair every production TypeScript module in ts/ and client-ts/ with dedicated unit tests. At least 100.

## Documentation

Companion *.zig.md design docs and local markdown link integrity.

- Fix broken relative and root-relative links in root Markdown files and docs/**/*.md.
- Maintain companion `*.zig.md` design documentation alongside top-level production `src/*.zig` modules. At least 90.

## Factory & Trust

Smithers Cloud projections, cache-poisoning trust boundaries, Obsidian wiki links, and MCP agent readiness.

- Keep .smithers/factory.json and .smithers/home.json valid and projected from FACTORY.ts and HOME.ts.
- Enforce cache-write isolation, canonical main release gating, protected trust roots, and person-only merge policy.
- Maintain all core .smithers/wiki pages and Mythical History with zero broken Obsidian wikilinks.
- Keep .mcp.json, AGENTS.md, and one-time sandbox auth tooling wired to smithers.sh/evmts/guillotine-mini/mcp.
