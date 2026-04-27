# Crash Reporting & Error Handling

## Overview

This document details comprehensive crash reporting and error handling strategies to ensure the Flutter app runs smoothly with proper error recovery and user feedback.

## Error Handling Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Error Handling Architecture                  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐      ┌──────────────┐      ┌────────────┐ │
│  │   Flutter    │      │  Error       │      │  Crash      │ │
│  │     App      │◄────►│  Handler     │◄────►│  Reporter   │ │
│  │              │      │              │      │             │ │
│  └──────────────┘      └──────────────┘      └────────────┘ │
│         │                       │                      │     │
│         │                       │                      │     │
│         ▼                       ▼                      ▼     │
│  ┌────────────────────────────────────────────────────────┐ │
│  │              Error Types & Handling                     │ │
│  │  ┌──────────────┐  ┌──────────────┐  ┌────────────┐   │ │
│  │  │  Network     │  │  Runtime     │  │  Fatal      │   │ │
│  │  │  Errors      │  │  Errors      │  │  Errors     │   │ │
│  │  └──────────────┘  └──────────────┘  └────────────┘   │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## Firebase Crashlytics Integration

### pubspec.yaml (Add dependencies)

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_crashlytics: ^3.4.9
  firebase_analytics: ^10.7.4
  sentry_flutter: ^7.14.0  # Alternative crash reporting
```

### lib/main.dart (Initialize Firebase)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'core/error/error_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  
  // Initialize Analytics
  final analytics = FirebaseAnalytics.instance;
  
  // Set up error handlers
  setupErrorHandlers();
  
  runApp(
    ProviderScope(
      observers: [
        ProviderLogger(),
      ],
      child: modelmanApp(analytics: analytics),
    ),
  );
}

void setupErrorHandlers() {
  // Flutter error handler
  FlutterError.onError = (errorDetails) async {
    FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };

  // Platform error handler
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
}
```

## Custom Error Handler

### lib/core/error/error_handler.dart

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

enum ErrorSeverity { low, medium, high, critical }

enum ErrorType {
  network,
  authentication,
  validation,
  runtime,
  database,
  fileSystem,
  unknown,
}

class AppError implements Exception {
  final String message;
  final ErrorType type;
  final ErrorSeverity severity;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  AppError({
    required this.message,
    required this.type,
    this.severity = ErrorSeverity.medium,
    this.originalError,
    this.stackTrace,
    this.metadata,
  });

  @override
  String toString() => 'AppError: $message (type: $type, severity: $severity)';
}

class ErrorHandler {
  final FirebaseCrashlytics _crashlytics;
  final SentryClient? _sentry;

  ErrorHandler({
    required FirebaseCrashlytics crashlytics,
    SentryClient? sentry,
  })  : _crashlytics = crashlytics,
        _sentry = sentry;

  // Handle error with logging and reporting
  Future<void> handleError(AppError error) async {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('Error: ${error.message}');
      debugPrint('Type: ${error.type}');
      debugPrint('Severity: ${error.severity}');
      if (error.stackTrace != null) {
        debugPrint('Stack trace: ${error.stackTrace}');
      }
    }

    // Report to Crashlytics
    await _reportToCrashlytics(error);

    // Report to Sentry if configured
    if (_sentry != null) {
      await _reportToSentry(error);
    }

    // Show user-friendly message based on severity
    _showUserMessage(error);
  }

  Future<void> _reportToCrashlytics(AppError error) async {
    await _crashlytics.recordError(
      error.message,
      error.stackTrace,
      fatal: error.severity == ErrorSeverity.critical,
      information: error.metadata?.entries.map((e) => e.key).toList(),
    );
  }

  Future<void> _reportToSentry(AppError error) async {
    if (_sentry == null) return;

    await _sentry.captureException(
      exception: error.originalError ?? error,
      stackTrace: error.stackTrace,
      hint: Hint.withMetadata(
        custom: {
          'error_type': error.type.name,
          'severity': error.severity.name,
          ...?error.metadata,
        },
      ),
    );
  }

  void _showUserMessage(AppError error) {
    // Show appropriate UI message based on error type and severity
    // This can be done via a snackbar, dialog, or error boundary
  }

  // Create error from exception
  static AppError fromException(
    dynamic exception, {
    StackTrace? stackTrace,
    ErrorType type = ErrorType.unknown,
    ErrorSeverity severity = ErrorSeverity.medium,
    Map<String, dynamic>? metadata,
  }) {
    return AppError(
      message: exception.toString(),
      type: type,
      severity: severity,
      originalError: exception,
      stackTrace: stackTrace,
      metadata: metadata,
    );
  }
}

