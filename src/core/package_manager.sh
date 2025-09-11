#!/bin/bash

# Package Manager Module
# This module handles package installation using pacman and AUR helpers

# =============================================================================
# PACKAGE MANAGER CONFIGURATION
# =============================================================================

# AUR helper preferences (in order of preference)
readonly AUR_HELPERS=("yay" "paru")
readonly DEFAULT_AUR_HELPER="paru"

# Package manager commands
readonly PACMAN_CMD="sudo pacman"
readonly PACMAN_SYNC_CMD="sudo pacman -S"
readonly PACMAN_UPDATE_CMD="sudo pacman -Syu"

# Installation options
readonly INSTALL_OPTS="--noconfirm --needed"
readonly AUR_INSTALL_OPTS="--noconfirm --needed"

# =============================================================================
# AUR HELPER DETECTION AND SETUP
# =============================================================================

# Check if AUR helper is installed
check_aur_helper() {
    local helper="$1"
    command -v "$helper" &> /dev/null
}

# Get available AUR helper
get_aur_helper() {
    for helper in "${AUR_HELPERS[@]}"; do
        if check_aur_helper "$helper"; then
            echo "$helper"
            return 0
        fi
    done
    return 1
}

# Install paru AUR helper
install_paru() {
    log_info "Installing paru AUR helper..."
    
    # Check if paru is already installed
    if check_aur_helper "paru"; then
        log_info "paru is already installed"
        return 0
    fi
    
    # Install paru dependencies
    print_info "Installing paru dependencies..."
    if ! $PACMAN_SYNC_CMD --needed base-devel git; then
        log_error "Failed to install paru dependencies"
        return 1
    fi
    
    # Clone and build paru
    print_info "Building paru from source..."
    local temp_dir
    temp_dir=$(mktemp -d)
    
    if ! git clone https://aur.archlinux.org/paru.git "$temp_dir/paru"; then
        log_error "Failed to clone paru repository"
        rm -rf "$temp_dir"
        return 1
    fi
    
    cd "$temp_dir/paru" || {
        log_error "Failed to enter paru directory"
        rm -rf "$temp_dir"
        return 1
    }
    
    # Build and install paru
    if ! makepkg -si --noconfirm; then
        log_error "Failed to build paru"
        cd - > /dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    # Verify installation
    if check_aur_helper "paru"; then
        print_success "paru installed successfully"
        return 0
    else
        log_error "paru installation verification failed"
        return 1
    fi
}

# Setup AUR helper
setup_aur_helper() {
    local aur_helper
    aur_helper=$(get_aur_helper)
    
    if [[ -n "$aur_helper" ]]; then
        log_info "Using AUR helper: $aur_helper"
        echo "$aur_helper"
        return 0
    fi
    
    # No AUR helper found, install paru
    print_warning "No AUR helper found. Installing paru..."
    if install_paru; then
        log_info "paru installed successfully"
        echo "paru"
        return 0
    else
        log_error "Failed to install paru"
        return 1
    fi
}

# =============================================================================
# PACKAGE DETECTION FUNCTIONS
# =============================================================================

# Check if package exists in official repositories
check_package_exists() {
    local package="$1"
    
    if [[ -z "$package" ]]; then
        log_error "Package name is required"
        return 1
    fi
    
    # Check if package exists in pacman
    if pacman -Si "$package" &> /dev/null; then
        echo "pacman"
        return 0
    fi
    
    return 1
}

# Check if package exists in AUR
check_aur_package_exists() {
    local package="$1"
    local aur_helper="$2"
    
    if [[ -z "$package" ]] || [[ -z "$aur_helper" ]]; then
        log_error "Package name and AUR helper are required"
        return 1
    fi
    
    # Check if package exists in AUR
    if "$aur_helper" -Si "$package" &> /dev/null; then
        echo "aur"
        return 0
    fi
    
    return 1
}

# Get package source (pacman or aur)
get_package_source() {
    local package="$1"
    local aur_helper="$2"
    
    # Check pacman first
    if check_package_exists "$package"; then
        echo "pacman"
        return 0
    fi
    
    # Check AUR if helper is available
    if [[ -n "$aur_helper" ]] && check_aur_package_exists "$package" "$aur_helper"; then
        echo "aur"
        return 0
    fi
    
    return 1
}

# =============================================================================
# PACKAGE INSTALLATION FUNCTIONS
# =============================================================================

