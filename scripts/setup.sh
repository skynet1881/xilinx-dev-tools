#!/usr/bin/env bash

set -Eeuo pipefail

source ~/Xilinx/Vitis/2023.2/settings64.sh

script="$(basename "$0")"

if [[ "$#" -ne 2 ]]; then
    echo "Usage: $script <xsa> <workspace>"
    exit 1
fi

xsa="$(realpath "$1")"
ws="$(realpath -m "$2")"

SCRIPT_DIR="$(
    cd "$(dirname "${BASH_SOURCE[0]}")"
    pwd
)"

if [[ ! -f "$xsa" ]]; then
    echo "ERROR: XSA does not exist: $xsa"
    exit 2
fi

mkdir -p "$ws"

echo "XSA:       $xsa"
echo "Workspace: $ws"

xsct -quiet \
    "$SCRIPT_DIR/setup.tcl" \
    "$xsa" \
    "$ws"