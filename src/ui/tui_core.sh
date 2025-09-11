#!/bin/bash

# TUI Core Module
# This module provides basic TUI functionality using fzf for navigation

# Note: Required modules should be sourced by the calling script
# This module assumes colors.sh, logging.sh, config.sh, and data_loader.sh are already loaded

# =============================================================================
# TUI CONFIGURATION
# =============================================================================

# TUI dimensions and colors
readonly TUI_HEIGHT=20
readonly TUI_WIDTH=80

# fzf options
readonly FZF_OPTS="--height=$TUI_HEIGHT --border --reverse --ansi"
readonly FZF_PREVIEW_OPTS="--preview-window=right:$TUI_PREVIEW_WIDTH"

# fzf key bindings for navigation
readonly FZF_NAV_OPTS="--bind=right:accept,left:abort,q:abort"

# =============================================================================
# TUI UTILITY FUNCTIONS
# =============================================================================

# Check if fzf is available
check_fzf_dependency() {
    if ! command -v fzf &> /dev/null; then
        log_error "fzf is required but not installed. Please install it with: sudo pacman -S fzf"
        return 1
    fi
    return 0
}

# Clear screen and show header
show_tui_header() {
    local title="$1"
    local subtitle="$2"
    
    # Don't clear screen when used with fzf as it interferes with the interface
    if [[ -z "$FZF_INTERACTIVE" ]]; then
        clear
    fi
    print_header "$title" "$COLOR_BLUE"
    if [[ -n "$subtitle" ]]; then
        print_color "$COLOR_CYAN" "$subtitle"
        echo
    fi
}

# Show TUI footer with instructions
show_tui_footer() {
    echo
    print_separator "$COLOR_GRAY"
    print_color "$COLOR_YELLOW" "Navigation: ↑↓ (select) | → (enter/confirm) | ← (back/exit) | Tab (toggle) | q (quit)"
}

# =============================================================================
# CATEGORY SELECTION FUNCTIONS
# =============================================================================

