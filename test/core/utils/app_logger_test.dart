import 'package:flutter_bloc_boilerplate/core/utils/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LogLevel enum', () {
    test('has correct numeric values for developer.log', () {
      expect(LogLevel.debug.value, 500);
      expect(LogLevel.info.value, 800);
      expect(LogLevel.warning.value, 900);
      expect(LogLevel.error.value, 1000);
    });
  });

  group('AppLogger', () {
    test('logs debug message without throwing', () {
      expect(
        () => AppLogger.debug(
          'Debug details',
          tag: 'TestTag',
          error: Exception('debug error'),
        ),
        returnsNormally,
      );
    });

    test('logs info message without throwing', () {
      expect(
        () => AppLogger.info('Operational info', tag: 'TestTag'),
        returnsNormally,
      );
    });

    test('logs warning message without throwing', () {
      expect(
        () => AppLogger.warning(
          'Warning event',
          tag: 'TestTag',
          error: Exception('warning error'),
        ),
        returnsNormally,
      );
    });

    test(
      'logs error message with recordToCrashReporter=false without throwing',
      () {
        expect(
          () => AppLogger.error(
            'Handled error',
            tag: 'TestTag',
            error: Exception('critical error'),
            stackTrace: StackTrace.current,
            recordToCrashReporter: false,
          ),
          returnsNormally,
        );
      },
    );
  });
}
