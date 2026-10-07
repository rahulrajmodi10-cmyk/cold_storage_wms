#!/bin/bash
# Transfer script - run on Android/Termux to package project for transfer

set -e

PROJECT_DIR="/data/data/com.termux/files/home/cold_storage_wms"
OUTPUT_FILE="cold_storage_wms.tar.gz"

echo "=== Packaging cold_storage_wms for transfer ==="
echo ""

# Verify project exists
if [ ! -d "$PROJECT_DIR" ]; then
    echo "ERROR: Project not found at $PROJECT_DIR"
    exit 1
fi

# Create archive (exclude build artifacts)
echo "Creating archive..."
cd "$(dirname "$PROJECT_DIR")"
tar -czf "$OUTPUT_FILE" \
    --exclude="build" \
    --exclude=".dart_tool" \
    --exclude="*.lock" \
    --exclude=".git" \
    cold_storage_wms

echo ""
echo "=== Transfer Complete ==="
echo "Archive: $(pwd)/$OUTPUT_FILE"
echo "Size: $(du -h "$OUTPUT_FILE" | cut -f1)"
echo ""
echo "Transfer methods:"
echo "  1. SCP: scp $(whoami)@$(hostname -I | awk '{print $1}'):$(pwd)/$OUTPUT_FILE ."
echo "  2. ADB: adb pull $(pwd)/$OUTPUT_FILE ."
echo "  3. Termux file share: termux-share $(pwd)/$OUTPUT_FILE"
echo ""
echo "On development machine, extract with:"
echo "  tar xzf $OUTPUT_FILE"