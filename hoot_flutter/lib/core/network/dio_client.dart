import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage_service.dart';

/// Provides a configured Dio HTTP client instance.
///
/// Includes auth token injection via [AuthInterceptor] and
/// debug logging in non-production builds.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.backendUrl,
    connectTimeout: AppConfig.connectionTimeout,
    receiveTimeout: AppConfig.requestTimeout,
    sendTimeout: AppConfig.requestTimeout,
    headers: {
      'Content-Type': ApiConstants.contentType,
    },
  ));

  // Add auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));

  // Add logging interceptor in debug mode
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  return dio;
});

/// Interceptor that injects the auth token into every outgoing request
/// and handles 401 responses by clearing the stored token.
class AuthInterceptor extends Interceptor {
  final Ref _ref;

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final storage = _ref.read(localStorageServiceProvider);
      final token = await storage.getAuthToken();

      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.authHeader] = token;
      }
    } catch (_) {
      // Storage not yet initialized — continue without token
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final storage = _ref.read(localStorageServiceProvider);
        await storage.clearAuthToken();
      } catch (_) {
        // Ignore storage errors during error handling
      }
    }
    handler.next(err);
  }
}
