#!/bin/bash

# Safe debug test - only tests individual functions without running full script
set -euo pipefail

# Set up required variables
LOGS_DIR="logs"
NO_SUDO_ASK="false"
mkdir -p "$LOGS_DIR"

# Source the core functions
source core/logging.sh
source core/system_checks.sh

# Initialize logging
init_logging

echo "=== Testing individual functions ==="

echo "1. Testing disk space check..."
check_disk_space

echo "2. Testing user permissions check..."
check_user_permissions

echo "3. Testing required tools check..."
check_required_tools

echo "4. Testing internet connection..."
check_internet_connection

echo "All individual tests passed!"
