# Warm and cold access

The first address or slot access records it in the Berlin transaction’s warm set. The next access uses the warm price. `setAccessList` supplies the contract address and the 32-byte key for slot zero before executing the same SLOAD or no-op SSTORE in a fresh transaction. The measured costs include the PUSH instructions. Transaction intrinsic charges for listing an address and key are calculated separately by the transaction runner.

Run [the example](main.zig) from the repository root.

```sh
zig build run-access-list
```

**Expected output**

```text
address=2600/100 slot=2100/100
SLOAD cold=2103 listed=103
SSTORE cold=2206 listed=106
```