# Show category selection menu
show_category_menu() {
    local title="Select Category"
    local subtitle="Choose a category to browse packages"
    local selected_count="$1"
    
    # Don't show header when using fzf as it interferes with the interface
    # show_tui_header "$title" "$subtitle"
    
    # Check dependencies
    if ! check_fzf_dependency; then
        return 1
    fi
    
    # Create category list with package counts
    local category_list=""
    while IFS= read -r category; do
        if [[ -n "$category" ]]; then
            local cat_packages
            cat_packages=$(get_packages_by_category "$category" | grep -c '^[a-zA-Z0-9-][a-zA-Z0-9-]*$')
            local category_display=$(echo "$category" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
            category_list+="$category_display ($cat_packages packages)"$'\n'
        fi
    done < <(get_all_categories)
    
    
    # Add confirm option if packages are selected
    if [[ -n "$selected_count" ]] && [[ "$selected_count" -gt 0 ]]; then
        category_list+="🚀 CONFIRM INSTALLATION ($selected_count packages selected)"$'\n'
    fi
    
    # Show category selection with fzf
    local selected_category
    local header_text="Select a category to browse packages (→ enter, ← exit, q quit)"
    if [[ -n "$selected_count" ]] && [[ "$selected_count" -gt 0 ]]; then
        header_text="Select a category or confirm installation ($selected_count packages selected) (→ enter, ← exit, q quit)"
    fi
    
    # Use fzf with proper input/output handling and navigation
    selected_category=$(echo "$category_list" | fzf $FZF_OPTS $FZF_NAV_OPTS --prompt="Category: " --header="$header_text")
    
    if [[ -z "$selected_category" ]]; then
        return 1
    fi
    
    # Check if confirm was selected
    if [[ "$selected_category" == *"CONFIRM INSTALLATION"* ]]; then
        echo "CONFIRM"
        return 0
    fi
    
    # Convert back to category name
    local category_name
    category_name=$(echo "$selected_category" | sed 's/ ([0-9]* packages)//' | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]')
    
    echo "$category_name"
}

# =============================================================================
# PACKAGE SELECTION FUNCTIONS
# =============================================================================

# Show package selection menu for a category
show_package_menu() {
    local category="$1"
    local previously_selected="$2"
    
    if [[ -z "$category" ]]; then
        log_error "Category is required for package menu"
        return 1
    fi
    
    local title="Select Packages"
    local category_display=$(echo "$category" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
    local subtitle="Choose packages from: $category_display"
    
    # Count previously selected packages in this category
    local prev_selected_count=0
    if [[ -n "$previously_selected" ]]; then
        local category_package_names
        category_package_names=$(get_packages_by_category "$category")
        while IFS= read -r cat_package; do
            if [[ -n "$cat_package" ]] && echo "$previously_selected" | grep -q "^$cat_package$"; then
                ((prev_selected_count++))
            fi
        done < <(echo "$category_package_names")
    fi
    
    # Don't show header when using fzf as it interferes with the interface
    # show_tui_header "$title" "$subtitle"
    
    # Check dependencies
    if ! check_fzf_dependency; then
        return 1
    fi
    
    # Get packages for the category
    local packages
    packages=$(get_packages_by_category "$category")
    
    if [[ -z "$packages" ]]; then
        print_error "No packages found for category: $category"
        return 1
    fi
    
    # Create package list with descriptions
    local package_list=""
    while IFS= read -r package; do
        local package_name
        package_name=$(get_package_name "$package")
        local package_desc
        package_desc=$(get_package_short_description "$package")
        local has_gui
        has_gui=$(get_package_has_gui "$package")
        
        # Add GUI indicator
        local gui_indicator=""
        if [[ "$has_gui" == "true" ]]; then
            gui_indicator="🖥️ "
        else
            gui_indicator="💻 "
        fi
        
        package_list+="$gui_indicator$package_name - $package_desc"$'\n'
    done < <(echo "$packages")
    
    # Show package selection with fzf and preview
    local selected_packages
    selected_packages=$(echo "$package_list" | fzf $FZF_OPTS $FZF_PREVIEW_OPTS $FZF_NAV_OPTS \
        --multi \
        --prompt="Packages: " \
        --header="Select packages to install (Tab select multiple, → confirm, ← back, q quit) - $prev_selected_count previously selected in this category" \
        --preview="show_package_preview {} $category")
    
    if [[ -z "$selected_packages" ]]; then
        return 1
    fi
    
    # Extract package names from selection
    local package_names=""
    while IFS= read -r line; do
        if [[ -n "$line" ]]; then
            # Remove GUI indicator and description, keep only package name
            local package_name
            # Extract package name by removing emoji and description
            package_name=$(echo "$line" | sed 's/^[^a-zA-Z]*//' | sed 's/ - .*$//')
            # Verify the package name exists in our data
            if [[ -n "$package_name" ]] && get_package_info "$package_name" >/dev/null 2>&1; then
                package_names+="$package_name"$'\n'
            fi
        fi
    done < <(echo "$selected_packages")
    
    echo "$package_names"
}

# =============================================================================
# PACKAGE PREVIEW FUNCTIONS
# =============================================================================

# Show package preview for fzf
show_package_preview() {
    local package_line="$1"
    local category="$2"
    
    if [[ -z "$package_line" ]]; then
        echo "No package selected"
        return 0
    fi
    
    # Extract package name from the line (remove GUI indicator and description)
    local package_name
    package_name=$(echo "$package_line" | sed 's/^[🖥️💻] //' | sed 's/ - .*$//')
    
    if [[ -z "$package_name" ]]; then
        echo "Invalid package name"
        return 0
    fi
    
    # Show package information
    echo "Package: $package_name"
    echo "Category: $category"
    echo "GUI: $(get_package_has_gui "$package_name")"
    echo
    echo "Description:"
    echo "═══════════════════════════════════════════════════════════════"
    get_simple_description "$package_name"
    echo
    echo "Image Preview:"
    echo "═══════════════════════════════════════════════════════════════"
    get_image_content "$package_name"
}

# Show package details interactively (for I keybind)
show_package_details_interactive() {
    local package_line="$1"
    
    if [[ -z "$package_line" ]]; then
        echo "No package selected"
        return 0
    fi
    
    # Extract package name from the line (remove GUI indicator and description)
    local package_name
    package_name=$(echo "$package_line" | sed 's/^[🖥️💻] //' | sed 's/ - .*$//')
    
    if [[ -z "$package_name" ]]; then
        echo "Invalid package name"
        return 0
    fi
    
    # Show detailed information
    clear
    print_header "Package Details" "$COLOR_BLUE"
    print_color "$COLOR_CYAN" "Package: $package_name"
    print_color "$COLOR_WHITE" "Category: $(get_package_category "$package_name")"
    print_color "$COLOR_WHITE" "GUI: $(get_package_has_gui "$package_name")"
    echo
    
    print_color "$COLOR_YELLOW" "Detailed Information:"
    print_separator "$COLOR_GRAY"
    get_detailed_description "$package_name"
    
    echo
    print_color "$COLOR_YELLOW" "Press any key to continue..."
    read -n 1 -s
}

# Show package details (legacy function)
show_package_details() {
    local package_name="$1"
    
    if [[ -z "$package_name" ]]; then
        log_error "Package name is required"
        return 1
    fi
    
    local title="Package Details"
    local subtitle="Information for: $package_name"
    
    show_tui_header "$title" "$subtitle"
    
    # Get package information
    local package_info
    package_info=$(get_package_info "$package_name")
    
    if [[ -z "$package_info" ]]; then
        print_error "Package information not found: $package_name"
        return 1
    fi
    
    # Display package information
    print_color "$COLOR_CYAN" "Package: $package_name"
    print_color "$COLOR_WHITE" "Category: $(get_package_category "$package_name")"
    print_color "$COLOR_WHITE" "GUI: $(get_package_has_gui "$package_name")"
    echo
    
    # Show simple description
    print_color "$COLOR_YELLOW" "Description:"
    get_simple_description "$package_name"
    
    echo
    print_color "$COLOR_YELLOW" "Press any key to continue..."
    read -n 1 -s
}

# =============================================================================
# MAIN TUI NAVIGATION
# =============================================================================

# Main TUI navigation loop
run_tui_navigation() {
    local selected_packages=""
    
    while true; do
        # Count selected packages (only count non-empty lines with valid package names)
        local selected_count=0
        if [[ -n "$selected_packages" ]]; then
            selected_count=$(echo "$selected_packages" | grep -c '^[a-zA-Z0-9-][a-zA-Z0-9-]*$')
        fi
        
        # Show category selection with selected count
        local selected_category
        selected_category=$(show_category_menu "$selected_count")
        
        if [[ -z "$selected_category" ]]; then
            # User pressed ESC or cancelled
            break
        fi
        
        # Check if confirm was selected
        if [[ "$selected_category" == "CONFIRM" ]]; then
            # User wants to install selected packages
            log_info "User confirmed installation of $selected_count packages"
            break
        fi
        
        # Show package selection for the category with previously selected packages
        local category_packages
        category_packages=$(show_package_menu "$selected_category" "$selected_packages")
        
        if [[ -n "$category_packages" ]]; then
            # Update the selected packages list with the new selections from this category
            # First, remove any packages from this category that were previously selected
            local category_package_names
            category_package_names=$(get_packages_by_category "$selected_category")
            
            # Remove packages from this category from the selected list
            while IFS= read -r cat_package; do
                if [[ -n "$cat_package" ]]; then
                    selected_packages=$(echo "$selected_packages" | grep -v "^$cat_package$")
                fi
            done < <(echo "$category_package_names")
            
            # Add the newly selected packages from this category
            local added_count=0
            while IFS= read -r package; do
                if [[ -n "$package" ]]; then
                    selected_packages+="$package"$'\n'
                    ((added_count++))
                fi
            done < <(echo "$category_packages")
            log_info "Updated selections for category $selected_category: $added_count packages selected"
        fi
    done
    
    # Return selected packages
    echo "$selected_packages"
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

# Export all TUI functions
export -f check_fzf_dependency
export -f show_tui_header
export -f show_tui_footer
export -f show_category_menu
export -f show_package_menu
export -f show_package_preview
export -f show_package_details_interactive
export -f show_package_details
export -f run_tui_navigation
