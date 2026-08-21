import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/user_preferences_repository.dart';

/// Use case that updates the notifications enabled preference.
@injectable
class UpdateNotificationsEnabledUseCase {
  /// Creates an [UpdateNotificationsEnabledUseCase] instance.
  const UpdateNotificationsEnabledUseCase(this._repository);

  final UserPreferencesRepository _repository;

  /// Updates whether notifications are enabled to [isEnabled].
  Future<(bool success, Failure? failure)> call(bool isEnabled) {
    return _repository.updateNotificationsEnabled(isEnabled);
  }
}
