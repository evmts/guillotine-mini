#!/bin/sh
set -eu

# The hosted image provides Node and Python. Keep this audit's exact tools in its disposable job.
tools=$(mktemp -d)
trap 'rm -rf "$tools"' EXIT
python3 -m pip install --disable-pip-version-check --no-cache-dir --no-deps --only-binary=:all: --target "$tools" ziglang==0.15.2
export PATH="$tools/ziglang:$PATH"
npm exec --yes --package=bun@1.4.2 --package=uphill@0.0.11 -- sh -ec '
  uphill check
  uphill --compact
  test -s .uphill/report.json
  bun .smithers/scripts/generate-audit-report.ts --skip-uphill --untrusted --verify
'
