import { describe, it, expect } from 'bun:test';
import { CallError, EvmError } from './errors';

describe('CallError', () => {
  it('should have all 36 error types', () => {
    const errorTypes = Object.values(CallError);
    expect(errorTypes).toHaveLength(36);
  });

  it('should have unique error type values', () => {
    const errorTypes = Object.values(CallError);
    const uniqueTypes = new Set(errorTypes);
    expect(uniqueTypes.size).toBe(errorTypes.length);
  });

  describe('execution errors', () => {
    it('should define InvalidJump', () => {
      expect(CallError.InvalidJump).toBe('InvalidJump');
    });

    it('should define OutOfGas', () => {
      expect(CallError.OutOfGas).toBe('OutOfGas');
    });

    it('should define InvalidOpcode', () => {
      expect(CallError.InvalidOpcode).toBe('InvalidOpcode');
    });

    it('should define RevertExecution', () => {
      expect(CallError.RevertExecution).toBe('RevertExecution');
    });
  });

  describe('stack errors', () => {
    it('should define StackUnderflow', () => {
      expect(CallError.StackUnderflow).toBe('StackUnderflow');
    });

    it('should define StackOverflow', () => {
      expect(CallError.StackOverflow).toBe('StackOverflow');
    });
  });

  describe('resource errors', () => {
    it('should define OutOfMemory', () => {
      expect(CallError.OutOfMemory).toBe('OutOfMemory');
    });

    it('should define AllocationError', () => {
      expect(CallError.AllocationError).toBe('AllocationError');
    });

    it('should define MemoryError', () => {
      expect(CallError.MemoryError).toBe('MemoryError');
    });

    it('should define StorageError', () => {
      expect(CallError.StorageError).toBe('StorageError');
    });
  });

  describe('call errors', () => {
    it('should define CallDepthExceeded', () => {
      expect(CallError.CallDepthExceeded).toBe('CallDepthExceeded');
    });

    it('should define InsufficientBalance', () => {
      expect(CallError.InsufficientBalance).toBe('InsufficientBalance');
    });

    it('should define StaticCallViolation', () => {
      expect(CallError.StaticCallViolation).toBe('StaticCallViolation');
    });
  });

  describe('contract errors', () => {
    it('should define ContractNotFound', () => {
      expect(CallError.ContractNotFound).toBe('ContractNotFound');
    });

    it('should define ContractCollision', () => {
      expect(CallError.ContractCollision).toBe('ContractCollision');
    });

    it('should define AccountNotFound', () => {
      expect(CallError.AccountNotFound).toBe('AccountNotFound');
    });
  });

  describe('bytecode errors', () => {
    it('should define InvalidBytecode', () => {
      expect(CallError.InvalidBytecode).toBe('InvalidBytecode');
    });

    it('should define BytecodeTooLarge', () => {
      expect(CallError.BytecodeTooLarge).toBe('BytecodeTooLarge');
    });

    it('should define TruncatedPush', () => {
      expect(CallError.TruncatedPush).toBe('TruncatedPush');
    });

    it('should define InvalidPush', () => {
      expect(CallError.InvalidPush).toBe('InvalidPush');
    });
  });

  describe('jump errors', () => {
    it('should define InvalidJumpDestination', () => {
      expect(CallError.InvalidJumpDestination).toBe('InvalidJumpDestination');
    });

    it('should define MissingJumpDestMetadata', () => {
      expect(CallError.MissingJumpDestMetadata).toBe('MissingJumpDestMetadata');
    });
  });

  describe('size limit errors', () => {
    it('should define InitcodeTooLarge', () => {
      expect(CallError.InitcodeTooLarge).toBe('InitcodeTooLarge');
    });

    it('should define CreateInitCodeSizeLimit', () => {
      expect(CallError.CreateInitCodeSizeLimit).toBe('CreateInitCodeSizeLimit');
    });

    it('should define CreateContractSizeLimit', () => {
      expect(CallError.CreateContractSizeLimit).toBe('CreateContractSizeLimit');
    });
  });

  describe('validation errors', () => {
    it('should define GasZeroError', () => {
      expect(CallError.GasZeroError).toBe('GasZeroError');
    });

    it('should define InvalidInputSize', () => {
      expect(CallError.InvalidInputSize).toBe('InvalidInputSize');
    });

    it('should define InvalidInitCodeSize', () => {
      expect(CallError.InvalidInitCodeSize).toBe('InvalidInitCodeSize');
    });

    it('should define InvalidCreateValue', () => {
      expect(CallError.InvalidCreateValue).toBe('InvalidCreateValue');
    });

    it('should define InvalidStaticCallValue', () => {
      expect(CallError.InvalidStaticCallValue).toBe('InvalidStaticCallValue');
    });
  });

  describe('miscellaneous errors', () => {
    it('should define PrecompileError', () => {
      expect(CallError.PrecompileError).toBe('PrecompileError');
    });

    it('should define OutOfBounds', () => {
      expect(CallError.OutOfBounds).toBe('OutOfBounds');
    });

    it('should define WriteProtection', () => {
      expect(CallError.WriteProtection).toBe('WriteProtection');
    });

    it('should define ExecutionTimeout', () => {
      expect(CallError.ExecutionTimeout).toBe('ExecutionTimeout');
    });

    it('should define NoSpaceLeft', () => {
      expect(CallError.NoSpaceLeft).toBe('NoSpaceLeft');
    });

    it('should define NeedAsyncData', () => {
      expect(CallError.NeedAsyncData).toBe('NeedAsyncData');
    });
  });
});

