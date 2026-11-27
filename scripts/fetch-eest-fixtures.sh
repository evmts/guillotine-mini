#!/usr/bin/env bash
set -euo pipefail

# Idempotent downloader for official Ethereum Execution Spec Tests (EEST).
# Downloads ethereum/execution-specs release tests@v21.0.3 fixtures.tar.gz,
# verifies its SHA-256 digest, and extracts fixtures/state_tests (plus optional
# fixtures/blockchain_tests) into .cache/eest-fixtures/tests_v21.0.3 with a
# `current` symlink and `STAMP` file.

TAG="${EEST_TAG:-tests@v21.0.3}"
ASSET="fixtures.tar.gz"
EXPECTED_SHA256="${EEST_SHA256:-46bd48fb71a23da084218fe856fe442ab0c8d00c85c1c1aead0d2a965804fd24}"
URL="${EEST_URL:-https://github.com/ethereum/execution-specs/releases/download/${TAG}/${ASSET}}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CACHE_ROOT="${EEST_CACHE_DIR:-${REPO_ROOT}/.cache/eest-fixtures}"
SAFE_TAG="${TAG//@/_}"
SAFE_TAG="${SAFE_TAG//\//_}"
TARGET_DIR="${CACHE_ROOT}/${SAFE_TAG}"
STAMP_FILE="${TARGET_DIR}/STAMP"
CURRENT_LINK="${CACHE_ROOT}/current"

FORCE=0
PRINT_DIR=0
WITH_BLOCKCHAIN="${EEST_INCLUDE_BLOCKCHAIN:-0}"

usage() {
    cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Idempotently download and extract official EEST fixtures (${TAG}).

Options:
  --print-dir         Print the target fixture directory path and exit
  --force             Re-download and re-extract even if STAMP matches
  --with-blockchain   Also extract fixtures/blockchain_tests
  -h, --help          Show this help message

Environment:
  EEST_CACHE_DIR           Override cache directory (default: .cache/eest-fixtures)
  EEST_TAG                 Override release tag (default: ${TAG})
  EEST_SHA256              Override expected SHA-256 (default: ${EXPECTED_SHA256})
  EEST_URL                 Override download URL
  EEST_INCLUDE_BLOCKCHAIN  Set to 1 to also extract fixtures/blockchain_tests
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --print-dir)
            PRINT_DIR=1
            shift
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --with-blockchain|--blockchain)
            WITH_BLOCKCHAIN=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "error: unknown argument: $1" >&2
            usage >&2
            exit 2
            ;;
    esac
done

if [[ "${PRINT_DIR}" -eq 1 ]]; then
    printf '%s\n' "${TARGET_DIR}"
    exit 0
fi

sha256_file() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$1" | awk '{print $1}'
    else
        echo "error: neither sha256sum nor shasum is installed" >&2
        exit 1
    fi
}

expected_stamp() {
    printf 'tag=%s\nasset=%s\nsha256=%s\n' "${TAG}" "${ASSET}" "${EXPECTED_SHA256}"
}

stamp_matches() {
    [[ -f "${STAMP_FILE}" ]] || return 1
    [[ -d "${TARGET_DIR}/fixtures/state_tests" ]] || return 1
    if [[ "${WITH_BLOCKCHAIN}" -eq 1 ]] && [[ ! -d "${TARGET_DIR}/fixtures/blockchain_tests" ]]; then
        return 1
    fi
    local actual
    actual="$(cat "${STAMP_FILE}")"
    local expected
    expected="$(expected_stamp)"
    [[ "${actual}" == "${expected}" ]]
}

mkdir -p "${CACHE_ROOT}"

if [[ "${FORCE}" -eq 0 ]] && stamp_matches; then
    ln -sfn "${SAFE_TAG}" "${CURRENT_LINK}"
    echo "eest fixtures already up to date: ${TARGET_DIR}" >&2
    printf '%s\n' "${TARGET_DIR}"
    exit 0
fi

TMP_DIR="$(mktemp -d "${CACHE_ROOT}/.tmp.${SAFE_TAG}.XXXXXX")"
cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

ARCHIVE="${TMP_DIR}/${ASSET}"
echo "downloading ${URL}..." >&2
if command -v curl >/dev/null 2>&1; then
    curl -fL --retry 3 --retry-delay 2 -o "${ARCHIVE}" "${URL}"
elif command -v wget >/dev/null 2>&1; then
    wget -O "${ARCHIVE}" "${URL}"
else
    echo "error: neither curl nor wget is installed" >&2
    exit 1
fi

ACTUAL_SHA256="$(sha256_file "${ARCHIVE}")"
if [[ "${ACTUAL_SHA256}" != "${EXPECTED_SHA256}" ]]; then
    echo "error: SHA-256 mismatch for ${ASSET}" >&2
    echo "  expected: ${EXPECTED_SHA256}" >&2
    echo "  actual:   ${ACTUAL_SHA256}" >&2
    exit 1
fi
echo "verified sha256=${ACTUAL_SHA256}" >&2

STAGE_DIR="${TMP_DIR}/stage"
mkdir -p "${STAGE_DIR}"

EXTRACT_PATHS=("fixtures/state_tests")
if [[ "${WITH_BLOCKCHAIN}" -eq 1 ]]; then
    EXTRACT_PATHS+=("fixtures/blockchain_tests")
fi

echo "extracting ${EXTRACT_PATHS[*]} into ${TARGET_DIR}..." >&2
tar -xzf "${ARCHIVE}" -C "${STAGE_DIR}" "${EXTRACT_PATHS[@]}"

expected_stamp > "${STAGE_DIR}/STAMP"

rm -rf "${TARGET_DIR}"
mv "${STAGE_DIR}" "${TARGET_DIR}"
ln -sfn "${SAFE_TAG}" "${CURRENT_LINK}"

echo "extracted EEST ${TAG} fixtures to ${TARGET_DIR}" >&2
printf '%s\n' "${TARGET_DIR}"
