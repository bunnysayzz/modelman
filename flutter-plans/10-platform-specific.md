# Platform-Specific Implementations

## Overview

This document details platform-specific implementations for iOS, Android, Web, and Desktop platforms in Flutter.

## Platform Support Matrix

```
┌─────────────────────────────────────────────────────────────┐
│                   Platform Support                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Feature              │ iOS │ Android │ Web │ Desktop │       │
│  ─────────────────────┼─────┼─────────┼─────┼─────────│       │
│  OAuth 2.1            │ ✅  │   ✅    │ ✅  │   ✅    │       │
│  Secure Storage      │ ✅  │   ✅    │ ❌  │   ✅    │       │
│  Deep Links          │ ✅  │   ✅    │ ✅  │   ✅    │       │
│  Keyboard Shortcuts   │ ✅  │   ✅    │ ✅  │   ✅    │       │
│  Local Storage       │ ✅  │   ✅    │ ✅  │   ✅    │       │
│  SQLite              │ ✅  │   ✅    │ ❌  │   ✅    │       │
│  Window Management   │ N/A │   N/A   │ N/A │   ✅    │       │
│  Menu Bar            │ N/A │   N/A   │ N/A │   ✅    │       │
│  System Tray         │ N/A │   N/A   │ N/A │   ✅    │       │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Platform Detection

### lib/core/platform/platform_service.dart

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlatformType { iOS, Android, Web, MacOS, Windows, Linux }

class PlatformService {
  static PlatformType get currentPlatform {
    if (kIsWeb) return PlatformType.Web;
    
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return PlatformType.iOS;
    }
    
    if (Theme.of(context).platform == TargetPlatform.android) {
      return PlatformType.Android;
    }
    
    if (Theme.of(context).platform == TargetPlatform.macOS) {
      return PlatformType.MacOS;
    }
    
    if (Theme.of(context).platform == TargetPlatform.windows) {
      return PlatformType.Windows;
    }
    
    if (Theme.of(context).platform == TargetPlatform.linux) {
      return PlatformType.Linux;
    }
    
    return PlatformType.Web;
  }

  static bool get isMobile {
    return currentPlatform == PlatformType.iOS || 
           currentPlatform == PlatformType.Android;
  }

  static bool get isDesktop {
    return currentPlatform == PlatformType.MacOS || 
           currentPlatform == PlatformType.Windows || 
           currentPlatform == PlatformType.Linux;
  }

  static bool get isWeb => currentPlatform == PlatformType.Web;

  static bool get isIOS => currentPlatform == PlatformType.iOS;
  
  static bool get isAndroid => currentPlatform == PlatformType.Android;
}

final platformServiceProvider = Provider<PlatformService>((ref) {
  return PlatformService();
});
```

## iOS-Specific Implementation

### lib/core/platform/ios/ios_service.dart

```dart
import 'dart:io';
import 'package:flutter/services.dart';

class IOSService {
  static const MethodChannel _channel = MethodChannel('hoot/ios');

  // Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestNotificationPermissions');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Check app store URL
  Future<void> openAppStore() async {
    const url = 'https://apps.apple.com/app/hoot';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // Handle iOS-specific OAuth configuration
  Future<void> configureOAuth({
    required String clientId,
    required String redirectScheme,
  }) async {
    // iOS-specific OAuth configuration
    // Already configured in Info.plist
  }

  // Get iOS device info
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = await _channel.invokeMethod('getDeviceInfo');
    return deviceInfo as Map<String, dynamic>;
  }
}
```

### ios/Runner/Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>Hoot</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>hoot</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    
    <!-- OAuth Deep Links -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.portkeyai.hoot</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>hoot</string>
            </array>
        </dict>
    </array>
    
    <!-- App Transport Security -->
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    
    <!-- Permissions -->
    <key>NSCameraUsageDescription</key>
    <string>Camera access is required for scanning QR codes</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Photo library access is required for saving images</string>
</dict>
</plist>
```

### ios/Runner/AppDelegate.swift

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let iosChannel = FlutterMethodChannel(name: "hoot/ios",
                                           binaryMessenger: controller.binaryMessenger)
    
    iosChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "requestNotificationPermissions":
        self.requestNotificationPermissions(result: result)
      case "getDeviceInfo":
        result(self.getDeviceInfo())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func requestNotificationPermissions(result: FlutterResult) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      result(granted)
    }
  }
  
  private func getDeviceInfo() -> [String: Any] {
    let device = UIDevice.current
    return [
      "model": device.model,
      "systemVersion": device.systemVersion,
      "name": device.name,
    ]
  }
}
```

## Android-Specific Implementation

### lib/core/platform/android/android_service.dart

