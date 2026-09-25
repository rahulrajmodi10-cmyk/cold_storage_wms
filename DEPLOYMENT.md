# Stepwise Deployment Guide

## Prerequisites Checklist

- [ ] GitHub repository created
- [ ] Flutter 3.47.5 installed locally (for verification)
- [ ] GitHub CLI (`gh`) installed (optional, for manual triggers)

---

## Step 1: Initialize Git & Push to GitHub

```bash
cd cold_storage_wms

# Initialize git if not already done
git init
git add .
git commit -m "Initial commit: Cold Storage WMS v1.0.0"

# Add GitHub remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/cold_storage_wms.git

# Push to main branch
git push -u origin main
```

---

## Step 2: Verify GitHub Actions Workflow

1. Go to your repo → **Actions** tab
2. Should see "Build & Release" workflow
3. Click **Run workflow** → select `main` branch → **Run workflow**
4. Wait for `analyze` and `test` jobs to complete (green checkmarks)

---

## Step 3: Create First Release (Manual Trigger)

```bash
# Option A: Via GitHub CLI
gh workflow run build.yml --ref main

# Option B: Via Git tag (triggers auto-release)
git tag v1.0.0
git push origin v1.0.0
```

**What happens:**
- GitHub Actions runs all build jobs
- On tag push: creates GitHub Release with all artifacts attached
- Check **Releases** page for downloadable APKs, web build, desktop builds

---

## Step 4: Install APK on Android Device

### Via ADB (from host machine with built artifacts)

```bash
# Download artifacts from GitHub Actions run
# Or download from Release page

# Install specific architecture (arm64 for most modern phones)
adb install app-release-arm64-v8a.apk

# Or install universal (larger)
adb install app-release.apk
```

### Direct from GitHub Release (on phone)

1. Open GitHub Release page in phone browser
2. Tap `app-release-arm64-v8a.apk` to download
3. Open downloaded file → Install
4. Allow "Install unknown apps" if prompted

---

## Step 5: Deploy Web Version

### Option A: GitHub Pages (Free)

1. Repo → **Settings** → **Pages**
2. Source: **GitHub Actions**
3. Add deploy job to workflow (see below)

### Option B: Firebase Hosting

```bash
# On host machine with flutter installed
cd cold_storage_wms
flutter build web --release
firebase deploy --only hosting
```

### Option C: Netlify/Vercel/Cloudflare Pages

1. Connect GitHub repo
2. Build command: `flutter build web --release`
3. Output directory: `build/web`
4. Deploy

---

## Step 6: Desktop Distribution

### Linux (.tar.gz or AppImage)
```bash
# Built artifact: build/linux/x64/release/bundle/
# Distribute the entire bundle folder
```

### macOS (.dmg or .app)
```bash
# Built artifact: build/macos/Build/Products/Release/
# Sign & notarize for distribution outside Mac App Store
```

### Windows (.exe or .msi)
```bash
# Built artifact: build/windows/x64/runner/Release/
# Create installer with Inno Setup or WiX
```

---

## Step 7: Configure Secrets (Optional)

For production, add to GitHub repo **Settings → Secrets → Actions**:

| Secret | Purpose |
|--------|---------|
| `FIREBASE_TOKEN` | Web deploy to Firebase |
| `KEYSTORE_PASSWORD` | Android signing |
| `KEY_PASSWORD` | Android signing |
| `APPLE_TEAM_ID` | macOS/iOS signing |
| `CERTIFICATE_PASSWORD` | Windows code signing |

---

## Step 8: Production Hardening (Before Real Deploy)

### Android Signing
```yaml
# Add to build-android job before build step
- name: Setup Keystore
  run: |
    echo "$KEYSTORE_BASE64" | base64 -d > keystore.jks
    echo "storeFile=keystore.jks" >> android/key.properties
    echo "storePassword=$KEYSTORE_PASSWORD" >> android/key.properties
    echo "keyAlias=upload" >> android/key.properties
    echo "keyPassword=$KEY_PASSWORD" >> android/key.properties
```

### iOS/macOS Certificates
```yaml
# Add to build-desktop macOS step
- uses: apple-actions/import-codesign-certs@v3
  with:
    p12-file-base64: ${{ secrets.CERTIFICATE_P12 }}
    p12-password: ${{ secrets.CERTIFICATE_PASSWORD }}
```

---

## Quick Reference Commands

```bash
# Local verification (Linux/macOS/Windows host)
flutter pub get
dart analyze lib/models/ lib/services/ db/
flutter test test/
flutter build apk --release --split-per-abi
flutter build web --release
flutter build linux --release

# Trigger CI manually
gh workflow run build.yml

# Create release
git tag v1.0.1 && git push origin v1.0.1

# Check workflow status
gh run list --workflow=build.yml
gh run view --log
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `flutter pub get` fails | Check pubspec.yaml syntax, run `flutter clean` first |
| Analyze fails | Run `dart analyze lib/models/ lib/services/ db/` locally first |
| Tests fail | Run `flutter test test/` locally, fix failures |
| APK too large | Enable `--split-per-abi`, remove unused dependencies |
| Web build fails | Check for dart:io imports in web code (use universal_io) |
| Release not created | Tag must match `v*` pattern (e.g., `v1.0.0`) |

---

## Support Matrix

| Platform | Build Status | Distribution |
|----------|--------------|--------------|
| Android (APK) | ✅ Ready | Play Store, Direct, MDM |
| Android (AAB) | ✅ Ready | Play Store |
| Web | ✅ Ready | Firebase, Netlify, Pages |
| Linux | ✅ Ready | Snap, Flatpak, Tarball |
| macOS | ✅ Ready | DMG, App Store |
| Windows | ✅ Ready | MSIX, Installer |
| iOS | ⚠️ Needs Xcode | TestFlight, App Store |

> **Note:** iOS requires macOS runner and Apple Developer account. Add `flutter build ipa` job if needed.