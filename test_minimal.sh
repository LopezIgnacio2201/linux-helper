#!/bin/bash

# Minimal test script
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
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
LOG_FILE=""
NO_SUDO_ASK=false

# Create necessary directories
mkdir -p "${LOGS_DIR}"

# Source core functions
source "${CORE_DIR}/system_checks.sh"
source "${CORE_DIR}/language.sh"
source "${CORE_DIR}/user_selection.sh"
source "${CORE_DIR}/module_manager.sh"
source "${CORE_DIR}/logging.sh"
source "${CORE_DIR}/package_manager.sh"

echo "Testing minimal script..."

# Initialize logging
init_logging

echo "Logging initialized"

# System checks
log_info "Performing system checks..."
check_system_requirements

echo "System checks completed"

log_info "System checks completed, proceeding to language selection..."

echo "About to call select_language..."

# Language selection
select_language

echo "Language selection completed"

echo "Test completed successfully"
