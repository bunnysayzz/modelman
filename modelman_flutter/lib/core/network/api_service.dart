import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import 'api_exception.dart';
import 'dio_client.dart';

/// High-level API service mapping every backend endpoint.
///
/// All methods return parsed Dart types. Errors are wrapped as
/// [ApiException] with user-friendly messages.
class ApiService {
  final Dio _dio;

  ApiService(this._dio);

  /// Wraps all API calls with proper error handling and retry logic.
  /// Retries up to [maxRetries] times for transient network errors.
  Future<T> _safeCall<T>(Future<T> Function() call, {int maxRetries = 2}) async {
    int attempt = 0;
    while (true) {
      try {
        return await call();
      } on DioException catch (e) {
        final isRetryable = e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout;

        if (isRetryable && attempt < maxRetries) {
          attempt++;
          // Exponential backoff: 500ms, 1500ms
          await Future.delayed(Duration(milliseconds: 500 * attempt));
          continue;
        }
        throw ApiException.fromDioException(e);
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException.fromError(e);
      }
    }
  }

  // ── Health ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> healthCheck() => _safeCall(() async {
        final response = await _dio.get(ApiConstants.health);
        return response.data as Map<String, dynamic>;
      });

  // ── Authentication ──────────────────────────────────────────

  Future<String> getAuthToken(String userId) => _safeCall(() async {
        final response = await _dio.post(
          ApiConstants.authToken,
          data: {'userId': userId},
        );
        return response.data['token'] as String;
      });

  // ── MCP Server Operations ──────────────────────────────────

  Future<Map<String, dynamic>> autoDetectServer(String url) =>
      _safeCall(() async {
        final response = await _dio.post(
          ApiConstants.mcpAutoDetect,
          data: {'url': url},
        );
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> connectToServer({
    required String serverId,
    required String serverName,
    required String url,
    required String transport,
    Map<String, dynamic>? auth,
    String? authorizationCode,
  }) =>
      _safeCall(() async {
        final response = await _dio.post(
          ApiConstants.mcpConnect,
          data: {
            'serverId': serverId,
            'serverName': serverName,
            'url': url,
            'transport': transport,
            if (auth != null) 'auth': auth,
            if (authorizationCode != null)
              'authorizationCode': authorizationCode,
          },
        );
        return response.data as Map<String, dynamic>;
      });

  Future<void> disconnectFromServer(String serverId) => _safeCall(() async {
        await _dio.post(
          ApiConstants.mcpDisconnect,
          data: {'serverId': serverId},
        );
      });

  Future<List<Map<String, dynamic>>> listTools(String serverId) =>
      _safeCall(() async {
        final response = await _dio.get(
          '${ApiConstants.mcpTools}/$serverId',
        );
        return (response.data['tools'] as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
      });

  Future<Map<String, dynamic>> executeTool({
    required String serverId,
    required String toolName,
    required Map<String, dynamic> arguments,
  }) =>
      _safeCall(() async {
        final response = await _dio.post(
          ApiConstants.mcpExecute,
          data: {
            'serverId': serverId,
            'toolName': toolName,
            'arguments': arguments,
          },
        );
        return response.data as Map<String, dynamic>;
      });

  Future<bool> getConnectionStatus(String serverId) => _safeCall(() async {
        final response = await _dio.get(
          '${ApiConstants.mcpStatus}/$serverId',
        );
        return response.data['connected'] as bool;
      });

  Future<Map<String, dynamic>> getServerInfo(String serverId) =>
      _safeCall(() async {
        final response = await _dio.get(
          '${ApiConstants.mcpServerInfo}/$serverId',
        );
        return response.data['serverInfo'] as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>?> getOAuthMetadata(String serverId) =>
      _safeCall(() async {
        final response = await _dio.get(
          '${ApiConstants.mcpOAuthMetadata}/$serverId',
        );
        return response.data['metadata'] as Map<String, dynamic>?;
      });

  Future<String> getFavicon({
    required String serverUrl,
    String? oauthLogoUri,
  }) =>
      _safeCall(() async {
        final response = await _dio.post(
          ApiConstants.mcpFavicon,
          data: {
            'serverUrl': serverUrl,
            if (oauthLogoUri != null) 'oauthLogoUri': oauthLogoUri,
          },
        );
        return response.data['faviconUrl'] as String;
      });

  Future<Map<String, dynamic>> getConnections() => _safeCall(() async {
        final response = await _dio.get(ApiConstants.mcpConnections);
        return response.data as Map<String, dynamic>;
      });

  // ── Tool Filter Operations ─────────────────────────────────

  Future<void> initializeToolFilter(
    List<Map<String, dynamic>> servers,
  ) =>
      _safeCall(() async {
        await _dio.post(
          ApiConstants.toolFilterInitialize,
          data: {'servers': servers},
        );
      });

  Future<Map<String, dynamic>> filterTools({
    required List<Map<String, dynamic>> messages,
    Map<String, dynamic>? options,
  }) =>
      _safeCall(() async {
        final response = await _dio.post(
          ApiConstants.toolFilterFilter,
          data: {
            'messages': messages,
            if (options != null) 'options': options,
          },
        );
        return response.data as Map<String, dynamic>;
      });

  Future<Map<String, dynamic>> getToolFilterStats() => _safeCall(() async {
        final response = await _dio.get(ApiConstants.toolFilterStats);
        return response.data['stats'] as Map<String, dynamic>;
      });

  Future<void> clearToolFilterCache() => _safeCall(() async {
        await _dio.post(ApiConstants.toolFilterClearCache);
      });

  // ── Chat / AI ──────────────────────────────────────────────

  Future<Map<String, dynamic>> sendChatMessage({
    required List<Map<String, dynamic>> messages,
    Map<String, dynamic>? options,
  }) =>
      _safeCall(() async {
        final response = await _dio.post(
          ApiConstants.chatSend,
          data: {
            'messages': messages,
            if (options != null) 'options': options,
          },
        );
        return response.data as Map<String, dynamic>;
      });
}

/// Provides a singleton [ApiService] backed by the Dio client.
final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiService(dio);
});
