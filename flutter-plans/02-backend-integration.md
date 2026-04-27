# Backend Integration

## Overview

This document details how to integrate the Flutter app with the existing Hoot Node.js backend. The backend remains unchanged - we only need to create the Flutter client to communicate with it.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App Layer                         │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │ API Services │◄────►│ Repositories │◄────►│  Providers  │ │
│  │  (Dio)       │      │  (Data Layer)│      │ (Riverpod)  │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                                                   │
│         │ HTTP/JSON                                         │
│         ▼                                                   │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Existing Node.js Backend                   │ │
│  │  - Express Server (localhost:8008)                     │ │
│  │  - MCP SDK                                             │ │
│  │  - SQLite Database                                      │ │
│  │  - JWT Authentication                                   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## API Service Layer

### lib/core/network/api_service.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'dio_client.dart';

class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  // Health Check
  Future<Map<String, dynamic>> healthCheck() async {
    final response = await _dio.get(ApiConstants.health);
    return response.data as Map<String, dynamic>;
  }

  // Authentication
  Future<String> getAuthToken(String userId) async {
    final response = await _dio.post(
      ApiConstants.authToken,
      data: {'userId': userId},
    );
    return response.data['token'] as String;
  }

  // MCP Server Operations
  Future<Map<String, dynamic>> autoDetectServer(String url) async {
    final response = await _dio.post(
      ApiConstants.mcpAutoDetect,
      data: {'url': url},
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> connectToServer({
    required String serverId,
    required String serverName,
    required String url,
    required String transport,
    Map<String, dynamic>? auth,
    String? authorizationCode,
  }) async {
    final response = await _dio.post(
      ApiConstants.mcpConnect,
      data: {
        'serverId': serverId,
        'serverName': serverName,
        'url': url,
        'transport': transport,
        if (auth != null) 'auth': auth,
        if (authorizationCode != null) 'authorizationCode': authorizationCode,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<void> disconnectFromServer(String serverId) async {
    await _dio.post(
      ApiConstants.mcpDisconnect,
      data: {'serverId': serverId},
    );
  }

  Future<List<Map<String, dynamic>>> listTools(String serverId) async {
    final response = await _dio.get(
      '${ApiConstants.mcpTools}/$serverId',
    );
    return (response.data['tools'] as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> executeTool({
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) async {
    final response = await _dio.post(
      ApiConstants.mcpExecute,
      data: {
        'serverId': serverId,
        'toolName': toolName,
        'arguments': arguments,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<bool> getConnectionStatus(String serverId) async {
    final response = await _dio.get(
      '${ApiConstants.mcpStatus}/$serverId',
    );
    return response.data['connected'] as bool;
  }

  Future<Map<String, dynamic>> getServerInfo(String serverId) async {
    final response = await _dio.get(
      '${ApiConstants.mcpServerInfo}/$serverId',
    );
    return response.data['serverInfo'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> getOAuthMetadata(String serverId) async {
    final response = await _dio.get(
      '${ApiConstants.mcpOAuthMetadata}/$serverId',
    );
    return response.data['metadata'] as Map<String, dynamic>?;
  }

  Future<String> getFavicon({
    required String serverUrl,
    String? oauthLogoUri,
  }) async {
    final response = await _dio.post(
      ApiConstants.mcpFavicon,
      data: {
        'serverUrl': serverUrl,
        if (oauthLogoUri != null) 'oauthLogoUri': oauthLogoUri,
      },
    );
    return response.data['faviconUrl'] as String;
  }

  // Tool Filter Operations
  Future<void> initializeToolFilter(List<Map<String, dynamic>> servers) async {
    await _dio.post(
      ApiConstants.toolFilterInitialize,
      data: {'servers': servers},
    );
  }

  Future<Map<String, dynamic>> filterTools({
    required List<Map<String, dynamic>> messages,
    Map<String, dynamic>? options,
  }) async {
    final response = await _dio.post(
      ApiConstants.toolFilterFilter,
      data: {
        'messages': messages,
        if (options != null) 'options': options,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getToolFilterStats() async {
    final response = await _dio.get(ApiConstants.toolFilterStats);
    return response.data['stats'] as Map<String, dynamic>;
  }

  Future<void> clearToolFilterCache() async {
    await _dio.post(ApiConstants.toolFilterClearCache);
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});
```

## Repository Layer

### lib/features/servers/data/repositories/server_repository.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';
import '../models/server_model.dart';

class ServerRepository {
  final ApiService _apiService;

  ServerRepository(this._apiService);

  Future<ServerConfig> autoDetectServer(String url) async {
    final result = await _apiService.autoDetectServer(url);
    return ServerConfig.fromJson(result);
  }

  Future<ConnectionResult> connectToServer({
    required String serverId,
    required String serverName,
    required String url,
    required String transport,
    AuthConfig? auth,
    String? authorizationCode,
  }) async {
    final result = await _apiService.connectToServer(
      serverId: serverId,
      serverName: serverName,
      url: url,
      transport: transport,
      auth: auth?.toJson(),
      authorizationCode: authorizationCode,
    );
    return ConnectionResult.fromJson(result);
  }

  Future<void> disconnectFromServer(String serverId) async {
    await _apiService.disconnectFromServer(serverId);
  }

  Future<List<ToolSchema>> listTools(String serverId) async {
    final tools = await _apiService.listTools(serverId);
    return tools.map((t) => ToolSchema.fromJson(t)).toList();
  }

  Future<ServerInfo?> getServerInfo(String serverId) async {
    final info = await _apiService.getServerInfo(serverId);
    return info != null ? ServerInfo.fromJson(info) : null;
  }

  Future<OAuthMetadata?> getOAuthMetadata(String serverId) async {
    final metadata = await _apiService.getOAuthMetadata(serverId);
    return metadata != null ? OAuthMetadata.fromJson(metadata) : null;
  }

  Future<String> getFavicon({
    required String serverUrl,
    String? oauthLogoUri,
  }) async {
    return await _apiService.getFavicon(
      serverUrl: serverUrl,
      oauthLogoUri: oauthLogoUri,
    );
  }
}

final serverRepositoryProvider = Provider<ServerRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ServerRepository(apiService);
});
```

## Data Models

### lib/features/servers/data/models/server_model.dart

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_model.freezed.dart';
part 'server_model.g.dart';

@freezed
class ServerConfig with _$ServerConfig {
  const factory ServerConfig({
    required String id,
    required String name,
    required String url,
    String? transport,
    @JsonKey(name: 'lastConnected') DateTime? lastConnected,
    @JsonKey(name: 'faviconUrl') String? faviconUrl,
    @JsonKey(default: false) bool connected,
    String? error,
    AuthConfig? auth,
  }) = _ServerConfig;

  factory ServerConfig.fromJson(Map<String, dynamic> json) =>
      _$ServerConfigFromJson(json);
}

@freezed
class AuthConfig with _$AuthConfig {
  const factory AuthConfig({
    String? type,
    String? apiKey,
    Map<String, dynamic>? oauth,
  }) = _AuthConfig;

  factory AuthConfig.fromJson(Map<String, dynamic> json) =>
      _$AuthConfigFromJson(json);
}

@freezed
class ConnectionResult with _$ConnectionResult {
  const factory ConnectionResult({
    @JsonKey(default: false) bool success,
    String? error,
    @JsonKey(name: 'needsAuth') bool? needsAuth,
    String? authorizationUrl,
  }) = _ConnectionResult;

  factory ConnectionResult.fromJson(Map<String, dynamic> json) =>
      _$ConnectionResultFromJson(json);
}

@freezed
class ToolSchema with _$ToolSchema {
  const factory ToolSchema({
    required String name,
    String? description,
    Map<String, dynamic>? inputSchema,
  }) = _ToolSchema;

  factory ToolSchema.fromJson(Map<String, dynamic> json) =>
      _$ToolSchemaFromJson(json);
}

@freezed
class ServerInfo with _$ServerInfo {
  const factory ServerInfo({
    String? name,
    String? version,
    String? title,
    String? description,
    String? websiteUrl,
    List<String>? icons,
    String? instructions,
  }) = _ServerInfo;

  factory ServerInfo.fromJson(Map<String, dynamic> json) =>
      _$ServerInfoFromJson(json);
}

@freezed
class OAuthMetadata with _$OAuthMetadata {
  const factory OAuthMetadata({
    String? issuer,
    String? authorizationEndpoint,
    String? tokenEndpoint,
    String? logoUri,
  }) = _OAuthMetadata;

  factory OAuthMetadata.fromJson(Map<String, dynamic> json) =>
      _$OAuthMetadataFromJson(json);
}
```

## SSE/WebSocket Integration

### lib/core/network/sse_client.dart

```dart
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SseConnectionState { connecting, connected, disconnected, error }

class SseClient {
  WebSocketChannel? _channel;
  final _controller = StreamController<Map<String, dynamic>>();
  final _stateController = StreamController<SseConnectionState>();
  
  Stream<Map<String, dynamic>> get events => _controller.stream;
  Stream<SseConnectionState> get state => _stateController.stream;
  
  SseConnectionState _currentState = SseConnectionState.disconnected;
  SseConnectionState get currentState => _currentState;

  void connect(String url) {
    _currentState = SseConnectionState.connecting;
    _stateController.add(_currentState);

    try {
      // Convert SSE endpoint to WebSocket if needed
      // Or use HTTP client with SSE parsing
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen(
        (data) {
          _currentState = SseConnectionState.connected;
          _stateController.add(_currentState);
          
          // Parse SSE data
          final lines = (data as String).split('\n');
          for (final line in lines) {
            if (line.startsWith('data: ')) {
              final jsonData = line.substring(6);
              try {
                final parsed = json.decode(jsonData) as Map<String, dynamic>;
                _controller.add(parsed);
              } catch (e) {
                // Handle parse error
              }
            }
          }
        },
        onError: (error) {
          _currentState = SseConnectionState.error;
          _stateController.add(_currentState);
        },
        onDone: () {
          _currentState = SseConnectionState.disconnected;
          _stateController.add(_currentState);
        },
      );
    } catch (e) {
      _currentState = SseConnectionState.error;
      _stateController.add(_currentState);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _currentState = SseConnectionState.disconnected;
    _stateController.add(_currentState);
  }

  void dispose() {
    _controller.close();
    _stateController.close();
    disconnect();
  }
}

final sseClientProvider = Provider<SseClient>((ref) {
  final client = SseClient();
  ref.onDispose(() => client.dispose());
  return client;
});
```

## Error Handling

### lib/core/network/api_error.dart

```dart
import 'package:dio/dio.dart';

enum ApiErrorType {
  network,
  auth,
  server,
  validation,
  unknown,
}

class ApiError implements Exception {
  final String message;
  final ApiErrorType type;
  final int? statusCode;
  final dynamic originalError;

  ApiError({
    required this.message,
    required this.type,
    this.statusCode,
    this.originalError,
  });

  static ApiError fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiError(
          message: 'Connection timeout',
          type: ApiErrorType.network,
          originalError: error,
        );
      
      case DioExceptionType.connectionError:
        return ApiError(
          message: 'No internet connection',
          type: ApiErrorType.network,
          originalError: error,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        
        if (statusCode == 401) {
          return ApiError(
            message: data?['message'] ?? 'Authentication failed',
            type: ApiErrorType.auth,
            statusCode: statusCode,
            originalError: error,
          );
        }
        
        if (statusCode == 400) {
          return ApiError(
            message: data?['error'] ?? 'Invalid request',
            type: ApiErrorType.validation,
            statusCode: statusCode,
            originalError: error,
          );
        }
        
        return ApiError(
          message: data?['error'] ?? 'Server error',
          type: ApiErrorType.server,
          statusCode: statusCode,
          originalError: error,
        );
      
      default:
        return ApiError(
          message: 'An unknown error occurred',
          type: ApiErrorType.unknown,
          originalError: error,
        );
    }
  }

  @override
  String toString() => 'ApiError: $message (type: $type)';
}
```

## Usage Example

### lib/features/servers/presentation/providers/server_provider.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/server_repository.dart';
import '../../data/models/server_model.dart';

class ServerNotifier extends StateNotifier<AsyncValue<List<ServerConfig>>> {
  final ServerRepository _repository;

  ServerNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadServers();
  }

  Future<void> loadServers() async {
    state = const AsyncValue.loading();
    try {
      // Load from local storage first
      final servers = await _repository.loadLocalServers();
      state = AsyncValue.data(servers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addServer(ServerConfig server) async {
    try {
      final currentServers = state.value ?? [];
      state = AsyncValue.data([...currentServers, server]);
      await _repository.saveLocalServers(state.value!);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeServer(String serverId) async {
    try {
      final currentServers = state.value ?? [];
      state = AsyncValue.data(
        currentServers.where((s) => s.id != serverId).toList(),
      );
      await _repository.saveLocalServers(state.value!);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final serverProvider = StateNotifierProvider<ServerNotifier, AsyncValue<List<ServerConfig>>>((ref) {
  final repository = ref.watch(serverRepositoryProvider);
  return ServerNotifier(repository);
});
```

## Testing

### test/core/network/api_service_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:hoot_flutter/core/network/api_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ApiService apiService;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiService = ApiService(mockDio);
  });

  group('ApiService', () {
    test('healthCheck returns success', () async {
      when(mockDio.get(any)).thenAnswer((_) async => Response(
        data: {'status': 'ok'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      final result = await apiService.healthCheck();
      
      expect(result['status'], 'ok');
      verify(mockDio.get('/health')).called(1);
    });

    test('getAuthToken returns token', () async {
      when(mockDio.post(any, data: anyNamed('data'))).thenAnswer((_) async => Response(
        data: {'token': 'test-token'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

      final token = await apiService.getAuthToken('user-123');
      
      expect(token, 'test-token');
    });
  });
}
```

## Next Steps

1. Review `03-state-management.md` for Riverpod state management setup
2. Implement repository layer for all features
3. Add error handling to all API calls
4. Create unit tests for API services
