#!/bin/bash

# ========================================
# Configuration Variables
# ========================================

# Source directory (iCloud Drive ebooks folder)
SOURCE_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/ebooks"

# Destination directory (Desktop by default)
DEST_DIR="$HOME/Desktop/epub_collection"

# How to handle duplicate filenames:
# "newest" - keep the newest version based on modification time
# "all" - keep all versions by adding numbers (file.epub, file_2.epub, etc.)
# "skip" - skip duplicates, keep only the first one found
DUPLICATE_STRATEGY="newest"

# ========================================
# Script Start
# ========================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}ePub File Collector${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Check if source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory does not exist:${NC}"
    echo -e "${RED}$SOURCE_DIR${NC}"
    exit 1
fi

# Create destination directory if it doesn't exist
if [ ! -d "$DEST_DIR" ]; then
    echo -e "${YELLOW}Creating destination directory...${NC}"
    mkdir -p "$DEST_DIR"
fi

# Counter variables
total_files=0
copied_files=0
skipped_files=0
duplicate_files=0

echo -e "${GREEN}Source:${NC} $SOURCE_DIR"
echo -e "${GREEN}Destination:${NC} $DEST_DIR"
echo -e "${GREEN}Duplicate Strategy:${NC} $DUPLICATE_STRATEGY\n"
echo -e "${YELLOW}Scanning for .epub files...${NC}\n"

# Find all .epub files recursively and process them
find "$SOURCE_DIR" -type f -iname "*.epub" | while IFS= read -r epub_file; do
    total_files=$((total_files + 1))
    
    # Get the basename of the file
    base_name=$(basename "$epub_file")
    dest_file="$DEST_DIR/$base_name"
    
    # Check if file already exists in destination
    if [ -f "$dest_file" ]; then
        duplicate_files=$((duplicate_files + 1))
        
        case $DUPLICATE_STRATEGY in
            "newest")
                # Compare modification times
                if [ "$epub_file" -nt "$dest_file" ]; then
                    echo -e "${YELLOW}Replacing with newer version:${NC} $base_name"
                    cp "$epub_file" "$dest_file"
                    copied_files=$((copied_files + 1))
                else
                    echo -e "${YELLOW}Skipping older version:${NC} $base_name"
                    skipped_files=$((skipped_files + 1))
                fi
                ;;
                
            "all")
                # Add number suffix to filename
                name_without_ext="${base_name%.epub}"
                counter=2
                new_name="${name_without_ext}_${counter}.epub"
                
                while [ -f "$DEST_DIR/$new_name" ]; do
                    counter=$((counter + 1))
                    new_name="${name_without_ext}_${counter}.epub"
                done
                
                echo -e "${YELLOW}Duplicate found, saving as:${NC} $new_name"
                cp "$epub_file" "$DEST_DIR/$new_name"
                copied_files=$((copied_files + 1))
                ;;
                
            "skip")
                echo -e "${YELLOW}Skipping duplicate:${NC} $base_name"
                skipped_files=$((skipped_files + 1))
                ;;
        esac
    else
        # First time seeing this filename
        echo -e "${GREEN}Copying:${NC} $base_name"
        cp "$epub_file" "$dest_file"
        copied_files=$((copied_files + 1))
    fi
    
done

# Get final counts (need to re-count since subshell variables don't persist)
total_files=$(find "$SOURCE_DIR" -type f -iname "*.epub" | wc -l | tr -d ' ')
copied_files=$(find "$DEST_DIR" -type f -iname "*.epub" | wc -l | tr -d ' ')

# Calculate total size of collected files
total_bytes=$(find "$DEST_DIR" -type f -iname "*.epub" -exec stat -f%z {} \; | awk '{sum+=$1} END {print sum}')

# Convert bytes to human-readable format
if [ -z "$total_bytes" ] || [ "$total_bytes" -eq 0 ]; then
    total_size="0 B"
else
    # Convert to appropriate unit
    if [ "$total_bytes" -lt 1024 ]; then
        total_size="${total_bytes} B"
    elif [ "$total_bytes" -lt 1048576 ]; then
        total_size=$(echo "scale=2; $total_bytes / 1024" | bc)" KB"
    elif [ "$total_bytes" -lt 1073741824 ]; then
        total_size=$(echo "scale=2; $total_bytes / 1048576" | bc)" MB"
    else
        total_size=$(echo "scale=2; $total_bytes / 1073741824" | bc)" GB"
    fi
fi

# Calculate percentage of 5GB limit
readest_limit_bytes=5368709120  # 5 GB in bytes
if [ -n "$total_bytes" ] && [ "$total_bytes" -gt 0 ]; then
    usage_percent=$(echo "scale=1; ($total_bytes / $readest_limit_bytes) * 100" | bc)
else
    usage_percent="0.0"
fi

# Summary
echo -e "\n${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Total .epub files found:${NC} $total_files"
echo -e "${GREEN}Files in destination:${NC} $copied_files"
echo -e "${GREEN}Total size:${NC} $total_size"
echo -e "${GREEN}Readest storage usage:${NC} $usage_percent% of 5 GB limit"

# Warning if over limit
if (( $(echo "$usage_percent > 100" | bc -l) )); then
    echo -e "${RED}⚠ Warning: Collection exceeds Readest storage limit!${NC}"
elif (( $(echo "$usage_percent > 90" | bc -l) )); then
    echo -e "${YELLOW}⚠ Warning: Collection is near Readest storage limit${NC}"
fi

echo -e "\n${GREEN}All files collected in:${NC} $DEST_DIR"
echo -e "${BLUE}========================================${NC}"