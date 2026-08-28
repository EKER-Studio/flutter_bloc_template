import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Reusable error display widget with an optional retry action.
class AppErrorView extends StatelessWidget {
  /// Creates an [AppErrorView].
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
  });

  /// Human-readable error message.
  final String message;

  /// Callback executed when the user taps the retry button.
  final VoidCallback? onRetry;

  /// Label for the retry button. Defaults to localized 'Retry'.
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buttonLabel = retryLabel ?? l10n.retry;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.errorPrefix(message),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: Text(buttonLabel)),
            ],
          ],
        ),
      ),
    );
  }
}