// Global error handler provider
final errorHandlerProvider = Provider<ErrorHandler>((ref) {
  return ErrorHandler(
    crashlytics: FirebaseCrashlytics.instance,
    sentry: SentryClient(),
  );
});
```

## Error Boundary Widget

### lib/shared/widgets/error_boundary.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/error_handler.dart';

class ErrorBoundary extends ConsumerStatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  ConsumerState<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends ConsumerState<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _error = null;
    _stackTrace = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _DefaultErrorWidget(
            error: _error!,
            stackTrace: _stackTrace,
            onRetry: () {
              setState(() {
                _error = null;
                _stackTrace = null;
              });
            },
          );
    }
    return child;
  }

  void _handleError(Object error, StackTrace stackTrace) {
    setState(() {
      _error = error;
      _stackTrace = stackTrace;
    });

    widget.onError?.call(error, stackTrace);

    // Report to error handler
    final appError = ErrorHandler.fromException(
      error,
      stackTrace: stackTrace,
      type: ErrorType.runtime,
    );
    ref.read(errorHandlerProvider).handleError(appError);
  }
}

class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Show full error details
                  _showErrorDialog(context);
                },
                child: const Text('View Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              if (stackTrace != null)
                Text(
                  'Stack Trace:\n$stackTrace',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
```

## Network Error Handling

### lib/core/network/network_error_handler.dart

```dart
import 'package:dio/dio.dart';
import '../error/error_handler.dart';

class NetworkErrorHandler {
  final ErrorHandler _errorHandler;

  NetworkErrorHandler(this._errorHandler);

  AppError handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          message: 'Connection timeout. Please check your internet connection.',
          type: ErrorType.network,
          severity: ErrorSeverity.medium,
          originalError: error,
          metadata: {'error_type': error.type.name},
        );

      case DioExceptionType.connectionError:
        return AppError(
          message: 'No internet connection. Please check your network.',
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          originalError: error,
          metadata: {'error_type': error.type.name},
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 401) {
          return AppError(
            message: 'Authentication failed. Please log in again.',
            type: ErrorType.authentication,
            severity: ErrorSeverity.high,
            originalError: error,
            metadata: {'status_code': statusCode, 'response': data},
          );
        }

        if (statusCode == 403) {
          return AppError(
            message: 'Access denied. You don\'t have permission.',
            type: ErrorType.authentication,
            severity: ErrorSeverity.high,
            originalError: error,
            metadata: {'status_code': statusCode, 'response': data},
          );
        }

        if (statusCode == 404) {
          return AppError(
            message: 'Resource not found.',
            type: ErrorType.network,
            severity: ErrorSeverity.medium,
            originalError: error,
            metadata: {'status_code': statusCode, 'response': data},
          );
        }

        if (statusCode == 500) {
          return AppError(
            message: 'Server error. Please try again later.',
            type: ErrorType.network,
            severity: ErrorSeverity.high,
            originalError: error,
            metadata: {'status_code': statusCode, 'response': data},
          );
        }

        return AppError(
          message: data?['error'] ?? 'An error occurred',
          type: ErrorType.network,
          severity: ErrorSeverity.medium,
          originalError: error,
          metadata: {'status_code': statusCode, 'response': data},
        );

      case DioExceptionType.cancel:
        return AppError(
          message: 'Request was cancelled.',
          type: ErrorType.network,
          severity: ErrorSeverity.low,
          originalError: error,
        );

      case DioExceptionType.unknown:
        return AppError(
          message: 'An unknown error occurred.',
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          originalError: error,
        );

      default:
        return AppError(
          message: 'An error occurred during network request.',
          type: ErrorType.network,
          severity: ErrorSeverity.medium,
          originalError: error,
        );
    }
  }

  Future<void> handleNetworkError(AppError error) async {
    await _errorHandler.handleError(error);
  }
}
```

