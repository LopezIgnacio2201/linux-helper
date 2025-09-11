#!/bin/bash

# Linux Helper Script - Main Execution Script
# This script receives a profile parameter and executes the appropriate profile script

# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Source the core modules
source "$PROJECT_ROOT/src/utils/colors.sh"
source "$PROJECT_ROOT/src/utils/logging.sh"
source "$PROJECT_ROOT/src/core/config.sh"

# =============================================================================
# PROFILE EXECUTION
# =============================================================================

# Execute profile script
execute_profile_script() {
    local profile="$1"
    local profile_script="$PROJECT_ROOT/src/profiles/${profile}.sh"
    
    log_info "Executing profile: $profile"
    
    # Check if profile script exists
    if [[ ! -f "$profile_script" ]]; then
        print_error "Profile script not found: $profile_script"
        exit 1
    fi
    
    # Make profile script executable
    chmod +x "$profile_script"
    
    # Execute profile script
    print_info "Starting $profile profile..."
    "$profile_script"
    
    # Check exit code
    if [[ $? -eq 0 ]]; then
        print_success "Profile execution completed successfully"
    else
        print_error "Profile execution failed"
        exit 1
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Main function
main() {
    local profile="$1"
    
    # Validate profile parameter
    if [[ -z "$profile" ]]; then
        print_error "No profile specified"
        exit 1
    fi
    
    # Initialize configuration
    if ! init_config; then
        print_error "Failed to initialize configuration"
        exit 1
    fi
    
    # Execute profile script
    execute_profile_script "$profile"
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Run main function with all arguments
main "$@"
