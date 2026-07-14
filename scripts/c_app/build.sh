#!/usr/bin/env bash

set -Eeuo pipefail

source ~/Xilinx/Vitis/2023.2/settings64.sh

if [[ "$#" -ne 1 ]]; then
    echo "Usage: $(basename "$0") <workspace>"
    exit 1
fi

workspace="$(realpath "$1")"

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
)"

if [[ ! -d "$workspace" ]]; then
    echo "ERROR: Workspace does not exist: $workspace"
    echo "Run setup.sh first."
    exit 2
fi

xsct -quiet \
    "$SCRIPT_DIR/build.tcl" \
    "$workspace"