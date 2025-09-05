#!/bin/bash

# Language selection and internationalization functions

# Language selection menu
select_language() {
    log_info "Selecting language..."
    
    local language_options=(
        "English" "English"
        "Español" "Spanish"
    )
    
    log_info "About to show language selection dialog..."
    LANGUAGE=$(dialog --clear \
        --backtitle "Linux Helper - Language Selection" \
        --title "Select Language / Seleccionar Idioma" \
        --menu "Choose your preferred language:" 10 50 2 \
        "${language_options[@]}" \
        2>&1 >/dev/tty)
    
    local dialog_exit_code=$?
    log_info "Dialog exit code: $dialog_exit_code"
    
    if [[ $dialog_exit_code -ne 0 ]]; then
        error_exit "Language selection cancelled"
    fi
    
    log_success "Language selected: ${LANGUAGE}"
}

# Get localized text
get_text() {
    local key="$1"
    
    case "${LANGUAGE}" in
        "English")
            case "$key" in
                "welcome") echo "Welcome to Linux Helper!" ;;
                "system_setup") echo "Automated Arch/EndeavourOS Setup" ;;
                "modular") echo "Modular • Customizable • Powerful" ;;
                "select_user_type") echo "Select your user type:" ;;
                "poweruser") echo "Power User" ;;
                "common") echo "Common Arch User" ;;
                "newbie") echo "Newbie User" ;;
                "select_modules") echo "Select modules to install:" ;;
                "install_packages") echo "Installing packages..." ;;
                "configure_system") echo "Configuring system..." ;;
                "setup_complete") echo "Setup Complete!" ;;
                "reboot_required") echo "Please reboot to apply all changes." ;;
                *) echo "$key" ;;
            esac
            ;;
        "Español")
            case "$key" in
                "welcome") echo "¡Bienvenido a Linux Helper!" ;;
                "system_setup") echo "Configuración Automatizada de Arch/EndeavourOS" ;;
                "modular") echo "Modular • Personalizable • Poderoso" ;;
                "select_user_type") echo "Selecciona tu tipo de usuario:" ;;
                "poweruser") echo "Usuario Avanzado" ;;
                "common") echo "Usuario Común de Arch" ;;
                "newbie") echo "Usuario Principiante" ;;
                "select_modules") echo "Selecciona módulos para instalar:" ;;
                "install_packages") echo "Instalando paquetes..." ;;
                "configure_system") echo "Configurando sistema..." ;;
                "setup_complete") echo "¡Configuración Completa!" ;;
                "reboot_required") echo "Por favor reinicia para aplicar todos los cambios." ;;
                *) echo "$key" ;;
            esac
            ;;
        *)
            echo "$key"
            ;;
    esac
}

