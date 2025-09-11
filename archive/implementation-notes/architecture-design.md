# System Architecture & Design

## Overall Architecture

### Core Application Structure
```
linux-helper-script/
├── src/
│   ├── main.py                 # Main application entry point
│   ├── core/
│   │   ├── app.py             # Main application class
│   │   ├── config.py          # Configuration management
│   │   └── logger.py          # Logging system
│   ├── ui/
│   │   ├── tui.py             # TUI interface (Textual)
│   │   ├── screens/           # Individual screen components
│   │   └── widgets/           # Custom widgets
│   ├── profiles/
│   │   ├── base.py            # Base profile class
│   │   ├── newbie.py          # Newbie profile
│   │   ├── common.py          # Common user profile
│   │   └── poweruser.py       # Power user profile
│   ├── modules/
│   │   ├── base.py            # Base module class
│   │   ├── gaming.py          # Gaming module
│   │   ├── programming.py     # Programming module
│   │   ├── media.py           # Media module
│   │   ├── system.py          # System tools module
│   │   └── office.py          # Office/Productivity module
│   ├── external/
│   │   ├── manager.py         # External project manager
│   │   ├── projects/          # External project definitions
│   │   └── installers/        # Installation scripts
│   ├── package/
│   │   ├── manager.py         # Package management
│   │   ├── pacman.py          # Pacman integration
│   │   └── aur.py             # AUR integration
│   ├── system/
│   │   ├── detector.py        # System detection
│   │   ├── validator.py       # System validation
│   │   └── installer.py       # System installation
│   └── locales/
│       ├── en/                # English translations
│       └── es/                # Spanish translations
├── config/
│   ├── profiles.yaml          # Profile configurations
│   ├── modules.yaml           # Module definitions
│   └── external.yaml          # External project registry
└── context/                   # Documentation (existing)
```

## Component Design

### 1. Main Application (`app.py`)
```python
class LinuxHelperApp:
    def __init__(self):
        self.config = ConfigManager()
        self.logger = Logger()
        self.ui = TUIManager()
        self.profile_manager = ProfileManager()
        self.module_manager = ModuleManager()
        self.external_manager = ExternalManager()
        self.package_manager = PackageManager()
    
    def run(self):
        # Main application loop
        # Handle command line arguments
        # Initialize UI
        # Execute user workflow
```

### 2. Profile System (`profiles/`)
```python
class BaseProfile:
    def __init__(self, name, description):
        self.name = name
        self.description = description
        self.packages = []
        self.modules = []
        self.configurations = {}
    
    def get_packages(self):
        return self.packages
    
    def get_modules(self):
        return self.modules
    
    def apply_configurations(self):
        # Apply profile-specific configurations
        pass

class NewbieProfile(BaseProfile):
    def __init__(self):
        super().__init__("newbie", "Windows-like experience")
        self.packages = self._load_newbie_packages()
        self.modules = ["system", "office", "media"]
        self.configurations = self._load_newbie_config()
```

### 3. Module System (`modules/`)
```python
class BaseModule:
    def __init__(self, name, description):
        self.name = name
        self.description = description
        self.packages = []
        self.configurations = {}
        self.dependencies = []
    
    def install(self):
        # Install module packages
        # Apply configurations
        # Handle dependencies
        pass
    
    def configure(self):
        # Apply module-specific configurations
        pass

class GamingModule(BaseModule):
    def __init__(self):
        super().__init__("gaming", "Gaming tools and optimizations")
        self.packages = [
            "steam", "lutris", "wine", "winetricks",
            "mangohud", "gamemode"
        ]
        self.external_projects = ["proton-ge", "tkg-kernels"]
```

### 4. TUI Interface (`ui/`)
```python
class TUIManager:
    def __init__(self):
        self.app = TextualApp()
        self.screens = {
            "welcome": WelcomeScreen(),
            "language": LanguageScreen(),
            "profile": ProfileScreen(),
            "desktop": DesktopScreen(),
            "modules": ModuleScreen(),
            "external": ExternalScreen(),
            "progress": ProgressScreen(),
            "complete": CompleteScreen()
        }
    
    def show_screen(self, screen_name):
        # Display specified screen
        pass
    
    def handle_navigation(self, key):
        # Handle user navigation
        pass
```

