import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Global error handler for the application.
///
/// Captures unhandled errors, logs them, and optionally reports them
/// to a crash reporting service.
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  bool _initialized = false;
  ErrorReportingService? _reportingService;

  /// Initialize the error handler.
  void initialize({ErrorReportingService? reportingService}) {
    if (_initialized) return;

    _reportingService = reportingService;

    // Flutter framework errors
    FlutterError.onError = (details) {
      _handleFlutterError(details);
    };

    // Dart async errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _handleDartError(error, stack);
      return true;
    };

    _initialized = true;
    _logger.i('Error handler initialized');
  }

  /// Handle Flutter framework errors.
  void _handleFlutterError(FlutterErrorDetails details) {
    _logger.e(
      'Flutter Error',
      error: details.exception,
      stackTrace: details.stack,
    );

    // Report to crash reporting service if available
    _reportingService?.reportError(
      details.exception.toString(),
      details.stack?.toString(),
      fatal: true,
    );
  }

  /// Handle Dart async errors.
  void _handleDartError(Object error, StackTrace stack) {
    _logger.e(
      'Dart Error',
      error: error,
      stackTrace: stack,
    );

    // Report to crash reporting service if available
    _reportingService?.reportError(
      error.toString(),
      stack.toString(),
      fatal: false,
    );
  }

  /// Log an info message.
  void info(String message) {
    _logger.i(message);
  }

  /// Log a warning message.
  void warning(String message) {
    _logger.w(message);
  }

  /// Log an error message.
  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a debug message (only in debug mode).
  void debug(String message) {
    if (kDebugMode) {
      _logger.d(message);
    }
  }
}

/// Interface for error reporting services (e.g., Sentry, Crashlytics).
abstract class ErrorReportingService {
  /// Report an error to the service.
  void reportError(String error, String? stackTrace, {bool fatal = false});
}

/// Console-only error reporting service for development.
class ConsoleErrorReportingService implements ErrorReportingService {
  @override
  void reportError(String error, String? stackTrace, {bool fatal = false}) {
    debugPrint('Error reported: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
    if (fatal) {
      debugPrint('Fatal error!');
    }
  }
}
