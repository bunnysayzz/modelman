# Deployment Checklist

## Overview

This document provides a comprehensive checklist for deploying the Flutter app to iOS, Android, Web, and Desktop platforms.

## Pre-Deployment Checklist

```
┌─────────────────────────────────────────────────────────────┐
│                   Pre-Deployment                               │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  [ ] Update version number in pubspec.yaml                  │
│  [ ] Update version number in AndroidManifest.xml           │
│  [ ] Update version number in Info.plist                    │
│  [ ] Run all tests and ensure they pass                      │
│  [ ] Check test coverage is > 80%                           │
│  [ ] Run code analysis (flutter analyze)                     │
│  [ ] Fix all linting issues                                 │
│  [ ] Update CHANGELOG.md                                     │
│  [ ] Create release notes                                   │
│  [ ] Test on all target platforms                           │
│  [ ] Check performance benchmarks                           │
│  [ ] Verify all API endpoints are correct                    │
│  [ ] Update backend URL if needed                           │
│  [ ] Clear debug logging                                     │
│  [ ] Verify OAuth flows work                                │
│  [ ] Test deep links                                        │
│  [ ] Verify secure storage works                            │
│  [ ] Check app icons and splash screens                      │
│  [ ] Verify permissions are correct                          │
│  [ ] Test on different screen sizes                          │
│  [ ] Verify accessibility features                          │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## iOS Deployment

### Preparation

```bash
# Update iOS version
open ios/Runner.xcworkspace
# Update version in Xcode: Runner > General > Version

# Update bundle identifier
# Change to your organization's bundle ID
# e.g., com.yourcompany.modelman
```

### Build Configuration

### ios/Runner.xcodeproj/project.pbxproj

```
# Ensure these settings are correct:
- Deployment Target: iOS 12.0 or higher
- Swift Compiler - Language Version: Swift 5
- Bundle Identifier: com.portkeyai.modelman
- Signing: Automatic signing or your developer certificate
```

### App Store Connect Setup

1. Create app in App Store Connect
2. Configure app information
3. Upload screenshots
4. Set pricing and availability
5. Submit for review

### Build and Upload

```bash
# Build for iOS (simulator)
flutter build ios --debug

# Build for iOS (device)
flutter build ios --release

# Archive and upload
# Open Xcode
open ios/Runner.xcworkspace
# Product > Archive
# Distribute App > App Store Connect
```

### TestFlight Deployment

```bash
# Build for TestFlight
flutter build ios --release

# Upload via Xcode
open ios/Runner.xcworkspace
# Product > Archive
# Distribute App > TestFlight
```

### iOS Checklist

- [ ] Bundle identifier is unique
- [ ] Version number follows semantic versioning
- [ ] Build number is incremented
- [ ] Provisioning profile is valid
- [ ] Code signing is configured
- [ ] App icons are included (all sizes)
- [ ] Launch screen is configured
- [ ] Info.plist permissions are correct
- [ ] OAuth deep links are configured
- [ ] App Store screenshots are uploaded
- [ ] App Store description is written
- [ ] Privacy policy URL is set
- [ ] App rating is appropriate
- [ ] Build is tested on physical devices
- [ ] TestFlight beta testing completed

## Android Deployment

### Preparation

```bash
# Update Android version
# Edit android/app/build.gradle
versionCode: 1  # Increment this
versionName: "1.0.0"  # Update this

# Update package name if needed
# Change com.portkeyai.modelman to your package
```

### Build Configuration

### android/app/build.gradle

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.portkeyai.modelman"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
            signingConfig signingConfigs.release
        }
    }
    
    splits {
        abi {
            enable true
            reset()
            include 'armeabi-v7a', 'arm64-v8a', 'x86_64'
            universalApk false
        }
    }
}
```

### Signing Configuration

### android/key.properties (Don't commit this)

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/keystore.jks
```

### android/app/build.gradle

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

### Build and Upload

```bash
# Build APK (for testing)
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Split APKs by ABI
flutter build apk --split-per-abi --release