```dart
import 'dart:io';
import 'package:flutter/services.dart';

class AndroidService {
  static const MethodChannel _channel = MethodChannel('hoot/android');

  // Request permissions
  Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod('requestPermissions');
      return result as bool;
    } catch (e) {
      return false;
    }
  }

  // Open Play Store
  Future<void> openPlayStore() async {
    const url = 'https://play.google.com/store/apps/details?id=com.portkeyai.hoot';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  // Share content
  Future<void> shareContent(String text) async {
    await _channel.invokeMethod('shareContent', {'text': text});
  }

  // Get Android device info
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceInfo = await _channel.invokeMethod('getDeviceInfo');
    return deviceInfo as Map<String, dynamic>;
  }
}
```

### android/app/src/main/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.portkeyai.hoot">
    
    <!-- Permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    
    <application
        android:label="Hoot"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:requestLegacyExternalStorage="true">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <!-- OAuth Deep Links -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data
                    android:scheme="hoot"
                    android:host="oauth"
                    android:path="/callback" />
            </intent-filter>
        </activity>
        
        <!-- Don't delete the meta-data below. -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### android/app/src/main/kotlin/com/portkeyai/hoot/MainActivity.kt

```kotlin
package com.portkeyai.hoot

import android.content.Intent
import android.os.Bundle
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "hoot/android"
    
    private val PERMISSIONS = arrayOf(
        android.Manifest.permission.CAMERA,
        android.Manifest.permission.READ_EXTERNAL_STORAGE,
        android.Manifest.permission.WRITE_EXTERNAL_STORAGE
    )
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermissions" -> {
                    requestPermissions(result)
                }
                "shareContent" -> {
                    val text = call.argument<String>("text")
                    shareContent(text)
                    result.success(null)
                }
                "getDeviceInfo" -> {
                    result.success(getDeviceInfo())
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun requestPermissions(result: MethodChannel.Result) {
        val permissionsToRequest = PERMISSIONS.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (permissionsToRequest.isEmpty()) {
            result.success(true)
        } else {
            ActivityCompat.requestPermissions(this, permissionsToRequest.toTypedArray(), 1001)
            result.success(true)
        }
    }
    
    private fun shareContent(text: String?) {
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/plain"
            putExtra(Intent.EXTRA_TEXT, text)
        }
        startActivity(Intent.createChooser(intent, "Share"))
    }
    
    private fun getDeviceInfo(): Map<String, Any> {
        return mapOf(
            "model" to android.os.Build.MODEL,
            "version" to android.os.Build.VERSION.RELEASE,
            "manufacturer" to android.os.Build.MANUFACTURER
        )
    }
}
```

## Web-Specific Implementation

### lib/core/platform/web/web_service.dart

```dart
import 'dart:html' as html;
import 'package:url_launcher/url_launcher.dart';

class WebService {
  // Check if running in web
  static bool get isWeb => identical(0, 0.0);

  // Handle OAuth callback from URL
  Map<String, String>? getOAuthCallbackParams() {
    final uri = html.window.location.href;
    final params = Uri.parse(uri).queryParameters;
    return params;
  }

  // Update URL without reload
  void updateUrl(String path) {
    html.window.history.pushState({}, '', path);
  }

  // Copy to clipboard
  Future<void> copyToClipboard(String text) async {
    await html.window.navigator.clipboard?.writeText(text);
  }

  // Download file
  void downloadFile(String content, String filename) {
    final blob = html.Blob([content], 'text/plain');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // Open external link
  Future<void> openExternalLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
```

### web/index.html

```html
<!DOCTYPE html>
<html>
<head>
    <base href="$FLUTTER_BASE_HREF">
    <meta charset="UTF-8">
    <meta content="IE=Edge" http-equiv="X-UA-Compatible">
    <meta name="description" content="Hoot - MCP Testing Tool">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="apple-mobile-web-app-title" content="Hoot">
    <link rel="apple-touch-icon" href="icons/Icon-192.png">
    <link rel="icon" type="image/png" href="favicon.png"/>
    <title>Hoot</title>
    <link rel="manifest" href="manifest.json">
    <style>
        body {
            margin: 0;
            padding: 0;
            background: #1a1a1a;
        }
        #loading {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #5CCFE6;
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            font-size: 24px;
        }
    </style>
</head>
<body>
    <div id="loading">Loading Hoot...</div>
    <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

### web/manifest.json

```json
{
    "name": "Hoot",
    "short_name": "Hoot",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#1a1a1a",
    "theme_color": "#5CCFE6",
    "description": "Hoot - MCP Testing Tool",
    "icons": [
        {
            "src": "icons/Icon-192.png",
            "sizes": "192x192",
            "type": "image/png"
        },
        {
            "src": "icons/Icon-512.png",
            "sizes": "512x512",
            "type": "image/png"
        }
    ]
}
```

## Desktop-Specific Implementation

### lib/core/platform/desktop/desktop_service.dart

```dart
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class DesktopService {
  // Initialize window manager
  Future<void> initializeWindow() async {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1200, 800),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Set window title
  Future<void> setWindowTitle(String title) async {
    await windowManager.setTitle(title);
  }

  // Minimize window
  Future<void> minimizeWindow() async {
    await windowManager.minimize();
  }

  // Maximize window
  Future<void> maximizeWindow() async {
    await windowManager.maximize();
  }

  // Close window
  Future<void> closeWindow() async {
    await windowManager.close();
  }

  // Check if window is maximized
  Future<bool> isMaximized() async {
    return await windowManager.isMaximized();
  }

  // Set window size
  Future<void> setWindowSize(double width, double height) async {
    await windowManager.setSize(Size(width, height));
  }

  // Set window position
  Future<void> setWindowPosition(double x, double y) async {
    await windowManager.setPosition(Offset(x, y));
  }
}

