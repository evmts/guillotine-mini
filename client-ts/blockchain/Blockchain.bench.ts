import * as Cause from "effect/Cause";
import * as Effect from "effect/Effect";
import { pipe } from "effect/Function";
import * as Layer from "effect/Layer";
import * as Schema from "effect/Schema";
import { Block, BlockHash, BlockNumber } from "voltaire-effect/primitives";
import {
  Blockchain,
  BlockchainLive,
  getBlockByNumber,
  initializeGenesis,
  putBlock,
  setCanonicalHead,
} from "./Blockchain";
import { BlockStoreMemoryLive, type BlockStoreError } from "./BlockStore";
import { makeBlock } from "./testUtils";

type BlockType = Block.BlockType;
type BlockHashType = BlockHash.BlockHashType;
type BlockNumberType = BlockNumber.BlockNumberType;

type BenchResult = {
  readonly label: string;
  readonly count: number;
  readonly ms: number;
  readonly opsPerSec: number;
  readonly msPerOp: number;
};

type ChainFixture = {
  readonly genesis: BlockType;
  readonly blocks: ReadonlyArray<BlockType>;
  readonly numbers: ReadonlyArray<BlockNumberType>;
};

const BlockHashBytesSchema = BlockHash.Bytes as unknown as Schema.Schema<
  BlockHashType,
  Uint8Array
>;

const BlockchainMemoryLive = BlockchainLive.pipe(
  Layer.provide(BlockStoreMemoryLive),
);

const blockHashFromNumber = (value: number): BlockHashType => {
  const bytes = new Uint8Array(32);
  let remaining = value;
  for (let i = bytes.length - 1; i >= 0 && remaining > 0; i -= 1) {
    bytes[i] = remaining & 0xff;
    remaining = Math.floor(remaining / 256);
  }
  return Schema.decodeSync(BlockHashBytesSchema)(bytes);
};

const makeChain = (count: number): ChainFixture => {
  const zeroHash = blockHashFromNumber(0);
  const genesisHash = blockHashFromNumber(1);
  const genesis = makeBlock({
    number: 0n,
    hash: genesisHash,
    parentHash: zeroHash,
  });

  const blocks: BlockType[] = [];
  let parent = genesisHash;
  for (let i = 0; i < count; i += 1) {
    const hash = blockHashFromNumber(i + 2);
    const block = makeBlock({
      number: BigInt(i + 1),
      hash,
      parentHash: parent,
    });
    blocks.push(block);
    parent = hash;
  }

  return {
    genesis,
    blocks,
    numbers: blocks.map((block) => block.header.number),
  } satisfies ChainFixture;
};

const benchPutBlocks = (blocks: ReadonlyArray<BlockType>) =>
  Effect.gen(function* () {
    for (const block of blocks) {
      yield* putBlock(block);
    }
  });

const benchProcessBlocks = (blocks: ReadonlyArray<BlockType>) =>
  Effect.gen(function* () {
    for (const block of blocks) {
      yield* putBlock(block);
      yield* setCanonicalHead(block.hash);
    }
  });

const benchReadByNumber = (numbers: ReadonlyArray<BlockNumberType>) =>
  Effect.gen(function* () {
    for (const number of numbers) {
      yield* getBlockByNumber(number);
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

const withFreshChain = <A, E>(
  count: number,
  effect: (fixture: ChainFixture) => Effect.Effect<A, E, Blockchain>,
): Effect.Effect<A, E | BlockStoreError> =>
  Effect.scoped(
    Effect.gen(function* () {
      const fixture = makeChain(count);
      return yield* effect(fixture);
    }).pipe(Effect.provide(BlockchainMemoryLive)),
  );

const benchPut = (count: number) =>
  withFreshChain(count, (fixture) =>
    Effect.gen(function* () {
      yield* initializeGenesis(fixture.genesis);
      return yield* measure(
        "putBlock",
        fixture.blocks.length,
        benchPutBlocks(fixture.blocks),
      );
    }),
  );

const benchProcess = (count: number) =>
  withFreshChain(count, (fixture) =>
    Effect.gen(function* () {
      yield* initializeGenesis(fixture.genesis);
      return yield* measure(
        "put+set head",
        fixture.blocks.length,
        benchProcessBlocks(fixture.blocks),
      );
    }),
  );

const benchReads = (count: number) =>
  withFreshChain(count, (fixture) =>
    Effect.gen(function* () {
      yield* initializeGenesis(fixture.genesis);
      yield* benchProcessBlocks(fixture.blocks);
      return yield* measure(
        "getBlockByNumber",
        fixture.numbers.length,
        benchReadByNumber(fixture.numbers),
      );
    }),
  );

const runBenchmarks = (count: number) =>
  Effect.gen(function* () {
    const results: BenchResult[] = [];
    results.push(yield* benchPut(count));
    results.push(yield* benchProcess(count));
    results.push(yield* benchReads(count));
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
  const count = parseCount(process.env.BLOCKCHAIN_BENCH_COUNT, 2_000);
  const results = yield* runBenchmarks(count);

  yield* Effect.sync(() => {
    console.log("Blockchain benchmarks (in-memory)");
    console.log(`Blocks: ${count}`);
    console.table(formatResults(results));
  });
});

pipe(
  main,
  Effect.tapErrorCause((cause) =>
    Effect.sync(() => {
      console.error("Benchmark failed");
      console.error(Cause.pretty(cause));
    }),
  ),
  Effect.runPromise,
);
