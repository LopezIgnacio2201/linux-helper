#!/bin/bash

# Linux Helper - Automated Arch/EndeavourOS Setup Script
# Author: Coffee
# Version: 1.0.0
# Description: Modular system setup for Arch-based distributions

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
CREATE_ALIASES=false

# Configuration flags
SKIP_LANGUAGE_SELECTION=false
SKIP_USER_TYPE_SELECTION=false
SKIP_MODULE_SELECTION=false
SKIP_PACKAGE_MANAGER_SELECTION=false
SKIP_ALIASES_PROMPT=false
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
source "${CORE_DIR}/aliases.sh"
source "${CORE_DIR}/config_manager.sh"

# Main function
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    # Initialize logging
    init_logging
    
    # Load custom configuration if provided
    load_custom_config
    
    # Display welcome banner
    show_banner
    
    # System checks
    log_info "Performing system checks..."
    check_system_requirements
    
    log_info "System checks completed, proceeding to language selection..."
    
    # Language selection (skip if using custom config)
    if [[ "$SKIP_LANGUAGE_SELECTION" == "false" ]]; then
        select_language
    fi
    
    # User type selection (skip if using custom config)
    if [[ "$SKIP_USER_TYPE_SELECTION" == "false" ]]; then
        select_user_type
    fi
    
    # Module selection based on user type (skip if using custom config)
    if [[ "$SKIP_MODULE_SELECTION" == "false" ]]; then
        if [[ "${USER_TYPE}" == "poweruser" ]]; then
            select_poweruser_modules
        elif [[ "${USER_TYPE}" == "common" ]]; then
            select_common_modules
        elif [[ "${USER_TYPE}" == "newbie" ]]; then
            select_newbie_modules
        fi
    fi
    
    # Package manager selection (skip if using custom config)
    if [[ "$SKIP_PACKAGE_MANAGER_SELECTION" == "false" ]]; then
        select_package_manager
    fi
    
    # Install selected modules
    install_selected_modules
    
    # Create aliases (skip if using custom config)
    if [[ "$SKIP_ALIASES_PROMPT" == "false" ]]; then
        prompt_create_aliases
    elif [[ "$CREATE_ALIASES" == "true" ]]; then
        create_aliases
    fi
    
    # Prompt to save configuration
    prompt_save_config
    
    # Final message
    show_completion_message
}

# Show welcome banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║                    🐧 Linux Helper 🐧                       ║
    ║                                                              ║
    ║              Automated Arch/EndeavourOS Setup                ║
    ║                                                              ║
    ║              Modular • Customizable • Powerful               ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${YELLOW}Welcome to Linux Helper!${NC}"
    echo -e "${YELLOW}This script will help you set up your Arch-based system.${NC}"
    echo ""
}

# Show completion message
show_completion_message() {
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║                    ✅ Setup Complete! ✅                     ║"
    echo "║                                                              ║"
    echo "║              Your system has been configured!                ║"
    echo "║                                                              ║"
    echo "║              Please reboot to apply all changes.             ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [[ -n "${LOG_FILE}" ]]; then
        echo -e "${BLUE}Log file saved to: ${LOG_FILE}${NC}"
    fi
}

# Parse command line arguments (legacy support)
parse_arguments_legacy() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-sudo-ask)
                NO_SUDO_ASK=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                # Let the new parse_arguments handle it
                return 0
                ;;
        esac
    done
}

# Show help message
show_help() {
    cat << EOF
Linux Helper - Automated Arch/EndeavourOS Setup Script

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --custom-config FILE    Use custom configuration file for automation
    --no-sudo-ask          Don't ask for sudo password on each command
    --help, -h             Show this help message

EXAMPLES:
    $0                                    # Interactive setup
    $0 --no-sudo-ask                      # Setup without repeated sudo prompts
    $0 --custom-config my-config.txt      # Use custom configuration file

DESCRIPTION:
    This script automates the setup of Arch-based Linux distributions
    with modular package installation and configuration management.

    Features:
    - Interactive module selection
    - Multiple user profiles (newbie, common, poweruser)
    - Package manager selection (paru, yay)
    - Command aliases creation
    - Custom configuration support
    - Comprehensive logging
    - Modular architecture

    Custom Configuration:
    Create a config file using the template in configs/custom-config-template.txt
    and use it to automate future installations.

EOF
}

# Error handling
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    log_error "$1"
    exit 1
}

# Trap errors
trap 'error_exit "Script failed at line $LINENO"' ERR

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

