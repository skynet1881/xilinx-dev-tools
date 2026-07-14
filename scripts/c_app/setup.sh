#!/usr/bin/env bash

set -Eeuo pipefail

VITIS_HOME="${VITIS_HOME:-/opt/Xilinx/Vitis/2023.2}"

if [[ $# -ne 4 ]]; then
    echo "Usage: $(basename "$0") <xsa> <workspace> <source-dir> <include-dir>"
    exit 1
fi

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
    pwd
)"

XSA="$(realpath "$1")"
WORKSPACE="$(realpath -m "$2")"
SOURCE_DIR="$(realpath "$3")"
INCLUDE_DIR="$(realpath "$4")"

if [[ ! -f "$XSA" ]]; then
    echo "ERROR: XSA file does not exist: $XSA" >&2
    exit 2
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: Source directory does not exist: $SOURCE_DIR" >&2
    exit 3
fi

if [[ ! -d "$INCLUDE_DIR" ]]; then
    echo "ERROR: Include directory does not exist: $INCLUDE_DIR" >&2
    exit 4
fi

set +u
source "${VITIS_HOME}/settings64.sh"
set -u

"${VITIS_HOME}/bin/xsct" -quiet \
    "${SCRIPT_DIR}/setup.tcl" \
    "$XSA" \
    "$WORKSPACE" \
    "$SOURCE_DIR" \
    "$INCLUDE_DIR"