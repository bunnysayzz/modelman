import 'package:flutter_test/flutter_test.dart';
import 'package:modelman_flutter/core/network/api_exception.dart';
import 'package:dio/dio.dart';

/// Tests for the ApiException error handling system.
void main() {
  group('ApiException', () {
    group('fromDioException', () {
      test('converts connection error to user-friendly message', () {
        final dioError = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
          message: 'The XMLHttpRequest onError callback was called.',
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.connectionError);
        expect(apiError.message, contains('Cannot connect'));
        expect(apiError.message, contains('backend is running'));
      });

      test('converts connection timeout to timeout message', () {
        final dioError = DioException(
          type: DioExceptionType.connectionTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.timeout);
        expect(apiError.message, contains('timed out'));
      });

      test('converts receive timeout to timeout message', () {
        final dioError = DioException(
          type: DioExceptionType.receiveTimeout,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.timeout);
        expect(apiError.message, contains('timed out'));
      });

      test('converts 401 to unauthorized message', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/test'),
            data: {'message': 'Invalid token'},
          ),
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.unauthorized);
        expect(apiError.statusCode, 401);
        expect(apiError.message, contains('Authentication failed'));
      });

      test('converts 403 to forbidden message', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 403,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.forbidden);
        expect(apiError.statusCode, 403);
        expect(apiError.message, contains('permission'));
      });

      test('converts 404 to not found message', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.notFound);
        expect(apiError.message, contains('not found'));
      });

      test('converts 500 to server error message', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/test'),
          ),
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.serverError);
        expect(apiError.message, contains('Server error'));
      });

      test('converts cancelled request', () {
        final dioError = DioException(
          type: DioExceptionType.cancel,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.cancelled);
        expect(apiError.message, contains('cancelled'));
      });

      test('handles XMLHttpRequest error in unknown type', () {
        final dioError = DioException(
          type: DioExceptionType.unknown,
          requestOptions: RequestOptions(path: '/test'),
          message: 'XMLHttpRequest error occurred',
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.type, ApiErrorType.connectionError);
        expect(apiError.message, contains('Network error'));
      });
    });

    group('fromError', () {
      test('wraps DioException via fromDioException', () {
        final dioError = DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/test'),
        );

        final apiError = ApiException.fromError(dioError);

        expect(apiError.type, ApiErrorType.connectionError);
      });

      test('returns same ApiException if already one', () {
        const original = ApiException(
          message: 'test error',
          type: ApiErrorType.unknown,
        );

        final result = ApiException.fromError(original);

        expect(result.message, 'test error');
      });

      test('wraps unknown errors', () {
        final error = Exception('something went wrong');

        final apiError = ApiException.fromError(error);

        expect(apiError.type, ApiErrorType.unknown);
        expect(apiError.message, contains('unexpected'));
      });
    });

    group('extractServerMessage', () {
      test('extracts message from Map response data', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 400,
            requestOptions: RequestOptions(path: '/test'),
            data: {'message': 'Custom error from server'},
          ),
        );

        final apiError = ApiException.fromDioException(dioError);

        // The message should contain the server's message
        expect(apiError.message, 'Custom error from server');
      });

      test('extracts error field from Map response data', () {
        final dioError = DioException(
          type: DioExceptionType.badResponse,
          requestOptions: RequestOptions(path: '/test'),
          response: Response(
            statusCode: 422,
            requestOptions: RequestOptions(path: '/test'),
            data: {'error': 'Validation failed'},
          ),
        );

        final apiError = ApiException.fromDioException(dioError);

        expect(apiError.message, 'Validation failed');
      });
    });

    test('toString returns message', () {
      const error = ApiException(
        message: 'Something broke',
        type: ApiErrorType.unknown,
      );

      expect(error.toString(), 'Something broke');
    });
  });
}