### 5. Package Management (`package/`)
```python
class PackageManager:
    def __init__(self):
        self.pacman = PacmanManager()
        self.aur = AURManager()
        self.installed = []
        self.failed = []
    
    def install_packages(self, packages):
        # Install packages via pacman or AUR
        # Handle dependencies
        # Provide progress feedback
        pass
    
    def check_availability(self, package):
        # Check if package is available in pacman
        # Fallback to AUR if needed
        pass
```

## Data Flow

### 1. Application Startup
```
Command Line Args → Config Loading → System Validation → 
Language Selection → Welcome Screen
```

### 2. User Workflow
```
Welcome → Language → Profile Selection → Desktop Environment → 
Module Selection → External Projects → Installation → Configuration → Complete
```

### 3. Installation Process
```
Package List → Dependency Resolution → Installation Queue → 
Progress Tracking → Error Handling → Configuration Application
```

## Configuration Management

### Profile Configuration (`profiles.yaml`)
```yaml
profiles:
  newbie:
    name: "Newbie"
    description: "Windows-like experience for new users"
    desktop_default: "gnome"
    modules:
      - system
      - office
      - media
    packages:
      - firefox
      - libreoffice-fresh
      - vlc
    configurations:
      desktop_theme: "arc"
      icon_theme: "papirus"
  
  common:
    name: "Common User"
    description: "Balanced experience for regular users"
    desktop_options: ["gnome", "kde", "xfce"]
    modules:
      - system
      - office
      - media
      - programming
    packages:
      - firefox
      - code
      - git
    configurations:
      shell: "zsh"
      terminal: "alacritty"
  
  poweruser:
    name: "Power User"
    description: "Advanced setup for experienced users"
    desktop_options: ["i3", "sway", "hyprland", "gnome", "kde"]
    modules:
      - system
      - programming
      - gaming
      - media
    packages:
      - vim
      - git
      - docker
    configurations:
      shell: "zsh"
      terminal: "alacritty"
      window_manager: "i3"
```

### Module Configuration (`modules.yaml`)
```yaml
modules:
  gaming:
    name: "Gaming"
    description: "Gaming tools and optimizations"
    packages:
      pacman:
        - steam
        - lutris
        - wine
        - winetricks
      aur:
        - mangohud
        - gamemode
    external_projects:
      - proton-ge
      - tkg-kernels
    configurations:
      steam_optimization: true
      wine_prefix: "/home/user/.wine"
  
  programming:
    name: "Programming"
    description: "Development tools and environments"
    packages:
      pacman:
        - code
        - git
        - python
        - nodejs
        - docker
      aur:
        - github-cli
    configurations:
      git_user_name: "{{ user_name }}"
      git_user_email: "{{ user_email }}"
```

## Error Handling & Logging

### Error Categories
1. **System Errors**: Non-Arch distribution, missing dependencies
2. **Package Errors**: Installation failures, dependency conflicts
3. **Configuration Errors**: Invalid settings, permission issues
4. **External Errors**: Script failures, network issues

### Logging Strategy
```python
class Logger:
    def __init__(self):
        self.log_file = "/var/log/linux-helper-script.log"
        self.verbose = False
    
    def log_operation(self, operation, status, details):
        # Log all operations with timestamps
        pass
    
    def log_error(self, error_type, message, traceback):
        # Log errors with full context
        pass
    
    def log_progress(self, current, total, description):
        # Log installation progress
        pass
```

## Performance Considerations

### 1. Package Installation
- Parallel package installation where possible
- Progress tracking and user feedback
- Efficient dependency resolution
- Caching of package information

### 2. UI Responsiveness
- Non-blocking operations
- Progress indicators
- Responsive interface during long operations
- Cancellation support

### 3. Memory Management
- Efficient data structures
- Lazy loading of configurations
- Cleanup of temporary files
- Resource monitoring
