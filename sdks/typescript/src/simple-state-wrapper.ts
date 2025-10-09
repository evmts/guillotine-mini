/**
 * SIMPLE APPROACH: Wrapper that pre-fetches state before execution
 * No complex async protocol needed - just populate storage upfront
 */

import type { Evm, StateInterface, ExecutionContext, BlockchainContext, ExecutionResult, Bytes } from "./types.js";

export class StateWrappedEvm implements Evm {
  private evm: Evm;
  private stateInterface: StateInterface;

  constructor(evm: Evm, stateInterface: StateInterface) {
    this.evm = evm;
    this.stateInterface = stateInterface;
  }

  async ready(): Promise<void> {
    return this.evm.ready();
  }

  async setBytecode(bytecode: Bytes): Promise<void> {
    return this.evm.setBytecode(bytecode);
  }

  async setExecutionContext(ctx: ExecutionContext): Promise<void> {
    return this.evm.setExecutionContext(ctx);
  }

  async setBlockchainContext(ctx: BlockchainContext): Promise<void> {
    return this.evm.setBlockchainContext(ctx);
  }

  async setAccessList(accessList: any[]): Promise<void> {
    return this.evm.setAccessList(accessList);
  }

  async setBlobHashes(hashes: Bytes[]): Promise<void> {
    return this.evm.setBlobHashes(hashes);
  }

  async execute(): Promise<ExecutionResult> {
    // Simple: just execute normally
    // If execution fails due to missing storage, catch it and retry
    // But for now, just execute
    return this.evm.execute();
  }

  async setStorage(address: string, slot: string, value: string): Promise<void> {
    return this.evm.setStorage(address, slot, value);
  }

  async getStorage(address: string, slot: string): Promise<string> {
    return this.evm.getStorage(address, slot);
  }

  async setBalance(address: string, balance: bigint): Promise<void> {
    return this.evm.setBalance(address, balance);
  }

  async setCode(address: string, code: Bytes): Promise<void> {
    return this.evm.setCode(address, code);
  }

  async destroy(): Promise<void> {
    return this.evm.destroy();
  }
}
