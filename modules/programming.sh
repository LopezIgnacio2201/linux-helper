#!/bin/bash

# Programming module - IDEs, editors, dev tools

MODULE_TITLE="Programming Tools"
MODULE_DEPENDENCIES=()

# Install programming packages
install_programming_packages() {
    log_info "Installing programming packages..."
    
    # Show programming tool selection
    local tool_options=(
        "editors" "Code Editors (VS Code, Cursor, Vim, Neovim)" "0"
        "languages" "Programming Languages (Python, Node.js, Rust, Go)" "0"
        "tools" "Development Tools (Git, Docker, Build tools)" "0"
        "databases" "Database Tools (PostgreSQL, MySQL, Redis)" "0"
        "web" "Web Development (Nginx, Apache, Node.js tools)" "0"
    )
    
    local selected_categories=($(dialog --clear \
        --backtitle "Linux Helper - Programming Tools" \
        --title "Select Programming Categories" \
        --checklist "Choose development categories:" 15 60 5 \
        "${tool_options[@]}" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        log_warning "Programming tools selection cancelled"
        return 0
    fi
    
    # Install selected categories
    for category in "${selected_categories[@]}"; do
        case "$category" in
            "editors")
                install_editors
                ;;
            "languages")
                install_languages
                ;;
            "tools")
                install_dev_tools
                ;;
            "databases")
                install_databases
                ;;
            "web")
                install_web_tools
                ;;
        esac
    done
    
    log_success "Programming tools installation completed"
}

# Install code editors
install_editors() {
    log_info "Installing code editors..."
    
    local editor_options=(
        "code" "Visual Studio Code" "0"
        "cursor" "Cursor AI Editor" "0"
        "neovim" "Neovim - Modern Vim" "0"
        "vim" "Vim - Classic editor" "0"
        "emacs" "Emacs - Extensible editor" "0"
        "sublime-text" "Sublime Text" "0"
        "atom" "Atom - GitHub's editor" "0"
    )
    
    local selected_editors=($(dialog --clear \
        --backtitle "Linux Helper - Code Editors" \
        --title "Select Code Editors" \
        --checklist "Choose editors to install:" 15 60 7 \
        "${editor_options[@]}" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        log_warning "Editor selection cancelled"
        return 0
    fi
    
    for editor in "${selected_editors[@]}"; do
        case "$editor" in
            "code")
                install_package "visual-studio-code-bin"
                ;;
            "cursor")
                install_package "cursor-bin"
                ;;
            "neovim")
                install_package "neovim"
                ;;
            "vim")
                install_package "vim"
                ;;
            "emacs")
                install_package "emacs"
                ;;
            "sublime-text")
                install_package "sublime-text-4"
                ;;
            "atom")
                install_package "atom"
                ;;
        esac
    done
}

# Install programming languages
install_languages() {
    log_info "Installing programming languages..."
    
    local language_options=(
        "python" "Python - General purpose language" "0"
        "nodejs" "Node.js - JavaScript runtime" "0"
        "rust" "Rust - Systems programming" "0"
        "go" "Go - Google's language" "0"
        "java" "Java - Enterprise development" "0"
        "csharp" "C# - Microsoft's language" "0"
        "php" "PHP - Web development" "0"
        "ruby" "Ruby - Dynamic language" "0"
    )
    
    local selected_languages=($(dialog --clear \
        --backtitle "Linux Helper - Programming Languages" \
        --title "Select Programming Languages" \
        --checklist "Choose languages to install:" 15 60 8 \
        "${language_options[@]}" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        log_warning "Language selection cancelled"
        return 0
    fi
    
    for language in "${selected_languages[@]}"; do
        case "$language" in
            "python")
                install_package "python"
                install_package "python-pip"
                install_package "python-virtualenv"
                ;;
            "nodejs")
                install_package "nodejs"
                install_package "npm"
                install_package "yarn"
                ;;
            "rust")
                install_package "rust"
                install_package "cargo"
                ;;
            "go")
                install_package "go"
                ;;
            "java")
                install_package "jdk-openjdk"
                install_package "maven"
                install_package "gradle"
                ;;
            "csharp")
                install_package "dotnet-runtime"
                install_package "dotnet-sdk"
                ;;
            "php")
                install_package "php"
                install_package "composer"
                ;;
            "ruby")
                install_package "ruby"
                install_package "gem"
                ;;
        esac
    done
}

# Install development tools
install_dev_tools() {
    log_info "Installing development tools..."
    
    local dev_tools=(
        "git"
        "github-cli"
        "docker"
        "docker-compose"
        "base-devel"
        "cmake"
        "ninja"
        "meson"
        "pkg-config"
        "valgrind"
        "gdb"
        "lldb"
        "strace"
        "htop"
        "tree"
        "jq"
        "curl"
        "wget"
        "rsync"
        "unzip"
        "zip"
        "tar"
        "gzip"
        "bzip2"
        "xz"
    )
    
    install_packages "${dev_tools[@]}"
}

