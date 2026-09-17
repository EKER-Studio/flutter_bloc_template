import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../core/presentation/extensions/failure_ui_extension.dart';
import '../../../../core/presentation/widgets/app_error_view.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_preferences.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/components/custom_settings_tile.dart';
import '../widgets/components/custom_settings_toggle.dart';
import '../widgets/components/section_header.dart';
import '../widgets/components/theme_selection_dialog.dart';

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.toUserMessage(l10n))),
          );
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
              body: AppErrorView(
                message: failure.toUserMessage(l10n),
                retryLabel: l10n.retry,
                onRetry: () => context.read<SettingsBloc>().add(
                  const SettingsWatchStarted(),
                ),
              ),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              SectionHeader(label: l10n.appearance),
              CustomSettingsTile(
                icon: Icons.palette_outlined,
                title: l10n.theme,
                valueText: _themeLabel(l10n, preferences.themeMode),
                onTap: () => _showThemePicker(context, preferences.themeMode),
              ),
              const SizedBox(height: 12),
              CustomSettingsToggle(
                icon: Icons.notifications_outlined,
                title: l10n.notifications,
                subtitle: l10n.receivePushNotifications,
                value: preferences.isNotificationsEnabled,
                onChanged: (value) {
                  context.read<SettingsBloc>().add(
                    SettingsNotificationsUpdated(value),
                  );
                },
              ),
              const SizedBox(height: 12),
              SectionHeader(label: l10n.about),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final version = snapshot.data?.version ?? '1.0.0';
                  return CustomSettingsTile(
                    icon: Icons.info_outline,
                    title: l10n.version,
                    valueText: 'v$version',
                    showChevron: false,
                  );
                },
              ),
              CustomSettingsTile(
                icon: Icons.policy_outlined,
                title: l10n.privacyPolicy,
                onTap: () => context.go('/settings/privacy-policy'),
              ),
              CustomSettingsTile(
                icon: Icons.code_rounded,
                title: l10n.licenses,
                onTap: () => context.go('/settings/licenses'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemePicker(BuildContext context, UserThemeMode current) {
    ThemeSelectionDialog.show(
      context,
      currentMode: current,
      onSelected: (mode) {
        context.read<SettingsBloc>().add(SettingsThemeModeUpdated(mode));
      },
    );
  }

  String _themeLabel(AppLocalizations l10n, UserThemeMode mode) {
    return switch (mode) {
      UserThemeMode.light => l10n.themeLight,
      UserThemeMode.dark => l10n.themeDark,
      UserThemeMode.system => l10n.themeSystem,
    };
  }
}
