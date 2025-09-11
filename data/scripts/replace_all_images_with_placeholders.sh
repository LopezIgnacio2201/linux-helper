#!/bin/bash

# Script to replace ALL package images with standardized "No IMG available" placeholders
# This ensures consistency before web scraping begins

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
IMAGES_DIR="$PROJECT_ROOT/images"

echo -e "${BLUE}🔄 Replacing ALL package images with standardized placeholders...${NC}"
echo -e "${YELLOW}This will replace all 336 package images (including the 80 original ASCII art)${NC}"
echo

# Function to create standardized placeholder
create_placeholder() {
    local package_name="$1"
    local category="$2"
    local output_file="$3"
    
    # Determine if it's GUI or CLI based on category and package name
    local app_type="[CLI Tool]"
    case "$category" in
        "browsers"|"file-managers"|"media-players"|"office-and-productivity"|"gaming"|"communication"|"graphics-and-design"|"development-tools")
            app_type="[GUI Application]"
            ;;
        "terminals")
            # Most terminals are GUI, but some might be CLI
            case "$package_name" in
                "tmux"|"screen"|"byobu")
                    app_type="[CLI Tool]"
                    ;;
                *)
                    app_type="[GUI Application]"
                    ;;
            esac
            ;;
        "utilities"|"privacy"|"cybersecurity")
            # Most are CLI tools
            app_type="[CLI Tool]"
            ;;
    esac
    
    # Create standardized placeholder
    cat > "$output_file" << EOF
┌─────────────────────────┐
│                         │
│      $package_name      │
│                         │
│   $app_type     │
│                         │
│  Screenshot not         │
│  available              │
│                         │
└─────────────────────────┘
EOF
}

# Counter for tracking progress
total_packages=0
processed_packages=0

# Count total packages first
echo -e "${BLUE}📊 Counting total packages...${NC}"
for category_dir in "$IMAGES_DIR"/*/; do
    if [[ -d "$category_dir" ]]; then
        category_name=$(basename "$category_dir")
        if [[ "$category_name" != "graphics-design" && "$category_name" != "office-productivity" ]]; then
            package_count=$(find "$category_dir" -name "*.txt" | wc -l)
            total_packages=$((total_packages + package_count))
        fi
    fi
done

echo -e "${GREEN}Found $total_packages packages to process${NC}"
echo

# Process each category
for category_dir in "$IMAGES_DIR"/*/; do
    if [[ -d "$category_dir" ]]; then
        category_name=$(basename "$category_dir")
        
        # Skip empty directories
        if [[ "$category_name" == "graphics-design" || "$category_name" == "office-productivity" ]]; then
            echo -e "${YELLOW}⏭️  Skipping empty directory: $category_name${NC}"
            continue
        fi
        
        echo -e "${BLUE}📁 Processing category: $category_name${NC}"
        
        # Process each package in the category
        for image_file in "$category_dir"*.txt; do
            if [[ -f "$image_file" ]]; then
                package_name=$(basename "$image_file" .txt)
                processed_packages=$((processed_packages + 1))
                
                # Create standardized placeholder
                create_placeholder "$package_name" "$category_name" "$image_file"
                
                # Progress indicator
                if (( processed_packages % 50 == 0 )); then
                    echo -e "${GREEN}✅ Processed $processed_packages/$total_packages packages${NC}"
                fi
            fi
        done
        
        echo -e "${GREEN}✅ Completed category: $category_name${NC}"
    fi
done

echo
echo -e "${GREEN}🎉 SUCCESS: All $processed_packages packages now have standardized placeholders!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo -e "   • Total packages processed: $processed_packages"
echo -e "   • All images replaced with 'No IMG available' placeholders"
echo -e "   • Ready for web scraping phase"
echo
echo -e "${YELLOW}🚀 Next step: Begin web scraping for all 336 packages${NC}"
