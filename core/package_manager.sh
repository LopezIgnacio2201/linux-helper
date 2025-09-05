#!/bin/bash

# Package manager functions

# Select package manager
select_package_manager() {
    log_info "Selecting package manager..."
    
    # Check if paru is installed
    if command -v paru >/dev/null 2>&1; then
        PACKAGE_MANAGER="paru"
        log_success "Using existing paru installation"
        return 0
    fi
    
    # Check if yay is installed
    if command -v yay >/dev/null 2>&1; then
        PACKAGE_MANAGER="yay"
        log_success "Using existing yay installation"
        return 0
    fi
    
    # For newbie users, install paru automatically
    if [[ "${USER_TYPE}" == "newbie" ]]; then
        install_paru
        PACKAGE_MANAGER="paru"
        return 0
    fi
    
    # For other users, let them choose
    local manager_options=(
        "paru" "Paru - Fast AUR helper (recommended)"
        "yay" "Yay - Yet Another Yaourt"
        "install_paru" "Install Paru (recommended)"
        "install_yay" "Install Yay"
    )
    
    PACKAGE_MANAGER=$(dialog --clear \
        --backtitle "Linux Helper - Package Manager Selection" \
        --title "Select Package Manager" \
        --menu "Choose your preferred AUR helper:" 12 60 4 \
        "${manager_options[@]}" \
        2>&1 >/dev/tty)
    
    if [[ $? -ne 0 ]]; then
        error_exit "Package manager selection cancelled"
    fi
    
    case "$PACKAGE_MANAGER" in
        "install_paru")
            install_paru
            PACKAGE_MANAGER="paru"
            ;;
        "install_yay")
            install_yay
            PACKAGE_MANAGER="yay"
            ;;
    esac
    
    log_success "Package manager selected: ${PACKAGE_MANAGER}"
}

# Install paru
install_paru() {
    log_info "Installing paru..."
    
    # Install dependencies
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Clone and build paru
    cd /tmp
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd /
    rm -rf /tmp/paru
    
    log_success "Paru installed successfully"
}

# Install yay
install_yay() {
    log_info "Installing yay..."
    
    # Install dependencies
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Clone and build yay
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd /
    rm -rf /tmp/yay
    
    log_success "Yay installed successfully"
}

# Install package with retry logic
install_package() {
    local package="$1"
    local retry_count=0
    local max_retries=2
    
    log_package_install "$package"
    
    while [[ $retry_count -le $max_retries ]]; do
        if [[ $retry_count -gt 0 ]]; then
            log_warning "Retrying installation of $package (attempt $((retry_count + 1)))"
        fi
        
        if install_package_attempt "$package"; then
            log_success "Successfully installed: $package"
            return 0
        fi
        
        ((retry_count++))
    done
    
    log_error "Failed to install $package after $max_retries retries"
    return 1
}

# Single package installation attempt
install_package_attempt() {
    local package="$1"
    
    case "$PACKAGE_MANAGER" in
        "paru")
            if [[ "${NO_SUDO_ASK}" == "true" ]]; then
                paru -S --needed --noconfirm "$package"
            else
                paru -S --needed "$package"
            fi
            ;;
        "yay")
            if [[ "${NO_SUDO_ASK}" == "true" ]]; then
                yay -S --needed --noconfirm "$package"
            else
                yay -S --needed "$package"
            fi
            ;;
        *)
            # Fallback to pacman
            if [[ "${NO_SUDO_ASK}" == "true" ]]; then
                sudo pacman -S --needed --noconfirm "$package"
            else
                sudo pacman -S --needed "$package"
            fi
            ;;
    esac
}

# Install multiple packages
install_packages() {
    local packages=("$@")
    local failed_packages=()
    
    log_info "Installing ${#packages[@]} packages..."
    
    for package in "${packages[@]}"; do
        if ! install_package "$package"; then
            failed_packages+=("$package")
        fi
    done
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_error "Failed to install packages: ${failed_packages[*]}"
        log_info "Please install these packages manually:"
        for package in "${failed_packages[@]}"; do
            echo "  ${PACKAGE_MANAGER} -S $package"
        done
        return 1
    fi
    
    log_success "All packages installed successfully"
    return 0
}

# Check if package is installed
is_package_installed() {
    local package="$1"
    pacman -Qi "$package" >/dev/null 2>&1
}

# Get package manager command
get_package_manager_cmd() {
    echo "$PACKAGE_MANAGER"
}

