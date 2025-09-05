#!/bin/bash

# Linux Helper - Demo Script
# This script demonstrates the Linux Helper functionality without making changes

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Demo function
show_demo() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║                    🐧 Linux Helper 🐧                       ║
    ║                                                              ║
    ║                        DEMO MODE                            ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    
    echo -e "${YELLOW}Welcome to the Linux Helper Demo!${NC}"
    echo -e "${YELLOW}This demo shows you what the script can do without making any changes.${NC}"
    echo ""
    
    # Show project structure
    echo -e "${BLUE}📁 Project Structure:${NC}"
    echo "├── linux-helper.sh          # Main script"
    echo "├── install.sh               # Curl installer"
    echo "├── core/                    # Core functionality"
    echo "│   ├── system_checks.sh     # System validation"
    echo "│   ├── language.sh          # Internationalization"
    echo "│   ├── user_selection.sh    # User type selection"
    echo "│   ├── module_manager.sh    # Module management"
    echo "│   ├── logging.sh           # Logging system"
    echo "│   └── package_manager.sh   # Package management"
    echo "├── modules/                 # Individual modules"
    echo "│   ├── terminal.sh          # Terminal setup"
    echo "│   ├── browsers.sh          # Browser installation"
    echo "│   ├── gaming.sh            # Gaming setup"
    echo "│   └── programming.sh       # Development tools"
    echo "├── configs/                 # Configuration files"
    echo "└── logs/                    # Log files"
    echo ""
    
    # Show user types
    echo -e "${BLUE}👥 User Types:${NC}"
    echo "1. ${GREEN}Power User${NC} - Full control, select individual modules and packages"
    echo "2. ${YELLOW}Common Arch User${NC} - Predefined profiles with some customization"
    echo "3. ${CYAN}Newbie User${NC} - Guided setup with use-case selection"
    echo ""
    
    # Show modules
    echo -e "${BLUE}📦 Available Modules:${NC}"
    echo "• ${GREEN}Terminal Setup${NC} - Ghostty, Zsh, Zellij, Starship, Fastfetch"
    echo "• ${GREEN}Web Browsers${NC} - LibreWolf, Firefox, Chromium, Brave, Chrome, Vivaldi"
    echo "• ${GREEN}Gaming${NC} - Steam, Wine, Proton, Gaming kernels, Gaming tools"
    echo "• ${GREEN}Programming${NC} - IDEs, Languages, Dev tools, Databases, Web tools"
    echo ""
    
    # Show features
    echo -e "${BLUE}✨ Key Features:${NC}"
    echo "• Modular design - install only what you need"
    echo "• Interactive menus with dialog"
    echo "• Comprehensive logging"
    echo "• Error handling with retry mechanisms"
    echo "• Internationalization (English, Spanish)"
    echo "• Package manager flexibility (paru, yay, pacman)"
    echo "• Configuration management"
    echo "• System validation"
    echo ""
    
    # Show usage examples
    echo -e "${BLUE}🚀 Usage Examples:${NC}"
    echo "• ${GREEN}Basic usage:${NC} ./linux-helper.sh"
    echo "• ${GREEN}No sudo prompts:${NC} ./linux-helper.sh --no-sudo-ask"
    echo "• ${GREEN}Curl installer:${NC} bash <(curl -sSL https://raw.githubusercontent.com/yourusername/linux-helper/main/install.sh)"
    echo ""
    
    # Show what happens during installation
    echo -e "${BLUE}🔄 Installation Process:${NC}"
    echo "1. System checks (Arch-based, internet, disk space, permissions)"
    echo "2. Language selection (English/Spanish)"
    echo "3. User type selection (Power/Common/Newbie)"
    echo "4. Module selection based on user type"
    echo "5. Package manager selection (paru/yay/pacman)"
    echo "6. Package installation with retry logic"
    echo "7. Configuration application"
    echo "8. Completion message with reboot reminder"
    echo ""
    
    # Show configuration examples
    echo -e "${BLUE}⚙️ Configuration Examples:${NC}"
    echo "• ${GREEN}Terminal:${NC} Ghostty with Catppuccin theme, Zsh with plugins, Zellij multiplexer"
    echo "• ${GREEN}Gaming:${NC} Steam, Wine, Proton-GE, Gaming kernel, Gamemode"
    echo "• ${GREEN}Programming:${NC} VS Code, Cursor, Neovim, Python, Node.js, Rust, Go, Docker"
    echo "• ${GREEN}Browsers:${NC} LibreWolf (privacy), Firefox, Chromium, Brave"
    echo ""
    
    # Show next steps
    echo -e "${BLUE}🎯 Next Steps:${NC}"
    echo "1. Run ${GREEN}./test.sh${NC} to validate the setup"
    echo "2. Run ${GREEN}./linux-helper.sh${NC} to start the installation"
    echo "3. Or use the curl installer for easy deployment"
    echo "4. Check the logs in the ${GREEN}logs/${NC} directory"
    echo "5. Customize modules and configurations as needed"
    echo ""
    
    echo -e "${PURPLE}Ready to automate your Linux setup? Let's go! 🚀${NC}"
}

# Main function
main() {
    show_demo
    
    echo -e "${YELLOW}Press Enter to continue or Ctrl+C to exit...${NC}"
    read -r
    
    echo -e "${GREEN}Demo completed! Run ./linux-helper.sh to start the real installation.${NC}"
}

# Run main function
main "$@"

