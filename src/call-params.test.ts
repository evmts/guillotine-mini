import { describe, it, expect } from 'vitest';
import {
  type CallParamsUnion,
  type CallParams,
  type CallCodeParams,
  type DelegateCallParams,
  type StaticCallParams,
  type CreateParams,
  type Create2Params,
  validate,
  getGas,
  setGas,
  getCaller,
  getInput,
  hasValue,
  isReadOnly,
  isCreate,
  getTo,
  clone,
  GasZeroError,
  InvalidInputSizeError,
  InvalidInitCodeSizeError,
  MAX_INITCODE_SIZE,
  MAX_INPUT_SIZE,
} from './call-params';

describe('CallParams', () => {
  const testAddress1 = '0x1234567890123456789012345678901234567890' as const;
  const testAddress2 = '0xabcdefabcdefabcdefabcdefabcdefabcdefabcd' as const;

  describe('CALL', () => {
    const callParams: CallParams = {
      type: 'call',
      caller: testAddress1,
      to: testAddress2,
      value: 100n,
      input: new Uint8Array([1, 2, 3]),
      gas: 21000n,
    };

    it('should validate valid parameters', () => {
      expect(() => validate(callParams)).not.toThrow();
    });

    it('should throw on zero gas', () => {
      const invalidParams = { ...callParams, gas: 0n };
      expect(() => validate(invalidParams)).toThrow(GasZeroError);
    });

    it('should throw on oversized input', () => {
      const largeInput = new Uint8Array(MAX_INPUT_SIZE + 1);
      const invalidParams = { ...callParams, input: largeInput };
      expect(() => validate(invalidParams)).toThrow(InvalidInputSizeError);
    });

    it('should get gas correctly', () => {
      expect(getGas(callParams)).toBe(21000n);
    });

    it('should set gas correctly', () => {
      const params = { ...callParams };
      setGas(params, 50000n);
      expect(params.gas).toBe(50000n);
    });

    it('should get caller correctly', () => {
      expect(getCaller(callParams)).toBe(testAddress1);
    });

    it('should get input correctly', () => {
      expect(getInput(callParams)).toEqual(new Uint8Array([1, 2, 3]));
    });

    it('should detect value transfer', () => {
      expect(hasValue(callParams)).toBe(true);
      const noValueParams = { ...callParams, value: 0n };
      expect(hasValue(noValueParams)).toBe(false);
    });

    it('should not be read-only', () => {
      expect(isReadOnly(callParams)).toBe(false);
    });

    it('should not be create', () => {
      expect(isCreate(callParams)).toBe(false);
    });

    it('should get target address', () => {
      expect(getTo(callParams)).toBe(testAddress2);
    });

    it('should clone correctly', () => {
      const cloned = clone(callParams);
      expect(cloned).toEqual(callParams);
      expect(cloned).not.toBe(callParams);
      // Verify deep copy of input
      if (cloned.type === 'call') {
        expect(cloned.input).not.toBe(callParams.input);
        expect(cloned.input).toEqual(callParams.input);
      }
    });
  });

  describe('CALLCODE', () => {
    const callCodeParams: CallCodeParams = {
      type: 'callcode',
      caller: testAddress1,
      to: testAddress2,
      value: 50n,
      input: new Uint8Array([4, 5, 6]),
      gas: 30000n,
    };

    it('should validate valid parameters', () => {
      expect(() => validate(callCodeParams)).not.toThrow();
    });

    it('should detect value transfer', () => {
      expect(hasValue(callCodeParams)).toBe(true);
    });

    it('should get target address', () => {
      expect(getTo(callCodeParams)).toBe(testAddress2);
    });

    it('should not be create', () => {
      expect(isCreate(callCodeParams)).toBe(false);
    });

    it('should clone correctly', () => {
      const cloned = clone(callCodeParams);
      expect(cloned).toEqual(callCodeParams);
      expect(cloned).not.toBe(callCodeParams);
    });
  });

  describe('DELEGATECALL', () => {
    const delegateCallParams: DelegateCallParams = {
      type: 'delegatecall',
      caller: testAddress1,
      to: testAddress2,
      input: new Uint8Array([7, 8, 9]),
      gas: 40000n,
    };

    it('should validate valid parameters', () => {
      expect(() => validate(delegateCallParams)).not.toThrow();
    });

    it('should not have value transfer', () => {
      expect(hasValue(delegateCallParams)).toBe(false);
    });

    it('should not be read-only', () => {
      expect(isReadOnly(delegateCallParams)).toBe(false);
    });

    it('should get target address', () => {
      expect(getTo(delegateCallParams)).toBe(testAddress2);
    });

    it('should clone correctly', () => {
      const cloned = clone(delegateCallParams);
      expect(cloned).toEqual(delegateCallParams);
      expect(cloned).not.toBe(delegateCallParams);
    });
  });

  describe('STATICCALL', () => {
    const staticCallParams: StaticCallParams = {
      type: 'staticcall',
      caller: testAddress1,
      to: testAddress2,
      input: new Uint8Array([10, 11, 12]),
      gas: 25000n,
    };

    it('should validate valid parameters', () => {
      expect(() => validate(staticCallParams)).not.toThrow();
    });

    it('should not have value transfer', () => {
      expect(hasValue(staticCallParams)).toBe(false);
    });

    it('should be read-only', () => {
      expect(isReadOnly(staticCallParams)).toBe(true);
    });

    it('should get target address', () => {
      expect(getTo(staticCallParams)).toBe(testAddress2);
    });

    it('should not be create', () => {
      expect(isCreate(staticCallParams)).toBe(false);
    });

    it('should clone correctly', () => {
      const cloned = clone(staticCallParams);
      expect(cloned).toEqual(staticCallParams);
      expect(cloned).not.toBe(staticCallParams);
    });
  });

  describe('CREATE', () => {
    const createParams: CreateParams = {
      type: 'create',
      caller: testAddress1,
      value: 1000n,
      initCode: new Uint8Array([0x60, 0x60, 0x60, 0x40, 0x52]),
      gas: 53000n,
    };

    it('should validate valid parameters', () => {
      expect(() => validate(createParams)).not.toThrow();
    });

    it('should throw on zero gas', () => {
      const invalidParams = { ...createParams, gas: 0n };
      expect(() => validate(invalidParams)).toThrow(GasZeroError);
    });

    it('should throw on oversized init code', () => {
      const largeInitCode = new Uint8Array(MAX_INITCODE_SIZE + 1);
      const invalidParams = { ...createParams, initCode: largeInitCode };
      expect(() => validate(invalidParams)).toThrow(InvalidInitCodeSizeError);
    });

    it('should accept max init code size', () => {
      const maxInitCode = new Uint8Array(MAX_INITCODE_SIZE);
      const validParams = { ...createParams, initCode: maxInitCode };
      expect(() => validate(validParams)).not.toThrow();
    });

    it('should detect value transfer', () => {
      expect(hasValue(createParams)).toBe(true);
      const noValueParams = { ...createParams, value: 0n };
      expect(hasValue(noValueParams)).toBe(false);
    });

    it('should be create', () => {
      expect(isCreate(createParams)).toBe(true);
    });

    it('should not have target address', () => {
      expect(getTo(createParams)).toBe(null);
    });

    it('should get init code as input', () => {
      expect(getInput(createParams)).toEqual(createParams.initCode);
    });

    it('should clone correctly', () => {
      const cloned = clone(createParams);
      expect(cloned).toEqual(createParams);
      expect(cloned).not.toBe(createParams);
      // Verify deep copy of init code
      if (cloned.type === 'create') {
        expect(cloned.initCode).not.toBe(createParams.initCode);
        expect(cloned.initCode).toEqual(createParams.initCode);
      }
    });
  });

  describe('CREATE2', () => {
    const create2Params: Create2Params = {
      type: 'create2',
      caller: testAddress1,
      value: 2000n,
      initCode: new Uint8Array([0x60, 0x80, 0x60, 0x40, 0x52]),
      salt: 0x1234567890abcdefn,
      gas: 53000n,
    };

    it('should validate valid parameters', () => {
      expect(() => validate(create2Params)).not.toThrow();
    });

    it('should throw on oversized init code', () => {
      const largeInitCode = new Uint8Array(MAX_INITCODE_SIZE + 1);
      const invalidParams = { ...create2Params, initCode: largeInitCode };
      expect(() => validate(invalidParams)).toThrow(InvalidInitCodeSizeError);
    });

    it('should detect value transfer', () => {
      expect(hasValue(create2Params)).toBe(true);
    });

    it('should be create', () => {
      expect(isCreate(create2Params)).toBe(true);
    });

    it('should not have target address', () => {
      expect(getTo(create2Params)).toBe(null);
    });

    it('should get init code as input', () => {
      expect(getInput(create2Params)).toEqual(create2Params.initCode);
    });

    it('should clone correctly', () => {
      const cloned = clone(create2Params);
      expect(cloned).toEqual(create2Params);
      expect(cloned).not.toBe(create2Params);
      // Verify deep copy of init code
      if (cloned.type === 'create2') {
        expect(cloned.initCode).not.toBe(create2Params.initCode);
        expect(cloned.initCode).toEqual(create2Params.initCode);
        expect(cloned.salt).toBe(create2Params.salt);
      }
    });
  });

  describe('Generic Helper Functions', () => {
    const testParams: CallParamsUnion[] = [
      {
        type: 'call',
        caller: testAddress1,
        to: testAddress2,
        value: 100n,
        input: new Uint8Array([1, 2, 3]),
        gas: 21000n,
      },
      {
        type: 'callcode',
        caller: testAddress1,
        to: testAddress2,
        value: 50n,
        input: new Uint8Array([4, 5, 6]),
        gas: 30000n,
      },
      {
        type: 'delegatecall',
        caller: testAddress1,
        to: testAddress2,
        input: new Uint8Array([7, 8, 9]),
        gas: 40000n,
      },
      {
        type: 'staticcall',
        caller: testAddress1,
        to: testAddress2,
        input: new Uint8Array([10, 11, 12]),
        gas: 25000n,
      },
      {
        type: 'create',
        caller: testAddress1,
        value: 1000n,
        initCode: new Uint8Array([0x60, 0x60]),
        gas: 53000n,
      },
      {
        type: 'create2',
        caller: testAddress1,
        value: 2000n,
        initCode: new Uint8Array([0x60, 0x80]),
        salt: 0xabcdefn,
        gas: 53000n,
      },
    ];

    it('should get gas for all param types', () => {
      expect(getGas(testParams[0])).toBe(21000n);
      expect(getGas(testParams[1])).toBe(30000n);
      expect(getGas(testParams[2])).toBe(40000n);
      expect(getGas(testParams[3])).toBe(25000n);
      expect(getGas(testParams[4])).toBe(53000n);
      expect(getGas(testParams[5])).toBe(53000n);
    });

    it('should set gas for all param types', () => {
      const newGas = 99999n;
      testParams.forEach((params) => {
        const p = { ...params };
        setGas(p, newGas);
        expect(p.gas).toBe(newGas);
      });
    });

    it('should get caller for all param types', () => {
      testParams.forEach((params) => {
        expect(getCaller(params)).toBe(testAddress1);
      });
    });

    it('should get input/init code for all param types', () => {
      expect(getInput(testParams[0])).toEqual(new Uint8Array([1, 2, 3]));
      expect(getInput(testParams[1])).toEqual(new Uint8Array([4, 5, 6]));
      expect(getInput(testParams[2])).toEqual(new Uint8Array([7, 8, 9]));
      expect(getInput(testParams[3])).toEqual(new Uint8Array([10, 11, 12]));
      expect(getInput(testParams[4])).toEqual(new Uint8Array([0x60, 0x60]));
      expect(getInput(testParams[5])).toEqual(new Uint8Array([0x60, 0x80]));
    });

    it('should detect value transfers correctly', () => {
      expect(hasValue(testParams[0])).toBe(true); // call with value
      expect(hasValue(testParams[1])).toBe(true); // callcode with value
      expect(hasValue(testParams[2])).toBe(false); // delegatecall (no value)
      expect(hasValue(testParams[3])).toBe(false); // staticcall (no value)
      expect(hasValue(testParams[4])).toBe(true); // create with value
      expect(hasValue(testParams[5])).toBe(true); // create2 with value
    });

    it('should detect read-only operations', () => {
      expect(isReadOnly(testParams[0])).toBe(false);
      expect(isReadOnly(testParams[1])).toBe(false);
      expect(isReadOnly(testParams[2])).toBe(false);
      expect(isReadOnly(testParams[3])).toBe(true); // staticcall only
      expect(isReadOnly(testParams[4])).toBe(false);
      expect(isReadOnly(testParams[5])).toBe(false);
    });

    it('should detect create operations', () => {
      expect(isCreate(testParams[0])).toBe(false);
      expect(isCreate(testParams[1])).toBe(false);
      expect(isCreate(testParams[2])).toBe(false);
      expect(isCreate(testParams[3])).toBe(false);
      expect(isCreate(testParams[4])).toBe(true); // create
      expect(isCreate(testParams[5])).toBe(true); // create2
    });

    it('should get target addresses correctly', () => {
      expect(getTo(testParams[0])).toBe(testAddress2);
      expect(getTo(testParams[1])).toBe(testAddress2);
      expect(getTo(testParams[2])).toBe(testAddress2);
      expect(getTo(testParams[3])).toBe(testAddress2);
      expect(getTo(testParams[4])).toBe(null); // create
      expect(getTo(testParams[5])).toBe(null); // create2
    });
  });

  describe('Edge Cases', () => {
    it('should handle empty input', () => {
      const params: CallParams = {
        type: 'call',
        caller: testAddress1,
        to: testAddress2,
        value: 0n,
        input: new Uint8Array(0),
        gas: 21000n,
      };
      expect(() => validate(params)).not.toThrow();
      expect(getInput(params).length).toBe(0);
    });

    it('should handle empty init code', () => {
      const params: CreateParams = {
        type: 'create',
        caller: testAddress1,
        value: 0n,
        initCode: new Uint8Array(0),
        gas: 53000n,
      };
      expect(() => validate(params)).not.toThrow();
      expect(getInput(params).length).toBe(0);
    });

    it('should handle maximum values', () => {
      const params: CallParams = {
        type: 'call',
        caller: testAddress1,
        to: testAddress2,
        value: 2n ** 256n - 1n, // Max u256
        input: new Uint8Array(1024), // Reasonable size
        gas: 2n ** 64n - 1n, // Max u64 represented as bigint
      };
      expect(() => validate(params)).not.toThrow();
    });

    it('should handle zero salt in CREATE2', () => {
      const params: Create2Params = {
        type: 'create2',
        caller: testAddress1,
        value: 0n,
        initCode: new Uint8Array([0x60, 0x00]),
        salt: 0n,
        gas: 53000n,
      };
      expect(() => validate(params)).not.toThrow();
      const cloned = clone(params);
      if (cloned.type === 'create2') {
        expect(cloned.salt).toBe(0n);
      }
    });

    it('should handle max salt in CREATE2', () => {
      const params: Create2Params = {
        type: 'create2',
        caller: testAddress1,
        value: 0n,
        initCode: new Uint8Array([0x60, 0x00]),
        salt: 2n ** 256n - 1n,
        gas: 53000n,
      };
      expect(() => validate(params)).not.toThrow();
    });
  });

  describe('Clone Deep Copy Verification', () => {
    it('should create independent copies of input data', () => {
      const original: CallParams = {
        type: 'call',
        caller: testAddress1,
        to: testAddress2,
        value: 100n,
        input: new Uint8Array([1, 2, 3, 4, 5]),
        gas: 21000n,
      };

      const cloned = clone(original);

      // Modify original input
      original.input[0] = 99;

      // Cloned should be unaffected
      if (cloned.type === 'call') {
        expect(cloned.input[0]).toBe(1);
        expect(original.input[0]).toBe(99);
      }
    });

    it('should create independent copies of init code', () => {
      const original: CreateParams = {
        type: 'create',
        caller: testAddress1,
        value: 1000n,
        initCode: new Uint8Array([0x60, 0x60, 0x60]),
        gas: 53000n,
      };

      const cloned = clone(original);

      // Modify original init code
      original.initCode[0] = 0xFF;

      // Cloned should be unaffected
      if (cloned.type === 'create') {
        expect(cloned.initCode[0]).toBe(0x60);
        expect(original.initCode[0]).toBe(0xFF);
      }
    });
  });
});
