#!/bin/bash

# Module management functions

# Get module title
get_module_title() {
    local module_name="$1"
    local module_file="${MODULES_DIR}/${module_name}.sh"
    
    if [[ -f "$module_file" ]]; then
        # Source the module to get its title
        source "$module_file"
        echo "${MODULE_TITLE:-$module_name}"
    else
        echo "$module_name"
    fi
}

# Install selected modules
install_selected_modules() {
    log_info "Installing selected modules..."
    
    if [[ ${#SELECTED_MODULES[@]} -eq 0 ]]; then
        log_warning "No modules selected"
        return 0
    fi
    
    for module in "${SELECTED_MODULES[@]}"; do
        install_module "$module"
    done
    
    log_success "All selected modules installed"
}

# Install a single module
install_module() {
    local module_name="$1"
    local module_file="${MODULES_DIR}/${module_name}.sh"
    
    if [[ ! -f "$module_file" ]]; then
        log_error "Module file not found: $module_file"
        return 1
    fi
    
    log_info "Installing module: $module_name"
    
    # Source the module
    source "$module_file"
    
    # Check if module has required functions
    if ! declare -f "install_${module_name}_packages" >/dev/null 2>&1; then
        log_error "Module $module_name is missing install_${module_name}_packages function"
        return 1
    fi
    
    # Install packages
    if ! "install_${module_name}_packages"; then
        log_error "Failed to install packages for module: $module_name"
        return 1
    fi
    
    # Install configurations if function exists
    if declare -f "configure_${module_name}" >/dev/null 2>&1; then
        log_info "Configuring module: $module_name"
        if ! "configure_${module_name}"; then
            log_error "Failed to configure module: $module_name"
            return 1
        fi
    fi
    
    log_success "Module $module_name installed successfully"
    return 0
}

# List available modules
list_available_modules() {
    local modules=()
    
    for module_file in "${MODULES_DIR}"/*.sh; do
        if [[ -f "$module_file" ]]; then
            local module_name=$(basename "$module_file" .sh)
            modules+=("$module_name")
        fi
    done
    
    echo "${modules[@]}"
}

# Check module dependencies
check_module_dependencies() {
    local module_name="$1"
    local module_file="${MODULES_DIR}/${module_name}.sh"
    
    if [[ ! -f "$module_file" ]]; then
        return 1
    fi
    
    # Source the module to check dependencies
    source "$module_file"
    
    if [[ -n "${MODULE_DEPENDENCIES:-}" ]]; then
        for dep in "${MODULE_DEPENDENCIES[@]}"; do
            if ! is_package_installed "$dep"; then
                log_warning "Module $module_name requires $dep"
                return 1
            fi
        done
    fi
    
    return 0
}

