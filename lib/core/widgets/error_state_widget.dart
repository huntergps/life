import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

enum ErrorType {
  network,
  timeout,
  parsing,
  authentication,
  notFound,
  serverError,
  unknown,
}

class ErrorStateWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;
  final VoidCallback? onOfflineMode;
  final bool showOfflineOption;
  final String? customMessage;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.stackTrace,
    this.onRetry,
    this.onOfflineMode,
    this.showOfflineOption = false,
    this.customMessage,
  });

  ErrorType _detectErrorType() {
    final errorString = error.toString().toLowerCase();

    if (error is SocketException || errorString.contains('socket') || errorString.contains('network')) {
      return ErrorType.network;
    }
    if (error is TimeoutException || errorString.contains('timeout') || errorString.contains('deadline')) {
      return ErrorType.timeout;
    }
    if (errorString.contains('format') || errorString.contains('parse') || errorString.contains('json')) {
      return ErrorType.parsing;
    }
    if (errorString.contains('auth') || errorString.contains('401') || errorString.contains('403')) {
      return ErrorType.authentication;
    }
    if (errorString.contains('404') || errorString.contains('not found')) {
      return ErrorType.notFound;
    }
    if (errorString.contains('500') || errorString.contains('502') || errorString.contains('503')) {
      return ErrorType.serverError;
    }

    return ErrorType.unknown;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorType = _detectErrorType();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.red.shade900.withValues(alpha: 0.2)
                    : Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getErrorIcon(errorType),
                size: 48,
                color: isDark ? Colors.red.shade400 : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Error title
            Text(
              _getErrorTitle(context, errorType),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Error description
            Text(
              customMessage ?? _getErrorDescription(context, errorType),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Action buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                // Retry button
                if (onRetry != null)
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: Text(context.t.common.retry),
                  ),

                // Offline mode button
                if (showOfflineOption && onOfflineMode != null)
                  OutlinedButton.icon(
                    onPressed: onOfflineMode,
                    icon: const Icon(Icons.cloud_off, size: 20),
                    label: Text(context.t.common.offlineMode),
                  ),
              ],
            ),

            // Technical details (collapsible)
            if (errorType == ErrorType.unknown || errorType == ErrorType.parsing)
              ExpansionTile(
                title: Text(
                  context.t.common.details,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        error.toString(),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: isDark ? Colors.white70 : Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.parsing:
        return Icons.code_off;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.serverError:
        return Icons.cloud_off;
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }

  String _getErrorTitle(BuildContext context, ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return context.t.error.network;
      case ErrorType.timeout:
        return context.t.error.timeout;
      case ErrorType.parsing:
        return context.t.error.parsing;
      case ErrorType.authentication:
        return context.t.error.authentication;
      case ErrorType.notFound:
        return context.t.error.notFound;
      case ErrorType.serverError:
        return context.t.error.serverError;
      case ErrorType.unknown:
        return context.t.common.error;
    }
  }

  String _getErrorDescription(BuildContext context, ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return context.t.error.networkDesc;
      case ErrorType.timeout:
        return context.t.error.timeoutDesc;
      case ErrorType.parsing:
        return context.t.error.parsingDesc;
      case ErrorType.authentication:
        return context.t.error.authenticationDesc;
      case ErrorType.notFound:
        return context.t.error.notFoundDesc;
      case ErrorType.serverError:
        return context.t.error.serverErrorDesc;
      case ErrorType.unknown:
        return context.t.error.unknownDesc;
    }
  }
}
