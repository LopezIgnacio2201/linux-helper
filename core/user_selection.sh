#!/bin/bash

# User type selection functions

# Select user type
select_user_type() {
    log_info "Selecting user type..."
    
    local user_type_options=(
        "poweruser" "$(get_text "poweruser") - Full control, select individual modules and packages"
        "common" "$(get_text "common") - Predefined profiles with some customization"
        "newbie" "$(get_text "newbie") - Guided setup with use-case selection"
    )
    
    USER_TYPE=$(dialog --clear \
        --backtitle "Linux Helper - User Type Selection" \
        --title "$(get_text "select_user_type")" \
        --menu "Choose your experience level:" 12 70 3 \
        "${user_type_options[@]}" \
        2>&1 >/dev/tty)
    
    if [[ $? -ne 0 ]]; then
        error_exit "User type selection cancelled"
    fi
    
    log_success "User type selected: ${USER_TYPE}"
}

# Select modules for poweruser
select_poweruser_modules() {
    log_info "Poweruser module selection..."
    
    # Get available modules
    local available_modules=()
    log_info "Scanning modules directory: ${MODULES_DIR}"
    
    for module_file in "${MODULES_DIR}"/*.sh; do
        if [[ -f "$module_file" ]]; then
            local module_name=$(basename "$module_file" .sh)
            log_info "Found module: $module_name"
            local module_title=$(get_module_title "$module_name")
            log_info "Module title: $module_title"
            available_modules+=("$module_name" "$module_title")
        fi
    done
    
    log_info "Total modules found: ${#available_modules[@]}"
    
    if [[ ${#available_modules[@]} -eq 0 ]]; then
        error_exit "No modules found in ${MODULES_DIR}"
    fi
    
    log_info "About to show module selection dialog..."
    
    # Create checklist dialog
    SELECTED_MODULES=($(dialog --clear \
        --backtitle "Linux Helper - Module Selection" \
        --title "$(get_text "select_modules")" \
        --checklist "Select modules to install:" 20 60 10 \
        "${available_modules[@]}" \
        2>&1 >/dev/tty))
    
    local dialog_exit_code=$?
    log_info "Dialog exit code: $dialog_exit_code"
    
    if [[ $dialog_exit_code -ne 0 ]]; then
        error_exit "Module selection cancelled"
    fi
    
    log_success "Selected modules: ${SELECTED_MODULES[*]}"
}

# Select modules for common user
select_common_modules() {
    log_info "Common user module selection..."
    
    # Predefined profiles for common users
    local profile_options=(
        "developer" "Developer - Programming tools, IDEs, version control"
        "gamer" "Gamer - Gaming tools, Steam, Proton, Wine"
        "content_creator" "Content Creator - Video/photo editing, streaming"
        "office" "Office - Productivity tools, browsers, office suite"
        "minimal" "Minimal - Essential tools only"
        "custom" "Custom - Select individual modules"
    )
    
    local selected_profile=$(dialog --clear \
        --backtitle "Linux Helper - Profile Selection" \
        --title "Select your profile:" \
        --menu "Choose a predefined profile or customize:" 15 70 6 \
        "${profile_options[@]}" \
        2>&1 >/dev/tty)
    
    if [[ $? -ne 0 ]]; then
        error_exit "Profile selection cancelled"
    fi
    
    # Set modules based on profile
    case "$selected_profile" in
        "developer")
            SELECTED_MODULES=("terminal" "programming" "browsers" "git")
            ;;
        "gamer")
            SELECTED_MODULES=("gaming" "browsers" "terminal")
            ;;
        "content_creator")
            SELECTED_MODULES=("multimedia" "browsers" "terminal" "programming")
            ;;
        "office")
            SELECTED_MODULES=("browsers" "office" "terminal")
            ;;
        "minimal")
            SELECTED_MODULES=("terminal" "browsers")
            ;;
        "custom")
            select_poweruser_modules
            return
            ;;
    esac
    
    log_success "Profile selected: ${selected_profile}"
    log_success "Selected modules: ${SELECTED_MODULES[*]}"
}

# Select modules for newbie user
select_newbie_modules() {
    log_info "Newbie user module selection..."
    
    # Use case selection for newbies
    local usecase_options=(
        "gaming" "Gaming - Play games on Linux"
        "programming" "Programming - Learn to code"
        "office" "Office Work - Productivity and documents"
        "multimedia" "Multimedia - Video, music, and photos"
        "web_browsing" "Web Browsing - Internet and social media"
        "dont_know" "I don't know - Install everything"
    )
    
    local selected_usecases=($(dialog --clear \
        --backtitle "Linux Helper - Use Case Selection" \
        --title "What will you use your system for?" \
        --checklist "Select all that apply:" 15 60 6 \
        "${usecase_options[@]}" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        error_exit "Use case selection cancelled"
    fi
    
    # Convert use cases to modules
    SELECTED_MODULES=("terminal" "browsers")  # Always include these
    
    for usecase in "${selected_usecases[@]}"; do
        case "$usecase" in
            "gaming")
                SELECTED_MODULES+=("gaming")
                ;;
            "programming")
                SELECTED_MODULES+=("programming")
                ;;
            "office")
                SELECTED_MODULES+=("office")
                ;;
            "multimedia")
                SELECTED_MODULES+=("multimedia")
                ;;
            "dont_know")
                # Install everything for newbies
                SELECTED_MODULES=("terminal" "browsers" "gaming" "programming" "office" "multimedia")
                break
                ;;
        esac
    done
    
    log_success "Selected use cases: ${selected_usecases[*]}"
    log_success "Selected modules: ${SELECTED_MODULES[*]}"
}

