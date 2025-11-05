/**
 * Debug logging utilities with configurable log levels
 * Port of src/logger.zig to TypeScript
 */

export enum LogLevel {
  NONE = 0,
  ERROR = 1,
  WARN = 2,
  INFO = 3,
  DEBUG = 4,
  TRACE = 5,
}

// Current log level (defaults to NONE for performance)
let currentLogLevel: LogLevel = LogLevel.NONE;

/**
 * Set the global log level
 * Only messages at or above this level will be logged
 */
export function setLogLevel(level: LogLevel): void {
  currentLogLevel = level;
}

/**
 * Get the current log level
 */
export function getLogLevel(): LogLevel {
  return currentLogLevel;
}

/**
 * Log an error message (always visible at ERROR level and above)
 */
export function error(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.ERROR) {
    console.error(`[ERROR] ${message}`, ...args);
  }
}

/**
 * Log a warning message (visible at WARN level and above)
 */
export function warn(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.WARN) {
    console.warn(`[WARN] ${message}`, ...args);
  }
}

/**
 * Log an informational message (visible at INFO level and above)
 */
export function info(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.INFO) {
    console.info(`[INFO] ${message}`, ...args);
  }
}

/**
 * Log a debug message (visible at DEBUG level and above)
 */
export function debug(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.DEBUG) {
    console.debug(`[DEBUG] ${message}`, ...args);
  }
}

/**
 * Log a trace message (visible at TRACE level only)
 */
export function trace(message: string, ...args: any[]): void {
  if (currentLogLevel >= LogLevel.TRACE) {
    console.log(`[TRACE] ${message}`, ...args);
  }
}

/**
 * Generic print function (bypasses log level checks)
 */
export function print(message: string, ...args: any[]): void {
  console.log(message, ...args);
}
