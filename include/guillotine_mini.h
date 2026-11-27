/**
 * @file guillotine_mini.h
 * @brief C99 ABI for Guillotine Mini — minimal Ethereum Virtual Machine in Zig.
 *
 * Covers the complete `evm_*` C/WASM reactor FFI exported by `src/root_c.zig`
 * and the EVMC ABI 12 entry point exported by `src/evmc_exports.zig`.
 *
 * Conventions:
 * - Addresses are 20-byte raw arrays.
 * - 256-bit words (values, balances, slots, gas prices, hashes) are 32-byte
 *   big-endian arrays.
 * - All pointers passed into the library may be NULL when their accompanying
 *   length/count is 0; otherwise NULL pointers are rejected safely.
 * - String/JSON/SVG getter pairs (`evm_get_*_len` / `evm_get_*`) return raw
 *   UTF-8 bytes without a NUL terminator.
 */

#ifndef GUILLOTINE_MINI_H
#define GUILLOTINE_MINI_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/** Semantic version of the Guillotine Mini C header. */
#define GUILLOTINE_MINI_VERSION_MAJOR 0
#define GUILLOTINE_MINI_VERSION_MINOR 2
#define GUILLOTINE_MINI_VERSION_PATCH 0

/** Inline fast-path capacity of `evm_async_request_t.json_data`. */
#define EVM_ASYNC_JSON_INLINE_CAPACITY 16384u

/** Log levels accepted by `evm_create`. */
enum evm_log_level {
    EVM_LOG_NONE  = 0,
    EVM_LOG_ERR   = 1,
    EVM_LOG_WARN  = 2,
    EVM_LOG_INFO  = 3,
    EVM_LOG_DEBUG = 4
};

/** `evm_async_request_t.output_type` values returned by `evm_call_ffi` / `evm_continue_ffi`. */
enum evm_async_output_type {
    EVM_ASYNC_RESULT          = 0,
    EVM_ASYNC_NEED_STORAGE    = 1,
    EVM_ASYNC_NEED_BALANCE    = 2,
    EVM_ASYNC_NEED_CODE       = 3,
    EVM_ASYNC_NEED_NONCE      = 4,
    EVM_ASYNC_READY_TO_COMMIT = 5,
    EVM_ASYNC_ERROR           = 255
};

/** `continue_type` values passed to `evm_continue_ffi`. */
enum evm_async_continue_type {
    EVM_CONTINUE_STORAGE      = 1,
    EVM_CONTINUE_BALANCE      = 2,
    EVM_CONTINUE_CODE         = 3,
    EVM_CONTINUE_NONCE        = 4,
    EVM_CONTINUE_AFTER_COMMIT = 5
};

/** Opaque handle representing a single EVM execution context. */
typedef struct evm_handle evm_handle_t;

/**
 * Output structure for the async state-injection protocol (`evm_call_ffi` /
 * `evm_continue_ffi`).
 *
 * Fixed ABI layout verified at compile time in `src/root_c.zig`:
 * - `output_type`: offset 0 (1 byte)
 * - `address`:     offset 1 (20 bytes)
 * - `slot`:        offset 21 (32 bytes)
 * - `json_len`:    offset 56 (4 bytes; 3 padding bytes before it)
 * - `json_data`:   offset 60 (16384 bytes)
 *
 * When `output_type == EVM_ASYNC_READY_TO_COMMIT`:
 * - `json_len` always holds the full untruncated byte length.
 * - If `json_len <= EVM_ASYNC_JSON_INLINE_CAPACITY`, `json_data[0..json_len]`
 *   holds the complete JSON payload.
 * - Otherwise `json_data` is zero-filled; fetch the full payload via
 *   `evm_get_state_changes_len` and `evm_get_state_changes`.
 */
typedef struct evm_async_request {
    uint8_t output_type;
    uint8_t address[20];
    uint8_t slot[32];
    uint32_t json_len;
    uint8_t json_data[EVM_ASYNC_JSON_INLINE_CAPACITY];
} evm_async_request_t;

/* -------------------------------------------------------------------------- */
/* Memory transfer helpers                                                    */
/* -------------------------------------------------------------------------- */

/** Allocate a 16-byte aligned transfer buffer inside the EVM allocator. */
uint8_t *evm_alloc(size_t len);

