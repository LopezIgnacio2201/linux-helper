# Package Data Structure

This directory contains all the package information, descriptions, and images for the Linux Helper Script.

## Directory Structure

```
data/
├── README.md                    # This file
├── metadata/
│   └── packages.yaml           # Main package metadata configuration
├── descriptions/
│   ├── browsers/               # Browser package descriptions
│   ├── terminals/              # Terminal package descriptions
│   ├── file-managers/          # File manager descriptions
│   ├── media-players/          # Media player descriptions
│   ├── office-productivity/    # Office and productivity descriptions
│   ├── gaming/                 # Gaming package descriptions
│   ├── communication/          # Communication app descriptions
│   ├── graphics-design/        # Graphics and design descriptions
│   ├── development-tools/      # Development tool descriptions
│   ├── utilities/              # Utility descriptions
│   ├── cybersecurity/          # Cybersecurity tool descriptions
│   └── privacy/                # Privacy tool descriptions
├── images/
│   ├── browsers/               # Browser screenshots and icons
│   ├── terminals/              # Terminal screenshots
│   ├── file-managers/          # File manager screenshots
│   ├── media-players/          # Media player screenshots
│   ├── office-productivity/    # Office app screenshots
│   ├── gaming/                 # Gaming app screenshots
│   ├── communication/          # Communication app screenshots
│   ├── graphics-design/        # Graphics app screenshots
│   ├── development-tools/      # Development tool screenshots
│   ├── utilities/              # Utility icons/screenshots
│   ├── cybersecurity/          # Security tool screenshots
│   └── privacy/                # Privacy tool screenshots
└── scripts/
    ├── setup_package_data.sh   # Master setup script
    ├── populate_package_data.sh # Populate from modules file
    ├── generate_descriptions.sh # Generate descriptions from pacman
    └── download_images.sh      # Download images from various sources
```

## Package Metadata Format

Each package in `metadata/packages.yaml` has the following structure:

```yaml
packages:
  package-name:
    name: "Display Name"
    short_description: "Brief description"
    category: "module-category"
    has_gui: true/false
    preview_type: "image" or "description"
    image_file: "filename.png" or ""
    description_file: "filename.md"
    info_sources:
      - "https://archlinux.org/packages/..."
      - "https://wiki.archlinux.org/..."
    fallback_text: "Error: Information or image couldn't be retrieved"
```

## Description File Format

Each package description in `descriptions/` is a Markdown file with:

```markdown
# Package Name

## Overview
Package description and key features

## Installation
```bash
sudo pacman -S package-name
```

## Use Cases
- Primary use cases
- Target users

## Configuration
- Configuration tips
- Customization options

## Related Packages
- Related or alternative packages

## Links
- Official website
- Documentation
- Arch Wiki page
```

## Image Requirements

- **Format**: PNG, JPG, or JPEG
- **Size**: Optimized for terminal display (200x100 to 400x200 pixels)
- **Content**: Screenshots for GUI apps, icons for CLI tools
- **Fallback**: Text-based fallback if image unavailable

## Setup Process

1. **Run the master setup script**:
   ```bash
   ./data/scripts/setup_package_data.sh
   ```

2. **Manual customization** (optional):
   - Edit package descriptions in `descriptions/`
   - Add custom images to `images/`
   - Update metadata in `metadata/packages.yaml`

3. **Regenerate data** (if needed):
   ```bash
   # Regenerate descriptions from pacman
   ./data/scripts/generate_descriptions.sh
   
   # Download images
   ./data/scripts/download_images.sh
   ```

## Integration with TUI

The TUI script will use this data structure to:

1. **Display package lists** from `packages.yaml`
2. **Show previews** using images or descriptions
3. **Display detailed info** when user presses 'I' key
4. **Handle fallbacks** when data is unavailable

## Customization

### Adding New Packages

1. Add package to `metadata/packages.yaml`
2. Create description file in appropriate category
3. Add image file (optional)
4. Test with TUI script

### Modifying Existing Packages

1. Edit description in `descriptions/category/package.md`
2. Replace image in `images/category/package.png`
3. Update metadata in `packages.yaml`

### Adding New Categories

1. Create directories in `descriptions/` and `images/`
2. Update category names in `packages.yaml`
3. Update TUI script to handle new category

## Dependencies

- **yq**: YAML processing
- **curl/wget**: Image downloading
- **ImageMagick**: Image processing (optional)
- **pacman**: Package information

## Notes

- All scripts include error handling and logging
- Images are cached locally to avoid repeated downloads
- Descriptions are generated from Arch package information
- Fallback text is shown when data cannot be retrieved
- The system is designed to be modular and extensible
