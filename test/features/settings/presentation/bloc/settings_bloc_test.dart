import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_state.dart';

import '../../../../helpers/fake_user_preferences_repository.dart';

/// A repository that fails on the first attempt of [updateThemeMode] with the
/// given [failure], then succeeds on subsequent calls.
class _FailingOnceThemeRepository implements UserPreferencesRepository {
  _FailingOnceThemeRepository(this._inner, this._failure);

  final FakeUserPreferencesRepository _inner;
  final Failure _failure;
  var _callCount = 0;

  @override
  Stream<UserPreferences> watch() => _inner.watch();

  @override
  Stream<UserThemeMode> watchThemeMode() => _inner.watchThemeMode();

  @override
  Future<UserPreferences> get() => _inner.get();

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode mode,
  ) async {
    _callCount++;
    if (_callCount == 1) return (false, _failure);
    return _inner.updateThemeMode(mode);
  }

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async {
    return _inner.updateNotificationsEnabled(isEnabled);
  }
}

/// A repository whose watch stream emits an error on the first data event.
class _ErrorStreamRepository implements UserPreferencesRepository {
  @override
  Stream<UserPreferences> watch() async* {
    throw const DatabaseFailure('stream error');
  }

  @override
  Stream<UserThemeMode> watchThemeMode() async* {
    throw const DatabaseFailure('stream error');
  }

  @override
  Future<UserPreferences> get() async => UserPreferences.defaults();

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode mode,
  ) async {
    return (true, null);
  }

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async {
    return (true, null);
  }
}

/// A repository that never emits a watch snapshot before a write succeeds.
class _SilentRepository implements UserPreferencesRepository {
  @override
  Stream<UserPreferences> watch() => const Stream.empty();

  @override
  Stream<UserThemeMode> watchThemeMode() => const Stream.empty();

  @override
  Future<UserPreferences> get() async => UserPreferences.defaults();

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode mode,
  ) async {
    return (true, null);
  }

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async {
    return (true, null);
  }
}

void main() {
  late FakeUserPreferencesRepository repository;

  setUp(() {
    repository = FakeUserPreferencesRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  /// Pumps the event loop until [bloc] reaches a state satisfying [predicate],
  /// guaranteeing the initial watch snapshot is loaded before an update event
  /// is dispatched (the watch-stream delivery is asynchronous relative to
  /// [SettingsWatchStarted]).
  Future<void> waitForState(
    SettingsBloc bloc,
    bool Function(SettingsState state) predicate,
  ) async {
    while (!predicate(bloc.state)) {
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }

  group('SettingsBloc', () {
    blocTest<SettingsBloc, SettingsState>(
      'watch started emits LoadInProgress then LoadSuccess with defaults',
      build: () => SettingsBloc.fromRepository(repository),
      act: (bloc) => bloc.add(const SettingsWatchStarted()),
      expect: () => [isA<SettingsLoadInProgress>(), isA<SettingsLoadSuccess>()],
    );

    blocTest<SettingsBloc, SettingsState>(
      'SettingsThemeModeUpdated: watch stream emits updated theme',
      build: () => SettingsBloc.fromRepository(repository),
      act: (bloc) async {
        bloc.add(const SettingsWatchStarted());
        await waitForState(bloc, (s) => s is SettingsLoadSuccess);
        bloc.add(const SettingsThemeModeUpdated(UserThemeMode.dark));
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SettingsLoadInProgress>(),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.themeMode,
          'themeMode',
          UserThemeMode.system,
        ),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.themeMode,
          'themeMode',
          UserThemeMode.dark,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'SettingsNotificationsUpdated: emits updated preference immediately',
      build: () => SettingsBloc.fromRepository(repository),
      act: (bloc) async {
        bloc.add(const SettingsWatchStarted());
        await waitForState(bloc, (s) => s is SettingsLoadSuccess);
        bloc.add(const SettingsNotificationsUpdated(false));
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SettingsLoadInProgress>(),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.isNotificationsEnabled,
          'isNotificationsEnabled',
          true,
        ),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.isNotificationsEnabled,
          'isNotificationsEnabled',
          false,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'SettingsNotificationsUpdated: emits success without prior watch snapshot',
      build: () => SettingsBloc.fromRepository(_SilentRepository()),
      act: (bloc) async {
        bloc.add(const SettingsWatchStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const SettingsNotificationsUpdated(false));
      },
      expect: () => [
        isA<SettingsLoadInProgress>(),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.isNotificationsEnabled,
          'isNotificationsEnabled',
          false,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'SettingsThemeModeUpdated rolls back to last known preferences on failure',
      build: () {
        final failingRepo = _FailingOnceThemeRepository(
          repository,
          const DatabaseFailure('write error'),
        );
        return SettingsBloc.fromRepository(failingRepo);
      },
      act: (bloc) async {
        bloc.add(const SettingsWatchStarted());
        // Let the watch stream microtask populate _lastKnownPreferences.
        await waitForState(bloc, (s) => s is SettingsLoadSuccess);
        bloc.add(const SettingsThemeModeUpdated(UserThemeMode.dark));
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<SettingsLoadInProgress>(),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.themeMode,
          'themeMode',
          UserThemeMode.system,
        ),
        isA<SettingsLoadSuccess>().having(
          (s) => s.preferences.themeMode,
          'themeMode',
          UserThemeMode.system,
        ),
      ],
    );

    blocTest<SettingsBloc, SettingsState>(
      'watch stream error without snapshot emits SettingsLoadFailure',
      build: () => SettingsBloc.fromRepository(_ErrorStreamRepository()),
      act: (bloc) => bloc.add(const SettingsWatchStarted()),
      expect: () => [isA<SettingsLoadInProgress>(), isA<SettingsLoadFailure>()],
    );

    blocTest<SettingsBloc, SettingsState>(
      'close() cancels subscription and does not emit after',
      build: () => SettingsBloc.fromRepository(repository),
      act: (bloc) async {
        bloc.add(const SettingsWatchStarted());
        // Let the watch stream microtask emit the initial load.
        await Future<void>.delayed(Duration.zero);
        await bloc.close();
      },
      expect: () => [isA<SettingsLoadInProgress>(), isA<SettingsLoadSuccess>()],
    );
  });
}
