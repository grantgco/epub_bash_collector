# ePub Collector for Readest

A bash script to help collect and organize your epub files for easy uploading to [Readest](https://readest.com), especially useful when syncing with KOReader devices.

## Why This Script?

Readest doesn't currently offer a Calibre plugin, and many users experience sync issues between Calibre and KOReader due to file checksum mismatches. This script provides a simple solution:

- Recursively crawls your ebooks directory
- Copies all `.epub` files to a single collection folder
- Handles duplicate filenames intelligently
- Tracks total collection size against Readest storage limits
- Ensures you're uploading the exact files that will match with KOReader

## Key Features

- **Recursive Search**: Finds all epub files in nested subdirectories
- **Duplicate Handling**: Three strategies for managing files with the same name
  - `newest` - Keep only the most recently modified version
  - `all` - Keep all versions with numbered suffixes
  - `skip` - Keep only the first one found
- **Storage Tracking**: Shows total size and percentage of Readest storage limit
- **Configurable Paths**: Easy-to-modify variables for source and destination
- **Compatible**: Works with macOS's default bash 3.2 (no upgrades needed)

## Installation

1. Download the script:
```bash
curl -O https://raw.githubusercontent.com/yourusername/epub-collector-readest/main/collect_epubs.sh
```

2. Make it executable:
```bash
chmod +x collect_epubs.sh
```

## Usage

### Basic Usage

Simply run the script:
```bash
./collect_epubs.sh
```

By default, it will:
- Search: `~/Library/Mobile Documents/com~apple~CloudDocs/ebooks`
- Output to: `~/Desktop/epub_collection`
- Use `newest` duplicate strategy

### Customization

Edit the variables at the top of the script:

```bash
# Source directory (iCloud Drive ebooks folder)
SOURCE_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/ebooks"

# Destination directory (Desktop by default)
DEST_DIR="$HOME/Desktop/epub_collection"

# Duplicate strategy: "newest", "all", or "skip"
DUPLICATE_STRATEGY="newest"
```

## Important: KOReader Sync Setup

For successful syncing between Readest and KOReader:

### 1. File Matching Method
- In KOReader: Settings → Progress sync → Document matching method → **Binary**
- The official Readest KOReader plugin uses binary checksums, not filenames
- Filenames can differ between Readest and KOReader - no problem!

### 2. Use Identical Files
⚠️ **Critical**: The epub files must be byte-for-byte identical

**DO**:
- ✅ Upload the exact files collected by this script to Readest
- ✅ Copy the same exact files to your KOReader device
- ✅ Keep original files unmodified

**DON'T**:
- ❌ Use Calibre's "Send to Device" with conversion enabled
- ❌ Edit metadata after collection
- ❌ Convert or optimize files between upload and device sync
- ❌ Use Calibre plugins that modify file contents

### 3. Recommended Workflow

1. Run this script to collect your epubs
2. Upload collected files to Readest via their web interface
3. Copy the **same exact files** from the collection folder to KOReader
4. Install the official Readest KOReader plugin
5. Configure KOReader to use Binary matching method
6. Enjoy synced reading progress and notes!

## Output Example

```
========================================
ePub File Collector
========================================

Source: /Users/you/Library/Mobile Documents/com~apple~CloudDocs/ebooks
Destination: /Users/you/Desktop/epub_collection
Duplicate Strategy: newest

Scanning for .epub files...

Copying: The Martian - Andy Weir.epub
Copying: Project Hail Mary - Andy Weir.epub
Replacing with newer version: Ready Player One - Ernest Cline.epub
...

========================================
Summary
========================================
Total .epub files found: 247
Files in destination: 247
Total size: 3.42 GB
Readest storage usage: 68.4% of 5 GB limit

All files collected in: /Users/you/Desktop/epub_collection
========================================
```

## Troubleshooting

### Script won't run
Make sure it's executable:
```bash
chmod +x collect_epubs.sh
```

### Source directory not found
Update `SOURCE_DIR` in the script to match your ebooks location

### KOReader sync not working
- Verify both devices are using **Binary** matching method
- Ensure the epub files are truly identical (same checksums)
- Check that you didn't modify files after collection
- Try re-uploading to Readest if files were previously uploaded with different versions

## Limitations

- Text/epub files only (no support for other ebook formats)
- Doesn't integrate directly with Calibre library database
- Requires manual upload to Readest (no API integration)
- Storage calculation assumes 5 GB limit (adjust in script for different plans)

## Contributing

Contributions welcome! Please feel free to submit issues or pull requests.

## License

MIT License - feel free to use and modify as needed.

## Related Projects

- [Readest](https://readest.com) - Modern web-based ebook reader
- [KOReader](https://github.com/koreader/koreader) - Document viewer for E Ink devices
- [Readest KOReader Plugin](https://github.com/readest/koreader-readest-sync) - Official sync plugin

## Acknowledgments

Created to help the Readest community overcome Calibre sync challenges. Special thanks to the Readest and KOReader teams for their excellent open-source tools.
