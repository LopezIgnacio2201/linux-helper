# Development Guidelines for Linux Helper Script

## 🚨 **CRITICAL RULES**

### **1. Small, Incremental Changes**
- **NEVER** make multiple large changes at once
- **ALWAYS** test each change before proceeding
- **ONE** issue at a time, **ONE** file at a time
- **AVOID** AI hallucination by keeping changes focused

### **2. Testing Protocol**
- Test every change immediately after making it
- Use `timeout` commands to prevent hanging
- Test both fzf and fallback interfaces
- Verify data loading functions work

### **3. File Modification Rules**
- **READ** the file completely before editing
- **UNDERSTAND** the current implementation
- **MAKE** minimal, targeted changes
- **TEST** the change immediately

## 🔧 **Common Issues & Solutions**

### **Readonly Variable Conflicts**
- **Cause**: Modules sourced multiple times
- **Solution**: Remove redundant sourcing, use single source point
- **Prevention**: Check sourcing order in profile scripts

### **fzf Interface Hanging**
- **Cause**: Terminal compatibility or fzf configuration
- **Solution**: Test fallback TUI, debug fzf options
- **Prevention**: Always test in different terminal environments

### **Data Loading Issues**
- **Cause**: yq version incompatibility or file paths
- **Solution**: Use hybrid parsing approach (already implemented)
- **Prevention**: Test data loading functions independently

## 📁 **File Structure Rules**

### **Core Modules** (src/core/)
- **config.sh**: Environment validation, constants, paths
- **data_loader.sh**: YAML parsing with hybrid approach
- **package_manager.sh**: Package installation logic

### **UI Modules** (src/ui/)
- **tui_core.sh**: fzf-based interface
- **tui_fallback.sh**: Text-based interface
- **Rule**: NO redundant sourcing, assume modules already loaded

### **Profile Scripts** (src/profiles/)
- **power.sh**: Power user profile (IMPLEMENTED)
- **common.sh**: Common user profile (PLANNED)
- **newbie.sh**: Newbie profile (PLANNED)

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

## 🚫 **What NOT to Do**

- **DON'T** modify multiple files simultaneously
- **DON'T** add complex features without testing basics
- **DON'T** change the data structure without understanding impact
- **DON'T** modify core modules without understanding dependencies
- **DON'T** assume fzf will work in all environments
- **DON'T** create new context files - UPDATE existing ones instead

## ✅ **What TO Do**

- **DO** test each change immediately
- **DO** use timeout commands for interactive testing
- **DO** check for readonly variable conflicts
- **DO** verify data loading works after changes
- **DO** test both fzf and fallback interfaces
- **DO** keep changes minimal and focused
- **DO** update existing context files when making working changes
