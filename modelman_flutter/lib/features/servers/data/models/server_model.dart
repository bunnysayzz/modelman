import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_model.freezed.dart';
part 'server_model.g.dart';

/// Configuration for an MCP server connection.
@freezed
class ServerConfig with _$ServerConfig {
  const factory ServerConfig({
    required String id,
    required String name,
    required String url,
    @Default('') String transport,
    @Default(false) bool connected,
    String? error,
    String? faviconUrl,
    DateTime? lastConnected,
    AuthConfig? auth,
  }) = _ServerConfig;

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);
}

/// Authentication configuration for a server.
@freezed
class AuthConfig with _$AuthConfig {
  const factory AuthConfig({
    required String type, // 'oauth', 'api_key', 'bearer', 'none'
    String? clientId,
    String? clientSecret,
    String? authorizationUrl,
    String? tokenUrl,
    String? redirectUri,
    List<String>? scopes,
    String? apiKey,
    String? bearerToken,
  }) = _AuthConfig;

  factory AuthConfig.fromJson(Map<String, dynamic> json) =>
      _$AuthConfigFromJson(json);
}

/// Server connection status for the UI.
enum ServerConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}
