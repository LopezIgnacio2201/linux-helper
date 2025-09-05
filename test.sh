#!/bin/bash

# Linux Helper - Test Script
# This script tests the basic functionality without installing packages

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test results
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    
    if eval "$test_command"; then
        echo -e "${GREEN}✓ PASSED: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAILED: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Main test function
main() {
    echo -e "${BLUE}Linux Helper - Test Suite${NC}"
    echo "=========================="
    echo ""
    
    # Test 1: Check if main script exists and is executable
    run_test "Main script exists and is executable" "test -x linux-helper.sh"
    
    # Test 2: Check if core directory exists
    run_test "Core directory exists" "test -d core"
    
    # Test 3: Check if modules directory exists
    run_test "Modules directory exists" "test -d modules"
    
    # Test 4: Check if configs directory exists
    run_test "Configs directory exists" "test -d configs"
    
    # Test 5: Check if all core files exist
    run_test "Core files exist" "test -f core/system_checks.sh && test -f core/language.sh && test -f core/user_selection.sh && test -f core/module_manager.sh && test -f core/logging.sh && test -f core/package_manager.sh"
    
    # Test 6: Check if all module files exist
    run_test "Module files exist" "test -f modules/terminal.sh && test -f modules/browsers.sh && test -f modules/gaming.sh && test -f modules/programming.sh"
    
    # Test 7: Check if config files exist
    run_test "Config files exist" "test -d configs/fastfetch && test -d configs/ghostty && test -d configs/starship && test -d configs/zellij && test -d configs/zshrc.d"
    
    # Test 8: Check if main script can be sourced without errors
    run_test "Main script syntax is valid" "bash -n linux-helper.sh"
    
    # Test 9: Check if core scripts can be sourced without errors
    run_test "Core scripts syntax is valid" "bash -n core/*.sh"
    
    # Test 10: Check if module scripts can be sourced without errors
    run_test "Module scripts syntax is valid" "bash -n modules/*.sh"
    
    # Test 11: Check if install script exists and is executable
    run_test "Install script exists and is executable" "test -x install.sh"
    
    # Test 12: Check if install script syntax is valid
    run_test "Install script syntax is valid" "bash -n install.sh"
    
    # Test 13: Check if README exists
    run_test "README exists" "test -f README.md"
    
    # Test 14: Check if logs directory exists
    run_test "Logs directory exists" "test -d logs"
    
    # Test 15: Check if all scripts have proper shebang
    run_test "Scripts have proper shebang" "grep -q '^#!/bin/bash' linux-helper.sh install.sh test.sh"
    
    # Summary
    echo "=========================="
    echo -e "${BLUE}Test Summary${NC}"
    echo "=========================="
    echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
    echo ""
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}🎉 All tests passed! The Linux Helper setup is ready.${NC}"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed. Please check the issues above.${NC}"
        exit 1
    fi
}

# Run main function
main "$@"
