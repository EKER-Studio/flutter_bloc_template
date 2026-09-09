import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

/// Events that can be dispatched to [AppThemeBloc].
sealed class AppThemeEvent {
  const AppThemeEvent();
}

/// Requests the start of the theme mode watch stream.
class AppThemeWatchStarted extends AppThemeEvent {
  const AppThemeWatchStarted();
}

/// Internal event emitted by the watch stream subscription when the repository
/// reports an updated theme mode. Not intended to be dispatched from the UI.
class AppThemeModeChanged extends AppThemeEvent {
  const AppThemeModeChanged(this.mode);

  /// The newly reported theme mode.
  final UserThemeMode mode;
}
