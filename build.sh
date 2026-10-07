#!/bin/bash
# Build script for cold_storage_wms
# Run on Linux/macOS/Windows (WSL) with Flutter SDK installed

set -e

echo "=== cold_storage_wms Build Script ==="
echo ""

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found in PATH"
    echo "Install Flutter SDK first: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "Flutter version: $(flutter --version | head -1)"
echo ""

# Get dependencies
echo "=== Getting dependencies ==="
flutter pub get

# Analyze
echo "=== Analyzing code ==="
flutter analyze

# Run tests
echo "=== Running tests ==="
flutter test

# Build APK
echo "=== Building release APK ==="
flutter build apk --release

# Build App Bundle
echo "=== Building app bundle ==="
flutter build appbundle --release

echo ""
echo "=== Build Complete ==="
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
echo "AAB: build/app/outputs/bundle/release/app-release.aab"
echo ""
echo "Install APK on device:"
echo "  adb install build/app/outputs/flutter-apk/app-release.apk"