#!/bin/bash

# Gaming module - Steam, Proton, Wine, Gaming kernel

MODULE_TITLE="Gaming Setup"
MODULE_DEPENDENCIES=()

# Install gaming packages
install_gaming_packages() {
    log_info "Installing gaming packages..."
    
    # Core gaming packages
    local core_packages=(
        "steam"
        "wine"
        "winetricks"
        "lutris"
        "gamemode"
        "mangohud"
        "vulkan-radeon"
        "lib32-vulkan-radeon"
        "vulkan-intel"
        "lib32-vulkan-intel"
        "vulkan-tools"
        "lib32-vulkan-tools"
    )
    
    # Install core packages
    install_packages "${core_packages[@]}"
    
    # Install Proton versions
    install_proton_versions
    
    # Install gaming kernel
    install_gaming_kernel
    
    # Install additional gaming tools
    install_gaming_tools
    
    log_success "Gaming packages installation completed"
}

# Install Proton versions
install_proton_versions() {
    log_info "Installing Proton versions..."
    
    local proton_options=(
        "proton-ge-custom" "Proton-GE - Community enhanced Proton"
        "proton-tkg" "Proton-TKG - Custom Proton builds"
        "protonup-qt" "ProtonUp-Qt - Proton version manager"
    )
    
    local selected_protons=($(dialog --clear \
        --backtitle "Linux Helper - Proton Selection" \
        --title "Select Proton Versions" \
        --checklist "Choose Proton versions to install:" 10 60 3 \
        "${proton_options[@]}" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        log_warning "Proton selection cancelled"
        return 0
    fi
    
    for proton in "${selected_protons[@]}"; do
        case "$proton" in
            "proton-ge-custom")
                install_package "proton-ge-custom-bin"
                ;;
            "proton-tkg")
                install_package "proton-tkg"
                ;;
            "protonup-qt")
                install_package "protonup-qt"
                ;;
        esac
    done
}

# Install gaming kernel
install_gaming_kernel() {
    log_info "Installing gaming kernel..."
    
    local kernel_options=(
        "linux-tkg" "Linux-TKG - Gaming optimized kernel"
        "linux-zen" "Linux-Zen - Low latency kernel"
        "linux-lts" "Linux-LTS - Long term support kernel"
        "none" "No custom kernel"
    )
    
    local selected_kernel=$(dialog --clear \
        --backtitle "Linux Helper - Gaming Kernel" \
        --title "Select Gaming Kernel" \
        --menu "Choose a gaming kernel (optional):" 12 60 4 \
        "${kernel_options[@]}" \
        2>&1 >/dev/tty)
    
    if [[ $? -ne 0 || "$selected_kernel" == "none" ]]; then
        log_info "No custom kernel selected"
        return 0
    fi
    
    case "$selected_kernel" in
        "linux-tkg")
            install_package "linux-tkg"
            install_package "linux-tkg-headers"
            ;;
        "linux-zen")
            install_package "linux-zen"
            install_package "linux-zen-headers"
            ;;
        "linux-lts")
            install_package "linux-lts"
            install_package "linux-lts-headers"
            ;;
    esac
    
    log_success "Gaming kernel installed: $selected_kernel"
}

# Install gaming tools
install_gaming_tools() {
    log_info "Installing additional gaming tools..."
    
    local gaming_tools=(
        "discord"
        "obs-studio"
        "obs-studio-plugins"
        "gimp"
        "krita"
        "blender"
        "godot"
        "godot-tools"
    )
    
    local selected_tools=($(dialog --clear \
        --backtitle "Linux Helper - Gaming Tools" \
        --title "Select Additional Gaming Tools" \
        --checklist "Choose additional tools:" 15 60 8 \
        "discord" "Discord - Gaming communication" \
        "obs-studio" "OBS Studio - Streaming/recording" \
        "obs-studio-plugins" "OBS Studio Plugins" \
        "gimp" "GIMP - Image editing" \
        "krita" "Krita - Digital painting" \
        "blender" "Blender - 3D modeling" \
        "godot" "Godot - Game engine" \
        "godot-tools" "Godot Tools" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        log_warning "Gaming tools selection cancelled"
        return 0
    fi
    
    if [[ ${#selected_tools[@]} -gt 0 ]]; then
        install_packages "${selected_tools[@]}"
    fi
}

# Configure gaming setup
configure_gaming() {
    log_info "Configuring gaming setup..."
    
    # Configure gamemode
    configure_gamemode
    
    # Configure Wine
    configure_wine
    
    # Configure Steam
    configure_steam
    
    log_success "Gaming configuration completed"
}

# Configure gamemode
configure_gamemode() {
    log_info "Configuring gamemode..."
    
    # Add user to games group
    sudo usermod -a -G games "$USER"
    
    # Enable gamemode for Steam
    mkdir -p "$HOME/.config/gamemode"
    cat > "$HOME/.config/gamemode/gamemode.ini" << 'EOF'
[general]
; GameMode configuration file
; This file is read by gamescope and the gamemode library

[gpu]
; Apply optimisations to the GPU
apply_gpu_optimisations=accept-responsibility
gpu_device=0
amd_performance_level=high

[cpu]
; Renice game process
renice=1
; Set ioprio for game process
ioprio=0

[supervisor]
; Supervisor optimisations
realtime=yes
; Set ioprio for supervisor process
ioprio=0

[general]
; Logging
softrealtime=yes
EOF
    
    log_success "Gamemode configured"
}

# Configure Wine
configure_wine() {
    log_info "Configuring Wine..."
    
    # Set Wine prefix
    export WINEPREFIX="$HOME/.wine"
    
    # Configure Wine for gaming
    winecfg &
    
    log_success "Wine configuration started (manual setup required)"
}

# Configure Steam
configure_steam() {
    log_info "Configuring Steam..."
    
    # Create Steam directory
    mkdir -p "$HOME/.steam"
    
    # Set Steam launch options for better performance
    cat > "$HOME/.steam/steam_launch_options.txt" << 'EOF'
# Steam launch options for better gaming performance
# Add these to your game's launch options in Steam:
# gamemoderun %command%

# For Proton games, you can also add:
# PROTON_USE_WINED3D=1 %command%
# PROTON_LOG=1 %command%
EOF
    
    log_success "Steam configuration completed"
}

