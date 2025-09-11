#!/bin/bash

# Data Loader Module
# This module handles loading and parsing package data from YAML files

# =============================================================================
# DATA LOADER CONFIGURATION
# =============================================================================

# Data file paths (from config.sh)
readonly PACKAGES_YAML_FILE="$METADATA_DIR/packages.yaml"
readonly DESCRIPTIONS_DIR_PATH="$DESCRIPTIONS_DIR"
readonly DETAILED_DIR_PATH="$DETAILED_DIR"
readonly IMAGES_DIR_PATH="$IMAGES_DIR"

# =============================================================================
# DATA LOADING FUNCTIONS
# =============================================================================

# Check if yq is available
check_yq_dependency() {
    if ! command -v yq &> /dev/null; then
        log_error "yq is required but not installed. Please install it with: sudo pacman -S yq"
        return 1
    fi
    return 0
}

# Get yq version
get_yq_version() {
    yq --version 2>/dev/null | grep -o 'v[0-9]' | sed 's/v//'
}

# Execute yq command with version compatibility
execute_yq() {
    local query="$1"
    local file="$2"
    local yq_version
    yq_version=$(get_yq_version)
    
    if [[ "$yq_version" == "3" ]]; then
        # yq v3 syntax
        yq read "$file" "$query" 2>/dev/null
    else
        # yq v4+ syntax
        yq eval "$query" "$file" 2>/dev/null
    fi
}

# Simple YAML parsing without yq dependency
parse_yaml_simple() {
    local yaml_file="$1"
    local query="$2"
    
    case "$query" in
        "package_count")
            # Count packages by counting lines that start with "  [package_name]:"
            grep -c "^  [a-zA-Z0-9-]*:" "$yaml_file" 2>/dev/null
            ;;
        "category_count")
            # Count unique categories
            grep "category:" "$yaml_file" | sed 's/.*category: *"\([^"]*\)".*/\1/' | sort -u | wc -l 2>/dev/null
            ;;
        "all_categories")
            # Get all unique categories
            grep "category:" "$yaml_file" | sed 's/.*category: *"\([^"]*\)".*/\1/' | sort -u 2>/dev/null
            ;;
        "package_names")
            # Get all package names
            grep "^  [a-zA-Z0-9-]*:" "$yaml_file" | sed 's/^  \([a-zA-Z0-9-]*\):.*/\1/' 2>/dev/null
            ;;
        "packages_by_category")
            local category="$3"
            # Get packages by category
            awk -v cat="$category" '
                /^  [a-zA-Z0-9-]*:/ { 
                    package = $1; 
                    gsub(/:/, "", package); 
                    gsub(/^  /, "", package);
                }
                /category:/ && $2 == "\"" cat "\"" { 
                    print package 
                }
            ' "$yaml_file" 2>/dev/null
            ;;
    esac
}

# Hybrid function that tries yq first, falls back to simple parsing
execute_yq_hybrid() {
    local query="$1"
    local file="$2"
    local category="$3"
    
    # Try yq first
    local result
    result=$(execute_yq "$query" "$file" 2>/dev/null)
    
    # If yq failed or returned empty, use simple parsing
    if [[ -z "$result" ]]; then
        case "$query" in
            ".packages | length"|"packages | length")
                result=$(parse_yaml_simple "$file" "package_count")
                ;;
            ".packages | to_entries | map(.value.category) | unique | length"|"packages | to_entries | map(.value.category) | unique | length")
                result=$(parse_yaml_simple "$file" "category_count")
                ;;
            ".packages | to_entries | map(.value.category) | unique | .[]"|"packages | to_entries | map(.value.category) | unique | .[]")
                result=$(parse_yaml_simple "$file" "all_categories")
                ;;
            ".packages | keys | .[]"|"packages | keys | .[]")
                result=$(parse_yaml_simple "$file" "package_names")
                ;;
            ".packages | to_entries | map(select(.value.category == \"$category\")) | map(.key) | .[]"|"packages | to_entries | map(select(.value.category == \"$category\")) | map(.key) | .[]")
                result=$(parse_yaml_simple "$file" "packages_by_category" "$category")
                ;;
        esac
    fi
    
    echo "$result"
}

# Load package metadata from YAML
load_package_metadata() {
    log_info "Loading package metadata from $PACKAGES_YAML_FILE"
    
    if [[ ! -f "$PACKAGES_YAML_FILE" ]]; then
        log_error "Package metadata file not found: $PACKAGES_YAML_FILE"
        return 1
    fi
    
    # Check yq dependency
    if ! check_yq_dependency; then
        return 1
    fi
    
    log_info "Package metadata loaded successfully"
    return 0
}

