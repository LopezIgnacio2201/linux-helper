#!/bin/bash

# Linux Package Manager Tool - Entry Point
# Usage: ./install.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Linux Package Manager Tool${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

# Check if running on Arch-based system
check_arch() {
    if ! command -v pacman &> /dev/null; then
        print_error "This tool is designed for Arch-based distributions only."
        print_error "Please run this on Arch Linux, Manjaro, EndeavourOS, or similar."
        exit 1
    fi
    print_status "Arch-based system detected ✓"
}

# Check sudo access
check_sudo() {
    print_status "Checking sudo access..."
    if ! sudo -n true 2>/dev/null; then
        print_warning "Sudo authentication required..."
        print_status "Please enter your password when prompted:"
        if ! sudo true; then
            print_error "Sudo authentication failed. Please check your password and try again."
            exit 1
        fi
    fi
    print_status "Sudo access confirmed ✓"
}

# Check if Go is installed
check_go() {
    if ! command -v go &> /dev/null; then
        print_warning "Go is not installed. Installing Go..."
        print_status "Requesting sudo privileges for Go installation..."
        sudo pacman -S go --noconfirm
        print_status "Go installed ✓"
    else
        print_status "Go is already installed ✓"
    fi
}

# Build the application
build_app() {
    print_status "Building Linux Package Manager Tool..."
    go build -o linux-package-manager main.go
    print_status "Application built successfully ✓"
}

# Main execution
main() {
    print_header
    
    # Check system requirements
    check_arch
    check_sudo
    check_go
    
    # Build the application
    build_app
    
    # Start the application
    print_status "Starting Linux Package Manager..."
    ./linux-package-manager
}

# Run main function with all arguments
main "$@"
