import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/settings/data/models/user_preferences_model.dart';
import 'package:flutter_bloc_boilerplate/features/settings/data/repositories/user_preferences_repository_impl.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

class MockIsar extends Mock implements Isar {}

class MockUserPreferencesCollection extends Mock
    implements IsarCollection<UserPreferencesModel> {}

void main() {
  late MockIsar mockIsar;
  late MockUserPreferencesCollection mockCollection;
  late UserPreferencesRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(UserPreferencesModel());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockCollection = MockUserPreferencesCollection();

    when(
      () => mockIsar.collection<UserPreferencesModel>(),
    ).thenReturn(mockCollection);

    when(() => mockIsar.writeTxn<void>(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[0] as Function;
      await callback();
    });
    when(() => mockIsar.writeTxn<dynamic>(any())).thenAnswer((
      invocation,
    ) async {
      final callback = invocation.positionalArguments[0] as Function;
      return await callback();
    });

    repository = UserPreferencesRepositoryImpl(mockIsar);
  });

  group('UserPreferencesRepositoryImpl.get', () {
    test('returns mapped entity when model exists in database', () async {
      final model = UserPreferencesModel()
        ..themeMode = 'dark'
        ..isNotificationsEnabled = false;

      when(
        () => mockCollection.get(userPreferencesSingletonId),
      ).thenAnswer((_) async => model);

      final result = await repository.get();

      expect(result.themeMode, UserThemeMode.dark);
      expect(result.isNotificationsEnabled, isFalse);
    });

    test('returns default entity when no model exists in database', () async {
      when(
        () => mockCollection.get(userPreferencesSingletonId),
      ).thenAnswer((_) async => null);

      final result = await repository.get();

      expect(result, equals(UserPreferences.defaults()));
    });

    test('throws DatabaseFailure when database query fails', () async {
      when(
        () => mockCollection.get(userPreferencesSingletonId),
      ).thenThrow(Exception('read error'));

      expect(() => repository.get(), throwsA(isA<DatabaseFailure>()));
    });
  });

  group('UserPreferencesRepositoryImpl.updateThemeMode', () {
    test('persists updated theme and returns success', () async {
      final existing = UserPreferencesModel()
        ..themeMode = 'system'
        ..isNotificationsEnabled = true;

      when(
        () => mockCollection.get(userPreferencesSingletonId),
      ).thenAnswer((_) async => existing);
      when(() => mockCollection.put(any())).thenAnswer((_) async => 0);

      final result = await repository.updateThemeMode(UserThemeMode.dark);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(
        () => mockCollection.put(
          any(
            that: isA<UserPreferencesModel>().having(
              (m) => m.themeMode,
              'themeMode',
              'dark',
            ),
          ),
        ),
      ).called(1);
    });

    test('returns failure when IsarError is thrown', () async {
      when(
        () => mockCollection.get(userPreferencesSingletonId),
      ).thenAnswer((_) async => null);
      when(
        () => mockCollection.put(any()),
      ).thenThrow(IsarError('disk failure'));

      final result = await repository.updateThemeMode(UserThemeMode.light);

      expect(result.$1, isFalse);
      expect(result.$2, isA<DatabaseFailure>());
      expect(result.$2!.message, 'disk failure');
    });

    test('returns failure on unexpected error', () async {
      when(
        () => mockCollection.get(userPreferencesSingletonId),
      ).thenThrow(Exception('corrupt'));

      final result = await repository.updateThemeMode(UserThemeMode.light);

      expect(result.$1, isFalse);
      expect(result.$2, isA<DatabaseFailure>());
      expect(result.$2!.message, contains('corrupt'));
    });
  });

  group('UserPreferencesRepositoryImpl.updateNotificationsEnabled', () {
    test(
      'persists updated notifications setting and returns success',
      () async {
        final existing = UserPreferencesModel()
          ..themeMode = 'system'
          ..isNotificationsEnabled = true;

        when(
          () => mockCollection.get(userPreferencesSingletonId),
        ).thenAnswer((_) async => existing);
        when(() => mockCollection.put(any())).thenAnswer((_) async => 0);

        final result = await repository.updateNotificationsEnabled(false);

        expect(result.$1, isTrue);
        expect(result.$2, isNull);
        verify(
          () => mockCollection.put(
            any(
              that: isA<UserPreferencesModel>().having(
                (m) => m.isNotificationsEnabled,
                'isNotificationsEnabled',
                false,
              ),
            ),
          ),
        ).called(1);
      },
    );

    test('returns failure when IsarError is thrown', () async {
      when(
        () => mockCollection.get(userPreferencesSingletonId),
      ).thenThrow(IsarError('transaction aborted'));

      final result = await repository.updateNotificationsEnabled(true);

      expect(result.$1, isFalse);
      expect(result.$2, isA<DatabaseFailure>());
      expect(result.$2!.message, 'transaction aborted');
    });
  });

  group('UserPreferencesRepositoryImpl.watch', () {
    test('streams mapped user preferences', () async {
      final model = UserPreferencesModel()
        ..themeMode = 'dark'
        ..isNotificationsEnabled = true;

      when(
        () => mockCollection.watchObject(
          userPreferencesSingletonId,
          fireImmediately: true,
        ),
      ).thenAnswer((_) => Stream.value(model));

      final stream = repository.watch();
      final emitted = await stream.first;

      expect(emitted.themeMode, UserThemeMode.dark);
      expect(emitted.isNotificationsEnabled, isTrue);
    });
  });

  group('UserPreferencesRepositoryImpl.watchThemeMode', () {
    test('streams mapped theme mode', () async {
      final model = UserPreferencesModel()
        ..themeMode = 'light'
        ..isNotificationsEnabled = true;

      when(
        () => mockCollection.watchObject(
          userPreferencesSingletonId,
          fireImmediately: true,
        ),
      ).thenAnswer((_) => Stream.value(model));

      final stream = repository.watchThemeMode();
      final emitted = await stream.first;

      expect(emitted, UserThemeMode.light);
    });
  });
}
