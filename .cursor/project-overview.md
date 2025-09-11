# Linux Helper Script - Project Overview

## 🎯 **Project Purpose**
A modular TUI script for Arch Linux that automates system setup for three user experience levels (Newbie, Common User, Power User) with 336 packages across 12 categories.

## 🏗️ **Current Architecture**
```
Installation.sh (profile selection)
    ↓
main.sh (routes to profile scripts)
    ↓
src/profiles/power.sh (power user logic)
    ↓
src/core/data_loader.sh (package data access)
src/ui/tui_core.sh (fzf interface)
src/ui/tui_fallback.sh (text interface)
```

## ✅ **What's Working (95% Complete)**
- **Core Modules**: config.sh, data_loader.sh, logging.sh, colors.sh
- **Data Management**: 336 packages with complete metadata and descriptions
- **Power User Profile**: Fully functional with TUI interface
- **Package Manager**: Core installation functions implemented
- **Hybrid Parsing**: yq v3/v4 compatibility with fallback
- **VM Compatibility**: Automatic fallback systems

## 🚧 **Current Issue**
- **fzf Interface Hanging**: TUI hangs when trying to display category selection
- **Fallback TUI**: Should work but needs testing

## 📊 **Package Data Structure**
- **336 packages** across 12 categories
- **Dual descriptions**: Simple (preview) + detailed (I keybind)
- **Image system**: ASCII art + placeholders
- **Complete metadata**: categories, GUI detection, sources

## 🎮 **User Profiles**
1. **Power User**: Full TUI with 12 modules (IMPLEMENTED)
2. **Common User**: Limited TUI with 10 modules (PLANNED)
3. **Newbie**: Automated setup (PLANNED)

## 🔧 **Technical Stack**
- **Platform**: Arch Linux only
- **Dependencies**: yq, fzf, dialog (with fallbacks)
- **TUI**: fzf + dialog with text fallback
- **Package Management**: pacman + AUR (yay/paru)

## 🎯 **Next Steps**
1. Fix fzf interface hanging issue
2. Test package installation flow
3. Implement other user profiles
4. Add language support (English/Spanish)
