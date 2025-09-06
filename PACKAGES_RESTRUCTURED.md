# 📦 Linux Helper - Restructured Packages

## 🎯 **Core Categories (Poweruser & Common Users)**

### 🎮 **Gaming**
- `steam` - Steam gaming platform
- `lutris` - Gaming platform for Linux
- `wine` - Windows compatibility layer
- `winetricks` - Wine helper utilities
- `gamemode` - Gaming performance optimization
- `mangohud` - Vulkan overlay for monitoring
- `vkbasalt` - Vulkan post processing layer
- `obs-studio` - Streaming/recording
- `obs-studio-plugins` - OBS plugins

**External Scripts (with warnings):**
- Arch Gaming Setup Script (30+ minutes, compilation required)
- Linux-TKG Kernel (compilation required)
- Proton-TKG (compilation required)

### 💻 **Programming**
- `visual-studio-code-bin` - VS Code
- `cursor-bin` - AI-powered editor
- `neovim` - Modern Vim
- `python` - Python interpreter
- `python-pip` - Python package manager
- `nodejs` - JavaScript runtime
- `npm` - Node package manager
- `rust` - Rust compiler
- `go` - Go compiler
- `git` - Version control
- `github-cli` - GitHub CLI tool
- `docker` - Container platform
- `build-essential` - Build tools

### 🌐 **Browsers**
- `firefox` - Mozilla Firefox
- `chromium` - Open source Chrome
- `google-chrome` - Google Chrome
- `brave-bin` - Privacy-focused browser
- `vivaldi` - Feature-rich browser

### 💻 **Terminal**
- `ghostty` - Modern terminal emulator
- `alacritty` - GPU-accelerated terminal
- `kitty` - GPU-accelerated terminal
- `zsh` - Z shell
- `fish` - Friendly interactive shell
- `zellij` - Terminal workspace
- `tmux` - Terminal multiplexer
- `starship` - Cross-shell prompt
- `fastfetch` - System information

### 🎨 **Media**
- `gimp` - GNU Image Manipulation
- `krita` - Digital painting
- `inkscape` - Vector graphics
- `blender` - 3D creation suite
- `audacity` - Audio editor
- `kdenlive` - Video editor
- `openshot` - Video editor
- `handbrake` - Video transcoder
- `ffmpeg` - Multimedia framework
- `mpv` - Media player
- `vlc` - Media player

### 📄 **Office**
- `libreoffice-fresh` - Office suite
- `onlyoffice` - Office suite
- `okular` - Document viewer
- `evince` - GNOME document viewer
- `zathura` - Minimal document viewer

### 🔧 **System**
- `paru` - AUR helper
- `yay` - Yet Another Yaourt
- `htop` - Interactive process viewer
- `btop` - Resource monitor
- `curl` - Data transfer tool
- `wget` - File downloader
- `rsync` - File synchronization

### 👥 **Social**
- `discord` - Communication platform
- `telegram-desktop` - Messaging app
- `slack` - Team communication

### 🖥️ **Virtualization**
- `virtualbox` - Virtualization platform
- `qemu` - Machine emulator
- `libvirt` - Virtualization API
- `virt-manager` - Virtual machine manager
- `docker` - Container platform
- `podman` - Container engine

### ⚡ **Command Replacements**
- `lsd` - Modern ls with colors and icons
- `exa` - Modern replacement for ls
- `bat` - Cat with syntax highlighting
- `fd` - Simple, fast alternative to find
- `ripgrep` - Fast text search
- `fzf` - Fuzzy finder
- `duf` - Disk usage/free utility
- `dust` - More intuitive version of du
- `ncdu` - Disk usage analyzer

---

## 🔬 **Extras Categories (--show-all-packages)**

### 🔒 **Privacy**
- `librewolf-bin` - Privacy-focused Firefox fork
- `tor-browser` - Anonymous browsing
- `signal-desktop` - Secure messaging
- `tor` - Anonymity network
- `torsocks` - Tor SOCKS proxy
- `privoxy` - Privacy enhancing proxy
- `dnscrypt-proxy` - DNS encryption

### 🛡️ **Cybersec**
- `nmap` - Network scanner
- `wireshark-cli` - Network protocol analyzer
- `tcpdump` - Network packet analyzer
- `john` - Password cracker
- `hashcat` - Password recovery tool
- `metasploit` - Penetration testing
- `burpsuite` - Web vulnerability scanner
- `sqlmap` - SQL injection tool
- `nikto` - Web server scanner
- `dirb` - Web content scanner

### 🤖 **AI Tools**
- `jupyter` - Interactive computing
- `tensorflow` - Machine learning framework
- `pytorch` - Machine learning library
- `opencv` - Computer vision library
- `scikit-learn` - Machine learning library

### 🗄️ **Database Systems**
- `postgresql` - Advanced database
- `mysql` - Popular database
- `mariadb` - MySQL fork
- `sqlite` - Embedded database
- `redis` - In-memory database
- `mongodb-tools` - MongoDB tools
- `pgadmin4` - PostgreSQL admin
- `mysql-workbench` - MySQL admin
- `dbeaver` - Universal database tool

### 🌐 **Web Development**
- `nginx` - Web server
- `apache` - Web server
- `caddy` - Web server with automatic HTTPS
- `certbot` - SSL certificate tool
- `certbot-nginx` - Nginx plugin
- `certbot-apache` - Apache plugin
- `yarn` - Package manager
- `pnpm` - Fast package manager
- `bun` - JavaScript runtime

### 📱 **Mobile Development**
- `android-studio` - Android IDE
- `flutter` - Cross-platform framework
- `react-native` - Mobile app framework
- `xamarin` - Cross-platform development

### 🔄 **Cross Platform**
- `electron` - Desktop app framework
- `tauri` - Desktop app framework
- `qt5` - Cross-platform toolkit
- `gtk4` - GUI toolkit

---

## 🎯 **Implementation Notes**

### **External Scripts Integration:**
```bash
# Gaming module will show:
┌─────────────────────────────────────┐
│ External Gaming Scripts             │
├─────────────────────────────────────┤
│ ⚠️  WARNING: External Scripts       │
│ These scripts are maintained by     │
│ third parties and may take 30+      │
│ minutes to complete. Please read    │
│ our README for detailed info.       │
│                                     │
│ [ ] Arch Gaming Setup Script        │
│ [ ] Linux-TKG Kernel               │
│ [ ] Proton-TKG                     │
│                                     │
│ Continue? (y/N): _                  │
└─────────────────────────────────────┘
```

### **GPU Auto-Detection:**
- **Newbie**: Auto-install appropriate drivers
- **Common/Poweruser**: Manual selection available
- **Detection**: `lspci | grep -i nvidia/amd`

### **Package Count:**
- **Core Categories**: ~80 packages
- **Extras Categories**: ~60 packages
- **Total**: ~140 packages (down from 295+)

This structure is much cleaner, more organized, and user-friendly while maintaining all the functionality you want!
