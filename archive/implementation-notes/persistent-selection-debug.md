# Persistent Selection Debug Guide

## 🎯 **Current Issue**

The persistent selection feature is implemented but not working correctly. Previously selected packages are not showing as selected when re-entering categories.

## 🔧 **Implementation Details**

### **Modified Functions**

#### **1. `show_package_menu(category, previously_selected)`**
- **Location**: `src/ui/tui_core.sh:127`
- **Changes**: Added `previously_selected` parameter
- **Purpose**: Show previously selected packages with ✓ indicators

#### **2. Selection Indicator Logic**
- **Location**: `src/ui/tui_core.sh:175-179`
- **Code**:
```bash
# Check if package is already selected
local selection_indicator=""
if [[ -n "$previously_selected" ]] && echo "$previously_selected" | grep -q "^$package$"; then
    selection_indicator="✓ "
fi
```

#### **3. Package Name Extraction**
- **Location**: `src/ui/tui_core.sh:204`
- **Code**:
```bash
package_name=$(echo "$line" | sed 's/^✓ //' | sed 's/^[^a-zA-Z]*//' | sed 's/ - .*$//')
```

#### **4. Selection Management**
- **Location**: `src/ui/tui_core.sh:356-382`
- **Logic**: Remove old category selections, add new ones

## 🐛 **Debugging Steps**

### **Step 1: Verify Parameter Passing**
```bash
# Test if previously_selected parameter is passed correctly
echo "Testing parameter passing..."
source src/ui/tui_core.sh
show_package_menu "browsers" "firefox"$'\n'"chromium"
```

### **Step 2: Test Selection Indicator Logic**
```bash
# Test the selection indicator logic
test_packages="firefox"$'\n'"chromium"
echo "Testing selection indicator for firefox:"
if echo "$test_packages" | grep -q "^firefox$"; then
    echo "✓ firefox - Should show checkmark"
else
    echo "○ firefox - No checkmark"
fi
```

### **Step 3: Test Package Name Extraction**
```bash
# Test package name extraction with selection indicator
test_line="✓ 🖥️ firefox - Package description"
extracted_name=$(echo "$test_line" | sed 's/^✓ //' | sed 's/^[^a-zA-Z]*//' | sed 's/ - .*$//')
echo "Test line: $test_line"
echo "Extracted name: $extracted_name"
```

### **Step 4: Test Category Package Counting**
```bash
# Test counting previously selected packages in a category
category="browsers"
category_packages=$(get_packages_by_category "$category")
echo "Packages in $category category:"
echo "$category_packages"

prev_selected_count=0
while IFS= read -r cat_package; do
    if [[ -n "$cat_package" ]] && echo "$test_packages" | grep -q "^$cat_package$"; then
        echo "  ✓ $cat_package (selected)"
        ((prev_selected_count++))
    else
        echo "  ○ $cat_package (not selected)"
    fi
done < <(echo "$category_packages")
echo "Total previously selected in browsers: $prev_selected_count"
```

## 🔍 **Potential Issues**

### **Issue 1: Parameter Not Passed**
- **Symptom**: `previously_selected` is empty
- **Check**: Verify `run_tui_navigation()` calls `show_package_menu` with both parameters
- **Fix**: Ensure `show_package_menu "$selected_category" "$selected_packages"` is called

### **Issue 2: Selection Indicator Logic**
- **Symptom**: No ✓ indicators shown
- **Check**: Verify `grep -q "^$package$"` logic
- **Fix**: Check if package names match exactly

### **Issue 3: Package Name Extraction**
- **Symptom**: Package names not extracted correctly
- **Check**: Verify `sed` commands handle selection indicators
- **Fix**: Test extraction with and without ✓ indicators

### **Issue 4: Selection State Management**
- **Symptom**: Selections not persisting
- **Check**: Verify selection removal and addition logic
- **Fix**: Test category-specific selection updates

## 🧪 **Test Commands**

### **Quick Test**
```bash
# Test the complete flow
echo -e "3\ny" | timeout 15 ./Installation.sh
```

### **Isolated Test**
```bash
# Test individual functions
source src/core/config.sh
source src/core/data_loader.sh
source src/ui/tui_core.sh

# Test selection indicator
test_selections="firefox"$'\n'"chromium"
show_package_menu "browsers" "$test_selections"
```

## 🎯 **Expected Behavior**

1. **Enter Category**: See packages with ✓ for previously selected
2. **Header**: Shows "X previously selected in this category"
3. **Modify Selections**: Use Tab to select/deselect
4. **Exit Category**: Selections saved
5. **Re-enter Category**: Previous selections still there with ✓

## 🚀 **Next Steps**

1. **Debug Parameter Passing**: Verify `previously_selected` is passed correctly
2. **Test Selection Logic**: Verify selection indicator logic works
3. **Test Extraction**: Verify package name extraction handles indicators
4. **Test Persistence**: Verify selections persist across navigation
5. **Fix Issues**: Address any problems found during debugging

## 📝 **Debug Log**

- **Implementation**: ✅ Complete
- **Parameter Passing**: 🚧 Needs verification
- **Selection Indicators**: 🚧 Needs testing
- **Package Extraction**: 🚧 Needs testing
- **Selection Persistence**: 🚧 Needs testing
- **Overall Status**: 🚧 Needs debugging
