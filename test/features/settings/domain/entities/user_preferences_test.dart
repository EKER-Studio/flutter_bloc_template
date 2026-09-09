import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

void main() {
  group('UserPreferences entity', () {
    test('defaults() creates system theme with notifications enabled', () {
      final defaults = UserPreferences.defaults();

      expect(defaults.themeMode, UserThemeMode.system);
      expect(defaults.isNotificationsEnabled, isTrue);
    });

    test('copyWith updates specified properties while preserving others', () {
      final initial = UserPreferences.defaults();

      final updatedTheme = initial.copyWith(themeMode: UserThemeMode.dark);
      expect(updatedTheme.themeMode, UserThemeMode.dark);
      expect(updatedTheme.isNotificationsEnabled, isTrue);

      final updatedNotifications = initial.copyWith(
        isNotificationsEnabled: false,
      );
      expect(updatedNotifications.themeMode, UserThemeMode.system);
      expect(updatedNotifications.isNotificationsEnabled, isFalse);

      final unchanged = initial.copyWith();
      expect(unchanged, equals(initial));
    });

    test('equality and hashCode verify value identity', () {
      const prefsA = UserPreferences(
        themeMode: UserThemeMode.light,
        isNotificationsEnabled: true,
      );
      const prefsB = UserPreferences(
        themeMode: UserThemeMode.light,
        isNotificationsEnabled: true,
      );
      const prefsC = UserPreferences(
        themeMode: UserThemeMode.dark,
        isNotificationsEnabled: true,
      );
      const prefsD = UserPreferences(
        themeMode: UserThemeMode.light,
        isNotificationsEnabled: false,
      );

      expect(prefsA, equals(prefsB));
      expect(prefsA.hashCode, equals(prefsB.hashCode));

      expect(prefsA, isNot(equals(prefsC)));
      expect(prefsA, isNot(equals(prefsD)));
      expect(prefsA, isNot(equals(Object())));
    });
  });
}