# Install package using pacman
install_pacman_package() {
    local package="$1"
    
    if [[ -z "$package" ]]; then
        log_error "Package name is required"
        return 1
    fi
    
    log_info "Installing package via pacman: $package"
    
    # Check if package is already installed
    if pacman -Qi "$package" &> /dev/null; then
        print_info "Package $package is already installed"
        return 0
    fi
    
    # Install package
    print_info "Installing $package..."
    if $PACMAN_SYNC_CMD $INSTALL_OPTS "$package"; then
        print_success "Successfully installed $package"
        return 0
    else
        log_error "Failed to install $package via pacman"
        return 1
    fi
}

# Install package using AUR helper
install_aur_package() {
    local package="$1"
    local aur_helper="$2"
    
    if [[ -z "$package" ]] || [[ -z "$aur_helper" ]]; then
        log_error "Package name and AUR helper are required"
        return 1
    fi
    
    log_info "Installing package via AUR ($aur_helper): $package"
    
    # Check if package is already installed
    if pacman -Qi "$package" &> /dev/null; then
        print_info "Package $package is already installed"
        return 0
    fi
    
    # Install package
    print_info "Installing $package from AUR..."
    if "$aur_helper" -S $AUR_INSTALL_OPTS "$package"; then
        print_success "Successfully installed $package from AUR"
        return 0
    else
        log_error "Failed to install $package via AUR"
        return 1
    fi
}

# Install single package
install_package() {
    local package="$1"
    local aur_helper="$2"
    
    if [[ -z "$package" ]]; then
        log_error "Package name is required"
        return 1
    fi
    
    # Get package source
    local source
    source=$(get_package_source "$package" "$aur_helper")
    
    if [[ -z "$source" ]]; then
        log_error "Package $package not found in pacman or AUR"
        return 1
    fi
    
    # Install based on source
    case "$source" in
        "pacman")
            install_pacman_package "$package"
            ;;
        "aur")
            install_aur_package "$package" "$aur_helper"
            ;;
        *)
            log_error "Unknown package source: $source"
            return 1
            ;;
    esac
}

# Install multiple packages
install_packages() {
    local packages="$1"
    local aur_helper="$2"
    local success_count=0
    local fail_count=0
    local failed_packages=""
    
    if [[ -z "$packages" ]]; then
        log_error "Package list is required"
        return 1
    fi
    
    log_info "Installing multiple packages..."
    
    # Count total packages
    local total_packages
    total_packages=$(echo "$packages" | wc -l)
    print_info "Installing $total_packages packages..."
    
    # Install each package
    while IFS= read -r package; do
        if [[ -n "$package" ]]; then
            print_info "Installing package $((success_count + fail_count + 1))/$total_packages: $package"
            
            if install_package "$package" "$aur_helper"; then
                ((success_count++))
            else
                ((fail_count++))
                failed_packages+="$package"$'\n'
            fi
        fi
    done < <(echo "$packages")
    
    # Show installation summary
    echo
    print_separator "$COLOR_GRAY"
    print_color "$COLOR_CYAN" "Installation Summary:"
    print_success "Successfully installed: $success_count packages"
    
    if [[ $fail_count -gt 0 ]]; then
        print_error "Failed to install: $fail_count packages"
        print_color "$COLOR_RED" "Failed packages:"
        while IFS= read -r failed_package; do
            if [[ -n "$failed_package" ]]; then
                print_color "$COLOR_RED" "  • $failed_package"
            fi
        done < <(echo "$failed_packages")
    fi
    
    # Return success if all packages installed
    if [[ $fail_count -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

# =============================================================================
# SYSTEM UPDATE FUNCTIONS
# =============================================================================

# Update system packages
update_system() {
    log_info "Updating system packages..."
    
    print_info "Updating package database and system..."
    if $PACMAN_UPDATE_CMD; then
        print_success "System updated successfully"
        return 0
    else
        log_error "Failed to update system"
        return 1
    fi
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Test package manager functionality
test_package_manager() {
    log_info "Testing package manager functionality..."
    
    # Test AUR helper setup
    local aur_helper
    aur_helper=$(setup_aur_helper)
    
    if [[ -n "$aur_helper" ]]; then
        print_success "AUR helper: $aur_helper"
    else
        print_error "Failed to setup AUR helper"
        return 1
    fi
    
    # Test package detection
    local test_package="firefox"
    local source
    source=$(get_package_source "$test_package" "$aur_helper")
    
    if [[ -n "$source" ]]; then
        print_success "Package detection working: $test_package found in $source"
    else
        print_error "Package detection failed for $test_package"
        return 1
    fi
    
    print_success "Package manager test completed successfully"
    return 0
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

# Export all package manager functions
export -f check_aur_helper
export -f get_aur_helper
export -f install_paru
export -f setup_aur_helper
export -f check_package_exists
export -f check_aur_package_exists
export -f get_package_source
export -f install_pacman_package
export -f install_aur_package
export -f install_package
export -f install_packages
export -f update_system
export -f test_package_manager
