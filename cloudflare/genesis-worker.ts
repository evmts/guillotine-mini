const GENESIS_ZSTD_URLS: Record<string, string> = {
  "base": "https://raw.githubusercontent.com/ethereum-optimism/superchain-registry/main/superchain/extra/genesis/mainnet/base.json.zst",
  "base-sepolia": "https://raw.githubusercontent.com/ethereum-optimism/superchain-registry/main/superchain/extra/genesis/sepolia/base.json.zst",
};

function normalizeChain(value: string | null): string | null {
  if (!value) return null;
  return value.trim().toLowerCase().replace(/_/g, "-");
}

function chainFromPath(pathname: string): string | null {
  const parts = pathname.split("/").filter(Boolean);
  if (parts.length >= 2 && parts[0] === "genesis") {
    return normalizeChain(parts[1]);
  }
  return null;
}

export default {
  async fetch(request: Request): Promise<Response> {
    if (request.method !== "GET") {
      return new Response("Method not allowed", { status: 405 });
    }

    const url = new URL(request.url);
    const chain = chainFromPath(url.pathname) ??
      normalizeChain(url.searchParams.get("chain")) ??
      "base";

    const upstream = GENESIS_ZSTD_URLS[chain];
    if (!upstream) {
      return new Response(`Unsupported chain: ${chain}`, { status: 400 });
    }

    const upstreamResponse = await fetch(upstream, {
      cf: { cacheTtl: 60 * 60 * 24 },
    });

    if (!upstreamResponse.ok || !upstreamResponse.body) {
      return new Response("Failed to fetch genesis", { status: 502 });
    }

    const headers = new Headers(upstreamResponse.headers);
    headers.set("content-type", "application/zstd");
    headers.set("cache-control", "public, max-age=86400");
    headers.set("access-control-allow-origin", "*");
    headers.set("x-genesis-chain", chain);
    headers.set("x-genesis-encoding", "zstd");
    headers.set("x-genesis-source", upstream);

    return new Response(upstreamResponse.body, { status: 200, headers });
  },
};
