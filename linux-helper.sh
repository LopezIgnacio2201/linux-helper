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

# Main function
main() {
    # Initialize logging
    init_logging
    
    # Display welcome banner
    show_banner
    
    # System checks
    log_info "Performing system checks..."
    check_system_requirements
    
    # Language selection
    select_language
    
    # User type selection
    select_user_type
    
    # Module selection based on user type
    if [[ "${USER_TYPE}" == "poweruser" ]]; then
        select_poweruser_modules
    elif [[ "${USER_TYPE}" == "common" ]]; then
        select_common_modules
    elif [[ "${USER_TYPE}" == "newbie" ]]; then
        select_newbie_modules
    fi
    
    # Package manager selection
    select_package_manager
    
    # Install selected modules
    install_selected_modules
    
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

# Parse command line arguments
parse_arguments() {
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
                echo -e "${RED}Unknown option: $1${NC}"
                show_help
                exit 1
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
    --no-sudo-ask    Don't ask for sudo password on each command
    --help, -h       Show this help message

EXAMPLES:
    $0                    # Interactive setup
    $0 --no-sudo-ask      # Setup without repeated sudo prompts

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
    parse_arguments "$@"
    main "$@"
fi

