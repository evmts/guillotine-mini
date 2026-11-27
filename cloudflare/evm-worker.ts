/**
 * Cloudflare Edge EVM Worker backed by `@tevm/guillotine-mini` +
 * `guillotine_mini_core.wasm` + lazy upstream JSON-RPC state injection.
 *
 * Serves `eth_call`, `eth_estimateGas`, `eth_createAccessList`,
 * `debug_traceCall`, and `web3_clientVersion` directly at the edge with zero
 * Node.js dependencies.
 */

import {
  SDK_VERSION,
  createEvm,
  hexToBytes,
  type CallOptions,
  type HardforkName,
  type Hex,
  type PrecompileModuleInput,
  type RpcBlockTag,
  type StateProvider,
  type WasmSource,
} from "../ts/index.ts";

export interface EvmWorkerEnv {
  readonly EVM_WASM?: WebAssembly.Module;
  readonly WASM_URL?: string;
  readonly UPSTREAM_RPC_URL?: string;
  readonly HARDFORK?: string;
  readonly CHAIN_ID?: string;
  readonly ALLOW_CUSTOM_RPC?: string;
  readonly [key: string]: unknown;
}

interface JsonRpcRequest {
  readonly jsonrpc?: string;
  readonly id?: string | number | null;
  readonly method: string;
  readonly params?: ReadonlyArray<unknown>;
}

interface RpcCallObject {
  readonly from?: Hex;
  readonly to?: Hex;
  readonly gas?: Hex;
  readonly gasPrice?: Hex;
  readonly value?: Hex;
  readonly data?: Hex;
  readonly input?: Hex;
  readonly bytecode?: Hex;
}

interface DebugTraceConfig {
  readonly tracer?: string;
  readonly tracerConfig?: {
    readonly onlyTopCall?: boolean;
    readonly withLog?: boolean;
  };
  readonly enableMemory?: boolean;
  readonly disableStack?: boolean;
  readonly disableStorage?: boolean;
  readonly enableReturnData?: boolean;
}

export interface WorkerDispatchOverrides {
  readonly wasm?: WasmSource;
  readonly precompiles?: ReadonlyArray<PrecompileModuleInput>;
  readonly stateProvider?: StateProvider;
}

const CORS_HEADERS: Record<string, string> = {
  "content-type": "application/json; charset=utf-8",
  "access-control-allow-origin": "*",
  "access-control-allow-methods": "GET, POST, OPTIONS",
  "access-control-allow-headers": "content-type, x-rpc-url",
};

const SUPPORTED_METHODS = [
  "eth_call",
  "eth_estimateGas",
  "eth_createAccessList",
  "debug_traceCall",
  "eth_chainId",
  "web3_clientVersion",
] as const;

function parseHexQuantity(value: string | undefined, fallback: bigint): bigint {
  if (!value || value === "0x") return fallback;
  return BigInt(value);
}

function toHexQuantity(value: bigint): Hex {
  return `0x${value.toString(16)}` as Hex;
}

function intrinsicGas(dataHex: Hex | undefined): bigint {
  let gas = 21_000n;
  if (!dataHex || dataHex === "0x") return gas;
  const bytes = hexToBytes(dataHex);
  for (let i = 0; i < bytes.length; i++) {
    gas += bytes[i] === 0 ? 4n : 16n;
  }
  return gas;
}

function collectPrecompileBindings(env: EvmWorkerEnv): WebAssembly.Module[] {
  const modules: WebAssembly.Module[] = [];
  for (const [key, value] of Object.entries(env)) {
    if (key.startsWith("PRECOMPILE_") && value instanceof WebAssembly.Module) {
      modules.push(value);
    }
  }
  return modules;
}

function buildCallOptions(callObj: RpcCallObject, blockTag: RpcBlockTag): CallOptions {
  const data = callObj.data ?? callObj.input;
  return {
    caller: callObj.from,
    to: callObj.to,
    gas: parseHexQuantity(callObj.gas, 16_777_216n),
    gasPrice: callObj.gasPrice ? parseHexQuantity(callObj.gasPrice, 0n) : undefined,
    value: parseHexQuantity(callObj.value, 0n),
    data,
    bytecode: callObj.bytecode,
    blockTag,
  };
}

function rpcOk(id: string | number | null | undefined, result: unknown): Record<string, unknown> {
  return { jsonrpc: "2.0", id: id ?? null, result };
}

function rpcErr(
  id: string | number | null | undefined,
  code: number,
  message: string,
  data?: unknown,
): Record<string, unknown> {
  return {
    jsonrpc: "2.0",
    id: id ?? null,
    error: data !== undefined ? { code, message, data } : { code, message },
  };
}

