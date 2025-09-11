#!/bin/bash

# TUI Fallback Module
# This module provides a simple text-based interface without fzf dependency

# Note: Required modules should be sourced by the calling script
# This module assumes colors.sh, logging.sh, config.sh, and data_loader.sh are already loaded

# =============================================================================
# FALLBACK TUI FUNCTIONS
# =============================================================================

# Show category selection without fzf
show_category_menu_fallback() {
    local title="Select Category"
    local subtitle="Choose a category to browse packages"
    
    clear
    print_header "$title" "$COLOR_BLUE"
    print_color "$COLOR_CYAN" "$subtitle"
    echo
    
    # Create category list with package counts
    local categories=()
    local category_names=()
    local category_counts=()
    
    while IFS= read -r category; do
        if [[ -n "$category" ]]; then
            local cat_packages
            cat_packages=$(get_packages_by_category "$category" | wc -l)
            local category_display=$(echo "$category" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
            
            categories+=("$category")
            category_names+=("$category_display")
            category_counts+=("$cat_packages")
        fi
    done < <(get_all_categories)
    
    # Display categories
    for i in "${!categories[@]}"; do
        local num=$((i + 1))
        print_color "$COLOR_GREEN" "$num) ${category_names[$i]} (${category_counts[$i]} packages)"
    done
    
    echo
    print_separator "$COLOR_GRAY"
    
    # Get user selection
    while true; do
        print_color_n "$COLOR_CYAN" "Enter category number (1-${#categories[@]}) or 'q' to quit: "
        read -r selection
        
        case "$selection" in
            [1-9]|[1-9][0-9])
                local index=$((selection - 1))
                if [[ $index -ge 0 && $index -lt ${#categories[@]} ]]; then
                    echo "${categories[$index]}"
                    return 0
                else
                    print_error "Invalid selection. Please enter a number between 1 and ${#categories[@]}"
                fi
                ;;
            [qQ])
                return 1
                ;;
            *)
                print_error "Invalid input. Please enter a number or 'q' to quit"
                ;;
        esac
    done
}

# Show package selection without fzf
show_package_menu_fallback() {
    local category="$1"
    
    if [[ -z "$category" ]]; then
        log_error "Category is required for package menu"
        return 1
    fi
    
    local title="Select Packages"
    local category_display=$(echo "$category" | sed 's/-/ /g' | sed 's/\b\w/\U&/g')
    local subtitle="Choose packages from: $category_display"
    
    clear
    print_header "$title" "$COLOR_BLUE"
    print_color "$COLOR_CYAN" "$subtitle"
    echo
    
    # Get packages for the category
    local packages
    packages=$(get_packages_by_category "$category")
    
    if [[ -z "$packages" ]]; then
        print_error "No packages found for category: $category"
        return 1
    fi
    
    # Create package arrays
    local package_list=()
    local package_names=()
    local package_descs=()
    local package_guis=()
    
    while IFS= read -r package; do
        if [[ -n "$package" ]]; then
            local package_name
            package_name=$(get_package_name "$package")
            local package_desc
            package_desc=$(get_package_short_description "$package")
            local has_gui
            has_gui=$(get_package_has_gui "$package")
            
            package_list+=("$package")
            package_names+=("$package_name")
            package_descs+=("$package_desc")
            package_guis+=("$has_gui")
        fi
    done < <(echo "$packages")
    
    # Display packages
    for i in "${!package_list[@]}"; do
        local num=$((i + 1))
        local gui_indicator=""
        if [[ "${package_guis[$i]}" == "true" ]]; then
            gui_indicator="🖥️ "
        else
            gui_indicator="💻 "
        fi
        
        print_color "$COLOR_GREEN" "$num) $gui_indicator${package_names[$i]}"
        print_color "$COLOR_GRAY" "   ${package_descs[$i]}"
    done
    
    echo
    print_separator "$COLOR_GRAY"
    print_color "$COLOR_YELLOW" "Enter package numbers separated by spaces (e.g., 1 3 5) or 'q' to quit: "
    
    # Get user selection
    read -r selection
    
    if [[ "$selection" == "q" || "$selection" == "Q" ]]; then
        return 1
    fi
    
    # Parse selection
    local selected_packages=""
    for num in $selection; do
        if [[ "$num" =~ ^[0-9]+$ ]]; then
            local index=$((num - 1))
            if [[ $index -ge 0 && $index -lt ${#package_list[@]} ]]; then
                selected_packages+="${package_list[$index]}"$'\n'
            fi
        fi
    done
    
    echo "$selected_packages"
}

# Main TUI navigation with fallback
run_tui_navigation_fallback() {
    local selected_packages=""
    
    while true; do
        # Show category selection
        local selected_category
        selected_category=$(show_category_menu_fallback)
        
        if [[ -z "$selected_category" ]]; then
            # User pressed 'q' or cancelled
            break
        fi
        
        # Show package selection for the category
        local category_packages
        category_packages=$(show_package_menu_fallback "$selected_category")
        
        if [[ -n "$category_packages" ]]; then
            # Add selected packages to the list
            selected_packages+="$category_packages"
        fi
        
        # Ask if user wants to continue browsing
        echo
        print_color "$COLOR_CYAN" "Continue browsing other categories? (y/N): "
        read -r continue_choice
        
        case "$continue_choice" in
            [yY]|[yY][eE][sS])
                continue
                ;;
            *)
                break
                ;;
        esac
    done
    
    # Return selected packages
    echo "$selected_packages"
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

# Export all fallback TUI functions
export -f show_category_menu_fallback
export -f show_package_menu_fallback
export -f run_tui_navigation_fallback
