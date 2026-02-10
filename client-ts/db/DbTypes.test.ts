import { assert, describe, it } from "@effect/vitest";
import * as Schema from "effect/Schema";
import {
  DbConfigSchema,
  DbMetricSchema,
  DbNameSchema,
  DbNames,
  ReadFlags,
  ReadFlagsSchema,
  WriteFlags,
  WriteFlagsSchema,
} from "./DbTypes";

describe("DbTypes", () => {
  it("accepts canonical DB names", () => {
    const decoded = Schema.decodeSync(DbNameSchema)(DbNames.state);
    assert.strictEqual(decoded, DbNames.state);
  });

  it("rejects invalid DB names", () => {
    assert.throws(() =>
      Schema.decodeSync(DbNameSchema)(
        "not-a-db" as unknown as Schema.Schema.Type<typeof DbNameSchema>,
      ),
    );
  });

  it("validates DbConfig", () => {
    const decoded = Schema.decodeSync(DbConfigSchema)({ name: DbNames.code });
    assert.deepStrictEqual(decoded, { name: DbNames.code });
  });

  it("combines ReadFlags bitwise", () => {
    const combined = ReadFlags.combine(
      ReadFlags.HintCacheMiss,
      ReadFlags.SkipDuplicateRead,
    );
    const expected = ReadFlagsSchema.make(17);
    assert.strictEqual(combined, expected);
  });

  it("rejects invalid ReadFlags values", () => {
    assert.throws(() => Schema.decodeSync(ReadFlagsSchema)(32));
  });

  it("combines WriteFlags bitwise", () => {
    const combined = WriteFlags.combine(
      WriteFlags.LowPriority,
      WriteFlags.DisableWAL,
    );
    assert.strictEqual(combined, WriteFlags.LowPriorityAndNoWAL);
  });

  it("rejects invalid WriteFlags values", () => {
    assert.throws(() => Schema.decodeSync(WriteFlagsSchema)(4));
  });

  it("validates DbMetric payloads", () => {
    const metric = Schema.decodeSync(DbMetricSchema)({
      size: 1,
      cacheSize: 2,
      indexSize: 3,
      memtableSize: 4,
      totalReads: 5,
      totalWrites: 6,
    });
    assert.deepStrictEqual(metric, {
      size: 1,
      cacheSize: 2,
      indexSize: 3,
      memtableSize: 4,
      totalReads: 5,
      totalWrites: 6,
    });
  });

  it("rejects invalid DbMetric payloads", () => {
    const invalidMetric: unknown = {
      size: 1,
      cacheSize: 2,
      indexSize: 3,
      memtableSize: 4,
      totalReads: 5,
      totalWrites: "6",
    };

    assert.throws(() =>
      Schema.decodeUnknownSync(DbMetricSchema)(invalidMetric),
    );
  });
});
