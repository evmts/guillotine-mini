import { TsBenchSuite } from "../../scripts/bench-ts-utils.ts";
import { ExExManager } from "./manager.ts";
import type { BlockId, ChainEventSource, ExExNotification } from "./types.ts";

function makeSource(count: number): ChainEventSource<number, number> {
  const blocks: Array<{ number: number; hash: string }> = [];
  for (let i = 1; i <= count; i += 1) {
    blocks.push({ number: i, hash: `0x${i.toString(16).padStart(64, "0")}` });
  }
  return {
    async *subscribe(signal?: AbortSignal): AsyncIterable<ExExNotification<number, number>> {
      for (const b of blocks) {
        if (signal?.aborted) return;
        yield {
          type: "ChainCommitted",
          new: {
            blocks: [b.number],
            receipts: [[b.number]],
            tip: { number: b.number, hash: b.hash },
          },
        } as unknown as ExExNotification<number, number>;
      }
    },
    async getChain(from: BlockId, to: BlockId) {
      const slice = blocks.filter((b) => b.number > Number(from.number) && b.number <= Number(to.number));
      return {
        blocks: slice.map((b) => b.number),
        receipts: slice.map((b) => [b.number]),
        tip: to,
      } as unknown as any;
    },
  };
}

const suite = new TsBenchSuite("ts/exex");

suite.section("ExExManager Notification Fan-Out");
const BLOCKS = 2_000;
await suite.benchAsync(`ExExManager single subscriber (${BLOCKS} notifications)`, BLOCKS, async () => {
  const manager = new ExExManager(makeSource(BLOCKS), async () => ({
    head: { number: 0n, hash: "0x00" },
  }) as any);
  let seen = 0;
  await manager.run({
    id: "bench-1",
    exex: async function* (ctx) {
      for await (const n of ctx.notifications) {
        seen += 1;
        yield (n as any).new.tip;
      }
      return undefined as never;
    },
  });
  if (seen !== BLOCKS) throw new Error(`expected ${BLOCKS}, got ${seen}`);
});

await suite.benchAsync(`ExExManager 4 concurrent subscribers (${BLOCKS} each)`, BLOCKS * 4, async () => {
  const manager = new ExExManager(makeSource(BLOCKS), async () => ({
    head: { number: 0n, hash: "0x00" },
  }) as any);
  let total = 0;
  await manager.runAll([1, 2, 3, 4].map((idx) => ({
    id: `bench-${idx}`,
    exex: async function* (ctx) {
      for await (const n of ctx.notifications) {
        total += 1;
        yield (n as any).new.tip;
      }
      return undefined as never;
    },
  })));
  if (total !== BLOCKS * 4) throw new Error(`expected ${BLOCKS * 4}, got ${total}`);
});

suite.finish();
