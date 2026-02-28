import 'package:flutter_test/flutter_test.dart';
import 'package:galapagos_wildlife/core/services/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('error() does not throw', () {
      expect(
        () => AppLogger.error('test error', Exception('boom'), StackTrace.current),
        returnsNormally,
      );
    });

    test('error() works with message only', () {
      expect(() => AppLogger.error('simple error'), returnsNormally);
    });

    test('warning() does not throw', () {
      expect(
        () => AppLogger.warning('test warning', Exception('oops')),
        returnsNormally,
      );
    });

    test('warning() works with message only', () {
      expect(() => AppLogger.warning('simple warning'), returnsNormally);
    });

    test('info() does not throw', () {
      expect(() => AppLogger.info('test info'), returnsNormally);
    });
  });
}
