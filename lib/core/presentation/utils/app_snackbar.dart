import 'package:flutter/material.dart';

import '../theme/app_feedback_theme.dart';

/// Feedback severity types specifying styling for [AppSnackBar].
enum SnackBarType {
  /// Positive success state.
  success,

  /// Error or exception state.
  error,

  /// Warning state requiring attention.
  warning,

  /// Informational announcement state.
  info,
}

/// Utility for presenting themed floating SnackBar notifications.
class AppSnackBar {
  AppSnackBar._();

  /// Displays a floating SnackBar notification.
  ///
  /// [context] Current build context.
  /// [message] Text string displayed in the notification.
  /// [type] Visual severity styling.
  /// [icon] Optional leading icon override.
  /// [action] Optional interactive action button.
  /// [duration] Notification display lifetime.
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    IconData? icon,
    SnackBarAction? action,
    Duration duration = const Duration(milliseconds: 3000),
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color backgroundColor;
    final Color foregroundColor;
    final IconData defaultIcon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = isDark
            ? AppFeedbackTheme.successBackgroundDark
            : AppFeedbackTheme.successBackgroundLight;
        foregroundColor = isDark
            ? AppFeedbackTheme.successForegroundDark
            : AppFeedbackTheme.successForegroundLight;
        defaultIcon = Icons.check_circle_outline_rounded;
      case SnackBarType.error:
        backgroundColor = isDark
            ? AppFeedbackTheme.errorBackgroundDark
            : AppFeedbackTheme.errorBackgroundLight;
        foregroundColor = isDark
            ? AppFeedbackTheme.errorForegroundDark
            : AppFeedbackTheme.errorForegroundLight;
        defaultIcon = Icons.error_outline_rounded;
      case SnackBarType.warning:
        backgroundColor = isDark
            ? AppFeedbackTheme.warningBackgroundDark
            : AppFeedbackTheme.warningBackgroundLight;
        foregroundColor = isDark
            ? AppFeedbackTheme.warningForegroundDark
            : AppFeedbackTheme.warningForegroundLight;
        defaultIcon = Icons.warning_amber_rounded;
      case SnackBarType.info:
        backgroundColor = isDark
            ? AppFeedbackTheme.infoBackgroundDark
            : AppFeedbackTheme.infoBackgroundLight;
        foregroundColor = isDark
            ? AppFeedbackTheme.infoForegroundDark
            : AppFeedbackTheme.infoForegroundLight;
        defaultIcon = Icons.info_outline_rounded;
    }

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsetsDirectional.only(
          bottom: 16,
          start: 16,
          end: 16,
        ),
        action: action,
        content: Row(
          children: [
            Icon(icon ?? defaultIcon, color: foregroundColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
