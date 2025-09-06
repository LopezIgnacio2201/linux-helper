#!/bin/bash

# Logging functions

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Initialize logging
init_logging() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    LOG_FILE="${LOGS_DIR}/linux-helper_${timestamp}.log"
    
    # Create log file
    touch "$LOG_FILE"
    
    log_info "Logging initialized: $LOG_FILE"
}

# Log info message
log_info() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${BLUE}[INFO]${NC} $message"
    echo "[$timestamp] [INFO] $message" >> "$LOG_FILE"
}

# Log success message
log_success() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${GREEN}[SUCCESS]${NC} $message"
    echo "[$timestamp] [SUCCESS] $message" >> "$LOG_FILE"
}

# Log warning message
log_warning() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${YELLOW}[WARNING]${NC} $message"
    echo "[$timestamp] [WARNING] $message" >> "$LOG_FILE"
}

# Log error message
log_error() {
    local message="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${RED}[ERROR]${NC} $message"
    echo "[$timestamp] [ERROR] $message" >> "$LOG_FILE"
}

# Log debug message (only if debug mode is enabled)
log_debug() {
    local message="$1"
    if [[ "${DEBUG:-false}" == "true" ]]; then
        local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
        echo -e "${PURPLE}[DEBUG]${NC} $message"
        echo "[$timestamp] [DEBUG] $message" >> "$LOG_FILE"
    fi
}

# Log command execution
log_command() {
    local command="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [COMMAND] $command" >> "$LOG_FILE"
}

# Log package installation
log_package_install() {
    local package="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [PACKAGE] Installing: $package" >> "$LOG_FILE"
}

# Log configuration change
log_config() {
    local config="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [CONFIG] $config" >> "$LOG_FILE"
}

