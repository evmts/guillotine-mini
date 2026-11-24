import { expect, test } from 'bun:test';
import { ExExManager, type ExExContextFactory } from './manager';
import type {
  BlockId,
  BlockReader,
  ChainEventSource,
  ExExNotification,
  StateReader,
} from './types';

const block = (number: bigint): BlockId => ({
  number,
  hash: ('0x' + number.toString(16).padStart(64, '0')) as BlockId['hash'],
});

const committed = (id: BlockId): ExExNotification<BlockId, never> => ({
  type: 'committed',
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
});

const contextFactory: ExExContextFactory<BlockId, never> = async () => ({
  head: block(1n),
  chainId: 1n,
  state: {} as StateReader,
  blocks: {} as BlockReader,
});

const gate = () => {
  let open!: () => void;
  const wait = new Promise<void>((resolve) => { open = resolve; });
  return { wait, open };
};

test('opens replay and live through one source subscription', async () => {
  const cursor = block(1n);
  const head = block(2n);
  const next = block(3n);
  const received: BlockId[] = [];
  const pending: BlockId[] = [];
  const done = new Error('done');
  let signal: AbortSignal | undefined;
  const source: ChainEventSource<BlockId, never> = {
    async subscribeFrom(from, subscriptionSignal) {
      expect(from).toEqual(cursor);
      signal = subscriptionSignal;
      return {
        head,
        notifications: (async function* () {
          yield committed(head);
          for (const id of pending) yield committed(id);
        })(),
      };
    },
  };
  const manager = new ExExManager(source, contextFactory);

  await expect(manager.run({
    id: 'backfill',
    startFrom: cursor,
    async *exex({ head: subscriptionHead, notifications }) {
      expect(subscriptionHead).toEqual(head);
      for await (const notification of notifications) {
        if (notification.type !== 'committed') throw new Error('Expected a commit');
        const tip = notification.chain.tip();
        received.push(tip);
        // Publish while the extension is still consuming replay.
        if (tip.number === head.number) pending.push(next);
        yield tip;
      }
      throw done;
    },
  })).rejects.toBe(done);

  expect(received).toEqual([head, next]);
  expect(manager.getFinishedHeight()).toEqual(next);
  expect(signal?.aborted).toBe(true);
});

test('waits for every registered extension before exposing a prune height', async () => {
  const fast = gate();
  const slow = gate();
  const allowSlow = gate();
  const stop = gate();
  const done = new Error('done');
  let contextCount = 0;
  const source: ChainEventSource<BlockId, never> = {
    async subscribeFrom() {
      return { head: block(100n), notifications: (async function* () {})() };
    },
  };
  const manager = new ExExManager(source, async () => {
    if (++contextCount === 2) await allowSlow.wait;
    return contextFactory();
  });
  const result = manager.runAll([
    {
      id: 'fast',
      async *exex() {
        yield block(100n);
        fast.open();
        await stop.wait;
        throw done;
      },
    },
    {
      id: 'slow',
      async *exex() {
        yield block(80n);
        slow.open();
        await stop.wait;
        throw done;
      },
    },
  ]);

  try {
    await fast.wait;
    expect(manager.getExExFinishedHeight('fast')).toEqual(block(100n));
    expect(manager.getFinishedHeight()).toBeNull();

    allowSlow.open();
    await slow.wait;
    expect(manager.getFinishedHeight()).toEqual(block(80n));
  } finally {
    allowSlow.open();
    stop.open();
    await expect(result).rejects.toBe(done);
  }
});
