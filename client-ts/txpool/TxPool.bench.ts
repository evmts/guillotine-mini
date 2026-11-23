import type {
  BaseFeePerGas,
  GasPrice,
  MaxFeePerGas,
  MaxPriorityFeePerGas,
} from "voltaire-effect/primitives";
import { TsBenchSuite } from "../../scripts/bench-ts-utils";
import { compareFeeMarketPriority } from "./TxPoolSorter";

const suite = new TsBenchSuite("client-ts/txpool");
suite.section("TxPool Fee Market Sorting");

type FeeTuple = {
  gasPrice: GasPrice.GasPriceType;
  maxFee: MaxFeePerGas.MaxFeePerGasType;
  maxPriority: MaxPriorityFeePerGas.MaxPriorityFeePerGasType;
};

const N = 10_000;
const baseFee = 25_000_000_000n as BaseFeePerGas.BaseFeePerGasType;
const tuples: FeeTuple[] = [];
let seed = 0xbadc0de1n;
for (let i = 0; i < N; i += 1) {
  seed = (seed * 6364136223846793005n + 1442695040888963407n) & ((1n << 64n) - 1n);
  const isLegacy = (seed & 3n) === 0n;
  const gp = ((seed % 100_000_000_000n) + 1n) as GasPrice.GasPriceType;
  const mf = (isLegacy ? 0n : (seed % 200_000_000_000n) + 1n) as MaxFeePerGas.MaxFeePerGasType;
  const mp = (isLegacy ? 0n : (seed % 10_000_000_000n) + 1n) as MaxPriorityFeePerGas.MaxPriorityFeePerGasType;
  tuples.push({ gasPrice: gp, maxFee: mf, maxPriority: mp });
}

// Warmup
for (let i = 0; i < 1000; i += 1) {
  const a = tuples[i]!;
  const b = tuples[(i + 1) % N]!;
  compareFeeMarketPriority(a.gasPrice, a.maxFee, a.maxPriority, b.gasPrice, b.maxFee, b.maxPriority, baseFee, true);
}

const cmpIters = 50_000;
let t0 = Bun.nanoseconds();
let acc = 0;
for (let i = 0; i < cmpIters; i += 1) {
  const a = tuples[i % N]!;
  const b = tuples[(i * 17 + 13) % N]!;
  acc += compareFeeMarketPriority(
    a.gasPrice,
    a.maxFee,
    a.maxPriority,
    b.gasPrice,
    b.maxFee,
    b.maxPriority,
    baseFee,
    true,
  );
}
let elapsed = Bun.nanoseconds() - t0;
if (acc === Number.MAX_SAFE_INTEGER) console.log(acc);
suite.record("compareFeeMarketPriority (EIP-1559/legacy mix)", cmpIters, elapsed);

const copy = tuples.slice();
t0 = Bun.nanoseconds();
copy.sort((a, b) =>
  compareFeeMarketPriority(
    a.gasPrice,
    a.maxFee,
    a.maxPriority,
    b.gasPrice,
    b.maxFee,
    b.maxPriority,
    baseFee,
    true,
  ),
);
elapsed = Bun.nanoseconds() - t0;
if (copy.length === 0) throw new Error("unexpected");
suite.record("Array.sort 10K fee tuples (EIP-1559/legacy mix)", N, elapsed);

suite.finish();