final desktopServiceProvider = Provider<DesktopService>((ref) {
  return DesktopService();
});
```

### macOS-Specific

#### macos/Runner/Info.plist

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>hoot</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSMinimumSystemVersion</key>
    <string>$(MACOSX_DEPLOYMENT_TARGET)</string>
    
    <!-- OAuth Deep Links -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>com.portkeyai.hoot</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>hoot</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

#### macos/Runner/MainFlutterWindow.swift

```swift
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    
    super.awakeFromNib()
  }
}
```

### Windows-Specific

#### windows/runner/win32_window.cpp

```cpp
#include "flutter/flutter_window.h"
#include "utils/flutter_utils.h"
#include <optional>

bool FlutterWindow::OnCreate(HWND hwnd, LPCWSTR title, POINT position, SIZE size) {
    if (!Win32Window::OnCreate(hwnd, title, position, size)) {
        return false;
    }

    RegisterPlugins(flutter_controller_->GetEngine());

    return true;
}

void FlutterWindow::OnDestroy() {
    Win32Window::OnDestroy();
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
    if (flutter_controller_ && message == WM_DPICHANGED) {
        flutter_controller_->HandleDpiChanged(wparam, lparam);
    }
    
    return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
```

### Linux-Specific

#### linux/my_application.cc

```cpp
#include "my_application.h"
#include <flutter_linux/flutter_linux.h>

struct _MyApplication {
    GtkApplication parent_instance;
    GtkWindow* window;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

static void my_application_activate(GApplication* application) {
    MyApplication* self = MY_APPLICATION(application);
    
    GtkWindow* window = GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));
    gtk_window_set_title(window, "Hoot");
    gtk_window_set_default_size(window, 1200, 800);
    gtk_widget_show(GTK_WIDGET(window));
    
    self->window = window;
}

static void my_application_class_init(MyApplicationClass* klass) {
    G_APPLICATION_CLASS(klass)->activate = my_application_activate;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
    return MY_APPLICATION(g_object_new(my_application_get_type(), "application-id", "com.portkeyai.hoot", nullptr));
}
```

## Responsive Layout

### lib/shared/widgets/responsive_layout.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/platform/platform_service.dart';

class ResponsiveLayout extends ConsumerWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    if (platform.isDesktop || screenWidth >= 1200) {
      return desktop;
    } else if (screenWidth >= 768) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
```

## Platform-Specific UI Components

### lib/shared/widgets/platform_aware_widget.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/platform/platform_service.dart';

class PlatformAwareWidget extends ConsumerWidget {
  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? android;
  final Widget Function(BuildContext)? ios;
  final Widget Function(BuildContext)? web;
  final Widget Function(BuildContext)? desktop;

  const PlatformAwareWidget({
    super.key,
    required this.mobile,
    this.android,
    this.ios,
    this.web,
    this.desktop,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(platformServiceProvider);

    switch (platform.currentPlatform) {
      case PlatformType.Android:
        return android?.call(context) ?? mobile(context);
      case PlatformType.iOS:
        return ios?.call(context) ?? mobile(context);
      case PlatformType.Web:
        return web?.call(context) ?? mobile(context);
      case PlatformType.MacOS:
      case PlatformType.Windows:
      case PlatformType.Linux:
        return desktop?.call(context) ?? mobile(context);
    }
  }
}
```

## Migration Checklist

- [ ] Implement PlatformService for detection
- [ ] Implement iOS-specific services
- [ ] Configure iOS Info.plist
- [ ] Implement Android-specific services
- [ ] Configure AndroidManifest.xml
- [ ] Implement Web-specific services
- [ ] Configure web/index.html and manifest.json
- [ ] Implement Desktop window management
- [ ] Configure macOS Info.plist
- [ ] Configure Windows runner
- [ ] Configure Linux application
- [ ] Implement responsive layout
- [ ] Create platform-aware widgets
- [ ] Test on all target platforms

## Next Steps

1. Review `11-performance-optimization.md` for performance strategies
2. Test OAuth flow on iOS and Android
3. Implement platform-specific shortcuts
4. Add platform-specific menus for desktop
