import type {
  BlockId,
  ChainEventSource,
  ExEx,
  ExExContext,
  ExExNotification,
  EVMBlock,
  TransactionReceipt,
} from './types';

// ============================================================================
// EXEX REGISTRATION
// ============================================================================

export interface ExExRegistration<Block = EVMBlock, Receipt = TransactionReceipt> {
  /** Unique identifier for this ExEx */
  id: string;
  /** The ExEx async generator function */
  exex: ExEx<Block, Receipt>;
  /** If provided, manager will backfill from this point */
  startFrom?: BlockId;
}

// ============================================================================
// CONTEXT FACTORY
// ============================================================================

export type ExExContextFactory<Block = EVMBlock, Receipt = TransactionReceipt> = () => Promise<
  Omit<ExExContext<Block, Receipt>, 'notifications'>
>;

// ============================================================================
// EXEX MANAGER
// ============================================================================

export class ExExManager<Block = EVMBlock, Receipt = TransactionReceipt> {
  private runners: Map<string, AsyncGenerator<BlockId, never, undefined>> = new Map();
  private finishedHeights: Map<string, BlockId> = new Map();
  private abortControllers: Map<string, AbortController> = new Map();

  constructor(
    private source: ChainEventSource<Block, Receipt>,
    private contextFactory: ExExContextFactory<Block, Receipt>
  ) {}

  /**
   * Start an ExEx. Returns when the ExEx crashes (which it shouldn't).
   */
  async run(registration: ExExRegistration<Block, Receipt>): Promise<void> {
    const { id, exex, startFrom } = registration;
    const baseCtx = await this.contextFactory();

    // Create abort controller for this ExEx
    const abortController = new AbortController();
    this.abortControllers.set(id, abortController);

    // Create notification stream (with optional backfill)
    const notifications = this.createNotificationStream(startFrom, baseCtx.head, abortController.signal);

    // Create full context
    const ctx: ExExContext<Block, Receipt> = { ...baseCtx, notifications };

    // Run the generator
    const generator = exex(ctx);
    this.runners.set(id, generator);

    try {
      for await (const finishedHeight of generator) {
        this.finishedHeights.set(id, finishedHeight);
      }
    } finally {
      this.runners.delete(id);
      this.abortControllers.delete(id);
    }
  }

  /**
   * Run multiple ExExes concurrently.
   */
  async runAll(registrations: ExExRegistration<Block, Receipt>[]): Promise<void> {
    await Promise.all(registrations.map((r) => this.run(r)));
  }

  /**
   * Stop a specific ExEx by ID
   */
  stop(id: string): void {
    const controller = this.abortControllers.get(id);
    if (controller) {
      controller.abort();
    }
  }

  /**
   * Stop all running ExExes
   */
  stopAll(): void {
    for (const controller of this.abortControllers.values()) {
      controller.abort();
    }
  }

  /**
   * Get the lowest finished height across all ExExes.
   * This is the safe point up to which the node can prune data.
   */
  getFinishedHeight(): BlockId | null {
    let lowest: BlockId | null = null;
    for (const height of this.finishedHeights.values()) {
      if (!lowest || height.number < lowest.number) {
        lowest = height;
      }
    }
    return lowest;
  }

  /**
   * Get the finished height for a specific ExEx
   */
  getExExFinishedHeight(id: string): BlockId | null {
    return this.finishedHeights.get(id) ?? null;
  }

  /**
   * Check if a specific ExEx is running
   */
  isRunning(id: string): boolean {
    return this.runners.has(id);
  }

  /**
   * Get all running ExEx IDs
   */
  getRunningExExIds(): string[] {
    return Array.from(this.runners.keys());
  }

  private async *createNotificationStream(
    startFrom: BlockId | undefined,
    head: BlockId,
    signal: AbortSignal
  ): AsyncIterable<ExExNotification<Block, Receipt>> {
    // Check for abort before starting
    if (signal.aborted) return;

    // Backfill if starting behind head
    if (startFrom && startFrom.number < head.number) {
      for await (const notification of this.source.replayRange(startFrom.number + 1n, head.number)) {
        if (signal.aborted) return;
        yield notification;
      }
    }

    // Then stream live
    for await (const notification of this.source.subscribe()) {
      if (signal.aborted) return;
      yield notification;
    }
  }
}
