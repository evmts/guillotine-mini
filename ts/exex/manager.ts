import type {
  BlockId,
  ChainEventSource,
  ExEx,
  ExExContext,
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
  /** If provided, notifications resume after this block */
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
  private finishedHeights: Map<string, BlockId | null> = new Map();
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
    if (this.abortControllers.has(id)) {
      throw new Error('ExEx already running: ' + id);
    }

    const abortController = new AbortController();
    this.abortControllers.set(id, abortController);
    // Register before startup can suspend. A restart must acknowledge again.
    this.finishedHeights.set(id, null);

    try {
      const baseCtx = await this.contextFactory();
      if (abortController.signal.aborted) return;

      const { head, notifications } = await this.source.subscribeFrom(
        startFrom,
        abortController.signal
      );
      if (abortController.signal.aborted) return;

      const generator = exex({ ...baseCtx, head, notifications });
      this.runners.set(id, generator);
      for await (const finishedHeight of generator) {
        this.finishedHeights.set(id, finishedHeight);
      }
    } finally {
      abortController.abort();
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
   * Get the lowest acknowledged height across all registered ExExes.
   * Pruning must wait until every registration has acknowledged a height.
   */
  getFinishedHeight(): BlockId | null {
    let lowest: BlockId | null = null;
    for (const height of this.finishedHeights.values()) {
      if (height === null) return null;
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
}
