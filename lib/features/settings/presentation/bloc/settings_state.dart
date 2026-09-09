import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';

/// States emitted by [SettingsBloc].
sealed class SettingsState {
  const SettingsState();
}

/// Initial state before [SettingsBloc] begins watching preferences.
class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Emitted while preferences are being loaded.
class SettingsLoadInProgress extends SettingsState {
  const SettingsLoadInProgress();
}

/// Emitted when preferences were loaded successfully.
class SettingsLoadSuccess extends SettingsState {
  const SettingsLoadSuccess(this.preferences);

  /// The loaded user preferences.
  final UserPreferences preferences;
}

/// Emitted when preferences failed to load or update.
class SettingsLoadFailure extends SettingsState {
  const SettingsLoadFailure(this.failure);

  /// Describes what went wrong.
  final Failure failure;
}
