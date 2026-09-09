import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/user_preferences.dart';
import '../repositories/user_preferences_repository.dart';

/// Use case that updates the selected application theme mode.
@injectable
class UpdateThemeModeUseCase {
  const UpdateThemeModeUseCase(this._repository);

  final UserPreferencesRepository _repository;

  /// Updates the application theme mode to [themeMode].
  Future<(bool success, Failure? failure)> call(UserThemeMode themeMode) {
    return _repository.updateThemeMode(themeMode);
  }
}