# Upload to Play Store
# Go to Google Play Console
# Create new release
# Upload appbundle
# Complete release notes
# Submit for review
```

### Internal Testing

```bash
# Build for internal testing
flutter build apk --release

# Upload to Play Console
# Create internal test track
# Upload APK
# Add testers
```

### Android Checklist

- [ ] Package name is unique
- [ ] Version code is incremented
- [ ] Version name follows semantic versioning
- [ ] Signing key is created and secured
- [ ] ProGuard/R8 rules are configured
- [ ] App icons are included (all densities)
- [ ] Adaptive icons are configured
- [ ] Permissions are declared in manifest
- [ ] OAuth deep links are configured
- [ ] Play Store listing is complete
- [ ] Screenshots are uploaded (phone, tablet)
- [ ] Feature graphic is uploaded
- [ ] Privacy policy URL is set
- [ ] Content rating questionnaire completed
- [ ] Build is tested on multiple devices
- [ ] Internal testing track is set up

## Web Deployment

### Build Configuration

```bash
# Build for web
flutter build web --release

# Build with custom base URL
flutter build web --release --base-href /modelman/

# Build for specific renderer
flutter build web --release --web-renderer canvaskit
```

### Firebase Hosting

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Firebase
firebase login
firebase init

# Deploy
firebase deploy

# Or use Flutter web build
flutter build web --release
firebase deploy --only hosting
```

### GitHub Pages

```bash
# Build web app
flutter build web --release --base-href /modelman/

# Copy to docs folder
cp -r build/web docs/

# Commit and push
git add docs/
git commit -m "Deploy web app"
git push origin main
```

### Vercel/Netlify

```bash
# Build web app
flutter build web --release

# Deploy to Vercel
vercel --prod

# Or deploy to Netlify
netlify deploy --prod --dir=build/web
```

### Web Checklist

- [ ] Base href is configured correctly
- [ ] PWA manifest is included
- [ ] Service worker is configured
- [ ] App icons are included
- [ ] Favicon is included
- [ ] Meta tags are configured
- [ ] CORS is configured for API calls
- [ ] OAuth redirect URLs are set
- [ ] Build is tested in multiple browsers
- [ ] Responsive design works on web
- [ ] Keyboard shortcuts work
- [ ] LocalStorage works correctly
- [ ] Performance is optimized (Lighthouse score > 90)
- [ ] Accessibility is verified (WCAG AA)

## Desktop Deployment

### Windows

```bash
# Build for Windows
flutter build windows --release

# Create installer
# Use Inno Setup or WiX Toolset
# Or use electron-builder wrapper

# Sign executable
signtool sign /f certificate.pfx /t timestamp-server-url build/windows/runner/Release/modelman.exe
```

### macOS

```bash
# Build for macOS
flutter build macos --release

# Create DMG
# Use dmgbuild or similar tool

# Sign and notarize
codesign --force --deep --sign "Developer ID Application: Your Name" build/macos/Build/Products/Release/modelman.app
xcrun notarytool submit build/macos/Build/Products/Release/modelman.app --apple-id "your@email.com" --password "app-specific-password" --wait
xcrun stapler staple build/macos/Build/Products/Release/modelman.app
```

### Linux

```bash
# Build for Linux
flutter build linux --release

# Create AppImage
# Use appimage-builder

# Create DEB/RPM packages
# Use appropriate packaging tools

# Sign packages
# Use GPG signing
```

### Desktop Checklist

- [ ] Window management works correctly
- [ ] Menu bar is configured (macOS)
- [ ] System tray is configured (Windows/Linux)
- [ ] Keyboard shortcuts work
- [ ] File permissions are correct
- [ ] App is signed (Windows/macOS)
- [ ] Notarization is complete (macOS)
- [ ] Installer is created
- [ ] Desktop integration works
- [ ] Auto-update is configured
- [ ] Tested on multiple screen resolutions
- [ ] Performance is acceptable

## CI/CD Pipeline

### GitHub Actions

### .github/workflows/deploy.yml

