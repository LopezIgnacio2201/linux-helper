#!/bin/bash

# Test the main script flow step by step
set -euo pipefail

# Set up required variables (same as main script)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_DIR="${SCRIPT_DIR}/core"
MODULES_DIR="${SCRIPT_DIR}/modules"
CONFIGS_DIR="${SCRIPT_DIR}/configs"
LOGS_DIR="${SCRIPT_DIR}/logs"

# Global variables
LANGUAGE="en"
USER_TYPE=""
SELECTED_MODULES=()
PACKAGE_MANAGER="paru"
NO_SUDO_ASK=false

# Create directories
mkdir -p "$LOGS_DIR"

# Source core functions
source "${CORE_DIR}/logging.sh"
source "${CORE_DIR}/system_checks.sh"
source "${CORE_DIR}/language.sh"
source "${CORE_DIR}/module_manager.sh"
source "${CORE_DIR}/user_selection.sh"

echo "=== Testing main script flow ==="

echo "1. Initializing logging..."
init_logging

echo "2. Running system checks..."
check_system_requirements

echo "3. Testing language selection (simulating English)..."
LANGUAGE="English"
echo "Language set to: $LANGUAGE"

echo "4. Testing user type selection (simulating poweruser)..."
USER_TYPE="poweruser"
echo "User type set to: $USER_TYPE"

echo "5. Testing poweruser module selection..."
select_poweruser_modules

echo "All main flow tests passed!"