describe('EvmError', () => {
  it('should create error with error type', () => {
    const error = new EvmError(CallError.OutOfGas);
    expect(error.errorType).toBe(CallError.OutOfGas);
    expect(error.message).toBe('OutOfGas');
    expect(error.name).toBe('EvmError');
  });

  it('should create error with custom message', () => {
    const error = new EvmError(CallError.OutOfGas, 'Not enough gas to continue');
    expect(error.errorType).toBe(CallError.OutOfGas);
    expect(error.message).toBe('Not enough gas to continue');
    expect(error.name).toBe('EvmError');
  });

  it('should be instanceof Error', () => {
    const error = new EvmError(CallError.StackOverflow);
    expect(error).toBeInstanceOf(Error);
  });

  it('should be instanceof EvmError', () => {
    const error = new EvmError(CallError.InvalidOpcode);
    expect(error).toBeInstanceOf(EvmError);
  });

  describe('usage examples', () => {
    it('should throw and catch EvmError', () => {
      const throwError = () => {
        throw new EvmError(CallError.InvalidJump, 'Jump to invalid destination');
      };

      expect(throwError).toThrow(EvmError);
      expect(throwError).toThrow('Jump to invalid destination');
    });

    it('should handle error in try-catch', () => {
      try {
        throw new EvmError(CallError.StackUnderflow);
      } catch (error) {
        expect(error).toBeInstanceOf(EvmError);
        if (error instanceof EvmError) {
          expect(error.errorType).toBe(CallError.StackUnderflow);
        }
      }
    });

    it('should differentiate error types', () => {
      const error1 = new EvmError(CallError.OutOfGas);
      const error2 = new EvmError(CallError.RevertExecution);

      expect(error1.errorType).not.toBe(error2.errorType);
    });

    it('should support pattern matching', () => {
      const handleError = (error: EvmError): string => {
        switch (error.errorType) {
          case CallError.OutOfGas:
            return 'Increase gas limit';
          case CallError.StackOverflow:
            return 'Reduce stack usage';
          case CallError.RevertExecution:
            return 'Transaction reverted';
          default:
            return 'Unknown error';
        }
      };

      expect(handleError(new EvmError(CallError.OutOfGas))).toBe('Increase gas limit');
      expect(handleError(new EvmError(CallError.StackOverflow))).toBe('Reduce stack usage');
      expect(handleError(new EvmError(CallError.RevertExecution))).toBe('Transaction reverted');
      expect(handleError(new EvmError(CallError.InvalidOpcode))).toBe('Unknown error');
    });
  });
});
