import { Smithers as S } from "@smthrs/targets"

/** Shared Zig benchmark utility and CLI entrypoint files under `client/`. */
const bench_utils = S.Filegroup({
  srcs: [S.file("bench_utils.zig")],
})

const cli_srcs = S.Filegroup({
  srcs: [S.file("cli.zig"), S.file("cli_bench.zig"), S.file("main.zig"), S.file("root.zig")],
})

const docs_srcs = S.Filegroup({
  srcs: [...S.glob(["*.md"])],
})

export const Package = S.Package({
  targets: { bench_utils, cli_srcs, docs_srcs },
})
