import 'dart:async' as async;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

sealed class AppException implements Exception {
  final String? debugMessage;
  const AppException([this.debugMessage]);
}

class NetworkException extends AppException {
  const NetworkException([super.debugMessage]);
}

class AppTimeoutException extends AppException {
  const AppTimeoutException([super.debugMessage]);
}

class AuthException extends AppException {
  const AuthException([super.debugMessage]);
}

class ValidationException extends AppException {
  const ValidationException([super.debugMessage]);
}

class StorageException extends AppException {
  const StorageException([super.debugMessage]);
}

class UnknownException extends AppException {
  const UnknownException([super.debugMessage]);
}

class ErrorHandler {
  ErrorHandler._();

  static AppException classify(Object error) {
    if (error is SocketException) {
      return NetworkException(error.message);
    }
    if (error is async.TimeoutException) {
      return const AppTimeoutException();
    }
    if (error is supabase.AuthException) {
      return AuthException(error.message);
    }
    if (error is supabase.StorageException) {
      return StorageException(error.message);
    }
    if (error is supabase.PostgrestException) {
      final code = error.code;
      if (code == '42501' || code == 'PGRST301') {
        return AuthException(error.message);
      }
      return UnknownException(error.message);
    }

    final message = error.toString().toLowerCase();
    if (message.contains('socket') ||
        message.contains('connection refused') ||
        message.contains('network is unreachable') ||
        message.contains('no internet') ||
        message.contains('failed host lookup')) {
      return NetworkException(error.toString());
    }
    if (message.contains('timeout') || message.contains('timed out')) {
      return const AppTimeoutException();
    }
    if (message.contains('unauthorized') ||
        message.contains('unauthenticated') ||
        message.contains('jwt expired') ||
        message.contains('invalid token')) {
      return AuthException(error.toString());
    }
    if (message.contains('storage') || message.contains('bucket')) {
      return StorageException(error.toString());
    }

    return UnknownException(error.toString());
  }

  static String _localizedMessage(BuildContext context, AppException exception) {
    final t = context.t.errors;
    return switch (exception) {
      NetworkException() => t.network,
      AppTimeoutException() => t.timeout,
      AuthException() => t.auth,
      ValidationException() => t.validation,
      StorageException() => t.storage,
      UnknownException() => t.unknown,
    };
  }

  static void showError(BuildContext context, Object error) {
    final exception = error is AppException ? error : classify(error);
    final message = _localizedMessage(context, exception);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark
            ? const Color(0xFF3A1A1A)
            : AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isDark
            ? const Color(0xFF1A3A1C)
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
