import 'package:flutter_test/flutter_test.dart';

/// Tests for the network-error detection logic mirrored from
/// [TrailEditService._isNetworkError].
///
/// Because `_isNetworkError` is a private static method, we replicate the
/// exact same logic here and verify each branch. Any change to the real
/// implementation should also update these tests.
///
/// The function under test (from trail_edit_service.dart):
///
/// ```dart
/// static bool _isNetworkError(Object e) {
///   final msg = e.toString().toLowerCase();
///   return msg.contains('socketexception') ||
///       msg.contains('failed host lookup') ||
///       msg.contains('network is unreachable') ||
///       msg.contains('no address associated with hostname') ||
///       msg.contains('clientexception') ||
///       msg.contains('network request failed') ||
///       msg.contains('connection refused') ||
///       msg.contains('connection timed out');
/// }
/// ```

bool _isNetworkError(Object e) {
  final msg = e.toString().toLowerCase();
  return msg.contains('socketexception') ||
      msg.contains('failed host lookup') ||
      msg.contains('network is unreachable') ||
      msg.contains('no address associated with hostname') ||
      msg.contains('clientexception') ||
      msg.contains('network request failed') ||
      msg.contains('connection refused') ||
      msg.contains('connection timed out');
}

void main() {
  group('TrailEditService._isNetworkError (logic mirror)', () {
    // -----------------------------------------------------------------------
    // Cases that SHOULD be recognised as network errors
    // -----------------------------------------------------------------------
    test('detects SocketException', () {
      expect(_isNetworkError(Exception('SocketException: connection refused')),
          isTrue);
    });

    test('detects socketexception (case-insensitive)', () {
      expect(_isNetworkError(Exception('SOCKETEXCEPTION')), isTrue);
    });

    test('detects failed host lookup', () {
      expect(_isNetworkError(Exception('Failed host lookup: example.com')),
          isTrue);
    });

    test('detects network is unreachable', () {
      expect(_isNetworkError(Exception('Network is unreachable')), isTrue);
    });

    test('detects no address associated with hostname', () {
      expect(
        _isNetworkError(
            Exception('No address associated with hostname: api.supabase.co')),
        isTrue,
      );
    });

    test('detects ClientException', () {
      expect(_isNetworkError(Exception('ClientException: read failed')),
          isTrue);
    });

    test('detects network request failed', () {
      expect(_isNetworkError(Exception('network request failed')), isTrue);
    });

    test('detects connection refused', () {
      expect(_isNetworkError(Exception('Connection refused')), isTrue);
    });

    test('detects connection timed out', () {
      expect(_isNetworkError(Exception('Connection timed out')), isTrue);
    });

    test('detection is case-insensitive for mixed case', () {
      expect(_isNetworkError(Exception('CONNECTION TIMED OUT')), isTrue);
      expect(_isNetworkError(Exception('Connection Refused')), isTrue);
    });

    // -----------------------------------------------------------------------
    // Cases that should NOT be recognised as network errors
    // -----------------------------------------------------------------------
    test('regular exception is not a network error', () {
      expect(_isNetworkError(Exception('NullPointerException')), isFalse);
    });

    test('empty exception is not a network error', () {
      expect(_isNetworkError(Exception('')), isFalse);
    });

    test('database error is not a network error', () {
      expect(_isNetworkError(Exception('SQLite constraint violation')), isFalse);
    });

    test('auth error is not a network error', () {
      expect(
          _isNetworkError(Exception('invalid login credentials')), isFalse);
    });

    test('generic string object is not a network error', () {
      expect(_isNetworkError('something went wrong'), isFalse);
    });

    test('null string representation is not a network error', () {
      expect(_isNetworkError(Exception('null')), isFalse);
    });

    // -----------------------------------------------------------------------
    // Edge cases
    // -----------------------------------------------------------------------
    test('partial match at start of message', () {
      expect(
          _isNetworkError(Exception('socketexception: no route to host')),
          isTrue);
    });

    test('partial match embedded in longer message', () {
      expect(
        _isNetworkError(Exception(
            'Error during HTTP request: connection refused by peer')),
        isTrue,
      );
    });
  });
}
