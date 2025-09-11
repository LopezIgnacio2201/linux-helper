#!/bin/bash

# Power User Profile Script
# This script handles the power user profile execution

# =============================================================================
# SCRIPT CONFIGURATION
# =============================================================================

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"

# Source the core modules
source "$PROJECT_ROOT/src/utils/colors.sh"
source "$PROJECT_ROOT/src/utils/logging.sh"
source "$PROJECT_ROOT/src/core/config.sh"
source "$PROJECT_ROOT/src/core/data_loader.sh"
source "$PROJECT_ROOT/src/core/package_manager.sh"
source "$PROJECT_ROOT/src/ui/tui_core.sh"
source "$PROJECT_ROOT/src/ui/tui_fallback.sh"

# =============================================================================
# POWER USER PROFILE EXECUTION
# =============================================================================

# Main power user profile function
main() {
    log_info "Starting Power User Profile"
    
    print_header "Power User Profile" "$COLOR_PURPLE"
    print_color "$COLOR_PURPLE" "Setting up advanced experience for experienced users..."
    print_color "$COLOR_GRAY" "This profile will:"
    print_color "$COLOR_GRAY" "• Show full TUI with 12 modules"
    print_color "$COLOR_GRAY" "• Display comprehensive submodules"
    print_color "$COLOR_GRAY" "• Provide full control over all decisions"
    print_color "$COLOR_GRAY" "• Include advanced CLI utilities and tools"
    echo
    
    # Load package data
    if ! load_package_metadata; then
        print_error "Failed to load package metadata"
        exit 1
    fi
    
    # Show package statistics
    local package_count
    package_count=$(get_package_count)
    local category_count
    category_count=$(get_category_count)
    
    print_success "Loaded $package_count packages across $category_count categories"
    
    # Show available categories
    print_info "Available categories:"
    while IFS= read -r category; do
        local cat_packages
        cat_packages=$(get_packages_by_category "$category" | wc -l)
        print_color "$COLOR_CYAN" "  • $category ($cat_packages packages)"
    done < <(get_all_categories)
    
    echo
    print_color "$COLOR_YELLOW" "Starting TUI interface..."
    print_color "$COLOR_GRAY" "You can now browse and select packages for installation"
    echo
    
    # Start TUI navigation (with fallback if fzf not available)
    local selected_packages
    if command -v fzf &> /dev/null; then
        print_info "Using fzf interface..."
        selected_packages=$(run_tui_navigation)
    else
        print_warning "fzf not available, using fallback interface..."
        selected_packages=$(run_tui_navigation_fallback)
    fi
    
    if [[ -n "$selected_packages" ]]; then
        echo
        print_success "Selected packages:"
        while IFS= read -r package; do
            if [[ -n "$package" ]]; then
                print_color "$COLOR_GREEN" "  • $package"
            fi
        done < <(echo "$selected_packages")
        
        echo
        print_color "$COLOR_YELLOW" "Starting package installation..."
        
        # Setup AUR helper
        local aur_helper
        aur_helper=$(setup_aur_helper)
        
        if [[ -z "$aur_helper" ]]; then
            print_error "Failed to setup AUR helper. Installation aborted."
            exit 1
        fi
        
        # Install selected packages
        if install_packages "$selected_packages" "$aur_helper"; then
            print_success "All packages installed successfully!"
        else
            print_warning "Some packages failed to install. Check the summary above."
        fi
    else
        print_info "No packages selected"
    fi
}

# =============================================================================
# SCRIPT EXECUTION
# =============================================================================

# Run main function
main "$@"