/** Release a transfer buffer returned by `evm_alloc`. NULL is a no-op. */
void evm_free(uint8_t *ptr, size_t len);

/* -------------------------------------------------------------------------- */
/* Lifecycle & host callback controls                                         */
/* -------------------------------------------------------------------------- */

/**
 * Create a new EVM handle.
 *
 * @param hardfork_name Optional UTF-8 fork name (e.g. "osaka", "prague",
 *                      "amsterdam"). NULL with `hardfork_len == 0` selects the
 *                      default configured hardfork.
 * @param hardfork_len  Byte length of `hardfork_name`.
 * @param log_level     Log verbosity (`0..4`, see `enum evm_log_level`).
 * @return Handle pointer, or NULL on invalid fork/log_level or OOM.
 */
evm_handle_t *evm_create(
    const char *hardfork_name,
    size_t hardfork_len,
    uint8_t log_level
);

/** Destroy an EVM handle and free all owned state. NULL is a no-op. */
void evm_destroy(evm_handle_t *handle);

/** Enable or disable WASM JS opcode callback dispatch (no-op on native). */
void evm_set_js_opcode_callbacks_enabled(bool enabled);

/* -------------------------------------------------------------------------- */
/* Execution & blockchain context configuration                               */
/* -------------------------------------------------------------------------- */

/** Set transient call bytecode (used when target has no installed code). */
bool evm_set_bytecode(
    evm_handle_t *handle,
    const uint8_t *bytecode,
    size_t bytecode_len
);

/**
 * Set message execution context.
 *
 * @param gas           Execution gas limit (must be >= 0).
 * @param caller_bytes  20-byte caller address.
 * @param address_bytes 20-byte target address.
 * @param value_bytes   32-byte big-endian call value in wei.
 * @param calldata      Calldata bytes (may be NULL when `calldata_len == 0`).
 * @param calldata_len  Byte length of `calldata`.
 */
bool evm_set_execution_context(
    evm_handle_t *handle,
    int64_t gas,
    const uint8_t *caller_bytes,
    const uint8_t *address_bytes,
    const uint8_t *value_bytes,
    const uint8_t *calldata,
    size_t calldata_len
);

/** Override `ORIGIN` (20 bytes); persists across calls. */
bool evm_set_origin(evm_handle_t *handle, const uint8_t *origin_bytes);

/** Override `GASPRICE` (32-byte big-endian); persists across calls. */
bool evm_set_gas_price(evm_handle_t *handle, const uint8_t *gas_price_bytes);

/**
 * Set block environment context.
 *
 * All byte-pointer parameters are required (32-byte big-endian words except
 * `block_coinbase_bytes` which is 20 bytes).
 */
bool evm_set_blockchain_context(
    evm_handle_t *handle,
    const uint8_t *chain_id_bytes,
    uint64_t block_number,
    uint64_t block_timestamp,
    const uint8_t *block_difficulty_bytes,
    const uint8_t *block_prevrandao_bytes,
    const uint8_t *block_coinbase_bytes,
    uint64_t block_gas_limit,
    const uint8_t *block_base_fee_bytes,
    const uint8_t *blob_base_fee_bytes
);

/** Set EIP-2930 access-list addresses (packed `count * 20` bytes). */
bool evm_set_access_list_addresses(
    evm_handle_t *handle,
    const uint8_t *addresses,
    size_t count
);

/**
 * Set EIP-2930 access-list storage keys.
 * `addresses` holds `count * 20` bytes and `slots` holds `count * 32` bytes.
 */
bool evm_set_access_list_storage_keys(
    evm_handle_t *handle,
    const uint8_t *addresses,
    const uint8_t *slots,
    size_t count
);

/** Set EIP-4844 blob versioned hashes (packed `count * 32` bytes). */
bool evm_set_blob_hashes(
    evm_handle_t *handle,
    const uint8_t *hashes,
    size_t count
);

/* -------------------------------------------------------------------------- */
/* Account & storage state accessors                                          */
/* -------------------------------------------------------------------------- */

/** Set storage slot (`address`: 20B, `slot`: 32B BE, `value`: 32B BE). */
bool evm_set_storage(
    evm_handle_t *handle,
    const uint8_t *address_bytes,
    const uint8_t *slot_bytes,
    const uint8_t *value_bytes
);

