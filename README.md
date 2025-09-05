# 🐧 Linux Helper

**Automated Arch/EndeavourOS Setup Script**

A modular, customizable, and powerful setup script for Arch-based distributions. Designed to automate the installation and configuration of your Linux system with a focus on power users while remaining accessible to newcomers.

## ✨ Features

- **Modular Design**: Each component is a separate module that can be installed independently
- **User Type Support**: Different experiences for newbies, common users, and power users
- **Interactive Menus**: Beautiful dialog-based interface for easy selection
- **Comprehensive Logging**: Detailed logs of all operations for debugging
- **Error Handling**: Robust error handling with retry mechanisms
- **Internationalization**: Support for multiple languages (English, Spanish)
- **Package Manager Flexibility**: Support for paru, yay, and pacman
- **Configuration Management**: Automatic application of custom configurations

## 🚀 Quick Start

### Option 1: Curl Installer (Recommended)
```bash
bash <(curl -sSL https://raw.githubusercontent.com/LopezIgnacio2201/linux-helper/main/install.sh)
```

### Option 2: Manual Installation
```bash
git clone https://github.com/LopezIgnacio2201/linux-helper.git
cd linux-helper
chmod +x linux-helper.sh
./linux-helper.sh
```

## 🎯 User Types

### Power User
- Full control over module and package selection
- Individual package selection within modules
- Advanced configuration options
- Detailed logging and error reporting

### Common Arch User
- Predefined profiles (Developer, Gamer, Content Creator, etc.)
- Some customization options
- Balanced between automation and control

### Newbie User
- Use-case based selection (Gaming, Programming, Office, etc.)
- Guided setup process
- Minimal user interaction required
- Safe defaults

## 📦 Available Modules

### Terminal Setup
- **Ghostty**: Modern terminal emulator
- **Zsh**: Advanced shell with plugins
- **Zellij**: Terminal multiplexer
- **Starship**: Cross-shell prompt
- **Fastfetch**: System information tool

### Web Browsers
- LibreWolf (Privacy-focused Firefox)
- Firefox
- Chromium
- Brave
- Google Chrome
- Vivaldi
- Tor Browser

### Gaming
- Steam
- Wine & Winetricks
- Lutris
- Proton versions (GE, TKG)
- Gaming kernels (TKG, Zen, LTS)
- Gaming tools (Discord, OBS, etc.)

### Programming
- **Editors**: VS Code, Cursor, Neovim, Vim, Emacs, Sublime Text
- **Languages**: Python, Node.js, Rust, Go, Java, C#, PHP, Ruby
- **Tools**: Git, Docker, Build tools, Debuggers
- **Databases**: PostgreSQL, MySQL, Redis, MongoDB, SQLite
- **Web**: Nginx, Apache, Certbot

## 🛠️ System Requirements

- **Distribution**: Arch Linux or Arch-based (EndeavourOS recommended)
- **Internet**: Active internet connection
- **Storage**: At least 2GB free space
- **Permissions**: User with sudo privileges
- **Tools**: curl, dialog (auto-installed if missing)

## 📁 Project Structure

```
linux-helper/
├── linux-helper.sh          # Main script
├── install.sh               # Curl installer
├── README.md                # This file
├── core/                    # Core functionality
│   ├── system_checks.sh     # System validation
│   ├── language.sh          # Internationalization
│   ├── user_selection.sh    # User type selection
│   ├── module_manager.sh    # Module management
│   ├── logging.sh           # Logging system
│   └── package_manager.sh   # Package management
├── modules/                 # Individual modules
│   ├── terminal.sh          # Terminal setup
│   ├── browsers.sh          # Browser installation
│   ├── gaming.sh            # Gaming setup
│   └── programming.sh       # Development tools
├── configs/                 # Configuration files
│   ├── fastfetch/           # Fastfetch configs
│   ├── ghostty/             # Ghostty configs
│   ├── starship/            # Starship configs
│   ├── zellij/              # Zellij configs
│   └── zshrc.d/             # Zsh configurations
└── logs/                    # Log files
```

## 🔧 Usage

### Basic Usage
```bash
./linux-helper.sh
```

### Advanced Options
```bash
./linux-helper.sh --no-sudo-ask    # Don't ask for sudo on each command
./linux-helper.sh --help           # Show help message
```

### Command Line Arguments
- `--no-sudo-ask`: Don't prompt for sudo password on each command
- `--help`, `-h`: Show help message

## 📝 Logging

The script creates detailed logs in the `logs/` directory:
- Timestamped entries
- Different log levels (INFO, SUCCESS, WARNING, ERROR, DEBUG)
- Command execution logs
- Package installation logs
- Configuration change logs

## 🎨 Customization

### Adding New Modules
1. Create a new `.sh` file in the `modules/` directory
2. Define `MODULE_TITLE` and `MODULE_DEPENDENCIES`
3. Implement `install_<module>_packages()` function
4. Optionally implement `configure_<module>()` function

### Adding Configurations
1. Place configuration files in the `configs/` directory
2. Update the module's configuration function to copy files
3. Ensure proper file permissions and locations

### Customizing Package Lists
Edit the package arrays in each module to add or remove packages.

## 🐛 Troubleshooting

### Common Issues

**Script fails with "command not found"**
- Ensure all required tools are installed
- Check internet connection
- Verify you're running on an Arch-based system

**Package installation fails**
- Check internet connection
- Update package database: `sudo pacman -Sy`
- Try installing packages manually

**Permission denied errors**
- Ensure you have sudo privileges
- Don't run the script as root
- Check file permissions

### Getting Help
1. Check the log files in `logs/` directory
2. Run with debug mode: `DEBUG=true ./linux-helper.sh`
3. Report issues on GitHub with log files

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Guidelines
- Follow the existing code style
- Add proper error handling
- Include logging for important operations
- Update documentation as needed
- Test on clean Arch/EndeavourOS installations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the Arch Linux community
- Built for EndeavourOS users
- Thanks to all contributors and testers

## 🔮 Future Plans

- [ ] Additional modules (multimedia, office, security)
- [ ] More language support
- [ ] GUI interface option
- [ ] Configuration versioning
- [ ] Rollback functionality
- [ ] Debloat module
- [ ] Alias management module
- [ ] Support for other distributions

---

**Made with ❤️ for the Linux community**

*Happy Linuxing! 🐧*

