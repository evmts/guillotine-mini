import * as Cause from "effect/Cause";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Schema from "effect/Schema";
import { Block, BlockHash } from "voltaire-effect/primitives";
import { BlockStoreMemoryLive, putBlock, setCanonicalHead } from "./BlockStore";
import { makeBlock } from "./testUtils";

type BlockType = Block.BlockType;
type BlockHashType = BlockHash.BlockHashType;

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

const BlockHashBytesSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;

const blockHashFromNumber = (value: number): BlockHashType => {
  const bytes = new Uint8Array(32);
  let remaining = value;
  for (let i = bytes.length - 1; i >= 0 && remaining > 0; i -= 1) {
    bytes[i] = remaining & 0xff;
    remaining = Math.floor(remaining / 256);
  }
  return Schema.decodeSync(BlockHashBytesSchema)(bytes);
};

const makeBlocks = (count: number): ReadonlyArray<BlockType> => {
  const blocks: BlockType[] = [];
  let parent = blockHashFromNumber(0);
  for (let i = 0; i < count; i += 1) {
    const hash = blockHashFromNumber(i + 1);
    blocks.push(
      makeBlock({
        number: BigInt(i),
        hash,
        parentHash: parent,
      }),
    );
    parent = hash;
  }
  return blocks;
};

const benchProcessBlocks = (blocks: ReadonlyArray<BlockType>) =>
  Effect.gen(function* () {
    for (const block of blocks) {
      yield* putBlock(block);
      yield* setCanonicalHead(block.hash);
    }
  });

const measure = <R, E>(
  label: string,
  count: number,
  effect: Effect.Effect<void, E, R>,
): Effect.Effect<BenchResult, E, R> =>
  Effect.gen(function* () {
    const start = Date.now();
    yield* effect;
    const ms = Date.now() - start;
    const safeMs = ms === 0 ? 1 : ms;
    return {
      label,
      count,
      ms,
      opsPerSec: (count / safeMs) * 1000,
      msPerOp: safeMs / count,
    } satisfies BenchResult;
  });

const runBenchmarks = (count: number) =>
  Effect.gen(function* () {
    const blocks = makeBlocks(count);
    const results: BenchResult[] = [];

    results.push(
      yield* measure("process+head", count, benchProcessBlocks(blocks)),
    );
    return results;
  });

const formatResults = (results: ReadonlyArray<BenchResult>) =>
  results.map((result) => ({
    label: result.label,
    count: result.count,
    ms: result.ms,
    msPerOp: Number(result.msPerOp.toFixed(6)),
    opsPerSec: Math.round(result.opsPerSec),
  }));

const parseCount = (value: string | undefined, fallback: number) => {
  if (value === undefined) {
    return fallback;
  }
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return fallback;
  }
  return Math.floor(parsed);
};

const main = Effect.gen(function* () {
  const count = parseCount(process.env.BLOCK_BENCH_COUNT, 2_000);
  const results = yield* runBenchmarks(count);

  yield* Effect.sync(() => {
    console.log("Block processing benchmark (put + set head)");
    console.log(`Blocks: ${count}`);
    console.table(formatResults(results));
  });
});

pipe(
  main,
  Effect.provide(BlockStoreMemoryLive),
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
