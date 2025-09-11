# Quick Reference - Linux Helper Script

## 🚀 **Quick Start Commands**

### **Test the Script**
```bash
# Test profile selection
./Installation.sh

# Test power user profile directly
echo -e "3\ny" | timeout 10 ./Installation.sh

# Test data loading
source src/core/config.sh && source src/core/data_loader.sh && get_all_categories
```

### **Debug TUI Issues**
```bash
# Test fzf directly
echo -e "browsers\nterminals\nfile-managers" | timeout 3 fzf --height=20 --border --reverse --ansi

# Test TUI functions
source src/ui/tui_core.sh && show_category_menu 0

# Test fallback TUI
source src/ui/tui_fallback.sh && show_category_menu_fallback
```

## 🔧 **Common Debugging**

### **Check Dependencies**
```bash
which yq fzf dialog
yq --version
```

### **Test Data Loading**
```bash
# Test package count
source src/core/config.sh && source src/core/data_loader.sh && get_package_count

# Test category loading
source src/core/config.sh && source src/core/data_loader.sh && get_all_categories

# Test specific category
source src/core/config.sh && source src/core/data_loader.sh && get_packages_by_category browsers
```

### **Test Package Manager**
```bash
source src/core/config.sh && source src/core/package_manager.sh && test_package_manager
```

## 📁 **Key Files**

### **Main Scripts**
- `Installation.sh` - Profile selection
- `main.sh` - Profile router
- `src/profiles/power.sh` - Power user profile

### **Core Modules**
- `src/core/config.sh` - Configuration
- `src/core/data_loader.sh` - Data loading
- `src/core/package_manager.sh` - Package installation

### **UI Modules**
- `src/ui/tui_core.sh` - fzf interface
- `src/ui/tui_fallback.sh` - Text interface

### **Data Files**
- `data/metadata/packages.yaml` - Package metadata
- `data/descriptions/` - Simple descriptions
- `data/detailed/` - Detailed descriptions

## 🚨 **Common Issues**

### **Readonly Variable Errors**
- **Cause**: Modules sourced multiple times
- **Solution**: Check sourcing order, remove duplicates

### **fzf Hanging**
- **Cause**: Terminal compatibility or fzf configuration
- **Solution**: Test fallback TUI, debug fzf options

### **Data Loading Issues**
- **Cause**: yq version or file paths
- **Solution**: Use hybrid parsing (already implemented)

## 🎯 **Current Status**
- **Power User Profile**: 95% complete
- **Main Issue**: fzf interface hanging
- **Next Step**: Debug and fix TUI interface
- **Data**: 100% complete (336 packages)
- **Core Modules**: All working