## Retry Mechanism

### lib/core/network/retry_mechanism.dart

```dart
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryableStatusCodes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
  });

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err)) {
      final retries = err.requestOptions.extra['retries'] ?? 0;

      if (retries < maxRetries) {
        err.requestOptions.extra['retries'] = retries + 1;

        await Future.delayed(retryDelay);

        try {
          final response = await Dio().fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.badResponse &&
        retryableStatusCodes.contains(error.response?.statusCode);
  }
}
```

## User Feedback UI

### lib/shared/widgets/error_snackbar.dart

```dart
import 'package:flutter/material.dart';
import '../../core/error/error_handler.dart';

class ErrorSnackbar {
  static void show(
    BuildContext context,
    AppError error, {
    SnackBarAction? action,
  }) {
    final backgroundColor = _getBackgroundColor(error.severity);
    final icon = _getIcon(error.severity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        action: action,
        duration: _getDuration(error.severity),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Color _getBackgroundColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  static IconData _getIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info;
      case ErrorSeverity.medium:
        return Icons.warning;
      case ErrorSeverity.high:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.error_outline;
    }
  }

  static Duration _getDuration(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return const Duration(seconds: 3);
      case ErrorSeverity.medium:
        return const Duration(seconds: 5);
      case ErrorSeverity.high:
        return const Duration(seconds: 8);
      case ErrorSeverity.critical:
        return const Duration(seconds: 10);
    }
  }
}
```

## Global Error Dialog

### lib/shared/widgets/global_error_dialog.dart

```dart
import 'package:flutter/material.dart';
import '../../core/error/error_handler.dart';

class GlobalErrorDialog extends StatelessWidget {
  final AppError error;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const GlobalErrorDialog({
    super.key,
    required this.error,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getIcon(error.severity),
            color: _getColor(error.severity),
          ),
          const SizedBox(width: 8),
          Text(_getTitle(error.severity)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.message),
          if (error.metadata != null && error.metadata!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Details:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...error.metadata!.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('${e.key}: ${e.value}'),
                )),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text('Dismiss'),
        ),
        ElevatedButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }

  IconData _getIcon(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Icons.info;
      case ErrorSeverity.medium:
        return Icons.warning;
      case ErrorSeverity.high:
        return Icons.error;
      case ErrorSeverity.critical:
        return Icons.error_outline;
    }
  }

  Color _getColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red.shade900;
    }
  }

  String _getTitle(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return 'Info';
      case ErrorSeverity.medium:
        return 'Warning';
      case ErrorSeverity.high:
        return 'Error';
      case ErrorSeverity.critical:
        return 'Critical Error';
    }
  }
}
```

## Logging Service

### lib/core/logging/logging_service.dart

```dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

enum LogLevel { trace, debug, info, warning, error, fatal }

class LoggingService {
  final Logger _logger;
  final bool _verboseLogging;

  LoggingService({bool verboseLogging = false})
      : _verboseLogging = verboseLogging,
        _logger = Logger(
          printer: PrettyPrinter(
            methodCount: 2,
            errorMethodCount: 8,
            lineLength: 120,
            colors: true,
            printEmojis: true,
            printTime: true,
          ),
        );

  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? metadata,
  }) {
    if (!_verboseLogging && level == LogLevel.debug) return;

    switch (level) {
      case LogLevel.trace:
        _logger.t(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.debug:
        _logger.d(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.info:
        _logger.i(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.warning:
        _logger.w(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.error:
        _logger.e(message, error: error, stackTrace: stackTrace);
        break;
      case LogLevel.fatal:
        _logger.f(message, error: error, stackTrace: stackTrace);
        break;
    }

    // Add metadata if provided
    if (metadata != null && metadata.isNotEmpty) {
      _logger.d('Metadata: $metadata');
    }
  }

  void trace(String message) => log(message, level: LogLevel.trace);
  void debug(String message) => log(message, level: LogLevel.debug);
  void info(String message) => log(message, level: LogLevel.info);
  void warning(String message) => log(message, level: LogLevel.warning);
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
  void fatal(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.fatal, error: error, stackTrace: stackTrace);
}

final loggingServiceProvider = Provider<LoggingService>((ref) {
  final settings = ref.watch(settingsServiceProvider).getSettings();
  return LoggingService(verboseLogging: settings.verboseLogging);
});
```

