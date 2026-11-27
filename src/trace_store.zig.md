# `src/trace_store.zig`

Configurable-retention trace store and indexed Parity `trace_filter` query engine.

## Responsibilities
- **`TraceStore`**: Ingests `CallTracer` trees from [`tracers.zig`](tracers.zig) via `recordCallTrace`, flattening non-precompile frames into owned `StoredTraceEntry` rows with `trace_address` paths and subtrace counts.
- **Secondary Indexing & Filtering**: Maintains `block_index`, `from_index`, and `to_index` hash sets to evaluate `TraceFilter` (`from_block`, `to_block`, `from_address`, `to_address`, `after`, `count`) via fast intersection queries (`filter`) and Parity JSON serialization (`writeFilterJson`).
- **Retention & Reorgs**: Enforces `RetentionConfig` (`max_blocks`, `max_entries`, `keep_reverted`) by evicting oldest blocks and provides `rollbackReorg(new_head_block)` to cleanly remove reorged block traces without leaking memory.

## Ownership & Safety
- `recordCallTrace` stages entries before indexing and uses `errdefer` rollback so partial transactions are never left indexed on out-of-memory errors.
- `deinit` and `clear` release all owned entries, payload copies, and secondary index sets.
