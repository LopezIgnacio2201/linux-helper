#!/bin/bash

# Debug module scanning
set -euo pipefail

# Set up required variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="${SCRIPT_DIR}/core"
MODULES_DIR="${SCRIPT_DIR}/modules"
LOGS_DIR="${SCRIPT_DIR}/logs"
NO_SUDO_ASK=false

# Create directories
mkdir -p "$LOGS_DIR"

# Source core functions
source "${CORE_DIR}/logging.sh"
source "${CORE_DIR}/module_manager.sh"

# Initialize logging
init_logging

echo "=== Debug Module Scanning ==="

echo "MODULES_DIR: $MODULES_DIR"
echo "Files in modules directory:"
ls -la "$MODULES_DIR"

echo ""
echo "Testing module scanning logic:"

# Get available modules
available_modules=()
echo "Scanning modules directory: ${MODULES_DIR}"

for module_file in "${MODULES_DIR}"/*.sh; do
    if [[ -f "$module_file" ]]; then
        module_name=$(basename "$module_file" .sh)
        echo "Found module: $module_name"
        module_title=$(get_module_title "$module_name")
        echo "Module title: $module_title"
        available_modules+=("$module_name" "$module_title")
    fi
done

echo ""
echo "Total modules found: ${#available_modules[@]}"
echo "Available modules array:"
printf '%s\n' "${available_modules[@]}"

echo ""
echo "Testing dialog command (this will show the dialog):"
echo "Press Ctrl+C to cancel if it hangs"

# Test dialog command
SELECTED_MODULES=($(dialog --clear \
    --backtitle "Linux Helper - Module Selection" \
    --title "Select modules to install:" \
    --checklist "Select modules to install:" 20 60 10 \
    "${available_modules[@]}" \
    2>&1 >/dev/tty))

echo "Dialog exit code: $?"
echo "Selected modules: ${SELECTED_MODULES[*]}"