# Get all package names
get_all_package_names() {
    # Use hybrid approach - try yq first, fall back to simple parsing
    local yq_version
    yq_version=$(get_yq_version)
    
    if [[ "$yq_version" == "3" ]]; then
        # yq v3 syntax
        execute_yq_hybrid 'packages | keys | .[]' "$PACKAGES_YAML_FILE"
    else
        # yq v4+ syntax
        execute_yq_hybrid '.packages | keys | .[]' "$PACKAGES_YAML_FILE"
    fi
}

# Get package count
get_package_count() {
    # Use hybrid approach - try yq first, fall back to simple parsing
    local yq_version
    yq_version=$(get_yq_version)
    
    if [[ "$yq_version" == "3" ]]; then
        execute_yq_hybrid 'packages | length' "$PACKAGES_YAML_FILE"
    else
        execute_yq_hybrid '.packages | length' "$PACKAGES_YAML_FILE"
    fi
}

# Get package info by name
get_package_info() {
    local package_name="$1"
    
    if [[ -z "$package_name" ]]; then
        log_error "Package name is required"
        return 1
    fi
    
    if ! check_yq_dependency; then
        return 1
    fi
    
    local yq_version
    yq_version=$(get_yq_version)
    
    if [[ "$yq_version" == "3" ]]; then
        execute_yq "packages.\"$package_name\"" "$PACKAGES_YAML_FILE"
    else
        execute_yq ".packages.\"$package_name\"" "$PACKAGES_YAML_FILE"
    fi
}

# Get package name (display name)
get_package_name() {
    local package_name="$1"
    local package_info
    package_info=$(get_package_info "$package_name")
    
    if [[ -n "$package_info" ]]; then
        local yq_version
        yq_version=$(get_yq_version)
        
        if [[ "$yq_version" == "3" ]]; then
            echo "$package_info" | yq read - '.name' 2>/dev/null
        else
            echo "$package_info" | yq eval '.name' 2>/dev/null
        fi
    fi
}

# Get package short description
get_package_short_description() {
    local package_name="$1"
    local package_info
    package_info=$(get_package_info "$package_name")
    
    if [[ -n "$package_info" ]]; then
        local yq_version
        yq_version=$(get_yq_version)
        
        if [[ "$yq_version" == "3" ]]; then
            echo "$package_info" | yq read - '.short_description' 2>/dev/null
        else
            echo "$package_info" | yq eval '.short_description' 2>/dev/null
        fi
    fi
}

# Get package category
get_package_category() {
    local package_name="$1"
    local package_info
    package_info=$(get_package_info "$package_name")
    
    if [[ -n "$package_info" ]]; then
        local yq_version
        yq_version=$(get_yq_version)
        
        if [[ "$yq_version" == "3" ]]; then
            echo "$package_info" | yq read - '.category' 2>/dev/null
        else
            echo "$package_info" | yq eval '.category' 2>/dev/null
        fi
    fi
}

# Get package GUI status
get_package_has_gui() {
    local package_name="$1"
    local package_info
    package_info=$(get_package_info "$package_name")
    
    if [[ -n "$package_info" ]]; then
        local yq_version
        yq_version=$(get_yq_version)
        
        if [[ "$yq_version" == "3" ]]; then
            echo "$package_info" | yq read - '.has_gui' 2>/dev/null
        else
            echo "$package_info" | yq eval '.has_gui' 2>/dev/null
        fi
    fi
}

# Get packages by category
get_packages_by_category() {
    local category="$1"
    
    if [[ -z "$category" ]]; then
        log_error "Category is required"
        return 1
    fi
    
    # Use hybrid approach - try yq first, fall back to simple parsing
    local yq_version
    yq_version=$(get_yq_version)
    
    if [[ "$yq_version" == "3" ]]; then
        execute_yq_hybrid "packages | to_entries | map(select(.value.category == \"$category\")) | map(.key) | .[]" "$PACKAGES_YAML_FILE" "$category"
    else
        execute_yq_hybrid ".packages | to_entries | map(select(.value.category == \"$category\")) | map(.key) | .[]" "$PACKAGES_YAML_FILE" "$category"
    fi
}

