import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/use_cases/watch_user_preferences_use_case.dart';

class MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

void main() {
  late MockUserPreferencesRepository mockRepository;
  late WatchUserPreferencesUseCase useCase;

  setUp(() {
    mockRepository = MockUserPreferencesRepository();
    useCase = WatchUserPreferencesUseCase(mockRepository);
  });

  group('WatchUserPreferencesUseCase', () {
    test('returns user preferences stream from repository', () {
      final preferences = UserPreferences.defaults();
      when(
        () => mockRepository.watch(),
      ).thenAnswer((_) => Stream.value(preferences));

      expect(useCase(), emitsInOrder([preferences, emitsDone]));
      verify(() => mockRepository.watch()).called(1);
    });

    test('forwards errors emitted by the repository stream', () {
      const failure = DatabaseFailure('stream failure');
      when(
        () => mockRepository.watch(),
      ).thenAnswer((_) => Stream.error(failure));

      expect(useCase(), emitsError(failure));
      verify(() => mockRepository.watch()).called(1);
    });
  });
}
