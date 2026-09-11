#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEMP_DIR="/tmp/test_migration_agents_$$"

echo "=== Running Installer Test Suite ==="
echo "Working directory: ${REPO_ROOT}"
echo "Test sandbox     : ${TEMP_DIR}"

mkdir -p "${TEMP_DIR}"

cleanup() {
    rm -rf "${TEMP_DIR}"
    echo "✓ Sandbox cleaned up."
}
trap cleanup EXIT

# 1. Test --list
echo "\nTest 1: install.py --list"
python3 "${REPO_ROOT}/install.py" --list

# 2. Test installing specific agent (copy)
echo "\nTest 2: Install agent (copy mode)"
python3 "${REPO_ROOT}/install.py" --agent mac-to-flutter --target-dir "${TEMP_DIR}/workspace"
[ -f "${TEMP_DIR}/workspace/agents/mac-to-flutter.md" ]
echo "✓ mac-to-flutter.md installed successfully"

# 3. Test installing specific skill (copy)
echo "\nTest 3: Install skill (copy mode)"
python3 "${REPO_ROOT}/install.py" --skill swift-to-electron --target-dir "${TEMP_DIR}/workspace"
[ -f "${TEMP_DIR}/workspace/skills/swift-to-electron/SKILL.md" ]
echo "✓ swift-to-electron skill installed successfully"

# 4. Test installing plugin (copy)
echo "\nTest 4: Install plugin"
python3 "${REPO_ROOT}/install.py" --plugin mac-to-maui --target-dir "${TEMP_DIR}/workspace"
[ -f "${TEMP_DIR}/workspace/plugins/mac-to-maui/plugin.json" ]
[ -f "${TEMP_DIR}/workspace/plugins/mac-to-maui/agents/mac-to-maui.md" ]
echo "✓ mac-to-maui plugin installed successfully"

# 5. Test installing all (symlink mode)
echo "\nTest 5: Install all with --link"
python3 "${REPO_ROOT}/install.py" --all --link --target-dir "${TEMP_DIR}/symlink_env"
[ -L "${TEMP_DIR}/symlink_env/agents/mac-to-flutter.md" ]
[ -L "${TEMP_DIR}/symlink_env/skills/swift-to-electron" ]
[ -L "${TEMP_DIR}/symlink_env/plugins/mac-to-maui" ]
echo "✓ --all with --link created valid symlinks"

echo "\n=== ALL INSTALLER TESTS PASSED ==="
