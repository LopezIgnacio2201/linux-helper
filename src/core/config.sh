#!/bin/bash

# Core Configuration Management
# This module handles all project configuration, constants, and environment validation

# =============================================================================
# CONFIGURATION CONSTANTS
# =============================================================================

# Project Information
readonly PROJECT_NAME="Linux Helper Script"
readonly PROJECT_VERSION="1.0.0"
readonly PROJECT_AUTHOR="Linux Helper Script Team"

# Directory Structure
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
readonly DATA_DIR="$PROJECT_ROOT/data"
readonly METADATA_DIR="$DATA_DIR/metadata"
readonly DESCRIPTIONS_DIR="$DATA_DIR/descriptions"
readonly DETAILED_DIR="$DATA_DIR/detailed"
readonly IMAGES_DIR="$DATA_DIR/images"
readonly SCRIPTS_DIR="$DATA_DIR/scripts"

# File Paths
readonly PACKAGES_YAML="$METADATA_DIR/packages.yaml"
readonly CONFIG_FILE="$SCRIPT_DIR/config/user_config.yaml"

# User Profiles
readonly PROFILE_NEWBIE="newbie"
readonly PROFILE_COMMON="common"
readonly PROFILE_POWER="power"
readonly PROFILE_EXPANDED="expanded"

# Module Categories
readonly CATEGORY_BROWSERS="browsers"
readonly CATEGORY_TERMINALS="terminals"
readonly CATEGORY_FILE_MANAGERS="file-managers"
readonly CATEGORY_MEDIA_PLAYERS="media-players"
readonly CATEGORY_OFFICE_PRODUCTIVITY="office-and-productivity"
readonly CATEGORY_GAMING="gaming"
readonly CATEGORY_COMMUNICATION="communication"
readonly CATEGORY_GRAPHICS_DESIGN="graphics-and-design"
readonly CATEGORY_DEVELOPMENT_TOOLS="development-tools"
readonly CATEGORY_UTILITIES="utilities"
readonly CATEGORY_PRIVACY="privacy"
readonly CATEGORY_CYBERSECURITY="cybersecurity"

# TUI Configuration
readonly TUI_PREVIEW_WIDTH=50
readonly TUI_PREVIEW_HEIGHT=20
readonly TUI_HEADER_HEIGHT=3
readonly TUI_FOOTER_HEIGHT=2

# Package Management
readonly PACKAGE_MANAGER_PACMAN="pacman"
readonly PACKAGE_MANAGER_AUR="aur"
readonly AUR_HELPER_YAY="yay"
readonly AUR_HELPER_PARU="paru"

# =============================================================================
# COLOR DEFINITIONS
# =============================================================================

# Colors are defined in src/utils/colors.sh
# This section is kept for reference but colors are sourced from colors.sh

# =============================================================================
# LOGGING CONFIGURATION
# =============================================================================

# Logging constants are defined in src/utils/logging.sh
# This section is kept for reference but logging is sourced from logging.sh

readonly LOG_FILE="$PROJECT_ROOT/logs/linux-helper.log"

# =============================================================================
# VALIDATION CONFIGURATION
# =============================================================================

readonly MIN_TERMINAL_WIDTH=60
readonly MIN_TERMINAL_HEIGHT=10
readonly REQUIRED_COMMANDS="yq fzf dialog"
readonly REQUIRED_PACKAGES="yq fzf dialog"

# =============================================================================
# CONFIGURATION FUNCTIONS
# =============================================================================

# Load user configuration
load_user_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        # Load user-specific configuration
        # This will be implemented when we add user preferences
        log_info "User configuration loaded from $CONFIG_FILE"
    else
        log_info "Using default configuration"
    fi
}

# Validate environment
validate_environment() {
    local errors=0
    
    log_info "Validating environment..."
    
    # Check if running on Arch Linux
    if [[ ! -f "/etc/arch-release" ]]; then
        log_error "This script is designed for Arch Linux only"
        ((errors++))
    fi
    
    # Check terminal size
    if [[ $COLUMNS -lt $MIN_TERMINAL_WIDTH ]] || [[ $LINES -lt $MIN_TERMINAL_HEIGHT ]]; then
        log_error "Terminal size too small. Minimum: ${MIN_TERMINAL_WIDTH}x${MIN_TERMINAL_HEIGHT}, Current: ${COLUMNS}x${LINES}"
        ((errors++))
    fi
    
    # Check required commands
    for cmd in $REQUIRED_COMMANDS; do
        if ! command -v "$cmd" &> /dev/null; then
            log_error "Required command not found: $cmd"
            ((errors++))
        fi
    done
    
    # Check required files
    if [[ ! -f "$PACKAGES_YAML" ]]; then
        log_error "Package metadata file not found: $PACKAGES_YAML"
        ((errors++))
    fi
    
    if [[ ! -d "$DESCRIPTIONS_DIR" ]]; then
        log_error "Descriptions directory not found: $DESCRIPTIONS_DIR"
        ((errors++))
    fi
    
    if [[ ! -d "$IMAGES_DIR" ]]; then
        log_error "Images directory not found: $IMAGES_DIR"
        ((errors++))
    fi
    
    if [[ $errors -gt 0 ]]; then
        log_error "Environment validation failed with $errors errors"
        return 1
    fi
    
    log_info "Environment validation successful"
    return 0
}

# Initialize configuration
init_config() {
    log_info "Initializing configuration..."
    
    # Create necessary directories
    mkdir -p "$(dirname "$LOG_FILE")"
    mkdir -p "$(dirname "$CONFIG_FILE")"
    
    # Load user configuration
    load_user_config
    
    # Validate environment
    if ! validate_environment; then
        log_error "Configuration initialization failed"
        return 1
    fi
    
    log_info "Configuration initialized successfully"
    return 0
}

# Get configuration value
get_config() {
    local key="$1"
    local default_value="$2"
    
    # This will be implemented when we add user preferences
    echo "${default_value}"
}

# Set configuration value
set_config() {
    local key="$1"
    local value="$2"
    
    # This will be implemented when we add user preferences
    log_info "Configuration set: $key=$value"
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Get project information
get_project_info() {
    echo "Project: $PROJECT_NAME"
    echo "Version: $PROJECT_VERSION"
    echo "Author: $PROJECT_AUTHOR"
    echo "Root: $PROJECT_ROOT"
}

# Check if running in debug mode
is_debug_mode() {
    [[ "${DEBUG:-0}" == "1" ]]
}

# Get current user profile
get_current_profile() {
    echo "${CURRENT_PROFILE:-$PROFILE_COMMON}"
}

# Set current user profile
set_current_profile() {
    local profile="$1"
    case "$profile" in
        "$PROFILE_NEWBIE"|"$PROFILE_COMMON"|"$PROFILE_POWER"|"$PROFILE_EXPANDED")
            CURRENT_PROFILE="$profile"
            log_info "User profile set to: $profile"
            ;;
        *)
            log_error "Invalid profile: $profile"
            return 1
            ;;
    esac
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

# Export all configuration functions
export -f load_user_config
export -f validate_environment
export -f init_config
export -f get_config
export -f set_config
export -f get_project_info
export -f is_debug_mode
export -f get_current_profile
export -f set_current_profile
