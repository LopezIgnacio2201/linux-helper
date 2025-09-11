# AI Assistant Context - Linux Helper Script

## 🎯 **Project Summary**
A modular TUI script for Arch Linux that automates system setup for three user profiles (Newbie, Common User, Power User) with 336 packages across 12 categories.

## 🚨 **CRITICAL AI GUIDELINES**

### **1. Development Approach**
- **SMALL STEPS**: Make one small change at a time
- **TEST IMMEDIATELY**: Test every change before proceeding
- **AVOID HALLUCINATION**: Don't make assumptions, verify everything
- **FOCUS**: Work on one issue at a time

### **2. Current Priority**
- **MAIN ISSUE**: Persistent package selection not working correctly
- **GOAL**: Fix persistent selection across category navigation
- **APPROACH**: Debug selection logic, test category re-entry, verify selection state

### **3. What NOT to Do**
- Don't modify multiple files simultaneously
- Don't add complex features without testing basics
- Don't change data structure without understanding impact
- Don't assume fzf works in all environments

## 🏗️ **Project Architecture**

### **Entry Points**
- `Installation.sh` - Profile selection (working)
- `main.sh` - Routes to profiles (working)
- `src/profiles/power.sh` - Power user profile (95% complete)

### **Core Modules**
- `src/core/config.sh` - Configuration and validation
- `src/core/data_loader.sh` - Package data loading (working)
- `src/core/package_manager.sh` - Package installation (ready)
- `src/utils/colors.sh` - Color system (working)
- `src/utils/logging.sh` - Logging system (working)

### **UI Modules**
- `src/ui/tui_core.sh` - fzf interface (persistent selection issue)
- `src/ui/tui_fallback.sh` - Text interface (needs testing)

## 📊 **Data Structure**
- **336 packages** across 12 categories
- **Complete metadata** in `data/metadata/packages.yaml`
- **Dual descriptions** in `data/descriptions/` and `data/detailed/`
- **Image placeholders** in `data/images/`

## 🔧 **Technical Details**

### **Dependencies**
- **Required**: yq, fzf, dialog
- **Platform**: Arch Linux only
- **Package Management**: pacman + AUR (yay/paru)

### **Hybrid Parsing**
- **Primary**: yq with v3/v4 compatibility
- **Fallback**: Simple text parsing using grep, sed, awk
- **Status**: Working perfectly

### **TUI Interface**
- **Primary**: fzf with beautiful interface
- **Fallback**: Text-based numbered menus
- **Status**: fzf working, persistent selection needs debugging

## 🎮 **User Profiles**

### **Power User Profile (IMPLEMENTED)**
- Full TUI with 12 modules
- Comprehensive package selection
- Advanced CLI utilities
- **Status**: 90% complete, persistent selection issue

### **Common User Profile (PLANNED)**
- Limited TUI with 10 modules
- Essential submodules only
- Simplified interface

### **Newbie Profile (PLANNED)**
- Fully automated setup
- Windows-like experience (KDE Plasma)
- Minimal user interaction

## 🧪 **Testing Commands**

### **Test Data Loading**
```bash
source src/core/config.sh && source src/core/data_loader.sh && get_all_categories
```

### **Test TUI Functions**
```bash
source src/ui/tui_core.sh && show_category_menu 0
```

### **Test Full Profile**
```bash
echo -e "3\ny" | timeout 10 ./Installation.sh
```

## 🚧 **Current Issues**

### **Primary Issue: Persistent Selection Not Working**
- **Location**: `src/ui/tui_core.sh` - `show_package_menu()` and `run_tui_navigation()` functions
- **Symptom**: Previously selected packages not showing as selected when re-entering categories
- **Impact**: Users lose their selections when navigating between categories
- **Priority**: HIGH - affects user experience

### **Recent Fixes Applied**
- **Arrow Key Navigation**: ✅ Right arrow to enter, left arrow to exit, q to quit
- **Package Counting**: ✅ Fixed inflated package counts (was showing 22 instead of actual count)
- **Package Name Extraction**: ✅ Robust extraction handling emoji characters
- **Duplicate Prevention**: ✅ Prevents duplicate package additions
- **Visual Indicators**: ✅ Added ✓ checkmarks for selected packages

### **Secondary Issues**
- **Fallback TUI**: Needs testing
- **Package Installation**: Ready but not tested
- **Other Profiles**: Not implemented

## 🔧 **Persistent Selection Implementation**

### **Current Implementation**
- **Function**: `show_package_menu(category, previously_selected)`
- **Visual Indicators**: `✓` checkmarks for selected packages
- **Header Info**: Shows count of previously selected packages in category
- **Selection Logic**: Removes old category selections, adds new ones

### **Key Functions Modified**
- `show_package_menu()`: Added `previously_selected` parameter
- `run_tui_navigation()`: Enhanced selection management logic
- Package name extraction: Handles `✓` indicators
- Selection counting: Category-specific counting

### **Expected Behavior**
1. Enter category → See previously selected packages with ✓
2. Modify selections → Use Tab to select/deselect
3. Exit category → Selections saved
4. Re-enter category → Previous selections still there
5. Cross-category → Selections combined

### **Debugging Needed**
- Verify `previously_selected` parameter is passed correctly
- Check selection indicator logic in package list creation
- Test selection state persistence across navigation
- Verify package name extraction with indicators

## 🎯 **Next Steps**
1. **Debug persistent selection logic** (current priority)
2. **Test category re-entry with selections**
3. **Verify selection state management**
4. **Test package installation flow**
5. **Implement other user profiles**
