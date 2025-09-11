#!/usr/bin/env python3
"""
Test script for web scraper - test with a few packages first
"""

import os
import sys
import requests
from PIL import Image
from io import BytesIO

# Add the scripts directory to Python path
script_dir = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, script_dir)

from web_scraper import PackageImageScraper

def test_single_package():
    """Test scraping a single package"""
    scraper = PackageImageScraper()
    
    # Test with Firefox
    print("🧪 Testing web scraper with Firefox...")
    
    # Test download with a simple, known working image
    url = "https://httpbin.org/image/png"
    image_data = scraper.download_image(url)
    
    if image_data:
        print("✅ Download successful")
        
        # Test processing
        image_path = scraper.process_image(image_data, "firefox")
        if image_path:
            print("✅ Image processing successful")
            
            # Test terminal display
            if scraper.test_terminal_display(image_path):
                print("✅ Terminal display test successful")
                print(f"Image saved to: {image_path}")
            else:
                print("❌ Terminal display test failed")
        else:
            print("❌ Image processing failed")
    else:
        print("❌ Download failed")

def test_placeholder_creation():
    """Test placeholder creation"""
    scraper = PackageImageScraper()
    
    print("🧪 Testing placeholder creation...")
    
    # Create test placeholder
    scraper.create_placeholder("test-package", "browsers", "[GUI Application]")
    
    # Check if file was created
    placeholder_path = scraper.get_package_image_path("test-package", "browsers")
    if os.path.exists(placeholder_path):
        print("✅ Placeholder creation successful")
        print(f"Placeholder saved to: {placeholder_path}")
        
        # Read and display content
        with open(placeholder_path, 'r') as f:
            content = f.read()
            print("Placeholder content:")
            print(content)
    else:
        print("❌ Placeholder creation failed")

def main():
    """Main test function"""
    print("🚀 Starting web scraper tests...\n")
    
    # Test 1: Single package scraping
    test_single_package()
    print()
    
    # Test 2: Placeholder creation
    test_placeholder_creation()
    print()
    
    print("🎉 Tests completed!")

if __name__ == "__main__":
    main()
