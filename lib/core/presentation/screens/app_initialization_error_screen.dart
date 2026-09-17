import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Fallback error content displayed when app bootstrapping or initialization fails.
class AppInitializationErrorContent extends StatelessWidget {
  /// The error object that occurred during startup.
  final Object error;

  /// Callback invoked when the user taps the retry button.
  final VoidCallback onRetry;

  /// Creates an [AppInitializationErrorContent].
  const AppInitializationErrorContent({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Semantics(
              container: true,
              label: l10n.initErrorSemantics,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Semantics(
                    excludeSemantics: true,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.warning_amber_rounded,
                        size: 48,
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.initErrorTitle,
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.initErrorSubtitle,
                    style: textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retryStartup),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(200, 52),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Standalone MaterialApp root rendered when main application configuration fails.
class AppInitializationErrorScreen extends StatelessWidget {
  /// The startup error details.
  final Object error;

  /// Callback invoked when the user taps the retry button.
  final VoidCallback onRetry;

  /// Creates an [AppInitializationErrorScreen].
  const AppInitializationErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AppInitializationErrorContent(error: error, onRetry: onRetry),
    );
  }
}
