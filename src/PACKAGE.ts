import { Smithers as S } from "@smthrs/targets"
import { Package as instructionsSrcsPkg } from "./instructions/PACKAGE.ts"
const instructionsSrcs = instructionsSrcsPkg.srcs
import { Package as precompilesSrcsPkg } from "./precompiles/PACKAGE.ts"
const precompilesSrcs = precompilesSrcsPkg.srcs

/**
 * Fine-grained Filegroups inside `src/` so incremental `affected` runs only
 * re-run benchmarks whose exact upstream source files changed.
 */
const bytecode_srcs = S.Filegroup({
  srcs: [S.file("bytecode.zig"), S.file("bench_bytecode.zig")],
})

const storage_srcs = S.Filegroup({
  srcs: [
    S.file("storage.zig"),
    S.file("access_list_manager.zig"),
    S.file("storage_injector.zig"),
    S.file("bench_storage.zig"),
  ],
})

const frame_srcs = S.Filegroup({
  srcs: [
    S.file("frame.zig"),
    S.file("opcode.zig"),
    S.file("errors.zig"),
    S.file("evm_config.zig"),
    S.file("logger.zig"),
    S.file("trace.zig"),
    S.file("inspector.zig"),
    S.file("bench_frame.zig"),
    bytecode_srcs,
    storage_srcs,
    instructionsSrcs,
    precompilesSrcs,
  ],
})

const evm_srcs = S.Filegroup({
  srcs: [
    S.file("evm.zig"),
    S.file("evm_test.zig"),
    S.file("root.zig"),
    S.file("host.zig"),
    S.file("call_params.zig"),
    S.file("call_result.zig"),
    S.file("async_executor.zig"),
    S.file("debugger.zig"),
    S.file("devtools_test.zig"),
    S.file("evmc_adapter.zig"),
    S.file("flamegraph.zig"),
    S.file("live_tracer.zig"),
    S.file("live_tracer_test.zig"),
    S.file("oom_safety_test.zig"),
    S.file("simulation.zig"),
    S.file("trace_store.zig"),
    S.file("tracers.zig"),
    S.file("tracers_test.zig"),
    S.file("bench_opcodes.zig"),
    S.file("bench_evm.zig"),
    frame_srcs,
  ],
})

const ffi_srcs = S.Filegroup({
  srcs: [
    S.file("root_c.zig"),
    S.file("bench_ffi.zig"),
    evm_srcs,
  ],
})

const docs_srcs = S.Filegroup({
  srcs: [...S.glob(["*.md"])],
})

export const Package = S.Package({
  targets: {
    bytecode_srcs,
    storage_srcs,
    frame_srcs,
    evm_srcs,
    ffi_srcs,
    docs_srcs,
  },
})
