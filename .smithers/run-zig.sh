#!/bin/sh
# Run zig under a machine-wide lock. Voltaire's blst step runs ./build.sh in
# its shared source tree on every build, so concurrent `zig build` processes
# (parallel smthrs targets, or two checkouts sharing ../voltaire) delete each
# other's objects. Drop this wrapper once Voltaire stops building blst in-tree.
set -eu

lock="${TMPDIR:-/tmp}/guillotine-mini-zig.lock"
while ! mkdir "$lock" 2>/dev/null; do
  holder=$(cat "$lock/pid" 2>/dev/null || true)
  if [ -n "$holder" ] && ! kill -0 "$holder" 2>/dev/null; then
    rm -rf "$lock"
    continue
  fi
  sleep 1
done
echo $$ > "$lock/pid"
trap 'rm -rf "$lock"' EXIT
trap 'exit 130' INT TERM

zig "$@"
