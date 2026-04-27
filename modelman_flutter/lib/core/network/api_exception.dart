import 'package:dio/dio.dart';

/// Represents a user-friendly API error with proper categorization.
class ApiException implements Exception {
  final String message;
  final String? technicalDetails;
  final ApiErrorType type;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.technicalDetails,
    this.type = ApiErrorType.unknown,
    this.statusCode,
  });

  /// Creates an [ApiException] from a [DioException].
  factory ApiException.fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return ApiException(
          message: 'Cannot connect to the server. Please check that the backend is running and the URL is correct.',
          technicalDetails: e.message,
          type: ApiErrorType.connectionError,
        );

      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: 'Connection timed out. The server took too long to respond.',
          technicalDetails: e.message,
          type: ApiErrorType.timeout,
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message: 'Request timed out while sending data.',
          technicalDetails: e.message,
          type: ApiErrorType.timeout,
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Response timed out. The server may be overloaded.',
          technicalDetails: e.message,
          type: ApiErrorType.timeout,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final serverMessage = _extractServerMessage(e.response?.data);

        if (statusCode == 401) {
          return ApiException(
            message: 'Authentication failed. Please log in again.',
            technicalDetails: serverMessage,
            type: ApiErrorType.unauthorized,
            statusCode: statusCode,
          );
        } else if (statusCode == 403) {
          return ApiException(
            message: 'You don\'t have permission to perform this action.',
            technicalDetails: serverMessage,
            type: ApiErrorType.forbidden,
            statusCode: statusCode,
          );
        } else if (statusCode == 404) {
          return ApiException(
            message: 'The requested resource was not found.',
            technicalDetails: serverMessage,
            type: ApiErrorType.notFound,
            statusCode: statusCode,
          );
        } else if (statusCode >= 500) {
          return ApiException(
            message: 'Server error. Please try again later.',
            technicalDetails: serverMessage ?? 'HTTP $statusCode',
            type: ApiErrorType.serverError,
            statusCode: statusCode,
          );
        }
        return ApiException(
          message: serverMessage ?? 'Request failed (HTTP $statusCode).',
          technicalDetails: 'Status code: $statusCode',
          type: ApiErrorType.badResponse,
          statusCode: statusCode,
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
          type: ApiErrorType.cancelled,
        );

      case DioExceptionType.badCertificate:
        return ApiException(
          message: 'SSL certificate verification failed. The connection is not secure.',
          technicalDetails: e.message,
          type: ApiErrorType.certificateError,
        );

      case DioExceptionType.unknown:
        if (e.message?.contains('XMLHttpRequest') == true) {
          return ApiException(
            message: 'Network error. The server may be offline or unreachable.',
            technicalDetails: e.message,
            type: ApiErrorType.connectionError,
          );
        }
        return ApiException(
          message: 'An unexpected error occurred.',
          technicalDetails: e.message ?? e.toString(),
          type: ApiErrorType.unknown,
        );
    }
  }

  /// Creates an [ApiException] from a generic error.
  factory ApiException.fromError(Object e) {
    if (e is DioException) {
      return ApiException.fromDioException(e);
    }
    if (e is ApiException) return e;
    return ApiException(
      message: 'An unexpected error occurred.',
      technicalDetails: e.toString(),
      type: ApiErrorType.unknown,
    );
  }

  static String? _extractServerMessage(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String?;
    }
    return data.toString();
  }

  @override
  String toString() => message;
}

/// Categorizes API errors for UI-level handling.
enum ApiErrorType {
  connectionError,
  timeout,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  badResponse,
  cancelled,
  certificateError,
  unknown,
}
