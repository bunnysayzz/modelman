# Modelman Flutter - Deployment Guide

This guide covers deploying the Modelman Flutter app to various platforms.

## Prerequisites

- Flutter SDK (3.0.0 or higher)
- Platform-specific SDKs:
  - Android: Android Studio / Android SDK
  - iOS: Xcode (macOS only)
  - macOS: Xcode (macOS only)
  - Windows: Visual Studio 2022 with C++ workload
  - Linux: Clang, Ninja, GTK3 development libraries

## Build for Release

### Android

```bash
cd modelman_flutter
flutter build apk --release
```

The APK will be generated at `build/app/outputs/flutter-apk/app-release.apk`.

For an App Bundle (required for Google Play Store):

```bash
flutter build appbundle --release
```

The AAB will be at `build/app/outputs/bundle/release/app-release.aab`.

#### Google Play Store

1. Create a Google Play Console account
2. Create a new app
3. Upload the AAB file
4. Complete store listing:
   - App name: Modelman
   - Short description: MCP Testing Tool
   - Full description: Modelman is a Postman-like tool for testing Model Context Protocol (MCP) servers with a beautiful interface.
   - Screenshots (required for phone, 7" tablet, 10" tablet)
   - Icon (512x512 PNG)
   - Feature graphic (1024x500 PNG)
5. Set pricing and distribution
6. Review and publish

### iOS

```bash
cd modelman_flutter
flutter build ios --release
```

Then open the Xcode project:

```bash
open ios/Runner.xcworkspace
```

#### App Store Connect

1. Create an Apple Developer account
2. Register a new App ID with bundle identifier: `com.portkeyai.modelman`
3. Create a provisioning profile
4. In Xcode:
   - Select the Runner target
   - Set Signing & Capabilities
   - Select your team and provisioning profile
5. Archive and upload to App Store Connect
6. Complete App Store listing:
   - App name: Modelman
   - Description
   - Screenshots (required for all device sizes)
   - App icon
7. Submit for review

### macOS

```bash
cd modelman_flutter
flutter build macos --release
```

The app bundle will be at `build/macos/Build/Products/Release/modelman.app`.

#### Mac App Store

1. Create an Apple Developer account
2. Register a new App ID: `com.portkeyai.modelman`
3. Create a provisioning profile
4. Enable App Sandbox entitlements in Xcode
5. Archive and upload to App Store Connect
6. Complete listing and submit for review

### Windows

```bash
cd modelman_flutter
flutter build windows --release
```

The executable will be at `build/windows/runner/Release/modelman.exe`.

#### Microsoft Store

1. Create a Microsoft Partner Center account
2. Reserve app name
3. Package the app using MSIX
4. Upload and complete listing
5. Submit for certification

### Linux

```bash
cd modelman_flutter
flutter build linux --release
```

The executable will be at `build/linux/x64/release/bundle/modelman`.

#### Distribution Options

- Snap Store
- Flathub (Flatpak)
- AppImage
- Direct download from website/GitHub releases

## Version Management

Update version in `pubspec.yaml`:

```yaml
version: 1.0.0+1
```

Format: `major.minor.patch+build_number`

## Code Signing

### Android

Create a keystore:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Reference it in `android/key.properties` (don't commit this file):

```properties
storePassword=your_password
keyPassword=your_password
keyAlias=upload
storeFile=/path/to/upload-keystore.jks
```

### iOS/macOS

Use Xcode's automatic signing with your Apple Developer account.

## CI/CD

### GitHub Actions

Example workflow for automated builds:

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      - run: flutter build ios --release --no-codesign
```

## Store Listing Assets

### Screenshots Required

- **iOS**: 6.7", 6.5", 5.5" iPhone; 12.9", 11" iPad Pro
- **Android**: Phone, 7" tablet, 10" tablet
- **macOS**: Various Mac screen sizes

### Icon Requirements

- **iOS**: 1024x1024 PNG (App Store)
- **Android**: 512x512 PNG (Google Play)
- **macOS**: 512x512 PNG (Mac App Store)
- **Windows**: Various sizes for Store listing

## Post-Release

1. Monitor crash reports (Sentry, Crashlytics)
2. Review user feedback
3. Address bugs and issues
4. Plan next release with new features
5. Update version number and changelog

## Troubleshooting

### Build Failures

- Ensure all dependencies are up to date: `flutter pub get`
- Clean build artifacts: `flutter clean`
- Check platform-specific SDK versions

### Signing Issues

- Verify provisioning profiles are valid
- Check bundle identifiers match
- Ensure certificates are not expired

### Store Rejection

- Review platform guidelines
- Check for missing required metadata
- Ensure app follows platform design guidelines
