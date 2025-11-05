import { describe, test, expect } from "bun:test";
import {
  CallResult,
  Log,
  Address,
  ZERO_ADDRESS,
  successWithOutput,
  successEmpty,
  failure,
  failureWithError,
  revertWithData,
  successWithLogs,
  isSuccess,
  isFailure,
  hasOutput,
  gasConsumed,
  clone,
  emptyTrace,
} from "./call-result";

describe("CallResult", () => {
  describe("successWithOutput", () => {
    test("creates successful result with output", () => {
      const output = new Uint8Array([1, 2, 3, 4]);
      const result = successWithOutput(1000n, output);

      expect(result.success).toBe(true);
      expect(result.gas_left).toBe(1000n);
      expect(result.output).toEqual(output);
      expect(result.output).not.toBe(output); // Should be a copy
      expect(result.refund_counter).toBe(0n);
      expect(result.logs).toEqual([]);
    });

    test("handles empty output", () => {
      const result = successWithOutput(1000n, new Uint8Array(0));

      expect(result.success).toBe(true);
      expect(result.output.length).toBe(0);
    });
  });

  describe("successEmpty", () => {
    test("creates successful result with no output", () => {
      const result = successEmpty(2000n);

      expect(result.success).toBe(true);
      expect(result.gas_left).toBe(2000n);
      expect(result.output.length).toBe(0);
      expect(result.logs).toEqual([]);
    });
  });

  describe("failure", () => {
    test("creates failed result", () => {
      const result = failure(500n);

      expect(result.success).toBe(false);
      expect(result.gas_left).toBe(500n);
      expect(result.output.length).toBe(0);
      expect(result.logs).toEqual([]);
    });
  });

  describe("failureWithError", () => {
    test("creates failed result with error info", () => {
      const result = failureWithError(500n, "Out of gas");

      expect(result.success).toBe(false);
      expect(result.gas_left).toBe(500n);
      expect(result.error_info).toBe("Out of gas");
      expect(result.output.length).toBe(0);
    });
  });

  describe("revertWithData", () => {
    test("creates reverted result with revert data", () => {
      const revert_data = new Uint8Array([0x08, 0xc3, 0x79, 0xa0]); // Error(string) selector
      const result = revertWithData(800n, revert_data);

      expect(result.success).toBe(false);
      expect(result.gas_left).toBe(800n);
      expect(result.output).toEqual(revert_data);
      expect(result.output).not.toBe(revert_data); // Should be a copy
      expect(result.error_info).toBeUndefined();
    });

    test("handles empty revert data", () => {
      const result = revertWithData(800n, new Uint8Array(0));

      expect(result.success).toBe(false);
      expect(result.output.length).toBe(0);
    });
  });

  describe("successWithLogs", () => {
    test("creates successful result with logs", () => {
      const address = new Uint8Array(20).fill(0x42);
      const topics = [0x1234567890abcdefn, 0xfedcba0987654321n];
      const data = new Uint8Array([1, 2, 3, 4, 5]);

      const logs: Log[] = [
        {
          address,
          topics,
          data,
        },
      ];

      const output = new Uint8Array([0xff, 0xee]);
      const result = successWithLogs(1500n, output, logs);

      expect(result.success).toBe(true);
      expect(result.gas_left).toBe(1500n);
      expect(result.output).toEqual(output);
      expect(result.logs.length).toBe(1);

      // Verify deep copy
      expect(result.logs[0].address).toEqual(address);
      expect(result.logs[0].address).not.toBe(address);
      expect(result.logs[0].topics).toEqual(topics);
      expect(result.logs[0].topics).not.toBe(topics);
      expect(result.logs[0].data).toEqual(data);
      expect(result.logs[0].data).not.toBe(data);
    });

    test("handles multiple logs", () => {
      const logs: Log[] = [
        {
          address: new Uint8Array(20).fill(0x11),
          topics: [0x1111n],
          data: new Uint8Array([1]),
        },
        {
          address: new Uint8Array(20).fill(0x22),
          topics: [0x2222n, 0x3333n],
          data: new Uint8Array([2, 3]),
        },
      ];

      const result = successWithLogs(1000n, new Uint8Array(0), logs);

      expect(result.logs.length).toBe(2);
      expect(result.logs[0].topics[0]).toBe(0x1111n);
      expect(result.logs[1].topics[1]).toBe(0x3333n);
    });
  });

  describe("isSuccess", () => {
    test("returns true for successful result", () => {
      const result = successEmpty(1000n);
      expect(isSuccess(result)).toBe(true);
    });

    test("returns false for failed result", () => {
      const result = failure(500n);
      expect(isSuccess(result)).toBe(false);
    });
  });

  describe("isFailure", () => {
    test("returns false for successful result", () => {
      const result = successEmpty(1000n);
      expect(isFailure(result)).toBe(false);
    });

    test("returns true for failed result", () => {
      const result = failure(500n);
      expect(isFailure(result)).toBe(true);
    });
  });

  describe("hasOutput", () => {
    test("returns true when result has output", () => {
      const result = successWithOutput(1000n, new Uint8Array([1, 2, 3]));
      expect(hasOutput(result)).toBe(true);
    });

    test("returns false when result has no output", () => {
      const result = successEmpty(1000n);
      expect(hasOutput(result)).toBe(false);
    });
  });

  describe("gasConsumed", () => {
    test("calculates gas consumed correctly", () => {
      const result = successEmpty(3000n);
      const consumed = gasConsumed(result, 5000n);
      expect(consumed).toBe(2000n);
    });

    test("returns 0 for invalid gas_left", () => {
      const result = successEmpty(10000n);
      const consumed = gasConsumed(result, 5000n);
      expect(consumed).toBe(0n);
    });

    test("handles exact gas consumption", () => {
      const result = successEmpty(0n);
      const consumed = gasConsumed(result, 21000n);
      expect(consumed).toBe(21000n);
    });
  });

  describe("clone", () => {
    test("creates deep copy of simple result", () => {
      const original = successWithOutput(1000n, new Uint8Array([1, 2, 3]));
      const copy = clone(original);

      expect(copy).toEqual(original);
      expect(copy).not.toBe(original);
      expect(copy.output).not.toBe(original.output);
    });

    test("creates deep copy of result with logs", () => {
      const logs: Log[] = [
        {
          address: new Uint8Array(20).fill(0x42),
          topics: [0x1234n],
          data: new Uint8Array([5, 6, 7]),
        },
      ];

      const original = successWithLogs(1000n, new Uint8Array([1, 2]), logs);
      const copy = clone(original);

      expect(copy.logs).toEqual(original.logs);
      expect(copy.logs).not.toBe(original.logs);
      expect(copy.logs[0]).not.toBe(original.logs[0]);
      expect(copy.logs[0].address).not.toBe(original.logs[0].address);
      expect(copy.logs[0].topics).not.toBe(original.logs[0].topics);
      expect(copy.logs[0].data).not.toBe(original.logs[0].data);
    });

    test("creates deep copy of result with created_address", () => {
      const address = new Uint8Array(20).fill(0x99);
      const original: CallResult = {
        ...successEmpty(1000n),
        created_address: address,
      };

      const copy = clone(original);

      expect(copy.created_address).toEqual(address);
      expect(copy.created_address).not.toBe(address);
    });

    test("handles result with error_info", () => {
      const original = failureWithError(500n, "Stack underflow");
      const copy = clone(original);

      expect(copy.error_info).toBe(original.error_info);
    });
  });

  describe("emptyTrace", () => {
    test("creates empty execution trace", () => {
      const trace = emptyTrace();
      expect(trace.steps).toEqual([]);
    });
  });

  describe("ZERO_ADDRESS", () => {
    test("is 20 bytes of zeros", () => {
      expect(ZERO_ADDRESS.length).toBe(20);
      expect(ZERO_ADDRESS.every((byte) => byte === 0)).toBe(true);
    });
  });

  describe("complex scenarios", () => {
    test("result with all fields populated", () => {
      const result: CallResult = {
        success: true,
        gas_left: 15000n,
        output: new Uint8Array([0xff, 0xee, 0xdd]),
        refund_counter: 4800n,
        logs: [
          {
            address: new Uint8Array(20).fill(0x11),
            topics: [0xAAAAn, 0xBBBBn],
            data: new Uint8Array([1, 2, 3]),
          },
        ],
        selfdestructs: [
          {
            contract: new Uint8Array(20).fill(0x22),
            beneficiary: new Uint8Array(20).fill(0x33),
          },
        ],
        accessed_addresses: [new Uint8Array(20).fill(0x44)],
        accessed_storage: [
          {
            address: new Uint8Array(20).fill(0x55),
            slot: 0x123n,
          },
        ],
        trace: {
          steps: [
            {
              pc: 0,
              opcode: 0x60,
              opcode_name: "PUSH1",
              gas: 10000n,
              depth: 0,
              gas_cost: 3n,
              stack: [0x42n],
              memory: new Uint8Array(0),
              mem_size: 0,
              storage_reads: [],
              storage_writes: [],
            },
          ],
        },
        created_address: new Uint8Array(20).fill(0x99),
      };

      expect(isSuccess(result)).toBe(true);
      expect(hasOutput(result)).toBe(true);
      expect(result.logs.length).toBe(1);
      expect(result.selfdestructs.length).toBe(1);
      expect(result.accessed_addresses.length).toBe(1);
      expect(result.accessed_storage.length).toBe(1);
      expect(result.trace?.steps.length).toBe(1);
      expect(result.created_address).toBeDefined();

      // Clone and verify all fields
      const copy = clone(result);
      expect(copy).toEqual(result);
      expect(copy).not.toBe(result);
    });

    test("result with refund counter", () => {
      const result: CallResult = {
        ...successEmpty(18000n),
        refund_counter: 2400n,
      };

      expect(result.refund_counter).toBe(2400n);

      const copy = clone(result);
      expect(copy.refund_counter).toBe(2400n);
    });

    test("result with trace containing storage operations", () => {
      const result: CallResult = {
        ...successEmpty(10000n),
        trace: {
          steps: [
            {
              pc: 10,
              opcode: 0x54,
              opcode_name: "SLOAD",
              gas: 9000n,
              depth: 1,
              gas_cost: 2100n,
              stack: [0x123n],
              memory: new Uint8Array(0),
              mem_size: 0,
              storage_reads: [
                {
                  address: new Uint8Array(20).fill(0xaa),
                  slot: 0x123n,
                  value: 0x456n,
                },
              ],
              storage_writes: [],
            },
            {
              pc: 11,
              opcode: 0x55,
              opcode_name: "SSTORE",
              gas: 6900n,
              depth: 1,
              gas_cost: 20000n,
              stack: [0x789n, 0x123n],
              memory: new Uint8Array(0),
              mem_size: 0,
              storage_reads: [],
              storage_writes: [
                {
                  address: new Uint8Array(20).fill(0xaa),
                  slot: 0x123n,
                  old_value: 0x456n,
                  new_value: 0x789n,
                },
              ],
            },
          ],
        },
      };

      expect(result.trace?.steps.length).toBe(2);
      expect(result.trace?.steps[0].storage_reads.length).toBe(1);
      expect(result.trace?.steps[1].storage_writes.length).toBe(1);

      const copy = clone(result);
      expect(copy.trace?.steps[0].storage_reads[0]).toEqual(result.trace?.steps[0].storage_reads[0]);
      expect(copy.trace?.steps[0].storage_reads[0].address).not.toBe(
        result.trace?.steps[0].storage_reads[0].address
      );
    });
  });
});
