#!/bin/bash

# Logging System
# This module provides structured logging functionality for the Linux Helper Script

# =============================================================================
# LOGGING CONFIGURATION
# =============================================================================

# Log levels (from config.sh)
readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3

# Default log level
LOG_LEVEL="${LOG_LEVEL:-$LOG_LEVEL_INFO}"

# =============================================================================
# LOGGING FUNCTIONS
# =============================================================================

# Get current timestamp
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# Get log level name
get_log_level_name() {
    local level="$1"
    case "$level" in
        $LOG_LEVEL_DEBUG) echo "DEBUG" ;;
        $LOG_LEVEL_INFO)  echo "INFO"  ;;
        $LOG_LEVEL_WARN)  echo "WARN"  ;;
        $LOG_LEVEL_ERROR) echo "ERROR" ;;
        *) echo "UNKNOWN" ;;
    esac
}

# Get log level color
get_log_level_color() {
    local level="$1"
    case "$level" in
        $LOG_LEVEL_DEBUG) echo "$COLOR_GRAY" ;;
        $LOG_LEVEL_INFO)  echo "$COLOR_WHITE" ;;
        $LOG_LEVEL_WARN)  echo "$COLOR_YELLOW" ;;
        $LOG_LEVEL_ERROR) echo "$COLOR_RED" ;;
        *) echo "$COLOR_RESET" ;;
    esac
}

# Core logging function
log_message() {
    local level="$1"
    local message="$2"
    local timestamp
    local level_name
    local level_color
    
    # Check if we should log this level
    if [[ $level -lt $LOG_LEVEL ]]; then
        return 0
    fi
    
    timestamp=$(get_timestamp)
    level_name=$(get_log_level_name "$level")
    level_color=$(get_log_level_color "$level")
    
    # Format: [TIMESTAMP] [LEVEL] MESSAGE
    local log_entry="[$timestamp] [$level_name] $message"
    
    # Print to console with colors (to stderr to avoid interfering with command substitution)
    echo -e "${level_color}${log_entry}${COLOR_RESET}" >&2
    
    # Write to log file (if LOG_FILE is set)
    if [[ -n "${LOG_FILE:-}" ]]; then
        # Create log directory if it doesn't exist
        mkdir -p "$(dirname "$LOG_FILE")"
        echo "$log_entry" >> "$LOG_FILE"
    fi
}

# Debug logging
log_debug() {
    log_message $LOG_LEVEL_DEBUG "$*"
}

# Info logging
log_info() {
    log_message $LOG_LEVEL_INFO "$*"
}

# Warning logging
log_warn() {
    log_message $LOG_LEVEL_WARN "$*"
}

# Error logging
log_error() {
    log_message $LOG_LEVEL_ERROR "$*"
}

# =============================================================================
# SPECIALIZED LOGGING FUNCTIONS
# =============================================================================

# Log function entry
log_function_entry() {
    local function_name="$1"
    log_debug "Entering function: $function_name"
}

# Log function exit
log_function_exit() {
    local function_name="$1"
    local exit_code="${2:-0}"
    if [[ $exit_code -eq 0 ]]; then
        log_debug "Exiting function: $function_name (success)"
    else
        log_debug "Exiting function: $function_name (error code: $exit_code)"
    fi
}

# Log package operation
log_package_operation() {
    local operation="$1"
    local package="$2"
    local status="$3"
    log_info "Package $operation: $package - $status"
}

# Log user action
log_user_action() {
    local action="$1"
    local details="$2"
    log_info "User action: $action - $details"
}

# Log system event
log_system_event() {
    local event="$1"
    local details="$2"
    log_info "System event: $event - $details"
}

# =============================================================================
# LOGGING CONFIGURATION FUNCTIONS
# =============================================================================

# Set log level
set_log_level() {
    local level="$1"
    case "$level" in
        "debug"|"DEBUG") LOG_LEVEL=$LOG_LEVEL_DEBUG ;;
        "info"|"INFO")   LOG_LEVEL=$LOG_LEVEL_INFO ;;
        "warn"|"WARN")   LOG_LEVEL=$LOG_LEVEL_WARN ;;
        "error"|"ERROR") LOG_LEVEL=$LOG_LEVEL_ERROR ;;
        *) log_error "Invalid log level: $level" ; return 1 ;;
    esac
    log_info "Log level set to: $(get_log_level_name $LOG_LEVEL)"
}

# Get current log level
get_log_level() {
    get_log_level_name $LOG_LEVEL
}

# Set log file
set_log_file() {
    local file="$1"
    LOG_FILE="$file"
    log_info "Log file set to: $LOG_FILE"
}

# Clear log file
clear_log_file() {
    if [[ -n "${LOG_FILE:-}" ]] && [[ -f "$LOG_FILE" ]]; then
        > "$LOG_FILE"
        log_info "Log file cleared: $LOG_FILE"
    fi
}

# =============================================================================
# LOGGING UTILITY FUNCTIONS
# =============================================================================

# Log command execution
log_command() {
    local command="$*"
    log_debug "Executing command: $command"
}

# Log command result
log_command_result() {
    local command="$1"
    local exit_code="$2"
    local output="$3"
    
    if [[ $exit_code -eq 0 ]]; then
        log_debug "Command successful: $command"
        if [[ -n "$output" ]]; then
            log_debug "Command output: $output"
        fi
    else
        log_error "Command failed: $command (exit code: $exit_code)"
        if [[ -n "$output" ]]; then
            log_error "Command output: $output"
        fi
    fi
}

# Log file operation
log_file_operation() {
    local operation="$1"
    local file="$2"
    local status="$3"
    log_debug "File $operation: $file - $status"
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

# Export all logging functions
export -f log_message
export -f log_debug
export -f log_info
export -f log_warn
export -f log_error
export -f log_function_entry
export -f log_function_exit
export -f log_package_operation
export -f log_user_action
export -f log_system_event
export -f set_log_level
export -f get_log_level
export -f set_log_file
export -f clear_log_file
export -f log_command
export -f log_command_result
export -f log_file_operation