## Load Balancing Strategy

### lib/core/network/load_balancer.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoadBalancer {
  final List<String> _backendUrls;
  int _currentIndex = 0;
  final Map<String, int> _failureCounts = {};

  LoadBalancer(this._backendUrls) {
    for (final url in _backendUrls) {
      _failureCounts[url] = 0;
    }
  }

  String getNextAvailableUrl() {
    // Select backend with least failures
    final sortedUrls = _backendUrls.toList()
      ..sort((a, b) => _failureCounts[a]!.compareTo(_failureCounts[b]!));

    final selectedUrl = sortedUrls.first;
    _currentIndex = _backendUrls.indexOf(selectedUrl);
    
    return selectedUrl;
  }

  void markFailure(String url) {
    _failureCounts[url] = (_failureCounts[url] ?? 0) + 1;
    
    // Reset failure count if too high (for retry)
    if (_failureCounts[url]! > 5) {
      _failureCounts[url] = 0;
    }
  }

  void markSuccess(String url) {
    _failureCounts[url] = 0;
  }

  String getCurrentUrl() {
    return _backendUrls[_currentIndex];
  }
}

class LoadBalancedDio {
  final LoadBalancer _loadBalancer;
  late final Dio _dio;

  LoadBalancedDio(this._loadBalancer) {
    _dio = Dio(BaseOptions(
      baseUrl: _loadBalancer.getCurrentUrl(),
    ));

    _dio.interceptors.add(_LoadBalancerInterceptor(_loadBalancer));
  }

  Dio get dio => _dio;
}

class _LoadBalancerInterceptor extends Interceptor {
  final LoadBalancer _loadBalancer;

