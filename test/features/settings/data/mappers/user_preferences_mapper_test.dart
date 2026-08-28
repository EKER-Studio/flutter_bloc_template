import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/features/settings/data/mappers/user_preferences_mapper.dart';
import 'package:flutter_bloc_boilerplate/features/settings/data/models/user_preferences_model.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

void main() {
  group('UserPreferencesMapper', () {
    test(
      'toEntity() converts UserPreferencesModel to UserPreferences entity correctly',
      () {
        final model = UserPreferencesModel()
          ..themeMode = 'dark'
          ..isNotificationsEnabled = false;

        final entity = model.toEntity();

        expect(entity.themeMode, UserThemeMode.dark);
        expect(entity.isNotificationsEnabled, false);
      },
    );

    test(
      'toEntity() defaults to system theme mode if storage value is invalid',
      () {
        final model = UserPreferencesModel()
          ..themeMode = 'invalid_mode'
          ..isNotificationsEnabled = true;

        final entity = model.toEntity();

        expect(entity.themeMode, UserThemeMode.system);
      },
    );

    test(
      'toModel() converts UserPreferences entity to UserPreferencesModel correctly',
      () {
        const entity = UserPreferences(
          themeMode: UserThemeMode.light,
          isNotificationsEnabled: true,
        );

        final model = entity.toModel();

        expect(model.id, userPreferencesSingletonId);
        expect(model.themeMode, 'light');
        expect(model.isNotificationsEnabled, true);
      },
    );
  });
}
