#!/bin/bash

# Color Definitions and Functions
# This module provides color definitions and utility functions for the Linux Helper Script

# =============================================================================
# COLOR DEFINITIONS
# =============================================================================

# Text Colors
readonly COLOR_RESET='\033[0m'
readonly COLOR_BLACK='\033[0;30m'
readonly COLOR_RED='\033[0;31m'
readonly COLOR_GREEN='\033[0;32m'
readonly COLOR_YELLOW='\033[1;33m'
readonly COLOR_BLUE='\033[0;34m'
readonly COLOR_PURPLE='\033[0;35m'
readonly COLOR_CYAN='\033[0;36m'
readonly COLOR_WHITE='\033[1;37m'
readonly COLOR_GRAY='\033[0;37m'

# Background Colors
readonly BG_COLOR_RESET='\033[0m'
readonly BG_COLOR_BLACK='\033[40m'
readonly BG_COLOR_RED='\033[41m'
readonly BG_COLOR_GREEN='\033[42m'
readonly BG_COLOR_YELLOW='\033[43m'
readonly BG_COLOR_BLUE='\033[44m'
readonly BG_COLOR_PURPLE='\033[45m'
readonly BG_COLOR_CYAN='\033[46m'
readonly BG_COLOR_WHITE='\033[47m'

# =============================================================================
# COLOR UTILITY FUNCTIONS
# =============================================================================

# Print colored text
print_color() {
    local color="$1"
    local text="$2"
    echo -e "${color}${text}${COLOR_RESET}"
}

# Print colored text without newline
print_color_n() {
    local color="$1"
    local text="$2"
    echo -ne "${color}${text}${COLOR_RESET}"
}

# Print success message
print_success() {
    print_color "$COLOR_GREEN" "✅ $*"
}

# Print error message
print_error() {
    print_color "$COLOR_RED" "❌ $*"
}

# Print warning message
print_warning() {
    print_color "$COLOR_YELLOW" "⚠️  $*"
}

# Print info message
print_info() {
    print_color "$COLOR_CYAN" "ℹ️  $*"
}

# Print debug message
print_debug() {
    print_color "$COLOR_GRAY" "🐛 $*"
}

# Print header
print_header() {
    local text="$1"
    local color="${2:-$COLOR_BLUE}"
    echo
    print_color "$color" "═══════════════════════════════════════════════════════════════"
    print_color "$color" "  $text"
    print_color "$color" "═══════════════════════════════════════════════════════════════"
    echo
}

# Print subheader
print_subheader() {
    local text="$1"
    local color="${2:-$COLOR_CYAN}"
    echo
    print_color "$color" "── $text ──"
    echo
}

# Print separator
print_separator() {
    local color="${1:-$COLOR_GRAY}"
    print_color "$color" "───────────────────────────────────────────────────────────────"
}

# Print progress bar
print_progress() {
    local current="$1"
    local total="$2"
    local width="${3:-50}"
    local color="${4:-$COLOR_GREEN}"
    
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${color}["
    printf "%*s" $filled | tr ' ' '='
    printf "%*s" $empty | tr ' ' '-'
    printf "] %d%%${COLOR_RESET}" $percentage
}

# Print status indicator
print_status() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "success"|"ok"|"done")
            print_color "$COLOR_GREEN" "✓ $message"
            ;;
        "error"|"fail"|"failed")
            print_color "$COLOR_RED" "✗ $message"
            ;;
        "warning"|"warn")
            print_color "$COLOR_YELLOW" "⚠ $message"
            ;;
        "info"|"information")
            print_color "$COLOR_CYAN" "ℹ $message"
            ;;
        "loading"|"progress")
            print_color "$COLOR_BLUE" "⟳ $message"
            ;;
        *)
            print_color "$COLOR_WHITE" "• $message"
            ;;
    esac
}

# =============================================================================
# THEME FUNCTIONS
# =============================================================================

# Apply theme colors
apply_theme() {
    local theme="$1"
    
    case "$theme" in
        "default")
            # Use default colors (already defined)
            ;;
        "dark")
            # Dark theme colors
            readonly THEME_BG="$COLOR_BLACK"
            readonly THEME_FG="$COLOR_WHITE"
            readonly THEME_ACCENT="$COLOR_CYAN"
            ;;
        "light")
            # Light theme colors
            readonly THEME_BG="$COLOR_WHITE"
            readonly THEME_FG="$COLOR_BLACK"
            readonly THEME_ACCENT="$COLOR_BLUE"
            ;;
        "colorful")
            # Colorful theme
            readonly THEME_BG="$COLOR_BLACK"
            readonly THEME_FG="$COLOR_WHITE"
            readonly THEME_ACCENT="$COLOR_PURPLE"
            ;;
        *)
            print_warning "Unknown theme: $theme, using default"
            ;;
    esac
}

# =============================================================================
# TUI COLOR FUNCTIONS
# =============================================================================

# Get TUI color for status
get_tui_status_color() {
    local status="$1"
    case "$status" in
        "selected") echo "$COLOR_GREEN" ;;
        "unselected") echo "$COLOR_WHITE" ;;
        "disabled") echo "$COLOR_GRAY" ;;
        "error") echo "$COLOR_RED" ;;
        "warning") echo "$COLOR_YELLOW" ;;
        "info") echo "$COLOR_CYAN" ;;
        *) echo "$COLOR_WHITE" ;;
    esac
}

# Get TUI color for category
get_tui_category_color() {
    local category="$1"
    case "$category" in
        "browsers") echo "$COLOR_BLUE" ;;
        "terminals") echo "$COLOR_GREEN" ;;
        "file-managers") echo "$COLOR_YELLOW" ;;
        "media-players") echo "$COLOR_PURPLE" ;;
        "office-and-productivity") echo "$COLOR_CYAN" ;;
        "gaming") echo "$COLOR_RED" ;;
        "communication") echo "$COLOR_GREEN" ;;
        "graphics-and-design") echo "$COLOR_PURPLE" ;;
        "development-tools") echo "$COLOR_BLUE" ;;
        "utilities") echo "$COLOR_GRAY" ;;
        "privacy") echo "$COLOR_CYAN" ;;
        "cybersecurity") echo "$COLOR_RED" ;;
        *) echo "$COLOR_WHITE" ;;
    esac
}

# =============================================================================
# EXPORT FUNCTIONS
# =============================================================================

# Export all color functions
export -f print_color
export -f print_color_n
export -f print_success
export -f print_error
export -f print_warning
export -f print_info
export -f print_debug
export -f print_header
export -f print_subheader
export -f print_separator
export -f print_progress
export -f print_status
export -f apply_theme
export -f get_tui_status_color
export -f get_tui_category_color
