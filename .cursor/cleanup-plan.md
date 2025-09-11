# Context Cleanup Plan

## 🎯 **Goal**
Remove redundant AI context files and consolidate essential information into `.cursor` folder for better AI performance.

## ✅ **Keep These Files**

### **Essential Documentation**
- `.cursor/project-overview.md` - Main project overview
- `.cursor/development-guidelines.md` - Development rules and guidelines
- `.cursor/current-status.md` - Current development status
- `.cursor/ai-context.md` - AI assistant context
- `.cursor/quick-reference.md` - Quick commands and debugging

### **Core Project Files**
- `README.md` - Main project documentation
- `data/metadata/packages.yaml` - Package data (essential)
- `data/descriptions/` - Package descriptions (essential)
- `data/detailed/` - Detailed descriptions (essential)

## 🗑️ **Remove These Files (Redundant)**

### **Context Directory**
- `context/ai-context.md` - Replaced by `.cursor/ai-context.md`
- `context/implementation-notes/next-chat-context.md` - Redundant
- `context/implementation-notes/current-development-status.md` - Redundant
- `context/documentation/project-overview.md` - Redundant
- `data/CURRENT_STATUS_AND_NEXT_STEPS.md` - Redundant

### **Ideas Directory (Outdated)**
- `context/ideas/` - All files (outdated brainstorming)
- `context/ideas/modules/` - All files (outdated)

### **Implementation Notes (Outdated)**
- `context/implementation-notes/architecture-design.md` - Outdated Python design
- `context/implementation-notes/external-integration.md` - Not implemented
- `context/implementation-notes/technical-decisions.md` - Outdated
- `context/implementation-notes/web-scraping-approach.md` - Not implemented

## 📁 **Reorganize These Files**

### **Keep but Move**
- `context/documentation/user-profiles.md` → `.cursor/user-profiles.md`
- `context/documentation/modules-system.md` → `.cursor/modules-system.md`
- `context/future-plans/roadmap.md` → `.cursor/roadmap.md`

### **Archive**
- `context/implementation-notes/` → `archive/implementation-notes/`
- `context/ideas/` → `archive/ideas/`

## 🎯 **Benefits**
1. **Cleaner AI Context**: Only essential files in `.cursor`
2. **Faster AI Performance**: Less redundant information
3. **Better Organization**: Clear separation of current vs outdated
4. **Easier Maintenance**: Single source of truth for AI context
