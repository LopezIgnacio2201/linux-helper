# .cursor Folder - AI Context for Linux Helper Script

This folder contains essential context files for AI assistants working on the Linux Helper Script project.

## 📁 **Files Overview**

### **Essential Reading (Start Here)**
1. **`project-overview.md`** - Main project overview and current status
2. **`development-guidelines.md`** - Critical development rules and guidelines
3. **`current-status.md`** - Detailed current development status
4. **`ai-context.md`** - AI assistant context and guidelines

### **Reference Files**
5. **`quick-reference.md`** - Quick commands and debugging
6. **`user-profiles.md`** - User profile specifications
7. **`modules-system.md`** - Module system documentation
8. **`roadmap.md`** - Future development plans

### **Planning Files**
9. **`cleanup-plan.md`** - Context cleanup plan (for reference)

## 🔄 **Updating Context Files**

**IMPORTANT**: When making changes that work, **UPDATE** the existing context files instead of creating new ones:
- Update `current-status.md` with new status
- Update `project-overview.md` with completed features
- Update `ai-context.md` with new guidelines
- Update `quick-reference.md` with new commands

**DO NOT** create new files for changes - keep the context consolidated.

## 🚨 **CRITICAL RULES**

### **For AI Assistants**
- **READ** `development-guidelines.md` FIRST
- **MAKE** small, incremental changes only
- **TEST** every change immediately
- **AVOID** hallucination by staying focused

### **Current Priority**
- **MAIN ISSUE**: fzf interface hanging in TUI
- **GOAL**: Fix TUI interface so users can select packages
- **APPROACH**: Debug fzf, test fallback, implement non-interactive mode

## 🎯 **Quick Start**

1. Read `project-overview.md` for project understanding
2. Read `development-guidelines.md` for development rules
3. Read `current-status.md` for current issues
4. Use `quick-reference.md` for commands and debugging

## 📊 **Project Status**
- **Power User Profile**: 95% complete
- **Main Issue**: fzf interface hanging
- **Data**: 100% complete (336 packages)
- **Core Modules**: All working
- **Next Step**: Fix TUI interface
