#!/bin/bash

# Aliases management functions

# Create aliases for command replacements
create_aliases() {
    local aliases_file="$HOME/.bash_aliases"
    local zsh_aliases_file="$HOME/.zsh_aliases"
    
    log_info "Creating aliases for command replacements..."
    
    # Create .bash_aliases if it doesn't exist
    if [[ ! -f "$aliases_file" ]]; then
        touch "$aliases_file"
        echo "# Linux Helper - Command Aliases" >> "$aliases_file"
        echo "# Generated on $(date)" >> "$aliases_file"
        echo "" >> "$aliases_file"
    fi
    
    # Create .zsh_aliases if it doesn't exist
    if [[ ! -f "$zsh_aliases_file" ]]; then
        touch "$zsh_aliases_file"
        echo "# Linux Helper - Command Aliases" >> "$zsh_aliases_file"
        echo "# Generated on $(date)" >> "$zsh_aliases_file"
        echo "" >> "$zsh_aliases_file"
    fi
    
    # Add aliases to both files
    add_alias_to_file "$aliases_file" "btop" "htop"
    add_alias_to_file "$aliases_file" "lsd" "lsd --tree --depth 1"
    add_alias_to_file "$aliases_file" "fd" "fd"
    add_alias_to_file "$aliases_file" "bat" "cat"
    add_alias_to_file "$aliases_file" "duf" "du"
    add_alias_to_file "$aliases_file" "gdu" "ncdu"
    
    add_alias_to_file "$zsh_aliases_file" "btop" "htop"
    add_alias_to_file "$zsh_aliases_file" "lsd" "lsd --tree --depth 1"
    add_alias_to_file "$zsh_aliases_file" "fd" "fd"
    add_alias_to_file "$zsh_aliases_file" "bat" "cat"
    add_alias_to_file "$zsh_aliases_file" "duf" "du"
    add_alias_to_file "$zsh_aliases_file" "gdu" "ncdu"
    
    # Add source commands to shell configs
    add_source_to_shell_config "$HOME/.bashrc" "$aliases_file"
    add_source_to_shell_config "$HOME/.zshrc" "$zsh_aliases_file"
    
    log_success "Aliases created successfully!"
    log_info "Bash aliases: $aliases_file"
    log_info "Zsh aliases: $zsh_aliases_file"
}

# Add alias to file if not already present
add_alias_to_file() {
    local file="$1"
    local alias_name="$2"
    local command="$3"
    
    # Check if alias already exists
    if ! grep -q "alias $alias_name=" "$file"; then
        echo "alias $alias_name='$command'" >> "$file"
        log_info "Added alias: $alias_name -> $command"
    else
        log_info "Alias $alias_name already exists, skipping..."
    fi
}

# Add source command to shell config if not present
add_source_to_shell_config() {
    local config_file="$1"
    local aliases_file="$2"
    
    if [[ -f "$config_file" ]]; then
        # Check if source command already exists
        if ! grep -q "source.*$(basename "$aliases_file")" "$config_file"; then
            echo "" >> "$config_file"
            echo "# Source Linux Helper aliases" >> "$config_file"
            echo "if [[ -f \"$aliases_file\" ]]; then" >> "$config_file"
            echo "    source \"$aliases_file\"" >> "$config_file"
            echo "fi" >> "$config_file"
            log_info "Added source command to $(basename "$config_file")"
        else
            log_info "Source command already exists in $(basename "$config_file")"
        fi
    fi
}

# Prompt user to create aliases
prompt_create_aliases() {
    if [[ "${USER_TYPE}" == "newbie" ]]; then
        return 0  # Skip for newbie users
    fi
    
    log_info "Prompting user for aliases creation..."
    
    dialog --title "Command Aliases" \
           --yesno "Would you like to create aliases for command replacements?\n\nThis will create aliases like:\n• btop -> htop\n• lsd -> lsd --tree --depth 1\n• bat -> cat\n• duf -> du\n• gdu -> ncdu\n\nAliases will be saved to ~/.bash_aliases and ~/.zsh_aliases" \
           12 60
    
    local response=$?
    
    if [[ $response -eq 0 ]]; then
        create_aliases
        return 0
    else
        log_info "User chose not to create aliases"
        return 1
    fi
}
