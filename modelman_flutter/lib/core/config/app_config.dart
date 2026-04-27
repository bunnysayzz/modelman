/// Application configuration constants.
///
/// Provides centralized access to backend URLs, feature flags, and
/// performance tuning parameters. Values can be overridden via
/// Dart compile-time environment variables.
class AppConfig {
  AppConfig._();

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
  static const String appName = 'Modelman';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'MCP Testing Tool';

  // Feature Flags
  static const bool enableHybridMode = true;
  static const bool enableToolFilter = true;
  static const bool enableKeyboardShortcuts = true;

  // Performance Configuration
  static const int maxHistoryEntries = 100;
  static const int maxCacheSize = 50; // MB
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration requestTimeout = Duration(seconds: 60);

  // WebSocket Configuration
  static String get webSocketUrl {
    final wsScheme = backendUrl.startsWith('https') ? 'wss' : 'ws';
    final host = backendUrl.replaceFirst(RegExp(r'https?://'), '');
    return '$wsScheme://$host';
  }
}
