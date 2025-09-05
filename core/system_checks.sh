#!/bin/bash

# System checks and validation functions

# Check if running on Arch-based system
check_arch_system() {
    if [[ ! -f /etc/arch-release ]] && [[ ! -f /etc/artix-release ]]; then
        error_exit "This script is designed for Arch-based distributions only!"
    fi
}

# Check if running on EndeavourOS
check_endeavouros() {
    if [[ -f /etc/endeavouros-release ]]; then
        log_info "Detected EndeavourOS - optimal compatibility"
        return 0
    else
        log_warning "Not running on EndeavourOS - compatibility may vary"
        return 1
    fi
}

# Check internet connection
check_internet_connection() {
    log_info "Checking internet connection..."
    
    if ! ping -c 1 archlinux.org >/dev/null 2>&1; then
        error_exit "No internet connection detected! Please check your network and try again."
    fi
    
    log_success "Internet connection verified"
}

# Check available disk space
check_disk_space() {
    log_info "Checking available disk space..."
    
    local available_space
    available_space=$(df / | awk 'NR==2 {print $4}')
    local required_space=2000000  # 2GB in KB
    
    if [[ $available_space -lt $required_space ]]; then
        error_exit "Insufficient disk space! At least 2GB free space required."
    fi
    
    log_success "Disk space check passed"
}

# Check user permissions
check_user_permissions() {
    log_info "Checking user permissions..."
    
    if [[ $EUID -eq 0 ]]; then
        error_exit "Please do not run this script as root! Run as a regular user with sudo privileges."
    fi
    
    # Check if user can use sudo
    if ! sudo -n true 2>/dev/null; then
        if [[ "${NO_SUDO_ASK}" == "false" ]]; then
            log_info "This script requires sudo privileges. You will be prompted for your password when needed."
        else
            log_info "Sudo privileges will be required for package installation."
        fi
    else
        log_success "Sudo privileges verified"
    fi
}

# Check if required tools are installed
check_required_tools() {
    log_info "Checking required tools..."
    
    local missing_tools=()
    
    # Check for dialog (required for interactive menus)
    if ! command -v dialog >/dev/null 2>&1; then
        missing_tools+=("dialog")
    fi
    
    # Check for curl (required for downloading)
    if ! command -v curl >/dev/null 2>&1; then
        missing_tools+=("curl")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_warning "Missing required tools: ${missing_tools[*]}"
        log_info "Installing missing tools..."
        
        for tool in "${missing_tools[@]}"; do
            install_package "$tool"
        done
    fi
    
    log_success "Required tools check passed"
}

# Main system requirements check
check_system_requirements() {
    log_info "Performing system requirements check..."
    
    check_arch_system
    check_endeavouros || true  # Don't fail if not on EOS, just warn
    check_internet_connection
    check_disk_space
    check_user_permissions
    check_required_tools
    
    log_success "All system requirements met!"
}

