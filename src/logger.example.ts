/**
 * Example usage of logger.ts
 * Run with: bun run src/logger.example.ts
 */

import * as logger from './logger';

console.log('=== Logger Example ===\n');

// Example 1: Different log levels
console.log('Example 1: Testing different log levels');
console.log('----------------------------------------');

logger.setLogLevel(logger.LogLevel.NONE);
console.log('\nLog Level: NONE (nothing should appear below)');
logger.error('This error is hidden');
logger.warn('This warning is hidden');
logger.info('This info is hidden');

logger.setLogLevel(logger.LogLevel.ERROR);
console.log('\nLog Level: ERROR (only errors)');
logger.error('Critical error occurred');
logger.warn('This warning is hidden');
logger.info('This info is hidden');

logger.setLogLevel(logger.LogLevel.WARN);
console.log('\nLog Level: WARN (errors and warnings)');
logger.error('Critical error occurred');
logger.warn('Something needs attention');
logger.info('This info is hidden');

logger.setLogLevel(logger.LogLevel.INFO);
console.log('\nLog Level: INFO (errors, warnings, info)');
logger.error('Critical error occurred');
logger.warn('Something needs attention');
logger.info('Application started successfully');
logger.debug('This debug message is hidden');

logger.setLogLevel(logger.LogLevel.DEBUG);
console.log('\nLog Level: DEBUG (all except trace)');
logger.error('Critical error occurred');
logger.warn('Something needs attention');
logger.info('Application started successfully');
logger.debug('Detailed debug information');
logger.trace('This trace is hidden');

logger.setLogLevel(logger.LogLevel.TRACE);
console.log('\nLog Level: TRACE (everything)');
logger.error('Critical error occurred');
logger.warn('Something needs attention');
logger.info('Application started successfully');
logger.debug('Detailed debug information');
logger.trace('Very detailed trace information');

// Example 2: Logging with arguments
console.log('\n\nExample 2: Logging with additional arguments');
console.log('---------------------------------------------');
logger.setLogLevel(logger.LogLevel.INFO);

const user = { id: 123, name: 'Alice' };
const balance = 1000n;
const address = '0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb';

logger.info('User logged in:', user);
logger.info('Balance updated:', balance.toString());
logger.info('Transaction from:', address);

// Example 3: Print function (always visible)
console.log('\n\nExample 3: Print function (bypasses log level)');
console.log('-----------------------------------------------');
logger.setLogLevel(logger.LogLevel.NONE);
logger.print('This is always visible regardless of log level');
logger.print('Gas used:', 21000, 'Gas limit:', 100000);

// Example 4: EVM execution logging
console.log('\n\nExample 4: Simulated EVM execution logging');
console.log('------------------------------------------');
logger.setLogLevel(logger.LogLevel.DEBUG);

logger.info('Starting EVM execution');
logger.debug('PC: 0, Opcode: PUSH1, Gas: 1000000');
logger.debug('PC: 2, Opcode: PUSH1, Gas: 999997');
logger.debug('PC: 4, Opcode: ADD, Gas: 999994');
logger.debug('PC: 5, Opcode: PUSH1, Gas: 999991');
logger.debug('Stack:', [3, 5]);
logger.trace('Memory: []');
logger.info('Execution completed successfully');

console.log('\n=== End of Example ===');
