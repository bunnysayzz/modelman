# Project Setup & Structure

## Flutter Project Initialization

### Step 1: Create Flutter Project

```bash
# Create new Flutter project
flutter create hoot_flutter --org com.portkeyai

# Navigate to project
cd hoot_flutter

# Enable multi-platform support
flutter config --enable-web
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
flutter config --enable-windows-desktop
```

### Step 2: Configure pubspec.yaml

```yaml
name: hoot_flutter
description: Hoot - MCP Testing Tool for Flutter
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  hooks_riverpod: ^2.4.9
  riverpod_lint: ^2.3.7

  # Network
  dio: ^5.4.0
  web_socket_channel: ^2.4.0
  connectivity_plus: ^5.0.2

  # Storage
  shared_preferences: ^2.2.2
  sqflite: ^2.3.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.1

  # Authentication
  flutter_appauth: ^6.0.0
  url_launcher: ^6.2.2
  flutter_secure_storage: ^9.0.0

  # JSON & Serialization
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1

  # UI Components
  flutter_markdown: ^0.6.14
  flutter_highlight: ^0.7.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  # Utilities
  uuid: ^4.3.3
  intl: ^0.18.1
  logger: ^2.0.2
  collection: ^1.18.0

  # Routing
  go_router: ^13.0.0

  # Code Generation
  freezed: ^2.4.6
  json_serializable: ^6.7.1
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.8

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
```

### Step 3: Directory Structure Creation

```bash
# Create directory structure
mkdir -p lib/core/{config,constants,network,state,storage,theme,router}
mkdir -p lib/features/{auth,servers,tools,chat,oauth}/{data,domain,presentation}/{repositories,models,entities,usecases,providers,pages}
mkdir -p lib/shared/{widgets,models,utils}
mkdir -p lib/l10n
mkdir -p test/{unit,integration}
mkdir -p integration_test
mkdir -p assets/{images,icons}
```

## File-by-File Setup

### lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    const ProviderScope(
      child: HootApp(),
    ),
  );
}

class HootApp extends ConsumerWidget {
  const HootApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Hoot',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
```

### lib/core/config/app_config.dart

```dart
class AppConfig {
  // API Configuration
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8008',
  );

  static const String frontendUrl = String.fromEnvironment(
    'FRONTEND_URL',
    defaultValue: 'http://localhost:8009',
  );

  // App Configuration
  static const String appName = 'Hoot';
  static const String appVersion = '1.0.0';
  
  // Feature Flags
  static const bool enableHybridMode = true;
  static const bool enableToolFilter = true;
  static const bool enableKeyboardShortcuts = true;
  
  // Performance Configuration
  static const int maxHistoryEntries = 100;
  static const int maxCacheSize = 50; // MB
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration requestTimeout = Duration(seconds: 60);
}
```

### lib/core/constants/api_constants.dart

```dart
class ApiConstants {
  // Base URLs
  static const String baseUrl = AppConfig.backendUrl;
  
  // Endpoints
  static const String health = '/health';
  static const String authToken = '/auth/token';
  static const String mcpAutoDetect = '/mcp/auto-detect';
  static const String mcpConnect = '/mcp/connect';
  static const String mcpDisconnect = '/mcp/disconnect';
  static const String mcpTools = '/mcp/tools';
  static const String mcpExecute = '/mcp/execute';
  static const String mcpStatus = '/mcp/status';
  static const String mcpConnections = '/mcp/connections';
  static const String mcpServerInfo = '/mcp/server-info';
  static const String mcpOAuthMetadata = '/mcp/oauth-metadata';
  static const String mcpFavicon = '/mcp/favicon';
  static const String mcpFaviconProxy = '/mcp/favicon-proxy';
  
  // Tool Filter Endpoints
  static const String toolFilterInitialize = '/mcp/tool-filter/initialize';
  static const String toolFilterFilter = '/mcp/tool-filter/filter';
  static const String toolFilterStats = '/mcp/tool-filter/stats';
  static const String toolFilterClearCache = '/mcp/tool-filter/clear-cache';
  
  // Headers
  static const String contentType = 'application/json';
  static const String authHeader = 'x-hoot-token';
}
```

### lib/core/network/dio_client.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../storage/local_storage_service.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.backendUrl,
    connectTimeout: AppConfig.connectionTimeout,
    receiveTimeout: AppConfig.requestTimeout,
    headers: {'Content-Type': 'application/json'},
  ));

  // Add auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));

  // Add logging interceptor (debug only)
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      response: true,
      error: true,
    ));
  }

  return dio;
});

class AuthInterceptor extends Interceptor {
  final Ref ref;
  
  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final storage = ref.read(localStorageServiceProvider);
    final token = await storage.getAuthToken();
    
    if (token != null) {
      options.headers[ApiConstants.authHeader] = token;
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired, refresh logic
      final storage = ref.read(localStorageServiceProvider);
      await storage.clearAuthToken();
      // Navigate to login or re-auth
    }
    handler.next(err);
  }
}
```

### lib/core/network/websocket_client.dart

```dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WebSocketStatus { connected, disconnected, connecting, error }

class WebSocketClient {
  WebSocketChannel? _channel;
  final _controller = StreamController<String>();
  final _statusController = StreamController<WebSocketStatus>();
  
  Stream<String> get messages => _controller.stream;
  Stream<WebSocketStatus> get status => _statusController.stream;
  
  WebSocketStatus _currentStatus = WebSocketStatus.disconnected;
  WebSocketStatus get currentStatus => _currentStatus;

  void connect(String url) {
    _currentStatus = WebSocketStatus.connecting;
    _statusController.add(_currentStatus);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen(
        (data) {
          _currentStatus = WebSocketStatus.connected;
          _statusController.add(_currentStatus);
          _controller.add(data as String);
        },
        onError: (error) {
          _currentStatus = WebSocketStatus.error;
          _statusController.add(_currentStatus);
        },
        onDone: () {
          _currentStatus = WebSocketStatus.disconnected;
          _statusController.add(_currentStatus);
        },
      );
    } catch (e) {
      _currentStatus = WebSocketStatus.error;
      _statusController.add(_currentStatus);
    }
  }

  void send(String message) {
    _channel?.sink.add(message);
  }

  void disconnect() {
    _channel?.sink.close();
    _currentStatus = WebSocketStatus.disconnected;
    _statusController.add(_currentStatus);
  }

  void dispose() {
    _controller.close();
    _statusController.close();
    disconnect();
  }
}

final webSocketClientProvider = Provider<WebSocketClient>((ref) {
  final client = WebSocketClient();
  ref.onDispose(() => client.dispose());
  return client;
});
```

### lib/core/storage/local_storage_service.dart

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Auth Token
  Future<String?> getAuthToken() async {
    return _prefs.getString('auth_token');
  }

  Future<void> setAuthToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  Future<void> clearAuthToken() async {
    await _prefs.remove('auth_token');
  }

  // User ID
  Future<String?> getUserId() async {
    return _prefs.getString('user_id');
  }

  Future<void> setUserId(String userId) async {
    await _prefs.setString('user_id', userId);
  }

  // Server Configs
  Future<List<Map<String, dynamic>>> getServerConfigs() async {
    final data = _prefs.getString('server_configs');
    if (data == null) return [];
    return List<Map<String, dynamic>>.from(json.decode(data));
  }

  Future<void> setServerConfigs(List<Map<String, dynamic>> configs) async {
    await _prefs.setString('server_configs', json.encode(configs));
  }

  // Theme Preference
  Future<bool> getIsDarkMode() async {
    return _prefs.getBool('is_dark_mode') ?? false;
  }

  Future<void> setIsDarkMode(bool isDarkMode) async {
    await _prefs.setBool('is_dark_mode', isDarkMode);
  }

  // Tool Filter Config
  Future<Map<String, dynamic>?> getToolFilterConfig() async {
    final data = _prefs.getString('tool_filter_config');
    if (data == null) return null;
    return json.decode(data) as Map<String, dynamic>;
  }

  Future<void> setToolFilterConfig(Map<String, dynamic> config) async {
    await _prefs.setString('tool_filter_config', json.encode(config));
  }
}

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main()');
});

// Initialize in main.dart
Future<ProviderContainer> initializeProviders() async {
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer();
  
  container.read(localStorageServiceProvider.overrideWithValue(
    LocalStorageService(prefs),
  ));
  
  return container;
}
```

### lib/core/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

final themeModeProvider = StateProvider<AppThemeMode>((ref) {
  return AppThemeMode.system;
});

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5CCFE6),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFFAFAFA),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5CCFE6),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
      ),
    );
  }
}
```

### lib/core/router/app_router.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/local_storage_service.dart';
import '../../features/servers/presentation/pages/servers_page.dart';
import '../../features/tools/presentation/pages/tools_page.dart';
import '../../features/chat/presentation/pages/chat_page.dart';
import '../../features/auth/presentation/pages/oauth_callback_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/servers',
    redirect: (context, state) {
      // Add auth redirect logic if needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/servers',
        name: 'servers',
        builder: (context, state) => const ServersPage(),
      ),
      GoRoute(
        path: '/tools',
        name: 'tools',
        builder: (context, state) => const ToolsPage(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) => const ChatPage(),
      ),
      GoRoute(
        path: '/oauth/callback',
        name: 'oauth-callback',
        builder: (context, state) {
          final params = state.uri.queryParameters;
          return OAuthCallbackPage(params: params);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
});
```

## Code Generation Setup

### build.yaml

```yaml
targets:
  $default:
    builders:
      json_serializable:
        options:
          explicit_to_json: true
          include_if_null: false
      freezed:
        options:
          union_key: type
          union_value_case: camelCase
      riverpod_generator:
        enabled: true
      riverpod_lint:
        enabled: true
```

### Run Code Generation

```bash
# Watch mode for development
flutter pub run build_runner watch --delete-conflicting-outputs

# One-time build
flutter pub run build_runner build --delete-conflicting-outputs
```

## Platform-Specific Configuration

### Android (android/app/build.gradle)

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.portkeyai.hoot"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

### iOS (ios/Runner/Info.plist)

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>hoot</string>
        </array>
    </dict>
</array>
```

## Testing Setup

### test/unit/example_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Example test', () {
    expect(true, isTrue);
  });
}
```

## Next Steps

1. Review `02-backend-integration.md` for API client implementation
2. Set up code generation with `flutter pub run build_runner build`
3. Configure platform-specific settings for iOS and Android
4. Initialize storage service in main.dart
