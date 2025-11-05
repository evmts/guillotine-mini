import { describe, expect, test } from "bun:test";
import { AccessListManager } from "./access-list-manager";

// Helper to create address from hex
function addressFromHex(hex: string): Uint8Array {
  const clean = hex.startsWith("0x") ? hex.slice(2) : hex;
  const padded = clean.padStart(40, "0");
  const bytes = new Uint8Array(20);
  for (let i = 0; i < 20; i++) {
    bytes[i] = parseInt(padded.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

// Helper to create 32-byte hash from hex
function hashFromHex(hex: string): Uint8Array {
  const clean = hex.startsWith("0x") ? hex.slice(2) : hex;
  const padded = clean.padStart(64, "0");
  const bytes = new Uint8Array(32);
  for (let i = 0; i < 32; i++) {
    bytes[i] = parseInt(padded.slice(i * 2, i * 2 + 2), 16);
  }
  return bytes;
}

describe("AccessListManager", () => {
  describe("accessAddress", () => {
    test("first access is cold (2600 gas)", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      const cost = manager.accessAddress(addr);
      expect(cost).toBe(2600);
    });

    test("second access is warm (100 gas)", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      manager.accessAddress(addr); // First access (cold)
      const cost = manager.accessAddress(addr); // Second access (warm)

      expect(cost).toBe(100);
    });

    test("different addresses have independent cold/warm state", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");

      const cost1 = manager.accessAddress(addr1); // Cold
      const cost2 = manager.accessAddress(addr2); // Cold
      const cost1Again = manager.accessAddress(addr1); // Warm

      expect(cost1).toBe(2600);
      expect(cost2).toBe(2600);
      expect(cost1Again).toBe(100);
    });

    test("isAddressWarm tracks state correctly", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      expect(manager.isAddressWarm(addr)).toBe(false);
      manager.accessAddress(addr);
      expect(manager.isAddressWarm(addr)).toBe(true);
    });
  });

  describe("accessStorageSlot", () => {
    test("first access is cold (2100 gas)", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const slot = 0n;

      const cost = manager.accessStorageSlot(addr, slot);
      expect(cost).toBe(2100);
    });

    test("second access is warm (100 gas)", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const slot = 0n;

      manager.accessStorageSlot(addr, slot); // First access (cold)
      const cost = manager.accessStorageSlot(addr, slot); // Second access (warm)

      expect(cost).toBe(100);
    });

    test("different slots have independent cold/warm state", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const slot0 = 0n;
      const slot1 = 1n;

      const cost0 = manager.accessStorageSlot(addr, slot0); // Cold
      const cost1 = manager.accessStorageSlot(addr, slot1); // Cold
      const cost0Again = manager.accessStorageSlot(addr, slot0); // Warm

      expect(cost0).toBe(2100);
      expect(cost1).toBe(2100);
      expect(cost0Again).toBe(100);
    });

    test("same slot on different addresses is independent", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");
      const slot = 0n;

      const cost1 = manager.accessStorageSlot(addr1, slot); // Cold
      const cost2 = manager.accessStorageSlot(addr2, slot); // Cold

      expect(cost1).toBe(2100);
      expect(cost2).toBe(2100);
    });

    test("isStorageSlotWarm tracks state correctly", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const slot = 0n;

      expect(manager.isStorageSlotWarm(addr, slot)).toBe(false);
      manager.accessStorageSlot(addr, slot);
      expect(manager.isStorageSlotWarm(addr, slot)).toBe(true);
    });

    test("handles large slot numbers (u256)", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const maxU256 = (1n << 256n) - 1n;

      const cost = manager.accessStorageSlot(addr, maxU256);
      expect(cost).toBe(2100);
      expect(manager.isStorageSlotWarm(addr, maxU256)).toBe(true);
    });
  });

  describe("preWarmAddresses", () => {
    test("pre-warmed address is warm on first access", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      manager.preWarmAddresses([addr]);
      const cost = manager.accessAddress(addr);

      expect(cost).toBe(100); // Warm, not cold
    });

    test("pre-warms multiple addresses", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");
      const addr3 = addressFromHex("0xdac17f958d2ee523a2206206994597c13d831ec7");

      manager.preWarmAddresses([addr1, addr2, addr3]);

      expect(manager.accessAddress(addr1)).toBe(100);
      expect(manager.accessAddress(addr2)).toBe(100);
      expect(manager.accessAddress(addr3)).toBe(100);
    });

    test("warmAddressCount tracks correctly", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");

      expect(manager.warmAddressCount).toBe(0);
      manager.preWarmAddresses([addr1, addr2]);
      expect(manager.warmAddressCount).toBe(2);
    });
  });

  describe("preWarmStorageSlots", () => {
    test("pre-warmed slot is warm on first access", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const slot = 0n;

      manager.preWarmStorageSlots([{ address: addr, slot }]);
      const cost = manager.accessStorageSlot(addr, slot);

      expect(cost).toBe(100); // Warm, not cold
    });

    test("pre-warms multiple slots", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      manager.preWarmStorageSlots([
        { address: addr, slot: 0n },
        { address: addr, slot: 1n },
        { address: addr, slot: 2n },
      ]);

      expect(manager.accessStorageSlot(addr, 0n)).toBe(100);
      expect(manager.accessStorageSlot(addr, 1n)).toBe(100);
      expect(manager.accessStorageSlot(addr, 2n)).toBe(100);
    });

    test("warmStorageSlotCount tracks correctly", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      expect(manager.warmStorageSlotCount).toBe(0);
      manager.preWarmStorageSlots([
        { address: addr, slot: 0n },
        { address: addr, slot: 1n },
      ]);
      expect(manager.warmStorageSlotCount).toBe(2);
    });
  });

  describe("preWarmFromAccessList", () => {
    test("pre-warms addresses from access list", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");

      manager.preWarmFromAccessList([
        { address: addr1, storageKeys: [] },
        { address: addr2, storageKeys: [] },
      ]);

      expect(manager.accessAddress(addr1)).toBe(100);
      expect(manager.accessAddress(addr2)).toBe(100);
    });

    test("pre-warms storage keys from access list", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const key0 = hashFromHex("0x00");
      const key1 = hashFromHex("0x01");

      manager.preWarmFromAccessList([
        { address: addr, storageKeys: [key0, key1] },
      ]);

      expect(manager.accessStorageSlot(addr, 0n)).toBe(100);
      expect(manager.accessStorageSlot(addr, 1n)).toBe(100);
    });

    test("handles complex access list", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");
      const key0 = hashFromHex("0x00");
      const key1 = hashFromHex("0x01");

      manager.preWarmFromAccessList([
        { address: addr1, storageKeys: [key0, key1] },
        { address: addr2, storageKeys: [key0] },
      ]);

      // All addresses should be warm
      expect(manager.accessAddress(addr1)).toBe(100);
      expect(manager.accessAddress(addr2)).toBe(100);

      // All specified slots should be warm
      expect(manager.accessStorageSlot(addr1, 0n)).toBe(100);
      expect(manager.accessStorageSlot(addr1, 1n)).toBe(100);
      expect(manager.accessStorageSlot(addr2, 0n)).toBe(100);

      // Unspecified slots should be cold
      expect(manager.accessStorageSlot(addr1, 2n)).toBe(2100);
      expect(manager.accessStorageSlot(addr2, 1n)).toBe(2100);
    });
  });

  describe("snapshot and restore", () => {
    test("snapshot captures current warm state", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const slot = 0n;

      manager.accessAddress(addr);
      manager.accessStorageSlot(addr, slot);

      const snapshot = manager.snapshot();

      // Verify snapshot captured the state
      expect(manager.isAddressWarm(addr)).toBe(true);
      expect(manager.isStorageSlotWarm(addr, slot)).toBe(true);
    });

    test("restore reverts to snapshot state", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");
      const slot = 0n;

      // Access addr1
      manager.accessAddress(addr1);
      const snapshot = manager.snapshot();

      // Access addr2 after snapshot
      manager.accessAddress(addr2);
      manager.accessStorageSlot(addr1, slot);

      expect(manager.isAddressWarm(addr2)).toBe(true);
      expect(manager.isStorageSlotWarm(addr1, slot)).toBe(true);

      // Restore to snapshot
      manager.restore(snapshot);

      // addr1 should still be warm (was in snapshot)
      expect(manager.isAddressWarm(addr1)).toBe(true);

      // addr2 should be cold (added after snapshot)
      expect(manager.isAddressWarm(addr2)).toBe(false);

      // slot should be cold (added after snapshot)
      expect(manager.isStorageSlotWarm(addr1, slot)).toBe(false);
    });

    test("restore handles nested snapshots", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");
      const addr3 = addressFromHex("0xdac17f958d2ee523a2206206994597c13d831ec7");

      // Level 0: addr1 warm
      manager.accessAddress(addr1);
      const snapshot1 = manager.snapshot();

      // Level 1: addr1, addr2 warm
      manager.accessAddress(addr2);
      const snapshot2 = manager.snapshot();

      // Level 2: addr1, addr2, addr3 warm
      manager.accessAddress(addr3);

      expect(manager.isAddressWarm(addr1)).toBe(true);
      expect(manager.isAddressWarm(addr2)).toBe(true);
      expect(manager.isAddressWarm(addr3)).toBe(true);

      // Restore to snapshot2: addr1, addr2 warm
      manager.restore(snapshot2);
      expect(manager.isAddressWarm(addr1)).toBe(true);
      expect(manager.isAddressWarm(addr2)).toBe(true);
      expect(manager.isAddressWarm(addr3)).toBe(false);

      // Restore to snapshot1: only addr1 warm
      manager.restore(snapshot1);
      expect(manager.isAddressWarm(addr1)).toBe(true);
      expect(manager.isAddressWarm(addr2)).toBe(false);
      expect(manager.isAddressWarm(addr3)).toBe(false);
    });

    test("snapshot is independent copy", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      const snapshot = manager.snapshot();

      // Modify manager after snapshot
      manager.accessAddress(addr);

      // Restore should revert to empty state
      manager.restore(snapshot);
      expect(manager.isAddressWarm(addr)).toBe(false);
    });
  });

  describe("clear", () => {
    test("clears all warm addresses", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0x6b175474e89094c44da98b954eedeac495271d0f");

      manager.accessAddress(addr1);
      manager.accessAddress(addr2);
      expect(manager.warmAddressCount).toBe(2);

      manager.clear();
      expect(manager.warmAddressCount).toBe(0);
      expect(manager.isAddressWarm(addr1)).toBe(false);
      expect(manager.isAddressWarm(addr2)).toBe(false);
    });

    test("clears all warm storage slots", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      manager.accessStorageSlot(addr, 0n);
      manager.accessStorageSlot(addr, 1n);
      expect(manager.warmStorageSlotCount).toBe(2);

      manager.clear();
      expect(manager.warmStorageSlotCount).toBe(0);
      expect(manager.isStorageSlotWarm(addr, 0n)).toBe(false);
      expect(manager.isStorageSlotWarm(addr, 1n)).toBe(false);
    });

    test("next access after clear is cold", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      manager.accessAddress(addr);
      expect(manager.accessAddress(addr)).toBe(100); // Warm

      manager.clear();

      expect(manager.accessAddress(addr)).toBe(2600); // Cold again
    });
  });

  describe("EIP-2929 compliance", () => {
    test("transaction with access list", () => {
      const manager = new AccessListManager();
      const tokenAddr = addressFromHex(
        "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"
      );
      const balanceSlot = 0n;
      const allowanceSlot = 1n;

      // Simulate EIP-2930 access list at transaction start
      manager.preWarmFromAccessList([
        {
          address: tokenAddr,
          storageKeys: [hashFromHex("0x00"), hashFromHex("0x01")],
        },
      ]);

      // All listed accesses should be warm
      expect(manager.accessAddress(tokenAddr)).toBe(100);
      expect(manager.accessStorageSlot(tokenAddr, balanceSlot)).toBe(100);
      expect(manager.accessStorageSlot(tokenAddr, allowanceSlot)).toBe(100);

      // Unlisted slot should be cold
      expect(manager.accessStorageSlot(tokenAddr, 2n)).toBe(2100);
    });

    test("nested call revert scenario", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const slot = 0n;

      // Parent call accesses address
      manager.accessAddress(addr);
      const parentSnapshot = manager.snapshot();

      // Child call accesses storage slot
      const childSnapshot = manager.snapshot();
      manager.accessStorageSlot(addr, slot);
      expect(manager.isStorageSlotWarm(addr, slot)).toBe(true);

      // Child call reverts
      manager.restore(childSnapshot);

      // Storage slot should be cold again
      expect(manager.isStorageSlotWarm(addr, slot)).toBe(false);

      // But address should still be warm
      expect(manager.isAddressWarm(addr)).toBe(true);
    });

    test("address stays warm across multiple calls", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      // First call
      expect(manager.accessAddress(addr)).toBe(2600); // Cold
      const snapshot1 = manager.snapshot();

      // Second call (nested)
      expect(manager.accessAddress(addr)).toBe(100); // Warm
      const snapshot2 = manager.snapshot();

      // Third call (nested deeper)
      expect(manager.accessAddress(addr)).toBe(100); // Still warm

      // Revert second call
      manager.restore(snapshot2);
      expect(manager.accessAddress(addr)).toBe(100); // Still warm

      // Revert first call
      manager.restore(snapshot1);
      expect(manager.accessAddress(addr)).toBe(100); // Still warm (was accessed before snapshot)
    });
  });

  describe("edge cases", () => {
    test("zero address", () => {
      const manager = new AccessListManager();
      const zeroAddr = new Uint8Array(20); // All zeros

      const cost = manager.accessAddress(zeroAddr);
      expect(cost).toBe(2600); // First access is cold
      expect(manager.accessAddress(zeroAddr)).toBe(100); // Second is warm
    });

    test("identical addresses with different representations", () => {
      const manager = new AccessListManager();
      const addr1 = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");
      const addr2 = addressFromHex("0xa0B86991c6218b36c1d19D4a2e9Eb0cE3606eB48"); // Mixed case

      manager.accessAddress(addr1);
      // Should be warm (same address, case doesn't matter in byte representation)
      expect(manager.accessAddress(addr2)).toBe(100);
    });

    test("slot zero is distinct from unaccessed", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      // Access slot 0
      manager.accessStorageSlot(addr, 0n);

      expect(manager.isStorageSlotWarm(addr, 0n)).toBe(true);
      expect(manager.isStorageSlotWarm(addr, 1n)).toBe(false);
    });

    test("empty access list", () => {
      const manager = new AccessListManager();

      manager.preWarmFromAccessList([]);

      expect(manager.warmAddressCount).toBe(0);
      expect(manager.warmStorageSlotCount).toBe(0);
    });

    test("multiple snapshots don't interfere", () => {
      const manager = new AccessListManager();
      const addr = addressFromHex("0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48");

      manager.accessAddress(addr);

      const snap1 = manager.snapshot();
      const snap2 = manager.snapshot();

      manager.clear();
      expect(manager.isAddressWarm(addr)).toBe(false);

      // Both snapshots should restore correctly
      manager.restore(snap1);
      expect(manager.isAddressWarm(addr)).toBe(true);

      manager.clear();
      manager.restore(snap2);
      expect(manager.isAddressWarm(addr)).toBe(true);
    });
  });
});
