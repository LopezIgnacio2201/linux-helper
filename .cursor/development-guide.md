# Development Guide - Linux Package Manager Tool

## Project Overview
A terminal-based package management tool for Arch/Arch-based distros with three user profiles and modular package selection.

## Current Progress
- ✅ **Foundation Setup**: Go + Bubble Tea TUI working
- ✅ **Data Loading**: All modules and profiles loaded correctly
- ✅ **Navigation**: Complete flow (profile → module → submodule → package selection) working
- ✅ **Styling**: Beautiful modern UI with Lipgloss
- ✅ **Data Structure**: Reorganized with actual data files in resources/
- ✅ **Package Selection**: TAB key selection with state persistence working
- 🚧 **Next**: Package installation logic and advanced features

## Data Structure

### File Organization
- **resources/**: Actual data files used by the script
  - `modules.txt`: Module definitions with type (DIRECT_PACKAGES or SUBMODULES)
  - `packages.txt`: Package definitions with module:submodule:package format
  - `profiles.txt`: Profile definitions with profile:module format
- **.cursor/**: Guide files for reference only (not used by script)
  - `modules-and-packages.txt`: Comprehensive guide with all modules/packages
  - `packages/`: Profile guide files
  - `development-guide.md`: This file
  - `development-status.md`: Current development status

### Data Format
- **modules.txt**: `MODULE_NAME:DIRECT_PACKAGES` or `MODULE_NAME:SUBMODULES`
- **packages.txt**: `MODULE_NAME:SUBMODULE_NAME:PACKAGE_NAME`
- **profiles.txt**: `PROFILE_NAME:MODULE_NAME`

### Module Types
- **Direct Package Modules**: Browsers, File Managers (skip submodule selection)
- **Submodule Modules**: Terminals, Gaming, Development Tools, etc. (show submodule selection)

## Core Features & Behaviors

### External Projects & Scripts Support
- **Gaming Extras**: Support for external projects like:
  - Proton TKG (custom Proton builds)
  - TKG Kernel (custom kernel builds)
  - Gaming setup scripts (automatic gaming package installation)
- **Integration**: Allow users to opt-in to install these "extras" gaming modules
- **External Repos**: Handle repositories and installation scripts from external sources

### Navigation & Keybinds
- **Arrow Keys**: 
  - Left/Right: Navigate in and out of modules/submodules
  - Up/Down: Navigate through menu items
- **ESC Key**: Go back/exit current level
- **? Key**: Show quick help menu with all available keybinds
- **ENTER Key**: 
  - Navigate into modules/submodules
  - Select single package
  - Confirm installation
- **TAB Key**: Select/deselect packages (only for actual packages, not modules)

### Package Selection Behavior
- **Selection State Persistence**: 
  - Previously selected packages remain selected when re-entering module
  - Visual indication of selected/deselected packages
  - Intuitive and easy to see selection status
- **Navigation Rules**:
  - Left arrow: Go back WITHOUT saving selections
  - "Confirm" option at bottom: Save selections and proceed
  - Only way to exit package selection: Left arrow (no save) or Confirm (save)

### Menu Structure
- **Top of Menu**: Module/submodule navigation
- **Bottom of Menu**: "Confirm" option for installation
- **Package Selection**: 
  - Left panel: Package list with selection indicators
  - Right panel: Simple description preview
  - I keybind: Detailed package information (man-page style)

### Post-Installation Features
- **Custom Configs**: Option to apply custom configurations
  - Custom zsh configs
  - Other personal configurations
- **Additional Prompts**: Various setup options after package installation

## Technical Requirements

### Package Management
- **Target**: Arch/Arch-based distros only
- **Package Managers**: pacman + AUR
- **AUR Helper Priority**: paru (default) → yay (fallback) → auto-install paru
- **Dependencies**: Let pacman handle automatically
- **Performance**: Lightweight and fast execution

### Error Handling
- **Package Installation Failures**: 
  - Show warning to user
  - Options: Force continue, retry, or exit script
  - Allow manual installation if needed

### Data Structure
- **Fresh Systems**: Primary target
- **Existing Systems**: Supported as fallback
- **Package Info**: 
  - Simple descriptions (right panel preview)
  - Detailed info (I keybind detailed view)
  - Image support (future feature, template ready)

## User Profiles

### Newbie User
- Core packages always installed
- Use case selection (Gaming, Day-to-day, Programming, Editing, Cybersecurity)
- Minimal interaction, automatic installation

### Common User
- TUI navigation through limited modules
- Individual package selection
- Access to: Core + limited Development + essential Utilities

### Power User
- **Access**: Only available with `--poweruser` parameter
- TUI navigation through ALL modules
- Full package selection freedom
- Access to: Core + Development + Utilities + Cybersecurity + Privacy

## Architecture Requirements

### Modularity
- **Fully modularized**: Easy to add/modify modules without breaking existing code
- **Future-proof**: Simple to extend with new modules
- **Maintainable**: Clean separation of concerns

### Installation Methods
- **Git Clone**: Full functionality when cloned from repo
- **Remote Installation**: One-liner installation similar to end-4 hyprland dots
  - `bash <(curl -s "https://your-domain.com/install.sh")`
  - Reference: [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)

### Debloat Module (Future)
- **Complete removal**: Remove program and all traces from system
- **Clean uninstall**: Unless repo is cloned, leave no traces
- **System cleanup**: Remove all installed packages and configurations

## Future Features

### Extras Module (Personal Customizations)
- **Zsh configurations**: Custom shell setups
- **Terminal customizations**: Ghostty configurations
- **Desktop customizations**: Hyprland configurations
- **Boot customizations**: GRUB configurations
- **Login customizations**: SDDM configurations
- **Boot animations**: Plymouth configurations

### Kernel Installation
- **Multiple kernel options**: LTS, Zen, Hardened
- **Gaming kernels**: TKG and other custom gaming kernels
- **User selection**: Prompt user to choose preferred kernel
- **Automatic installation**: Handle kernel installation process

### Additional Features
- Image previews for applications
- Custom configuration management
- Additional post-installation setup options
- External project integration expansion
