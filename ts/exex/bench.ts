import { TsBenchSuite } from "../../scripts/bench-ts-utils.ts";
import { ExExManager, type ExExContextFactory } from "./manager.ts";
import type {
  BlockId,
  BlockReader,
  ChainEventSource,
  ExExNotification,
  Hash,
  StateReader,
} from "./types.ts";

function makeBlockId(n: number): BlockId {
  return {
    number: BigInt(n),
    hash: `0x${n.toString(16).padStart(64, "0")}` as Hash,
  };
}

function makeCommitted(id: BlockId): ExExNotification<BlockId, never> {
  return {
    type: "committed",
    chain: {
      blocks: [id],
      receipts: new Map(),
      stateChanges: {
        accountChanges: [],
        storageChanges: [],
        createdContracts: [],
        destroyedContracts: [],
      },
      tip: () => id,
    },
  };
}

function makeSource(count: number): ChainEventSource<BlockId, never> {
  const blocks: BlockId[] = [];
  for (let i = 1; i <= count; i += 1) {
    blocks.push(makeBlockId(i));
  }
  const head = blocks[blocks.length - 1] ?? makeBlockId(0);
  return {
    async subscribeFrom(_cursor: BlockId | undefined, signal: AbortSignal) {
      return {
        head,
        notifications: (async function* () {
          for (const id of blocks) {
            if (signal.aborted) return;
            yield makeCommitted(id);
          }
        })(),
      };
    },
  };
}

const contextFactory: ExExContextFactory<BlockId, never> = async () => ({
  head: makeBlockId(0),
  chainId: 1n,
  state: {} as StateReader,
  blocks: {} as BlockReader,
});

const suite = new TsBenchSuite("ts/exex");

suite.section("ExExManager Notification Fan-Out");
const BLOCKS = 2_000;
await suite.benchAsync(
  `ExExManager single subscriber (${BLOCKS} notifications)`,
  BLOCKS,
  async () => {
    const manager = new ExExManager(makeSource(BLOCKS), contextFactory);
    let seen = 0;
    await manager.run({
      id: "bench-1",
      exex: async function* (ctx) {
        for await (const n of ctx.notifications) {
          seen += 1;
          if (n.type === "committed") yield n.chain.tip();
        }
        return undefined as never;
      },
    });
    if (seen !== BLOCKS) throw new Error(`expected ${BLOCKS}, got ${seen}`);
  },
);

await suite.benchAsync(
  `ExExManager 4 concurrent subscribers (${BLOCKS} each)`,
  BLOCKS * 4,
  async () => {
    const manager = new ExExManager(makeSource(BLOCKS), contextFactory);
    let total = 0;
    await manager.runAll(
      [1, 2, 3, 4].map((idx) => ({
        id: `bench-${idx}`,
        exex: async function* (ctx) {
          for await (const n of ctx.notifications) {
            total += 1;
            if (n.type === "committed") yield n.chain.tip();
          }
          return undefined as never;
        },
      })),
    );
    if (total !== BLOCKS * 4) throw new Error(`expected ${BLOCKS * 4}, got ${total}`);
  },
);

suite.finish();
