# Building cold_storage_wms on a Development Machine

## Prerequisites

- **OS**: Linux (Ubuntu 22.04+), macOS (12+), or Windows 10/11
- **Flutter SDK**: 3.22+ (stable channel)
- **Android SDK**: API level 34 (for Android builds)
- **Git**: For version control

## Quick Start

### 1. Install Flutter SDK

**Linux/macOS:**
```bash
# Download and extract Flutter
cd ~
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.22.0-stable.tar.xz
tar xf flutter_linux_3.22.0-stable.tar.xz
export PATH="$PATH:~/flutter/bin"

# Verify installation
flutter doctor
```

**Windows:**
```powershell
# Download from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add C:\flutter\bin to PATH
flutter doctor
```

### 2. Transfer Project from Android/Termux

**Option A: Via SCP (recommended)**
```bash
# On your Android device (Termux)
tar -czf cold_storage_wms.tar.gz -C /data/data/com.termux/files/home cold_storage_wms

# On your development machine
scp user@android-ip:/data/data/com.termux/files/home/cold_storage_wms.tar.gz .
tar xzf cold_storage_wms.tar.gz
```

**Option B: Via ADB**
```bash
# On development machine with ADB
adb pull /data/data/com.termux/files/home/cold_storage_wms.tar.gz .
tar xzf cold_storage_wms.tar.gz
```

**Option C: Via Git (if initialized)**
```bash
# On Android device
cd /data/data/com.termux/files/home/cold_storage_wms
git init
git add .
git commit -m "Initial commit"

# On development machine
git clone ssh://user@android-ip/data/data/com.termux/files/home/cold_storage_wms
```

### 3. Build the Project

```bash
cd cold_storage_wms

# Get dependencies
flutter pub get

# Analyze code
flutter analyze

# Run tests
flutter test

# Build release APK
flutter build apk --release

# Build app bundle (for Play Store)
flutter build appbundle --release
```

### 4. Output Locations

- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **App Bundle**: `build/app/outputs/bundle/release/app-release.aab`

## Build Script

Save as `build.sh` and run with `bash build.sh`:

```bash
#!/bin/bash
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
```

## Troubleshooting

### Flutter Doctor Issues
```bash
flutter doctor -v
# Follow Android SDK setup instructions if needed
```

### Dependency Conflicts
```bash
flutter pub upgrade
flutter pub get
```

### Out of Memory (large projects)
```bash
export GRADLE_OPTS="-Xmx4g"
flutter build apk --release
```

### Android License Issues
```bash
flutter doctor --android-licenses
```

## Project Structure Overview

```
cold_storage_wms/
├── lib/
│   ├── main.dart                 # App entry, DB init (v5 migrations)
│   ├── models/                   # Data models (8 files)
│   ├── services/                 # Business logic (11 services)
│   ├── screens/                  # UI screens (6 screens)
│   └── widgets/                  # Reusable UI components
├── test/                         # Unit/widget tests
├── android/                      # Android-specific config
├── ios/                          # iOS-specific config
├── pubspec.yaml                  # Dependencies (70+ packages)
└── BUILD.md                      # This file
```

## Key Dependencies

- `sqflite` - SQLite database
- `flutter_bloc` / `provider` - State management
- `tflite_flutter` - On-device ML inference
- `mobile_scanner` - Camera barcode/QR scanning
- `google_ml_kit` - OCR for gatepass processing
- `fl_chart` - Charts for finance dashboard
- `pdf` / `printing` - PDF generation for invoices
- `geolocator` / `google_maps_flutter` - GPS & maps for logistics

## CI/CD (Optional)

Create `.github/workflows/build.yml`:

```yaml
name: Build APK
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.22.0'
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk
```

## Support

- Flutter docs: https://flutter.dev/docs
- Issue tracker: Create issue in project repository