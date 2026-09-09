import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/use_cases/update_notifications_enabled_use_case.dart';

class MockUserPreferencesRepository extends Mock
    implements UserPreferencesRepository {}

void main() {
  late MockUserPreferencesRepository mockRepository;
  late UpdateNotificationsEnabledUseCase useCase;

  setUp(() {
    mockRepository = MockUserPreferencesRepository();
    useCase = UpdateNotificationsEnabledUseCase(mockRepository);
  });

  group('UpdateNotificationsEnabledUseCase', () {
    test('forwards update call to repository and returns success', () async {
      when(
        () => mockRepository.updateNotificationsEnabled(any()),
      ).thenAnswer((_) async => (true, null));

      final result = await useCase(false);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(() => mockRepository.updateNotificationsEnabled(false)).called(1);
    });

    test(
      'forwards update call to repository and returns failure on error',
      () async {
        const failure = DatabaseFailure('failed to update');
        when(
          () => mockRepository.updateNotificationsEnabled(any()),
        ).thenAnswer((_) async => (false, failure));

        final result = await useCase(true);

        expect(result.$1, isFalse);
        expect(result.$2, failure);
        verify(() => mockRepository.updateNotificationsEnabled(true)).called(1);
      },
    );
  });
}