async function handleSingleRpc(
  req: JsonRpcRequest,
  env: EvmWorkerEnv,
  rpcUrl: string | undefined,
  overrides?: WorkerDispatchOverrides,
): Promise<Record<string, unknown>> {
  const id = req.id ?? null;
  if (req.method === "web3_clientVersion") {
    return rpcOk(id, `guillotine-mini/${SDK_VERSION}/wasm32-wasi`);
  }
  if (req.method === "eth_chainId") {
    return rpcOk(id, toHexQuantity(BigInt(env.CHAIN_ID ?? "1")));
  }

  const wasmSource: WasmSource | undefined = overrides?.wasm ?? env.EVM_WASM ?? env.WASM_URL;
  if (!wasmSource) {
    return rpcErr(id, -32603, "EVM WASM binary is not configured (bind EVM_WASM or set WASM_URL)");
  }

  const params = req.params ?? [];
  const callObj = (params[0] ?? {}) as RpcCallObject;
  const blockTag = ((params[1] as RpcBlockTag | undefined) ?? "latest");
  const precompiles = overrides?.precompiles ?? collectPrecompileBindings(env);
  const hardfork = (env.HARDFORK ?? "osaka") as HardforkName;

  const evm = await createEvm({
    wasm: wasmSource,
    hardfork,
    precompiles,
    rpcUrl: overrides?.stateProvider ? undefined : rpcUrl,
    stateProvider: overrides?.stateProvider,
    blockTag,
    blockContext: { chainId: BigInt(env.CHAIN_ID ?? "1") },
  });

  try {
    const callOpts = buildCallOptions(callObj, blockTag);

    if (req.method === "eth_call") {
      const res = await evm.call(callOpts);
      if (!res.success) {
        const decoded = evm.decodeRevert(res.output);
        const reason = decoded?.reason ? `execution reverted: ${decoded.reason}` : "execution reverted";
        return rpcErr(id, 3, reason, res.outputHex);
      }
      return rpcOk(id, res.outputHex);
    }

    if (req.method === "eth_estimateGas") {
      const res = await evm.call(callOpts);
      if (!res.success) {
        const decoded = evm.decodeRevert(res.output);
        const reason = decoded?.reason ? `execution reverted: ${decoded.reason}` : "execution reverted";
        return rpcErr(id, 3, reason, res.outputHex);
      }
      const total = intrinsicGas(callObj.data ?? callObj.input) + res.gasUsed;
      return rpcOk(id, toHexQuantity(total));
    }

    if (req.method === "eth_createAccessList") {
      const { result, accessList } = await evm.createAccessList(callOpts);
      const total = intrinsicGas(callObj.data ?? callObj.input) + result.gasUsed;
      return rpcOk(id, {
        accessList,
        gasUsed: toHexQuantity(total),
        ...(result.success ? {} : { error: "execution reverted" }),
      });
    }

    if (req.method === "debug_traceCall") {
      const cfg = (params[2] ?? {}) as DebugTraceConfig;
      if (cfg.tracer === "callTracer") {
        const traced = await evm.callTrace(callOpts, {
          onlyTopCall: cfg.tracerConfig?.onlyTopCall,
          withLog: cfg.tracerConfig?.withLog,
        });
        return rpcOk(id, traced.callFrame);
      }
      if (cfg.tracer === "flamegraph") {
        const fg = await evm.flamegraphSvg(callOpts);
        return rpcOk(id, { svg: fg.svg, folded: fg.folded, gasUsed: toHexQuantity(fg.result.gasUsed) });
      }
      const traced = await evm.trace(callOpts, {
        enableMemory: cfg.enableMemory,
        disableStack: cfg.disableStack,
        disableStorage: cfg.disableStorage,
        enableReturnData: cfg.enableReturnData,
      });
      return rpcOk(id, {
        gas: Number(traced.result.gasUsed),
        failed: !traced.result.success,
        returnValue: traced.result.outputHex,
        structLogs: traced.steps,
      });
    }

    return rpcErr(id, -32601, `Method not found: ${req.method}`);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    return rpcErr(id, -32000, message);
  } finally {
    evm.dispose();
  }
}

export async function handleEvmWorkerRequest(
  request: Request,
  env: EvmWorkerEnv,
  overrides?: WorkerDispatchOverrides,
): Promise<Response> {
  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  const url = new URL(request.url);
  if (request.method === "GET" && (url.pathname === "/" || url.pathname === "/health")) {
    return new Response(
      JSON.stringify({
        status: "ok",
        runtime: `guillotine-mini/${SDK_VERSION}`,
        hardfork: env.HARDFORK ?? "osaka",
        methods: SUPPORTED_METHODS,
      }),
      { status: 200, headers: CORS_HEADERS },
    );
  }

  if (request.method !== "POST") {
    return new Response(JSON.stringify(rpcErr(null, -32600, "Only POST JSON-RPC requests are supported")), {
      status: 405,
      headers: CORS_HEADERS,
    });
  }

  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return new Response(JSON.stringify(rpcErr(null, -32700, "Parse error")), {
      status: 400,
      headers: CORS_HEADERS,
    });
  }

  const customRpc = env.ALLOW_CUSTOM_RPC === "true" ? request.headers.get("x-rpc-url") ?? undefined : undefined;
  const rpcUrl = customRpc ?? env.UPSTREAM_RPC_URL;

  if (Array.isArray(body)) {
    const responses = await Promise.all(
      body.map((item) => handleSingleRpc(item as JsonRpcRequest, env, rpcUrl, overrides)),
    );
    return new Response(JSON.stringify(responses), { status: 200, headers: CORS_HEADERS });
  }

  const response = await handleSingleRpc(body as JsonRpcRequest, env, rpcUrl, overrides);
  return new Response(JSON.stringify(response), { status: 200, headers: CORS_HEADERS });
}

export default {
  fetch(request: Request, env: EvmWorkerEnv): Promise<Response> {
    return handleEvmWorkerRequest(request, env);
  },
};
