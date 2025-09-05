#!/bin/bash

# Linux Helper - Curl Installer
# This script downloads and runs the Linux Helper setup

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
REPO_URL="https://raw.githubusercontent.com/LopezIgnacio2201/linux-helper/main"
TEMP_DIR="/tmp/linux-helper-$$"

# Show banner
show_banner() {
    clear
    echo -e "${BLUE}"
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
    echo -e "${YELLOW}This installer will download and run the setup script.${NC}"
    echo ""
}

# Check system requirements
check_requirements() {
    echo -e "${BLUE}Checking system requirements...${NC}"
    
    # Check if running on Arch-based system
    if [[ ! -f /etc/arch-release ]] && [[ ! -f /etc/artix-release ]]; then
        echo -e "${RED}Error: This script is designed for Arch-based distributions only!${NC}"
        exit 1
    fi
    
    # Check internet connection
    if ! ping -c 1 archlinux.org >/dev/null 2>&1; then
        echo -e "${RED}Error: No internet connection detected!${NC}"
        exit 1
    fi
    
    # Check for required tools
    local missing_tools=()
    
    if ! command -v curl >/dev/null 2>&1; then
        missing_tools+=("curl")
    fi
    
    if ! command -v dialog >/dev/null 2>&1; then
        missing_tools+=("dialog")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Installing missing tools: ${missing_tools[*]}${NC}"
        sudo pacman -S --needed --noconfirm "${missing_tools[@]}"
    fi
    
    echo -e "${GREEN}System requirements check passed!${NC}"
}

# Download and setup Linux Helper
download_setup() {
    echo -e "${BLUE}Downloading Linux Helper...${NC}"
    
    # Create temporary directory
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # Download main script
    curl -sSL "${REPO_URL}/linux-helper.sh" -o linux-helper.sh
    chmod +x linux-helper.sh
    
    # Download core files
    mkdir -p core
    curl -sSL "${REPO_URL}/core/system_checks.sh" -o core/system_checks.sh
    curl -sSL "${REPO_URL}/core/language.sh" -o core/language.sh
    curl -sSL "${REPO_URL}/core/user_selection.sh" -o core/user_selection.sh
    curl -sSL "${REPO_URL}/core/module_manager.sh" -o core/module_manager.sh
    curl -sSL "${REPO_URL}/core/logging.sh" -o core/logging.sh
    curl -sSL "${REPO_URL}/core/package_manager.sh" -o core/package_manager.sh
    
    # Download modules
    mkdir -p modules
    curl -sSL "${REPO_URL}/modules/terminal.sh" -o modules/terminal.sh
    curl -sSL "${REPO_URL}/modules/browsers.sh" -o modules/browsers.sh
    curl -sSL "${REPO_URL}/modules/gaming.sh" -o modules/gaming.sh
    curl -sSL "${REPO_URL}/modules/programming.sh" -o modules/programming.sh
    
    # Download configs
    mkdir -p configs
    # Note: Configs would need to be uploaded to the repository
    
    echo -e "${GREEN}Download completed!${NC}"
}

# Run Linux Helper
run_setup() {
    echo -e "${BLUE}Starting Linux Helper setup...${NC}"
    echo ""
    
    # Run the main script
    ./linux-helper.sh "$@"
}

# Cleanup
cleanup() {
    if [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# Main function
main() {
    # Set up cleanup trap
    trap cleanup EXIT
    
    # Show banner
    show_banner
    
    # Check requirements
    check_requirements
    
    # Ask for confirmation
    echo -e "${YELLOW}This will download and run the Linux Helper setup script.${NC}"
    echo -e "${YELLOW}Do you want to continue? (y/N)${NC}"
    read -r response
    
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Installation cancelled.${NC}"
        exit 0
    fi
    
    # Download and run setup
    download_setup
    run_setup "$@"
}

# Run main function
main "$@"

