#!/usr/bin/env bash
#
# install.sh - Shell entrypoint for macOS Migration Agents & Skills installer
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if command -v python3 >/dev/null 2>&1; then
    exec python3 "${SCRIPT_DIR}/install.py" "$@"
else
    echo "Error: python3 is required to run the installer." >&2
    exit 1
fi
