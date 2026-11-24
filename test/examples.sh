#!/bin/sh
# Run the documented build targets, then exercise the CLI with a known trace.
set -eu
zig build run-simple-call run-access-list run-call-types run-direct-frame \
    run-nested-calls run-precompiles run-tracing run-transient-storage \
    run-hardfork-features run-host-interface

trace=$(mktemp)
trap 'rm -f "$trace"' EXIT
zig build run-example -- tracing > "$trace"
diff -u examples/tracing/trace-output.jsonl "$trace"
