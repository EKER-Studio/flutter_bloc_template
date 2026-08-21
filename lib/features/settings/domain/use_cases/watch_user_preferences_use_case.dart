import 'package:injectable/injectable.dart';

import '../entities/user_preferences.dart';
import '../repositories/user_preferences_repository.dart';

/// Use case that streams the latest user preferences.
@injectable
class WatchUserPreferencesUseCase {
  /// Creates a [WatchUserPreferencesUseCase] instance.
  const WatchUserPreferencesUseCase(this._repository);

  final UserPreferencesRepository _repository;

  /// Streams user preferences updates.
  Stream<UserPreferences> call() => _repository.watch();
}
