# Technical Decisions & Implementation Choices

## TUI Framework Selection

### Recommended Options (Modern & Beautiful)

1. **Textual (Python)** - **RECOMMENDED**
   - Modern, web-inspired TUI framework
   - CSS-like styling system
   - Rich widget set and animations
   - Active development and community
   - Excellent documentation
   - Perfect for complex, beautiful interfaces

2. **Rich (Python)**
   - Beautiful terminal formatting
   - Built-in TUI capabilities
   - Excellent for progress bars and status displays
   - Simpler than Textual but still modern

3. **Bubble Tea (Go)**
   - Functional, stateful architecture
   - Based on Elm architecture
   - Very clean and modular
   - High performance

4. **Ratatui (Rust)**
   - Declarative approach
   - High performance and safety
   - Good for complex applications

### Decision: **fzf + dialog (Bash)**
- **fzf**: Modern, beautiful, fast selection interface
- **dialog**: Reliable forms and confirmations
- **Bash-native**: No Python dependencies, pure shell script
- **Hybrid approach**: Best of both worlds - modern looks with bash compatibility

## Language Support Implementation

### Approach: **gettext + JSON configuration**
- **Default**: English
- **Secondary**: Spanish
- **Implementation**: 
  - Use `gettext` for internationalization
  - Store translations in `.po` files
  - Language selection at startup
  - Fallback to English if translation missing

### File Structure:
```
src/
├── locales/
│   ├── en/
│   │   └── messages.po
│   └── es/
│       └── messages.po
```

## Configuration Storage

### Format: **YAML**
- Human-readable
- Supports complex data structures
- Easy to edit and maintain
- Good for nested configurations

### Structure:
```yaml
# config.yaml
user_profile: "newbie"
language: "en"
desktop_environment: "gnome"
modules:
  gaming: true
  programming: false
  media: true
```

## Package Management Strategy

### Primary: **pacman (Official Repositories)**
- Focus on official Arch packages
- Better system stability
- Faster installation
- Less bloat

### Secondary: **AUR (via yay/paru)**
- Only when pacman alternative unavailable
- Clearly marked in package lists
- User warning about AUR packages
- Optional installation

### Implementation:
- Check package availability in pacman first
- Fallback to AUR if needed
- User confirmation for AUR packages
- Dependency resolution handled by package managers

## User Experience Design

### Progress Feedback:
- **Real-time progress bars** for package installation
- **Transparent logging** of all operations
- **Step-by-step status** updates
- **Error handling** with clear messages

### Implementation:
- Use Rich/Textual progress widgets
- Log all operations to file
- Display current operation clearly
- Show estimated time remaining

## External Project Integration

### Supported External Projects:
1. **Proton-GE** - Gaming compatibility
2. **Proton-TKG** - Gaming compatibility  
3. **TKG Kernels** - Performance kernels
4. **arch-gaming-setup** - Gaming optimization script

### Integration Strategy:
- **Modular plugin system**
- **External script execution**
- **Configuration management**
- **Error handling and rollback**

### Implementation:
```python
class ExternalProject:
    def __init__(self, name, install_script, config):
        self.name = name
        self.install_script = install_script
        self.config = config
    
    def install(self):
        # Execute external installation
        # Handle errors gracefully
        # Update system configuration
```

## System Requirements

### Target Systems:
- **Primary**: Fresh Arch Linux installations
- **Secondary**: Existing systems (with warnings)
- **Validation**: Check for Arch-based distributions
- **Exit**: Non-Arch distributions with clear error

### Dependency Management:
- **bash 4.0+** (shell script)
- **fzf** (modern TUI selection)
- **dialog** (forms and confirmations)
- **pacman** (package manager)
- **yay/paru** (AUR helper)
- **git** (for external projects)

## Architecture Overview

### Core Components:
1. **Main Application** - TUI interface and orchestration
2. **Profile Manager** - User profile handling
3. **Module System** - Package and configuration modules
4. **Language Manager** - Internationalization
5. **External Integration** - Third-party project support
6. **Configuration Manager** - Settings and preferences

### Data Flow:
```
User Input → Profile Selection → Module Selection → 
Package Installation → Configuration → External Projects → 
System Setup Complete
```
