import 'dart:developer' as dev;

/// Centralized logging utility for the app.
/// Wraps [dev.log] with structured severity levels.
class AppLogger {
  AppLogger._();

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    dev.log(
      message,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
      name: 'galapagos',
    );
  }

  static void warning(String message, [Object? error]) {
    dev.log(message, level: 900, error: error, name: 'galapagos');
  }

  static void info(String message) {
    dev.log(message, level: 800, name: 'galapagos');
  }
}
