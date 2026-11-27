import { expect, test } from "bun:test"
import manifest from "../factory.json"

test("the manual Uphill audit resolves to the checked-in flow", async () => {
  expect(manifest.apiVersion).toBe(1)
  const manual = manifest.contributes.triggers.filter((row) => row.on === "manual" && row.flow === "uphill")
  expect(manual).toHaveLength(1)
  const flow = manifest.flows.find((entry) => entry.id === manual[0]!.flow)
  expect(flow?.path).toBe(".smithers/flows/uphill/flow.ts")
  expect(await Bun.file(new URL("../../" + flow!.path, import.meta.url)).exists()).toBe(true)
})