/** Read storage slot (`address`: 20B, `slot`: 32B BE, `value_out`: 32B BE). */
bool evm_get_storage(
    evm_handle_t *handle,
    const uint8_t *address_bytes,
    const uint8_t *slot_bytes,
    uint8_t *value_bytes
);

/** Set account balance (`address`: 20B, `balance`: 32B BE). */
bool evm_set_balance(
    evm_handle_t *handle,
    const uint8_t *address_bytes,
    const uint8_t *balance_bytes
);

/** Install persistent account code at `address` (20B). */
bool evm_set_code(
    evm_handle_t *handle,
    const uint8_t *address_bytes,
    const uint8_t *code,
    size_t code_len
);

/** Set account nonce (`address`: 20B). */
bool evm_set_nonce(
    evm_handle_t *handle,
    const uint8_t *address_bytes,
    uint64_t nonce
);

/* -------------------------------------------------------------------------- */
/* Synchronous execution & result introspection                               */
/* -------------------------------------------------------------------------- */

/** Execute the configured call synchronously; returns true on success. */
bool evm_execute(evm_handle_t *handle);

/** Return remaining gas after the last call. */
int64_t evm_get_gas_remaining(evm_handle_t *handle);

/** Return gas consumed by the last call. */
int64_t evm_get_gas_used(evm_handle_t *handle);

/** Return true if the last call succeeded. */
bool evm_is_success(evm_handle_t *handle);

/** Return byte length of the last call's return or revert data. */
size_t evm_get_output_len(evm_handle_t *handle);

/** Copy return/revert data into `buffer`; returns bytes copied. */
size_t evm_get_output(
    evm_handle_t *handle,
    uint8_t *buffer,
    size_t buffer_len
);

/** Return number of logs emitted by the last call. */
size_t evm_get_log_count(evm_handle_t *handle);

/**
 * Read log entry `index`.
 * `address_out` needs 20 bytes; `topics_out` needs `4 * 32 = 128` bytes.
 */
bool evm_get_log(
    evm_handle_t *handle,
    size_t index,
    uint8_t *address_out,
    size_t *topics_count_out,
    uint8_t *topics_out,
    size_t *data_len_out,
    uint8_t *data_out,
    size_t data_max_len
);

/** Return effective gas refund counter from the last execution. */
uint64_t evm_get_gas_refund(evm_handle_t *handle);

/** Return number of storage slots written by the last transaction. */
size_t evm_get_storage_change_count(evm_handle_t *handle);

/** Read written storage slot `index` (`address`: 20B, `slot`: 32B, `value`: 32B). */
bool evm_get_storage_change(
    evm_handle_t *handle,
    size_t index,
    uint8_t *address_out,
    uint8_t *slot_out,
    uint8_t *value_out
);

/* -------------------------------------------------------------------------- */
/* Async lazy state-injection protocol                                        */
/* -------------------------------------------------------------------------- */

/** Enable lazy storage/account state injection on `handle` (idempotent). */
bool evm_enable_storage_injector(evm_handle_t *handle);

/** Start an async call; populates `request_out` with result or next data need. */
bool evm_call_ffi(evm_handle_t *handle, evm_async_request_t *request_out);

/**
 * Resume a suspended async call.
 *
 * Payload formats for `data_ptr[0..data_len]`:
 * - `EVM_CONTINUE_STORAGE`      (1): `address(20) || slot(32) || value(32)` (84B)
 * - `EVM_CONTINUE_BALANCE`      (2): `address(20) || balance(32)` (52B)
 * - `EVM_CONTINUE_CODE`         (3): `address(20) || bytecode(N)` (>=20B)
 * - `EVM_CONTINUE_NONCE`        (4): `address(20) || nonce(8, BE)` (28B)
 * - `EVM_CONTINUE_AFTER_COMMIT` (5): empty (0B)
 */
bool evm_continue_ffi(
    evm_handle_t *handle,
    uint8_t continue_type,
    const uint8_t *data_ptr,
    size_t data_len,
    evm_async_request_t *request_out
);

/** Return full byte length of pending state-changes JSON (when ready_to_commit). */
size_t evm_get_state_changes_len(evm_handle_t *handle);