# Install database tools
install_databases() {
    log_info "Installing database tools..."
    
    local db_options=(
        "postgresql" "PostgreSQL - Advanced database" "0"
        "mysql" "MySQL - Popular database" "0"
        "redis" "Redis - In-memory database" "0"
        "mongodb" "MongoDB - Document database" "0"
        "sqlite" "SQLite - Embedded database" "0"
    )
    
    local selected_dbs=($(dialog --clear \
        --backtitle "Linux Helper - Database Tools" \
        --title "Select Database Tools" \
        --checklist "Choose databases to install:" 12 60 5 \
        "${db_options[@]}" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        log_warning "Database selection cancelled"
        return 0
    fi
    
    for db in "${selected_dbs[@]}"; do
        case "$db" in
            "postgresql")
                install_package "postgresql"
                install_package "postgresql-libs"
                ;;
            "mysql")
                install_package "mysql"
                install_package "mysql-libs"
                ;;
            "redis")
                install_package "redis"
                ;;
            "mongodb")
                install_package "mongodb-tools"
                ;;
            "sqlite")
                install_package "sqlite"
                ;;
        esac
    done
}

# Install web development tools
install_web_tools() {
    log_info "Installing web development tools..."
    
    local web_tools=(
        "nginx"
        "apache"
        "httpd"
        "certbot"
        "certbot-nginx"
        "certbot-apache"
    )
    
    local selected_web_tools=($(dialog --clear \
        --backtitle "Linux Helper - Web Tools" \
        --title "Select Web Development Tools" \
        --checklist "Choose web tools:" 12 60 6 \
        "nginx" "Nginx - Web server" "0" \
        "apache" "Apache - Web server" "0" \
        "httpd" "HTTPD - Apache HTTP server" "0" \
        "certbot" "Certbot - SSL certificates" "0" \
        "certbot-nginx" "Certbot Nginx plugin" "0" \
        "certbot-apache" "Certbot Apache plugin" "0" \
        2>&1 >/dev/tty))
    
    if [[ $? -ne 0 ]]; then
        log_warning "Web tools selection cancelled"
        return 0
    fi
    
    if [[ ${#selected_web_tools[@]} -gt 0 ]]; then
        install_packages "${selected_web_tools[@]}"
    fi
}

# Configure programming setup
configure_programming() {
    log_info "Configuring programming setup..."
    
    # Configure Git
    configure_git
    
    # Configure Docker
    configure_docker
    
    # Configure development environment
    configure_dev_environment
    
    log_success "Programming configuration completed"
}

# Configure Git
configure_git() {
    log_info "Configuring Git..."
    
    # Set Git configuration
    if ! git config --global user.name >/dev/null 2>&1; then
        local git_name=$(dialog --clear \
            --backtitle "Linux Helper - Git Configuration" \
            --title "Git Configuration" \
            --inputbox "Enter your Git username:" 8 50 \
            2>&1 >/dev/tty)
        
        if [[ $? -eq 0 && -n "$git_name" ]]; then
            git config --global user.name "$git_name"
        fi
    fi
    
    if ! git config --global user.email >/dev/null 2>&1; then
        local git_email=$(dialog --clear \
            --backtitle "Linux Helper - Git Configuration" \
            --title "Git Configuration" \
            --inputbox "Enter your Git email:" 8 50 \
            2>&1 >/dev/tty)
        
        if [[ $? -eq 0 && -n "$git_email" ]]; then
            git config --global user.email "$git_email"
        fi
    fi
    
    # Set default branch name
    git config --global init.defaultBranch main
    
    log_success "Git configured"
}

# Configure Docker
configure_docker() {
    log_info "Configuring Docker..."
    
    # Add user to docker group
    sudo usermod -a -G docker "$USER"
    
    # Enable Docker service
    sudo systemctl enable docker
    sudo systemctl start docker
    
    log_success "Docker configured (reboot required for group changes)"
}

# Configure development environment
configure_dev_environment() {
    log_info "Configuring development environment..."
    
    # Create development directory
    mkdir -p "$HOME/Development"
    
    # Set up common aliases
    cat >> "$HOME/.zshrc" << 'EOF'

# Development aliases
alias dev='cd ~/Development'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gb='git branch'
alias gco='git checkout'
alias gd='git diff'
alias glog='git log --oneline --graph --decorate'

# Docker aliases
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dpa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'

# Development tools
alias py='python3'
alias pip='pip3'
alias node='nodejs'
alias npm='npm'
alias yarn='yarn'
EOF
    
    log_success "Development environment configured"
}

