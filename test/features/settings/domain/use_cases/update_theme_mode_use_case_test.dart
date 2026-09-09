import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/use_cases/update_theme_mode_use_case.dart';

class MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

void main() {
  late MockUserPreferencesRepository mockRepository;
  late UpdateThemeModeUseCase useCase;

  setUpAll(() {
    registerFallbackValue(UserThemeMode.system);
  });

  setUp(() {
    mockRepository = MockUserPreferencesRepository();
    useCase = UpdateThemeModeUseCase(mockRepository);
  });

  group('UpdateThemeModeUseCase', () {
    test('forwards update call to repository and returns success', () async {
      when(
        () => mockRepository.updateThemeMode(any()),
      ).thenAnswer((_) async => (true, null));

      final result = await useCase(UserThemeMode.dark);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(
        () => mockRepository.updateThemeMode(UserThemeMode.dark),
      ).called(1);
    });

    test(
      'forwards update call to repository and returns failure on error',
      () async {
        const failure = DatabaseFailure('failed to update theme');
        when(
          () => mockRepository.updateThemeMode(any()),
        ).thenAnswer((_) async => (false, failure));

        final result = await useCase(UserThemeMode.light);

        expect(result.$1, isFalse);
        expect(result.$2, failure);
        verify(
          () => mockRepository.updateThemeMode(UserThemeMode.light),
        ).called(1);
      },
    );
  });
}