/**
 * Copy full pending state-changes JSON (all-or-nothing).
 * Always returns the full length; copies iff `buffer != NULL && buffer_len >= full_len`.
 */
size_t evm_get_state_changes(
    evm_handle_t *handle,
    uint8_t *buffer,
    size_t buffer_len
);

/* -------------------------------------------------------------------------- */
/* Tracing, call trees, access lists, flamegraphs & revert decoding           */
/* -------------------------------------------------------------------------- */

/** Enable EIP-3155 JSONL opcode tracing for subsequent calls. */
void evm_enable_tracing(
    evm_handle_t *handle,
    bool enable_memory,
    bool disable_stack,
    bool disable_storage,
    bool enable_return_data
);

/** Disable EIP-3155 opcode tracing. */
void evm_disable_tracing(evm_handle_t *handle);

/** Return byte length of the last call's EIP-3155 JSONL trace. */
size_t evm_get_trace_json_len(evm_handle_t *handle);

/** Copy EIP-3155 JSONL trace into `buffer`; returns bytes copied. */
size_t evm_get_trace_json(
    evm_handle_t *handle,
    uint8_t *buffer,
    size_t buffer_len
);

/** Enable Geth-compatible `callTracer` for subsequent calls. */
void evm_enable_call_tracer(
    evm_handle_t *handle,
    bool only_top_call,
    bool with_log
);

/** Return byte length of the last call's `callTracer` JSON. */
size_t evm_get_call_trace_json_len(evm_handle_t *handle);

/** Copy `callTracer` JSON into `buffer`; returns bytes copied. */
size_t evm_get_call_trace_json(
    evm_handle_t *handle,
    uint8_t *buffer,
    size_t buffer_len
);

/** Enable EIP-2930 access-list tracking (`eth_createAccessList`) for subsequent calls. */
void evm_enable_access_list_tracker(evm_handle_t *handle);

/** Return byte length of the last call's access-list JSON. */
size_t evm_get_access_list_json_len(evm_handle_t *handle);

/** Copy access-list JSON into `buffer`; returns bytes copied. */
size_t evm_get_access_list_json(
    evm_handle_t *handle,
    uint8_t *buffer,
    size_t buffer_len
);

/** Enable SVG / folded-stack gas flamegraph profiling for subsequent calls. */
bool evm_enable_flamegraph(evm_handle_t *handle, bool compact_addresses);

/** Return byte length of the last call's flamegraph SVG document. */
size_t evm_get_flamegraph_svg_len(evm_handle_t *handle);

/** Copy flamegraph SVG into `buffer`; returns bytes copied. */
size_t evm_get_flamegraph_svg(
    evm_handle_t *handle,
    uint8_t *buffer,
    size_t buffer_len
);

/** Return byte length of the last call's folded-stack flamegraph text. */
size_t evm_get_flamegraph_folded_len(evm_handle_t *handle);

/** Copy folded-stack flamegraph text into `buffer`; returns bytes copied. */
size_t evm_get_flamegraph_folded(
    evm_handle_t *handle,
    uint8_t *buffer,
    size_t buffer_len
);

/** Return byte length of the decoded revert reason JSON for the last call. */
size_t evm_decode_revert_json_len(evm_handle_t *handle);

/** Copy decoded revert JSON into `buffer`; returns bytes copied. */
size_t evm_decode_revert_json(
    evm_handle_t *handle,
    uint8_t *buffer,
    size_t buffer_len
);

/* -------------------------------------------------------------------------- */
/* EVMC ABI 12 shared library entry point                                     */
/* -------------------------------------------------------------------------- */

/** Forward declaration of EVMC's `struct evmc_vm` (`<evmc/evmc.h>`). */
struct evmc_vm;

/**
 * Create a Guillotine Mini EVMC ABI 12 VM instance.
 *
 * Call `vm->destroy(vm)` when finished. Compatible with EVMC v11/v12 hosts
 * (such as `evmc run`, Reth, Erigon, Silkworm, and Besu EVMC loaders).
 */
struct evmc_vm *evmc_create_guillotine_mini(void);

#ifdef __cplusplus
}
#endif

#endif /* GUILLOTINE_MINI_H */
