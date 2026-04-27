# Modelman Flutter

<img src="../modelman.png" alt="Modelman Logo" width="100" height="100">

Modelman - MCP Testing Tool for Flutter

A beautiful Flutter application for testing Model Context Protocol (MCP) servers with a Postman-like interface.

## Features

- **Server Management** - Connect to multiple MCP servers with auto-detection
- **Tool Execution** - Test tools with JSON parameter editor
- **Chat Interface** - AI-powered tool testing with conversation
- **8 Beautiful Themes** - Light and dark modes
- **OAuth 2.1 Support** - Secure authentication with PKCE flow
- **Cross-Platform** - Runs on Android, iOS, macOS, Windows, and Linux

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Installation

```bash
git clone https://github.com/bunnysayzz/modelman.git
cd modelman/modelman_flutter
flutter pub get
```

### Running the App

```bash
flutter run
```

For specific platforms:

```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios

# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

## Building for Release

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions.

### Quick Build Commands

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## Architecture

- **State Management** - Riverpod
- **Routing** - GoRouter
- **Network** - Dio
- **Storage** - SharedPreferences, Flutter Secure Storage
- **UI Components** - Material Design 3

## Development

### Running Tests

```bash
flutter test
```

### Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](../CONTRIBUTING.md) for details.

## License

MIT License - see [LICENSE](../LICENSE) for details.
