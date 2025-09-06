#!/bin/bash

# Custom configuration management functions

# Parse command line arguments
parse_arguments() {
    CUSTOM_CONFIG_FILE=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --custom-config)
                CUSTOM_CONFIG_FILE="$2"
                shift 2
                ;;
            --no-sudo-ask)
                NO_SUDO_ASK=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

# Show help message
show_help() {
    echo "Linux Helper - Arch-based System Setup Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --custom-config FILE    Use custom configuration file"
    echo "  --help, -h             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Interactive mode"
    echo "  $0 --custom-config my-config.txt     # Use custom config"
    echo ""
}

# Load custom configuration
load_custom_config() {
    if [[ -z "$CUSTOM_CONFIG_FILE" ]]; then
        return 0
    fi
    
    if [[ ! -f "$CUSTOM_CONFIG_FILE" ]]; then
        log_error "Custom config file not found: $CUSTOM_CONFIG_FILE"
        exit 1
    fi
    
    log_info "Loading custom configuration from: $CUSTOM_CONFIG_FILE"
    
    # Source the custom config file
    source "$CUSTOM_CONFIG_FILE"
    
    # Set flags to skip interactive prompts
    SKIP_LANGUAGE_SELECTION=true
    SKIP_USER_TYPE_SELECTION=true
    SKIP_MODULE_SELECTION=true
    SKIP_PACKAGE_MANAGER_SELECTION=true
    SKIP_ALIASES_PROMPT=true
    
    log_success "Custom configuration loaded successfully!"
}

# Save current configuration
save_current_config() {
    if [[ "${USER_TYPE}" == "newbie" ]]; then
        return 0  # Skip for newbie users
    fi
    
    local config_dir="$HOME/Documents/linux-helper-configs"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local config_file="$config_dir/linux-helper-config_${timestamp}.txt"
    
    # Create config directory if it doesn't exist
    mkdir -p "$config_dir"
    
    log_info "Saving current configuration..."
    
    # Create configuration file
    cat > "$config_file" << EOF
# Linux Helper - Custom Configuration
# Generated on $(date)
# User Type: $USER_TYPE
# Language: $LANGUAGE

# System Configuration
USER_TYPE="$USER_TYPE"
LANGUAGE="$LANGUAGE"
PACKAGE_MANAGER="$PACKAGE_MANAGER"

# Selected Modules
SELECTED_MODULES=($(printf '"%s" ' "${SELECTED_MODULES[@]}"))

# Module-specific configurations
EOF

    # Add module-specific configurations
    for module in "${SELECTED_MODULES[@]}"; do
        if [[ -f "${MODULES_DIR}/${module}.sh" ]]; then
            # Extract module configuration if it exists
            if grep -q "MODULE_CONFIG=" "${MODULES_DIR}/${module}.sh"; then
                echo "" >> "$config_file"
                echo "# $module configuration" >> "$config_file"
                grep "MODULE_CONFIG=" "${MODULES_DIR}/${module}.sh" >> "$config_file"
            fi
        fi
    done
    
    # Add aliases configuration
    echo "" >> "$config_file"
    echo "# Aliases configuration" >> "$config_file"
    echo "CREATE_ALIASES=$CREATE_ALIASES" >> "$config_file"
    
    log_success "Configuration saved to: $config_file"
    log_info "You can use this config file with: $0 --custom-config \"$config_file\""
    
    return 0
}

# Prompt user to save configuration
prompt_save_config() {
    if [[ "${USER_TYPE}" == "newbie" ]]; then
        return 0  # Skip for newbie users
    fi
    
    log_info "Prompting user to save configuration..."
    
    dialog --title "Save Configuration" \
           --yesno "Would you like to save your current configuration for future use?\n\nThis will create a config file in your Documents directory that you can use to automate future installations." \
           10 60
    
    local response=$?
    
    if [[ $response -eq 0 ]]; then
        save_current_config
        return 0
    else
        log_info "User chose not to save configuration"
        return 1
    fi
}

# Create template configuration file
create_config_template() {
    local template_file="configs/custom-config-template.txt"
    
    # Create configs directory if it doesn't exist
    mkdir -p "configs"
    
    cat > "$template_file" << 'EOF'
# Linux Helper - Custom Configuration Template
# Copy this file and modify it according to your preferences
# Then run: ./linux-helper.sh --custom-config your-config.txt

# Basic Configuration
USER_TYPE="poweruser"  # Options: newbie, common, poweruser
LANGUAGE="en"          # Options: en, es
PACKAGE_MANAGER="paru" # Options: paru, yay

# Selected Modules (space-separated)
SELECTED_MODULES=("browsers" "gaming" "programming" "terminal" "media" "office" "system" "social" "virtualization" "command_replacements" "file_managers" "windows_users")

# Module-specific configurations
# Browsers
BROWSERS_SELECTED=("firefox" "librewolf-bin" "tor-browser")

# Gaming
GAMING_SELECTED=("steam" "lutris" "wine" "gamemode")

# Programming
PROGRAMMING_SELECTED=("visual-studio-code-bin" "neovim" "git" "nodejs" "python")

# Terminal
TERMINAL_SELECTED=("zsh" "starship" "zellij" "ghostty")

# Media
MEDIA_SELECTED=("vlc" "mpv" "obs-studio")

# Office
OFFICE_SELECTED=("libreoffice-fresh" "obsidian")

# System
SYSTEM_SELECTED=("paru" "htop" "btop" "curl" "wget")

# Social
SOCIAL_SELECTED=("discord" "telegram-desktop")

# Virtualization
VIRTUALIZATION_SELECTED=("qemu" "virt-manager")

# Command Replacements
COMMAND_REPLACEMENTS_SELECTED=("lsd" "bat" "fd" "ripgrep" "fzf" "duf" "gdu")

# File Managers
FILE_MANAGERS_SELECTED=("dolphin" "ranger")

# Windows Users
WINDOWS_USERS_SELECTED=("wine" "bottles" "krita" "gimp" "libreoffice-fresh")

# Aliases
CREATE_ALIASES=true
EOF

    log_success "Configuration template created: $template_file"
    log_info "You can copy and modify this template for your custom configurations"
}
