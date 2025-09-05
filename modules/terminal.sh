#!/bin/bash

# Terminal module - Ghostty, Zsh, Zellij, Starship, Fastfetch

MODULE_TITLE="Terminal Setup"
MODULE_DEPENDENCIES=()

# Install terminal packages
install_terminal_packages() {
    log_info "Installing terminal packages..."
    
    local packages=(
        "ghostty"
        "zsh"
        "zellij"
        "starship"
        "fastfetch"
        "fira-code-nerd-font"
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
        "zsh-completions"
    )
    
    install_packages "${packages[@]}"
}

# Configure terminal setup
configure_terminal() {
    log_info "Configuring terminal setup..."
    
    # Set zsh as default shell
    configure_zsh_shell
    
    # Configure ghostty
    configure_ghostty
    
    # Configure zsh
    configure_zsh
    
    # Configure zellij
    configure_zellij
    
    # Configure starship
    configure_starship
    
    # Configure fastfetch
    configure_fastfetch
    
    log_success "Terminal configuration completed"
}

# Set zsh as default shell
configure_zsh_shell() {
    log_info "Setting zsh as default shell..."
    
    if [[ "$SHELL" != "/bin/zsh" ]]; then
        sudo chsh -s /bin/zsh "$USER"
        log_success "Zsh set as default shell (will take effect after reboot)"
    else
        log_info "Zsh is already the default shell"
    fi
}

# Configure ghostty
configure_ghostty() {
    log_info "Configuring Ghostty..."
    
    local ghostty_config_dir="$HOME/.config/ghostty"
    mkdir -p "$ghostty_config_dir"
    
    # Copy ghostty config
    if [[ -f "${CONFIGS_DIR}/ghostty/config" ]]; then
        cp "${CONFIGS_DIR}/ghostty/config" "$ghostty_config_dir/"
        log_success "Ghostty configuration applied"
    else
        # Create default config
        cat > "$ghostty_config_dir/config" << 'EOF'
theme = catppuccin-mocha

command = /bin/zsh

font-family = "FiraCode Nerd Font"
font-size = 10

window-padding-x = 20
window-padding-y = 14
window-padding-balance = false
EOF
        log_success "Default Ghostty configuration created"
    fi
}

# Configure zsh
configure_zsh() {
    log_info "Configuring Zsh..."
    
    # Create .zshrc if it doesn't exist
    if [[ ! -f "$HOME/.zshrc" ]]; then
        touch "$HOME/.zshrc"
    fi
    
    # Configure zshrc.d directory
    local zshrc_d_dir="$HOME/.config/zshrc.d"
    mkdir -p "$zshrc_d_dir"
    
    # Copy zshrc.d files
    if [[ -d "${CONFIGS_DIR}/zshrc.d" ]]; then
        cp "${CONFIGS_DIR}/zshrc.d"/* "$zshrc_d_dir/"
        log_success "Zsh configuration files copied"
    fi
    
    # Create main .zshrc
    cat > "$HOME/.zshrc" << 'EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source configuration files
if [[ -d "$HOME/.config/zshrc.d" ]]; then
    for file in "$HOME/.config/zshrc.d"/*.zsh; do
        [[ -f "$file" ]] && source "$file"
    done
fi

# Source configuration files
if [[ -d "$HOME/.config/zshrc.d" ]]; then
    for file in "$HOME/.config/zshrc.d"/*.sh; do
        [[ -f "$file" ]] && source "$file"
    done
fi

# Initialize Starship
eval "$(starship init zsh)"

# Zsh plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt SHARE_HISTORY

# Auto-completion
autoload -Uz compinit
compinit

# Key bindings
bindkey '^H' backward-kill-word 
bindkey '^Z' undo

# Aliases
alias ls='lsd'
alias ll='lsd -l'
alias la='lsd -la'
alias lt='lsd --tree'
alias cat='bat'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Fastfetch on terminal start
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch
fi
EOF
    
    log_success "Zsh configuration completed"
}

# Configure zellij
configure_zellij() {
    log_info "Configuring Zellij..."
    
    local zellij_config_dir="$HOME/.config/zellij"
    mkdir -p "$zellij_config_dir"
    
    # Copy zellij config
    if [[ -f "${CONFIGS_DIR}/zellij/config.kdl" ]]; then
        cp "${CONFIGS_DIR}/zellij/config.kdl" "$zellij_config_dir/"
        log_success "Zellij configuration applied"
    else
        # Generate default config
        zellij setup --dump-config > "$zellij_config_dir/config.kdl"
        log_success "Default Zellij configuration generated"
    fi
}

# Configure starship
configure_starship() {
    log_info "Configuring Starship..."
    
    local starship_config_dir="$HOME/.config"
    
    # Copy starship config
    if [[ -f "${CONFIGS_DIR}/starship/starship.toml" ]]; then
        cp "${CONFIGS_DIR}/starship/starship.toml" "$starship_config_dir/"
        log_success "Starship configuration applied"
    else
        # Create default config
        cat > "$starship_config_dir/starship.toml" << 'EOF'
format = """
[ ](bg:#9A348E)\
$os\
$username\
[ ](bg:#DA627D fg:#9A348E)\
$directory\
[ ](fg:#DA627D bg:#FCA17D)\
$git_branch\
$git_status\
[ ](fg:#FCA17D bg:#86BBD8)\
$c\
$elixir\
$elm\
$golang\
$gradle\
$haskell\
$java\
$julia\
$nodejs\
$nim\
$rust\
$scala\
[ ](fg:#86BBD8 bg:#06969A)\
$docker_context\
[ ](fg:#06969A bg:#33658A)\
$time\
[ ](fg:#33658A)\
"""

[username]
show_always = true
style_user = "bg:#9A348E"
style_root = "bg:#9A348E"
format = '[$user ]($style)'
disabled = false

[directory]
style = "bg:#DA627D"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:#FCA17D"
format = '[ $symbol $branch ]($style)'

[git_status]
style = "bg:#FCA17D"
format = '[$all_status$ahead_behind ]($style)'

[time]
disabled = false
time_format = "%R"
style = "bg:#33658A"
format = '[ ♥ $time ]($style)'
EOF
        log_success "Default Starship configuration created"
    fi
}

# Configure fastfetch
configure_fastfetch() {
    log_info "Configuring Fastfetch..."
    
    local fastfetch_config_dir="$HOME/.config/fastfetch"
    mkdir -p "$fastfetch_config_dir"
    
    # Copy fastfetch config
    if [[ -f "${CONFIGS_DIR}/fastfetch/config.jsonc" ]]; then
        cp "${CONFIGS_DIR}/fastfetch/config.jsonc" "$fastfetch_config_dir/"
        log_success "Fastfetch configuration applied"
    fi
    
    # Copy custom logo
    if [[ -f "${CONFIGS_DIR}/fastfetch/custom_logo.txt" ]]; then
        cp "${CONFIGS_DIR}/fastfetch/custom_logo.txt" "$fastfetch_config_dir/"
        log_success "Fastfetch custom logo applied"
    fi
}

