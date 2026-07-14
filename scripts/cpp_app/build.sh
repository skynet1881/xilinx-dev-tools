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

if [[ $# -ne 1 ]]; then
    echo "Usage: $(basename "$0") <workspace>"
    exit 1
fi

SCRIPT_DIR="$(
    cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
    pwd
)"

WORKSPACE="$(realpath "$1")"
SETTINGS_SCRIPT="${VITIS_HOME}/settings64.sh"
XSCT="${VITIS_HOME}/bin/xsct"

if [[ ! -d "$WORKSPACE" ]]; then
    echo "ERROR: Workspace does not exist: $WORKSPACE" >&2
    echo "Run setup.sh first." >&2
    exit 2
fi

if [[ ! -f "$SETTINGS_SCRIPT" ]]; then
    echo "ERROR: Vitis settings script does not exist: $SETTINGS_SCRIPT" >&2
    echo "Set VITIS_HOME to your Vitis installation directory." >&2
    exit 3
fi

if [[ ! -x "$XSCT" ]]; then
    echo "ERROR: XSCT executable does not exist: $XSCT" >&2
    echo "Set VITIS_HOME to your Vitis installation directory." >&2
    exit 4
fi

set +u
source "$SETTINGS_SCRIPT"
set -u

"$XSCT" -quiet \
    "${SCRIPT_DIR}/build.tcl" \
    "$WORKSPACE"
