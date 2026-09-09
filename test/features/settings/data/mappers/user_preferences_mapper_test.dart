import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/features/settings/data/mappers/user_preferences_mapper.dart';
import 'package:flutter_bloc_boilerplate/features/settings/data/models/user_preferences_model.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

void main() {
  group('UserPreferencesMapper', () {
    for (final mode in UserThemeMode.values) {
      for (final notifications in [true, false]) {
        test('round-trips ${mode.name} with notifications=$notifications', () {
          final entity = UserPreferences(
            themeMode: mode,
            isNotificationsEnabled: notifications,
          );

          final model = entity.toModel();
          expect(model.id, userPreferencesSingletonId);
          expect(model.themeMode, mode.name);
          expect(model.isNotificationsEnabled, notifications);

          final reconstructed = model.toEntity();
          expect(reconstructed.themeMode, mode);
          expect(reconstructed.isNotificationsEnabled, notifications);
        });
      }
    }

    test(
      'toEntity() defaults to system theme mode if storage value is invalid',
      () {
        final model = UserPreferencesModel()
          ..themeMode = 'unknown_future_mode'
          ..isNotificationsEnabled = true;

        final entity = model.toEntity();

        expect(entity.themeMode, UserThemeMode.system);
        expect(entity.isNotificationsEnabled, isTrue);
      },
    );

    test('toEntity() defaults to system theme mode on empty string', () {
      final model = UserPreferencesModel()
        ..themeMode = ''
        ..isNotificationsEnabled = false;

      final entity = model.toEntity();

      expect(entity.themeMode, UserThemeMode.system);
      expect(entity.isNotificationsEnabled, isFalse);
    });
  });
}
