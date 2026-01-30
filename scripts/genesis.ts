#!/usr/bin/env bun
/**
 * Genesis Fetcher
 * Fetches Base genesis via Cloudflare backend and copies it to the clipboard.
 *
 * Usage:
 *   GENESIS_API_URL=https://<worker-host> bun scripts/genesis.ts
 *   GENESIS_API_URL=https://<worker-host> bun scripts/genesis.ts base-sepolia
 *   bun scripts/genesis.ts --chain base --endpoint https://<worker-host>
 */

import * as fzstd from "fzstd";

const SUPPORTED_CHAINS = new Set(["base", "base-sepolia"]);

function showHelp(): void {
  console.log(`Genesis Fetcher

USAGE:
  GENESIS_API_URL=https://<worker-host> bun scripts/genesis.ts [chain]
  bun scripts/genesis.ts --chain <chain> --endpoint https://<worker-host>

CHAINS:
  base (default)
  base-sepolia
`);
}

function normalizeChain(value: string): string {
  return value.trim().toLowerCase().replace(/_/g, "-");
}

function buildGenesisUrl(endpoint: string, chain: string): URL {
  const url = new URL(endpoint);
  if (url.pathname === "" || url.pathname === "/") {
    url.pathname = "/genesis";
  } else if (!url.pathname.endsWith("/genesis")) {
    url.pathname = `${url.pathname.replace(/\/$/, "")}/genesis`;
  }
  url.searchParams.set("chain", chain);
  return url;
}

async function copyToClipboard(text: string): Promise<void> {
  const platform = process.platform;
  const commands: string[][] = [];

  if (platform === "darwin") {
    commands.push(["pbcopy"]);
  } else if (platform === "win32") {
    commands.push(["clip"]);
  } else {
    if (process.env.WAYLAND_DISPLAY) {
      commands.push(["wl-copy"]);
    }
    commands.push(["xclip", "-selection", "clipboard"]);
  }

  let lastError: Error | null = null;
  for (const cmd of commands) {
    try {
      await runClipboardCommand(cmd, text);
      return;
    } catch (err) {
      lastError = err instanceof Error ? err : new Error(String(err));
    }
  }

  throw lastError ?? new Error("No clipboard command available.");
}

async function runClipboardCommand(cmd: string[], text: string): Promise<void> {
  const proc = Bun.spawn({
    cmd,
    stdin: "pipe",
    stdout: "ignore",
    stderr: "pipe",
  });

  const writer = proc.stdin?.getWriter();
  if (!writer) {
    throw new Error(`Failed to open stdin for ${cmd.join(" ")}.`);
  }

  await writer.write(new TextEncoder().encode(text));
  await writer.close();

  const exitCode = await proc.exited;
  if (exitCode !== 0) {
    const stderr = proc.stderr ? await new Response(proc.stderr).text() : "";
    const message = stderr.trim() || `Clipboard command failed: ${cmd.join(" ")}`;
    throw new Error(message);
  }
}

const args = process.argv.slice(2);
let chain = "base";
let endpoint = process.env.GENESIS_API_URL ?? "";

for (let i = 0; i < args.length; i += 1) {
  const arg = args[i];
  if (arg === "--help" || arg === "-h") {
    showHelp();
    process.exit(0);
  }
  if (arg === "--chain" || arg === "-c") {
    chain = args[i + 1] ?? "";
    i += 1;
    continue;
  }
  if (arg === "--endpoint" || arg === "-e") {
    endpoint = args[i + 1] ?? "";
    i += 1;
    continue;
  }
  if (!arg.startsWith("-") && i === 0) {
    chain = arg;
    continue;
  }
}

if (!endpoint) {
  console.error("Missing GENESIS_API_URL (Cloudflare worker endpoint).");
  showHelp();
  process.exit(1);
}

chain = normalizeChain(chain);
if (!SUPPORTED_CHAINS.has(chain)) {
  console.error(`Unsupported chain: ${chain}`);
  showHelp();
  process.exit(1);
}

const url = buildGenesisUrl(endpoint, chain);
const response = await fetch(url.toString());

if (!response.ok) {
  const errorText = await response.text();
  console.error(`Failed to fetch genesis (${response.status}). ${errorText.trim()}`);
  process.exit(1);
}

const contentType = response.headers.get("content-type") ?? "";
const isZstd = contentType.includes("application/zstd") ||
  response.headers.get("x-genesis-encoding") === "zstd";

const genesisText = isZstd
  ? new TextDecoder().decode(fzstd.decompress(new Uint8Array(await response.arrayBuffer())))
  : await response.text();

await copyToClipboard(genesisText);
console.log(`Copied ${chain} genesis to clipboard (${genesisText.length} chars).`);
