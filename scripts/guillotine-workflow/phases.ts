export const phases = [
  { id: "phase-0-db", name: "DB Abstraction Layer" },
  { id: "phase-1-trie", name: "Merkle Patricia Trie" },
  { id: "phase-2-world-state", name: "World State (Journal + Snapshot/Restore)" },
  { id: "phase-3-evm-state", name: "EVM ↔ WorldState Integration (Transaction/Block Processing)" },
  { id: "phase-4-blockchain", name: "Block Chain Management" },
  { id: "phase-5-txpool", name: "Transaction Pool" },
  { id: "phase-6-jsonrpc", name: "JSON-RPC Server" },
  { id: "phase-7-engine-api", name: "Engine API (Consensus Layer Interface)" },
  { id: "phase-8-networking", name: "Networking (devp2p)" },
  { id: "phase-9-sync", name: "Synchronization" },
  { id: "phase-10-runner", name: "Runner (Entry Point + CLI)" },
] as const;

export type PhaseId = (typeof phases)[number]["id"];
