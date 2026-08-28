import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_preferences.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

/// Screen displaying user settings and preferences.
class SettingsScreen extends StatelessWidget {
  /// Creates a [SettingsScreen].
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<SettingsBloc, SettingsState>(
      listenWhen: (previous, current) =>
          current is SettingsLoadFailure && previous is! SettingsLoadFailure,
      listener: (context, state) {
        if (state is SettingsLoadFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.failure.userMessage)));
        }
      },
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return switch (state) {
            SettingsInitial() => const SizedBox.shrink(),
            SettingsLoadInProgress() => Scaffold(
              appBar: AppBar(title: Text(l10n.settings)),
              body: const AppLoadingIndicator(),
            ),
            SettingsLoadSuccess(:final preferences) => _buildSettings(
              context,
              preferences,
            ),
            SettingsLoadFailure(:final failure) => Scaffold(
              appBar: AppBar(title: Text(l10n.settings)),
              body: Center(child: Text('Error: ${failure.userMessage}')),
            ),
          };
        },
      ),
    );
  }

  Scaffold _buildSettings(BuildContext context, UserPreferences preferences) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            title: Text(l10n.theme),
            subtitle: Text(_themeLabel(context, preferences.themeMode)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemePicker(context, preferences.themeMode),
          ),
          SwitchListTile(
            title: Text(l10n.notifications),
            subtitle: Text(l10n.receivePushNotifications),
            value: preferences.isNotificationsEnabled,
            onChanged: (value) {
              context.read<SettingsBloc>().add(
                SettingsNotificationsUpdated(value),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showThemePicker(BuildContext context, UserThemeMode current) {
    final l10n = AppLocalizations.of(context);
    showDialog<UserThemeMode>(
      context: context,
      builder: (dialogContext) => RadioGroup<UserThemeMode>(
        groupValue: current,
        onChanged: (value) {
          if (value != null) {
            context.read<SettingsBloc>().add(SettingsThemeModeUpdated(value));
            Navigator.of(dialogContext).pop();
          }
        },
        child: SimpleDialog(
          title: Text(l10n.theme),
          children: UserThemeMode.values.map((mode) {
            return RadioListTile<UserThemeMode>(
              title: Text(_themeLabel(context, mode)),
              value: mode,
            );
          }).toList(),
        ),
      ),
    );
  }

  String _themeLabel(BuildContext context, UserThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    return switch (mode) {
      UserThemeMode.light => l10n.themeLight,
      UserThemeMode.dark => l10n.themeDark,
      UserThemeMode.system => l10n.themeSystem,
    };
  }
}
