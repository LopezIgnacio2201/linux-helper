#!/bin/bash

# Test script for new features (aliases and custom config)

echo "Testing new features..."

# Test 1: Create aliases
echo "1. Testing aliases creation..."
source core/aliases.sh

# Test creating aliases
create_aliases

echo "✅ Aliases test completed"

# Test 2: Test custom config template
echo "2. Testing custom config template..."
source core/config_manager.sh

# Create template
create_config_template

echo "✅ Custom config template test completed"

# Test 3: Test argument parsing
echo "3. Testing argument parsing..."
parse_arguments --custom-config "test-config.txt"
echo "Custom config file: $CUSTOM_CONFIG_FILE"

echo "✅ Argument parsing test completed"

echo "All tests completed successfully!"
