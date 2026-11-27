import { Smithers as S } from "@smthrs/targets";

const srcs = S.Filegroup({
  srcs: [...S.glob(["*.ts"])],
});

const test = S.Shell.Test({
  bin: S.Host.bin("bun"),
  args: ["test", "./ts/"],
  data: [srcs],
  sandbox: "none",
});

export const Package = S.Package({
  targets: { srcs, test },
});
