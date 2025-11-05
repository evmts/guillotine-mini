/**
 * Tests for logger.ts
 */

import { describe, test, expect, beforeEach, afterEach, mock, spyOn } from 'bun:test';
import * as logger from './logger';

describe('logger', () => {
  // Spy on console methods
  let errorSpy: any;
  let warnSpy: any;
  let infoSpy: any;
  let debugSpy: any;
  let logSpy: any;

  beforeEach(() => {
    errorSpy = spyOn(console, 'error').mockImplementation(() => {});
    warnSpy = spyOn(console, 'warn').mockImplementation(() => {});
    infoSpy = spyOn(console, 'info').mockImplementation(() => {});
    debugSpy = spyOn(console, 'debug').mockImplementation(() => {});
    logSpy = spyOn(console, 'log').mockImplementation(() => {});
  });

  afterEach(() => {
    mock.restore();
    logger.setLogLevel(logger.LogLevel.NONE);
  });

  describe('setLogLevel and getLogLevel', () => {
    test('should set and get log level', () => {
      logger.setLogLevel(logger.LogLevel.INFO);
      expect(logger.getLogLevel()).toBe(logger.LogLevel.INFO);

      logger.setLogLevel(logger.LogLevel.DEBUG);
      expect(logger.getLogLevel()).toBe(logger.LogLevel.DEBUG);
    });

    test('should default to NONE', () => {
      expect(logger.getLogLevel()).toBe(logger.LogLevel.NONE);
    });
  });

  describe('log level filtering', () => {
    test('NONE level should suppress all logs', () => {
      logger.setLogLevel(logger.LogLevel.NONE);

      logger.error('test error');
      logger.warn('test warn');
      logger.info('test info');
      logger.debug('test debug');
      logger.trace('test trace');

      expect(errorSpy).not.toHaveBeenCalled();
      expect(warnSpy).not.toHaveBeenCalled();
      expect(infoSpy).not.toHaveBeenCalled();
      expect(debugSpy).not.toHaveBeenCalled();
      expect(logSpy).not.toHaveBeenCalled();
    });

    test('ERROR level should only show errors', () => {
      logger.setLogLevel(logger.LogLevel.ERROR);

      logger.error('test error');
      logger.warn('test warn');
      logger.info('test info');
      logger.debug('test debug');

      expect(errorSpy).toHaveBeenCalledWith('[ERROR] test error');
      expect(warnSpy).not.toHaveBeenCalled();
      expect(infoSpy).not.toHaveBeenCalled();
      expect(debugSpy).not.toHaveBeenCalled();
    });

    test('WARN level should show errors and warnings', () => {
      logger.setLogLevel(logger.LogLevel.WARN);

      logger.error('test error');
      logger.warn('test warn');
      logger.info('test info');
      logger.debug('test debug');

      expect(errorSpy).toHaveBeenCalledWith('[ERROR] test error');
      expect(warnSpy).toHaveBeenCalledWith('[WARN] test warn');
      expect(infoSpy).not.toHaveBeenCalled();
      expect(debugSpy).not.toHaveBeenCalled();
    });

    test('INFO level should show errors, warnings, and info', () => {
      logger.setLogLevel(logger.LogLevel.INFO);

      logger.error('test error');
      logger.warn('test warn');
      logger.info('test info');
      logger.debug('test debug');

      expect(errorSpy).toHaveBeenCalledWith('[ERROR] test error');
      expect(warnSpy).toHaveBeenCalledWith('[WARN] test warn');
      expect(infoSpy).toHaveBeenCalledWith('[INFO] test info');
      expect(debugSpy).not.toHaveBeenCalled();
    });

    test('DEBUG level should show all except trace', () => {
      logger.setLogLevel(logger.LogLevel.DEBUG);

      logger.error('test error');
      logger.warn('test warn');
      logger.info('test info');
      logger.debug('test debug');
      logger.trace('test trace');

      expect(errorSpy).toHaveBeenCalledWith('[ERROR] test error');
      expect(warnSpy).toHaveBeenCalledWith('[WARN] test warn');
      expect(infoSpy).toHaveBeenCalledWith('[INFO] test info');
      expect(debugSpy).toHaveBeenCalledWith('[DEBUG] test debug');
      expect(logSpy).not.toHaveBeenCalled();
    });

    test('TRACE level should show all messages', () => {
      logger.setLogLevel(logger.LogLevel.TRACE);

      logger.error('test error');
      logger.warn('test warn');
      logger.info('test info');
      logger.debug('test debug');
      logger.trace('test trace');

      expect(errorSpy).toHaveBeenCalledWith('[ERROR] test error');
      expect(warnSpy).toHaveBeenCalledWith('[WARN] test warn');
      expect(infoSpy).toHaveBeenCalledWith('[INFO] test info');
      expect(debugSpy).toHaveBeenCalledWith('[DEBUG] test debug');
      expect(logSpy).toHaveBeenCalledWith('[TRACE] test trace');
    });
  });

  describe('arguments handling', () => {
    test('should handle multiple arguments', () => {
      logger.setLogLevel(logger.LogLevel.INFO);

      const obj = { foo: 'bar' };
      const arr = [1, 2, 3];

      logger.info('test message', obj, arr, 42);

      expect(infoSpy).toHaveBeenCalledWith('[INFO] test message', obj, arr, 42);
    });

    test('should handle no additional arguments', () => {
      logger.setLogLevel(logger.LogLevel.ERROR);

      logger.error('simple error');

      expect(errorSpy).toHaveBeenCalledWith('[ERROR] simple error');
    });
  });

  describe('print function', () => {
    test('should bypass log level checks', () => {
      logger.setLogLevel(logger.LogLevel.NONE);

      logger.print('always visible');

      expect(logSpy).toHaveBeenCalledWith('always visible');
    });

    test('should handle arguments', () => {
      logger.print('message with args', 123, { key: 'value' });

      expect(logSpy).toHaveBeenCalledWith('message with args', 123, { key: 'value' });
    });
  });

  describe('log level enum values', () => {
    test('should have correct numeric ordering', () => {
      expect(logger.LogLevel.NONE).toBe(0);
      expect(logger.LogLevel.ERROR).toBe(1);
      expect(logger.LogLevel.WARN).toBe(2);
      expect(logger.LogLevel.INFO).toBe(3);
      expect(logger.LogLevel.DEBUG).toBe(4);
      expect(logger.LogLevel.TRACE).toBe(5);
    });
  });
});
