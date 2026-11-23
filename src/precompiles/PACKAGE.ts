import { Smithers as S } from "@smthrs/targets"

const srcs = S.Filegroup({
  srcs: [...S.glob(["*.zig", "*.md"])],
})

export const Package = S.Package({
  targets: { srcs },
})
