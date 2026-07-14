#!/usr/bin/env bash

set -Eeuo pipefail

VITIS_VERSION="${VITIS_VERSION:-2023.2}"

if [[ -z "${VITIS_HOME:-}" ]]; then
    if [[ -d "${HOME}/Xilinx/Vitis/${VITIS_VERSION}" ]]; then
        VITIS_HOME="${HOME}/Xilinx/Vitis/${VITIS_VERSION}"
    else
        VITIS_HOME="/opt/Xilinx/Vitis/${VITIS_VERSION}"
    fi
fi

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
SETTINGS_SCRIPT="${VITIS_HOME}/settings64.sh"
XSCT="${VITIS_HOME}/bin/xsct"

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

if [[ ! -f "${SOURCE_DIR}/main.cpp" ]]; then
    echo "ERROR: C++ entry point does not exist: ${SOURCE_DIR}/main.cpp" >&2
    exit 5
fi

if [[ ! -f "$SETTINGS_SCRIPT" ]]; then
    echo "ERROR: Vitis settings script does not exist: $SETTINGS_SCRIPT" >&2
    echo "Set VITIS_HOME to your Vitis installation directory." >&2
    exit 6
fi

if [[ ! -x "$XSCT" ]]; then
    echo "ERROR: XSCT executable does not exist: $XSCT" >&2
    echo "Set VITIS_HOME to your Vitis installation directory." >&2
    exit 7
fi

set +u
source "$SETTINGS_SCRIPT"
set -u

"$XSCT" -quiet \
    "${SCRIPT_DIR}/setup.tcl" \
    "$XSA" \
    "$WORKSPACE" \
    "$SOURCE_DIR" \
    "$INCLUDE_DIR"
