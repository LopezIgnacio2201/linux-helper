#!/bin/bash

# Browser module - Multiple browser options

MODULE_TITLE="Web Browsers"
MODULE_DEPENDENCIES=()

# Install browser packages
install_browsers_packages() {
    log_info "Installing browser packages..."
    
    # Show browser selection menu
    local browser_options=(
        "librewolf" "LibreWolf - Privacy-focused Firefox fork"
        "firefox" "Firefox - Mozilla's web browser"
        "chromium" "Chromium - Open source Chrome"
        "brave" "Brave - Privacy-focused browser"
        "google-chrome" "Google Chrome - Popular web browser"
        "vivaldi" "Vivaldi - Feature-rich browser"
        "tor-browser" "Tor Browser - Anonymous browsing"
    )
    
    local selected_browsers=($(dialog --clear \
        --backtitle "Linux Helper - Browser Selection" \
        --title "Select Browsers to Install" \
        --checklist "Choose browsers to install:" 15 60 7 \
        "${browser_options[@]}" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        log_warning "Browser selection cancelled"
        return 0
    fi
    
    if [[ ${#selected_browsers[@]} -eq 0 ]]; then
        log_warning "No browsers selected"
        return 0
    fi
    
    # Install selected browsers
    for browser in "${selected_browsers[@]}"; do
        install_browser "$browser"
    done
    
    log_success "Browser installation completed"
}

# Install individual browser
install_browser() {
    local browser="$1"
    
    case "$browser" in
        "librewolf")
            install_package "librewolf-bin"
            ;;
        "firefox")
            install_package "firefox"
            ;;
        "chromium")
            install_package "chromium"
            ;;
        "brave")
            install_package "brave-bin"
            ;;
        "google-chrome")
            install_package "google-chrome"
            ;;
        "vivaldi")
            install_package "vivaldi"
            ;;
        "tor-browser")
            install_package "tor-browser"
            ;;
        *)
            log_warning "Unknown browser: $browser"
            ;;
    esac
}

# Configure browsers
configure_browsers() {
    log_info "Configuring browsers..."
    
    # Set default browser (if only one is installed)
    configure_default_browser
    
    log_success "Browser configuration completed"
}

# Configure default browser
configure_default_browser() {
    local browsers=()
    
    # Check which browsers are installed
    for browser in librewolf firefox chromium brave google-chrome vivaldi; do
        if command -v "$browser" >/dev/null 2>&1; then
            browsers+=("$browser")
        fi
    done
    
    if [[ ${#browsers[@]} -eq 1 ]]; then
        # Only one browser installed, set as default
        local browser="${browsers[0]}"
        xdg-settings set default-web-browser "${browser}.desktop"
        log_success "Set $browser as default browser"
    elif [[ ${#browsers[@]} -gt 1 ]]; then
        # Multiple browsers, let user choose
        local browser_options=()
        for browser in "${browsers[@]}"; do
            browser_options+=("$browser" "$browser")
        done
        
        local default_browser=$(dialog --clear \
            --backtitle "Linux Helper - Default Browser" \
            --title "Select Default Browser" \
            --menu "Choose your default browser:" 10 50 ${#browsers[@]} \
            "${browser_options[@]}" \
            2>&1 >/dev/tty)
        
        if [[ $? -eq 0 ]]; then
            xdg-settings set default-web-browser "${default_browser}.desktop"
            log_success "Set $default_browser as default browser"
        fi
    fi
}