  _LoadBalancerInterceptor(this._loadBalancer);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.receiveTimeout) {
      _loadBalancer.markFailure(err.requestOptions.uri.toString());
      
      // Retry with next available URL
      final nextUrl = _loadBalancer.getNextAvailableUrl();
      err.requestOptions.baseUrl = nextUrl;
      
      // Retry request
      _fetchWithRetry(err.requestOptions, handler);
    } else {
      handler.next(err);
    }
  }

  Future<void> _fetchWithRetry(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final response = await Dio().fetch(options);
      _loadBalancer.markSuccess(options.uri.toString());
      handler.resolve(response);
    } catch (e) {
      handler.next(err);
    }
  }
}
```

## Health Check Service

### lib/core/network/health_check_service.dart

```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthCheckService {
  final Dio _dio;

  HealthCheckService(this._dio);

  Future<bool> checkHealth(String url) async {
    try {
      final response = await _dio.get(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, bool>> checkAllBackends(List<String> urls) async {
    final results = <String, bool>{};
    
    await Future.wait(
      urls.map((url) async {
        final isHealthy = await checkHealth(url);
        results[url] = isHealthy;
      }),
    );

    return results;
  }
}

final healthCheckServiceProvider = Provider<HealthCheckService>((ref) {
  final dio = ref.watch(dioProvider);
  return HealthCheckService(dio);
});
```

## Error Recovery Strategies

### lib/core/error/recovery_service.dart

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../error/error_handler.dart';
import '../network/health_check_service.dart';

class RecoveryService {
  final ErrorHandler _errorHandler;
  final HealthCheckService _healthCheckService;

  RecoveryService(this._errorHandler, this._healthCheckService);

  Future<bool> attemptRecovery(AppError error) async {
    switch (error.type) {
      case ErrorType.network:
        return await _recoverFromNetworkError(error);
      case ErrorType.authentication:
        return await _recoverFromAuthError(error);
      case ErrorType.database:
        return await _recoverFromDatabaseError(error);
      default:
        return false;
    }
  }

  Future<bool> _recoverFromNetworkError(AppError error) async {
    // Check if backend is available
    final health = await _healthCheckService.checkHealth(
      error.metadata?['backend_url'] ?? '',
    );

    if (!health) {
      // Backend is down, show user message
      return false;
    }

    // Try to reconnect
    return true;
  }

  Future<bool> _recoverFromAuthError(AppError error) async {
    // Clear auth token and prompt re-login
    // Navigate to login screen
    return true;
  }

  Future<bool> _recoverFromDatabaseError(AppError error) async {
    // Try to reinitialize database
    // If that fails, clear cache and reinitialize
    return true;
  }
}

final recoveryServiceProvider = Provider<RecoveryService>((ref) {
  final errorHandler = ref.watch(errorHandlerProvider);
  final healthCheckService = ref.watch(healthCheckServiceProvider);
  return RecoveryService(errorHandler, healthCheckService);
});
```

## Testing Error Handling

### test/core/error/error_handler_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:modelman_flutter/core/error/error_handler.dart';

class MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  group('ErrorHandler', () {
    test('handles network error correctly', () {
      final error = AppError(
        message: 'Network error',
        type: ErrorType.network,
        severity: ErrorSeverity.high,
      );

      expect(error.type, ErrorType.network);
      expect(error.severity, ErrorSeverity.high);
    });

    test('creates error from exception', () {
      final exception = Exception('Test error');
      final error = ErrorHandler.fromException(exception);

      expect(error.message, contains('Test error'));
      expect(error.type, ErrorType.unknown);
    });
  });
}
```

## Error Handling Checklist

- [ ] Initialize Firebase Crashlytics
- [ ] Initialize Sentry (alternative)
- [ ] Implement custom ErrorHandler
- [ ] Create ErrorBoundary widget
- [ ] Implement network error handling
- [ ] Add retry mechanism
- [ ] Create error snackbar UI
- [ ] Create global error dialog
- [ ] Implement logging service
- [ ] Add load balancing
- [ ] Implement health check service
- [ ] Create recovery service
- [ ] Test error scenarios
- [ ] Verify crash reporting works
- [ ] Test error recovery flows

## Migration Checklist

- [ ] Set up Firebase Crashlytics
- [ ] Implement global error handlers
- [ ] Create error boundary widgets
- [ ] Add network error handling
- [ ] Implement retry logic
- [ ] Create user-friendly error messages
- [ ] Add logging service
- [ ] Implement load balancing
- [ ] Add health checks
- [ ] Create error recovery strategies
- [ ] Test all error scenarios
- [ ] Monitor crash reports in production
- [ ] Set up alerts for critical errors

## Next Steps

1. All Flutter implementation plans are now complete
2. Begin implementation following the plan order
3. Set up Firebase project for crash reporting
4. Implement error handling early in development
5. Test error scenarios regularly during development

---

## Summary

All 16 markdown files have been created in the `flutter-plans` folder, providing a comprehensive A-Z implementation plan for porting modelman from React/TypeScript to Flutter multi-platform:

1. **00-overview-architecture.md** - High-level architecture and technology mapping
2. **01-project-setup-structure.md** - Project initialization and configuration
3. **02-backend-integration.md** - API client and repository layer
4. **03-state-management.md** - Riverpod state management
5. **04-authentication-oauth.md** - OAuth 2.1 implementation
6. **05-ui-components-core.md** - Core UI components
7. **06-mcp-client-implementation.md** - MCP client logic
8. **07-chat-hybrid-interface.md** - Chat interface with AI
9. **08-themes-styling.md** - 8 theme implementations
10. **09-data-persistence.md** - Storage strategies
11. **10-platform-specific.md** - Platform configurations
12. **11-performance-optimization.md** - Performance strategies
13. **12-testing-strategy.md** - Testing approaches
14. **13-deployment-checklist.md** - Deployment guides
15. **14-postman-like-ui-structure.md** - Postman-inspired UI layout
16. **15-settings-configuration.md** - Settings and configuration system
16. **16-crash-reporting-error-handling.md** - Error handling and crash reporting

The plan ensures a smooth, laggy-free experience with proper load balancing, crash reporting, error handling, and a professional Postman-like UI structure with full user configurability.
