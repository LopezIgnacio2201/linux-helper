#!/bin/bash

# Simple dialog test
echo "Testing dialog in VM..."
echo "This should show a simple dialog menu"
echo "Use arrow keys to navigate, Enter to select"

dialog --clear \
    --backtitle "Test Dialog" \
    --title "Test Menu" \
    --menu "Choose an option:" 10 30 3 \
    "1" "Option 1" \
    "2" "Option 2" \
    "3" "Option 3" \
    2>&1 >/dev/tty

echo "Dialog exit code: $?"
echo "Test completed"
