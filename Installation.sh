#!/bin/bash

# Linux Helper Script - Main Installation Script
# This script prompts the user to select a profile and executes the appropriate behavior

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
# PROFILE DEFINITIONS
# =============================================================================

# Profile constants
readonly PROFILE_NEWBIE="newbie"
readonly PROFILE_COMMON="common"
readonly PROFILE_POWER="power"

# Profile descriptions
readonly NEWBIE_DESC="Windows-like experience for new users (Fully automated setup)"
readonly COMMON_DESC="Balanced experience for regular users (Limited TUI with 10 modules)"
readonly POWER_DESC="Advanced setup for experienced users (Full TUI with 12 modules)"

# =============================================================================
# DISPLAY FUNCTIONS
# =============================================================================

# Display welcome banner
show_welcome_banner() {
    clear
    print_header "Linux Helper Script" "$COLOR_BLUE"
    print_color "$COLOR_CYAN" "Welcome to the Linux Helper Script!"
    print_color "$COLOR_WHITE" "This script will help you set up your Arch Linux system with the right tools for your experience level."
    echo
    print_color "$COLOR_YELLOW" "Please select your user profile:"
    echo
}

# Display profile options
show_profile_options() {
    print_color "$COLOR_GREEN" "1) Newbie Profile"
    print_color "$COLOR_GRAY" "   $NEWBIE_DESC"
    echo
    
    print_color "$COLOR_BLUE" "2) Common User Profile"
    print_color "$COLOR_GRAY" "   $COMMON_DESC"
    echo
    
    print_color "$COLOR_PURPLE" "3) Power User Profile"
    print_color "$COLOR_GRAY" "   $POWER_DESC"
    echo
    
    print_separator "$COLOR_GRAY"
}

# =============================================================================
# PROFILE SELECTION FUNCTIONS
# =============================================================================

# Get user profile selection
get_profile_selection() {
    local selection
    local valid_selection=false
    
    while [[ "$valid_selection" == false ]]; do
        print_color_n "$COLOR_CYAN" "Enter your choice (1-3): "
        read -r selection
        
        case "$selection" in
            1)
                selected_profile="$PROFILE_NEWBIE"
                valid_selection=true
                ;;
            2)
                selected_profile="$PROFILE_COMMON"
                valid_selection=true
                ;;
            3)
                selected_profile="$PROFILE_POWER"
                valid_selection=true
                ;;
            *)
                print_error "Invalid selection. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

# Confirm profile selection
confirm_profile_selection() {
    local profile_name
    local profile_desc
    
    case "$selected_profile" in
        "$PROFILE_NEWBIE")
            profile_name="Newbie Profile"
            profile_desc="$NEWBIE_DESC"
            ;;
        "$PROFILE_COMMON")
            profile_name="Common User Profile"
            profile_desc="$COMMON_DESC"
            ;;
        "$PROFILE_POWER")
            profile_name="Power User Profile"
            profile_desc="$POWER_DESC"
            ;;
    esac
    
    echo
    print_color "$COLOR_YELLOW" "You selected: $profile_name"
    print_color "$COLOR_GRAY" "$profile_desc"
    echo
    
    local confirm
    print_color_n "$COLOR_CYAN" "Continue with this profile? (y/N): "
    read -r confirm
    
    case "$confirm" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# =============================================================================
# PROFILE EXECUTION
# =============================================================================

# Execute selected profile
execute_profile() {
    # Call main.sh with the selected profile
    "$PROJECT_ROOT/main.sh" "$selected_profile"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

# Main function
main() {
    # Initialize configuration
    if ! init_config; then
        print_error "Failed to initialize configuration"
        exit 1
    fi
    
    # Show welcome banner
    show_welcome_banner
    
    # Show profile options
    show_profile_options
    
    # Get user selection
    get_profile_selection
    
    # Confirm selection
    if ! confirm_profile_selection; then
        print_info "Profile selection cancelled by user"
        exit 0
    fi
    
    # Execute selected profile
    execute_profile
    
    # Show completion message
    echo
    print_success "Profile selection completed successfully!"
    print_info "Thank you for using Linux Helper Script!"
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Run main function
main "$@"
