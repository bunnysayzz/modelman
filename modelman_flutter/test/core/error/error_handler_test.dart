import 'package:flutter_test/flutter_test.dart';
import 'package:modelman_flutter/core/error/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    late ErrorHandler errorHandler;

    setUp(() {
      errorHandler = ErrorHandler();
    });

    test('should initialize without throwing', () {
      expect(() => errorHandler.initialize(), returnsNormally);
    });

    test('should log info message', () {
      errorHandler.initialize();
      expect(() => errorHandler.info('Test info'), returnsNormally);
    });

    test('should log warning message', () {
      errorHandler.initialize();
      expect(() => errorHandler.warning('Test warning'), returnsNormally);
    });

    test('should log error message', () {
      errorHandler.initialize();
      expect(() => errorHandler.error('Test error'), returnsNormally);
    });

    test('should log debug message in debug mode', () {
      errorHandler.initialize();
      expect(() => errorHandler.debug('Test debug'), returnsNormally);
    });
  });

  group('ConsoleErrorReportingService', () {
    test('should report error without throwing', () {
      final service = ConsoleErrorReportingService();
      expect(
        () => service.reportError('Test error', 'Test stack', fatal: true),
        returnsNormally,
      );
    });
  });
}