```yaml
name: Deploy

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build Android App Bundle
        run: flutter build appbundle --release
      
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.portkeyai.modelman
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: completed

  build-ios:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Upload to TestFlight
        uses: apple-actions/upload-testflight-build@v1
        with:
          app-path: build/ios/iphoneos/Runner.app
          issuer-id: ${{ secrets.APP_STORE_ISSUER_ID }}
          api-key-id: ${{ secrets.APP_STORE_API_KEY_ID }}
          api-key: ${{ secrets.APP_STORE_API_KEY }}

  build-web:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Build Web
        run: flutter build web --release
      
      - name: Deploy to Firebase
        uses: w9jds/firebase-action@master
        with:
          args: deploy --only hosting
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
```

## Post-Deployment Checklist

```
┌─────────────────────────────────────────────────────────────┐
│                   Post-Deployment                             │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  [ ] Verify app is available in store                       │
│  [ ] Test download and installation                         │
│  [ ] Verify OAuth flow works in production                    │
│  [ ] Test all critical features                             │
│  [ ] Monitor crash reports (Firebase Crashlytics)            │
│  [ ] Monitor analytics (Firebase Analytics)                  │
│  [ ] Monitor performance (Firebase Performance)              │
│  [ ] Check user feedback                                     │
│  [ ] Update documentation                                    │
│  [ ] Announce release                                       │
│  [ ] Monitor for issues                                    │
│  [ ] Prepare for hotfix if needed                            │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Monitoring and Analytics

### Firebase Setup

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure

# Add Firebase to app
flutter pub add firebase_core firebase_analytics firebase_crashlytics firebase_performance
```

### Analytics Implementation

### lib/core/analytics/analytics_service.dart

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }

  Future<void> logServerAdded(String serverName) async {
    await _analytics.logEvent(
      name: 'server_added',
      parameters: {'server_name': serverName},
    );
  }

  Future<void> logToolExecuted(String toolName) async {
    await _analytics.logEvent(
      name: 'tool_executed',
      parameters: {'tool_name': toolName},
    );
  }

  Future<void> logOAuthInitiated(String provider) async {
    await _analytics.logEvent(
      name: 'oauth_initiated',
      parameters: {'provider': provider},
    );
  }
}

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final analytics = FirebaseAnalytics.instance;
  return AnalyticsService(analytics);
});
```

### Crashlytics Setup

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

Future<void> setupCrashlytics() async {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
}
```

## Rollback Strategy

### Quick Rollback Steps

**iOS:**
1. Go to App Store Connect
2. Create new version with previous build
3. Submit for expedited review
4. Or use TestFlight for immediate rollback

**Android:**
1. Go to Google Play Console
2. Create new release with previous APK
3. Publish to production track
4. Takes ~1-2 hours to propagate

**Web:**
1. Revert to previous commit
2. Redeploy to hosting
3. Immediate effect

**Desktop:**
1. Host previous version
2. Update download links
3. Notify users

## Version Management

### Semantic Versioning

```
Format: MAJOR.MINOR.PATCH

MAJOR: Breaking changes
MINOR: New features (backward compatible)
PATCH: Bug fixes

Example: 1.0.0 → 1.0.1 → 1.1.0 → 2.0.0
```

### Release Notes Template

```markdown
## Version X.Y.Z

### Features
- New feature 1
- New feature 2

### Bug Fixes
- Fixed bug 1
- Fixed bug 2

### Improvements
- Performance improvement
- UI polish

### Breaking Changes
- Breaking change description
- Migration guide
```

## Final Deployment Checklist

- [ ] All platforms built successfully
- [ ] All platforms tested
- [ ] CI/CD pipeline is working
- [ ] Monitoring is configured
- [ ] Analytics is tracking
- [ ] Crash reporting is enabled
- [ ] Documentation is updated
- [ ] Release notes are written
- [ ] Announcement is prepared
- [ ] Support team is informed
- [ ] Rollback plan is documented

## Next Steps

1. Begin implementation following the plans in order
2. Set up CI/CD pipeline early
3. Test deployment process in staging environment first
4. Monitor first release closely
5. Gather user feedback for improvements