# Get all categories
get_all_categories() {
    # Use hybrid approach - try yq first, fall back to simple parsing
    local yq_version
    yq_version=$(get_yq_version)
    
    if [[ "$yq_version" == "3" ]]; then
        execute_yq_hybrid 'packages | to_entries | map(.value.category) | unique | .[]' "$PACKAGES_YAML_FILE"
    else
        execute_yq_hybrid '.packages | to_entries | map(.value.category) | unique | .[]' "$PACKAGES_YAML_FILE"
    fi
}

# Get category count
get_category_count() {
    # Use hybrid approach - try yq first, fall back to simple parsing
    local yq_version
    yq_version=$(get_yq_version)
    
    if [[ "$yq_version" == "3" ]]; then
        execute_yq_hybrid 'packages | to_entries | map(.value.category) | unique | length' "$PACKAGES_YAML_FILE"
    else
        execute_yq_hybrid '.packages | to_entries | map(.value.category) | unique | length' "$PACKAGES_YAML_FILE"
    fi
}

# =============================================================================
# DESCRIPTION LOADING FUNCTIONS
# =============================================================================

# Get simple description file path
get_simple_description_path() {
    local package_name="$1"
    local category
    category=$(get_package_category "$package_name")
    
    if [[ -z "$category" ]]; then
        return 1
    fi
    
    echo "$DESCRIPTIONS_DIR_PATH/$category/$package_name.md"
}

# Get detailed description file path
get_detailed_description_path() {
    local package_name="$1"
    local category
    category=$(get_package_category "$package_name")
    
    if [[ -z "$category" ]]; then
        return 1
    fi
    
    echo "$DETAILED_DIR_PATH/$category/$package_name.md"
}

# Get simple description content
get_simple_description() {
    local package_name="$1"
    local desc_path
    desc_path=$(get_simple_description_path "$package_name")
    
    if [[ -f "$desc_path" ]]; then
        cat "$desc_path"
    else
        echo "No description available"
    fi
}

# Get detailed description content
get_detailed_description() {
    local package_name="$1"
    local desc_path
    desc_path=$(get_detailed_description_path "$package_name")
    
    if [[ -f "$desc_path" ]]; then
        cat "$desc_path"
    else
        echo "No detailed description available"
    fi
}

# =============================================================================
# IMAGE LOADING FUNCTIONS
# =============================================================================

# Get image file path
get_image_path() {
    local package_name="$1"
    local category
    category=$(get_package_category "$package_name")
    
    if [[ -z "$category" ]]; then
        return 1
    fi
    
    echo "$IMAGES_DIR_PATH/$category/$package_name.txt"
}

# Get image content
get_image_content() {
    local package_name="$1"
    local image_path
    image_path=$(get_image_path "$package_name")
    
    if [[ -f "$image_path" ]]; then
        cat "$image_path"
    else
        echo "No image available"
    fi
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

# Test data loader functionality
test_data_loader() {
    log_info "Testing data loader functionality..."
    
    # Test package count
    local count
    count=$(get_package_count)
    if [[ "$count" -gt 0 ]]; then
        print_success "Package count: $count"
    else
        print_error "Failed to get package count"
        return 1
    fi
    
    # Test category count
    local cat_count
    cat_count=$(get_category_count)
    if [[ "$cat_count" -gt 0 ]]; then
        print_success "Category count: $cat_count"
    else
        print_error "Failed to get category count"
        return 1
    fi
    
    # Test getting first package
    local first_package
    first_package=$(get_all_package_names | head -1)
    if [[ -n "$first_package" ]]; then
        print_success "First package: $first_package"
        
        # Test package info
        local package_name
        package_name=$(get_package_name "$first_package")
        if [[ -n "$package_name" ]]; then
            print_success "Package display name: $package_name"
        fi
        
        # Test category
        local category
        category=$(get_package_category "$first_package")
        if [[ -n "$category" ]]; then
            print_success "Package category: $category"
        fi
    else
        print_error "Failed to get first package"
        return 1
    fi
    
    print_success "Data loader test completed successfully"
    return 0
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

# Export all data loader functions
export -f check_yq_dependency
export -f get_yq_version
export -f execute_yq
export -f parse_yaml_simple
export -f execute_yq_hybrid
export -f load_package_metadata
export -f get_all_package_names
export -f get_package_count
export -f get_package_info
export -f get_package_name
export -f get_package_short_description
export -f get_package_category
export -f get_package_has_gui
export -f get_packages_by_category
export -f get_all_categories
export -f get_category_count
export -f get_simple_description_path
export -f get_detailed_description_path
export -f get_simple_description
export -f get_detailed_description
export -f get_image_path
export -f get_image_content
export -f test_data_loader
