import { Smithers as S } from "@smthrs/targets"

/** Shared `client-ts` config and Voltaire peer repair scripts. */
const config_srcs = S.Filegroup({
  srcs: [
    S.file("package.json"),
    S.file("tsconfig.json"),
    ...S.glob(["scripts/**", "packages/**", "*.ts", "*.json", "*.md"]),
  ],
})

export const Package = S.Package({
  targets: { config_srcs },
})
