# Cloudflare Edge Workers (`guillotine-mini`)

This directory contains two Cloudflare Workers:

1. **Edge EVM JSON-RPC Worker (`evm-worker.ts`, default target)** — executes
   Ethereum EVM bytecode directly inside Cloudflare Workers using
   `@tevm/guillotine-mini`, `guillotine_mini_core.wasm`, modular precompile WASM
   reactors, and lazy upstream JSON-RPC state injection (`evm_call_ffi` /
   `evm_continue_ffi`).
2. **Genesis Proxy Worker (`genesis-worker.ts`, `--env genesis`)** — proxies
   zstd-compressed OP Superchain genesis files (`GET /genesis/base`,
   `GET /genesis/base-sepolia`).

## Supported Edge EVM JSON-RPC Methods

- `eth_call` — stateless or forked execution with decoded Solidity revert errors
- `eth_estimateGas` — execution gas + calldata intrinsic gas estimation
- `eth_createAccessList` — EIP-2930 access list generation
- `debug_traceCall` — EIP-3155 `structLogs`, Geth `callTracer`, and `flamegraph`
- `eth_chainId` & `web3_clientVersion`
- `GET /health` — runtime status and supported method list

## Build WASM & Run Locally

```bash
# 1. Build modular core + precompile WASM reactors
zig build wasm-modular

# 2. Configure upstream Ethereum RPC URL for lazy state injection
cd cloudflare
echo 'UPSTREAM_RPC_URL=https://ethereum-rpc.publicnode.com' > .dev.vars

# 3. Start local Wrangler dev server
wrangler dev
```

## Example Request

```bash
curl -sS http://127.0.0.1:8787 \
  -H 'content-type: application/json' \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "eth_call",
    "params": [{"to": "0x0000000000000000000000000000000000000004", "data": "0xdeadbeef"}, "latest"]
  }'
```

## Deploy

```bash
cd cloudflare
wrangler secret put UPSTREAM_RPC_URL
wrangler deploy

# Deploy the genesis proxy worker separately:
wrangler deploy --env genesis
```
