import 'package:flutter/material.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../domain/entities/user_preferences.dart';

/// A dialog for choosing the app theme mode (system, light, dark).
class ThemeSelectionDialog extends StatelessWidget {
  /// The currently active theme mode.
  final UserThemeMode currentMode;

  /// Callback invoked when a theme mode is selected.
  final ValueChanged<UserThemeMode> onSelected;

  /// Creates a [ThemeSelectionDialog].
  const ThemeSelectionDialog({
    super.key,
    required this.currentMode,
    required this.onSelected,
  });

  /// Shows the dialog and calls [onSelected] when a mode is picked.
  static Future<void> show(
    BuildContext context, {
    required UserThemeMode currentMode,
    required ValueChanged<UserThemeMode> onSelected,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => ThemeSelectionDialog(
        currentMode: currentMode,
        onSelected: (mode) {
          onSelected(mode);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SimpleDialog(
      title: Text(l10n.theme),
      children: [
        RadioGroup<UserThemeMode>(
          groupValue: currentMode,
          onChanged: (value) {
            if (value != null) {
              onSelected(value);
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in UserThemeMode.values)
                RadioListTile<UserThemeMode>(
                  title: Text(_themeLabel(l10n, mode)),
                  value: mode,
                ),
            ],
          ),
        ),
      ],
    );
  }

  static String _themeLabel(AppLocalizations l10n, UserThemeMode mode) {
    return switch (mode) {
      UserThemeMode.light => l10n.themeLight,
      UserThemeMode.dark => l10n.themeDark,
      UserThemeMode.system => l10n.themeSystem,
    };
  }
}
