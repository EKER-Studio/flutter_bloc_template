import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';

import '../../domain/entities/user_preferences.dart';

/// Events that can be dispatched to [SettingsBloc].
sealed class SettingsEvent {
  const SettingsEvent();
}

/// Requests the start of the preferences watch stream.
class SettingsWatchStarted extends SettingsEvent {
  /// Creates a [SettingsWatchStarted] event.
  const SettingsWatchStarted();
}

/// Persists the selected theme mode. The resulting preferences change is
/// propagated back to the state via the repository watch stream.
class SettingsThemeModeUpdated extends SettingsEvent {
  /// Creates a [SettingsThemeModeUpdated] event with the given [mode].
  const SettingsThemeModeUpdated(this.mode);

  /// The theme mode to persist.
  final UserThemeMode mode;
}

/// Persists the notifications toggle and immediately emits the updated
/// preference without relying on the watch stream alone.
class SettingsNotificationsUpdated extends SettingsEvent {
  /// Creates a [SettingsNotificationsUpdated] event with the given [enabled].
  const SettingsNotificationsUpdated(this.enabled);

  /// Whether notifications should be enabled.
  final bool enabled;
}

/// Internal event emitted by the watch stream subscription when the repository
/// reports updated preferences. Not intended to be dispatched from the UI.
class SettingsPreferencesUpdated extends SettingsEvent {
  /// Creates a [SettingsPreferencesUpdated] event with the given [preferences].
  const SettingsPreferencesUpdated(this.preferences);

  /// The complete current user preferences.
  final UserPreferences preferences;
}

/// Internal event emitted by the watch stream subscription when the repository
/// reports an error. Not intended to be dispatched from the UI.
class SettingsWatchFailed extends SettingsEvent {
  /// Creates a [SettingsWatchFailed] event with the given [failure].
  const SettingsWatchFailed(this.failure);

  /// Describes what went wrong.
  final Failure failure;
}
