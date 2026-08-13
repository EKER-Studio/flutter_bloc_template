import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/bloc/app_theme_bloc.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/bloc/app_theme_event.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/bloc/app_theme_state.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';

class _TestThemeRepository implements UserPreferencesRepository {
  _TestThemeRepository(this._themeModeStream);

  final Stream<UserThemeMode> _themeModeStream;

  @override
  Stream<UserPreferences> watch() => const Stream.empty();

  @override
  Stream<UserThemeMode> watchThemeMode() => _themeModeStream;

  @override
  Future<UserPreferences> get() async => UserPreferences.defaults();

  @override
  Future<(bool success, Failure? failure)> updateThemeMode(
    UserThemeMode themeMode,
  ) async => (true, null);

  @override
  Future<(bool success, Failure? failure)> updateNotificationsEnabled(
    bool isEnabled,
  ) async => (true, null);
}

void main() {
  group('AppThemeState', () {
    group('toJson / fromJson round-trip', () {
      test('light mode round-trips correctly', () {
        const original = AppThemeState(UserThemeMode.light);
        final json = original.toJson();
        final restored = AppThemeState.fromJson(json);
        expect(restored.mode, UserThemeMode.light);
      });

      test('dark mode round-trips correctly', () {
        const original = AppThemeState(UserThemeMode.dark);
        final json = original.toJson();
        final restored = AppThemeState.fromJson(json);
        expect(restored.mode, UserThemeMode.dark);
      });

      test('system mode round-trips correctly', () {
        const original = AppThemeState(UserThemeMode.system);
        final json = original.toJson();
        final restored = AppThemeState.fromJson(json);
        expect(restored.mode, UserThemeMode.system);
      });
    });

    group('fromJson malformed data gracefully falls back to system', () {
      test('missing key returns system', () {
        final state = AppThemeState.fromJson({});
        expect(state.mode, UserThemeMode.system);
      });

      test('null value returns system', () {
        final state = AppThemeState.fromJson({'mode': null});
        expect(state.mode, UserThemeMode.system);
      });

      test('string value returns system', () {
        final state = AppThemeState.fromJson({'mode': 'light'});
        expect(state.mode, UserThemeMode.system);
      });

      test('double value returns system', () {
        final state = AppThemeState.fromJson({'mode': 1.5});
        expect(state.mode, UserThemeMode.system);
      });

      test('negative index returns system', () {
        final state = AppThemeState.fromJson({'mode': -1});
        expect(state.mode, UserThemeMode.system);
      });

      test('index equal to enum length returns system', () {
        final state = AppThemeState.fromJson({
          'mode': UserThemeMode.values.length,
        });
        expect(state.mode, UserThemeMode.system);
      });

      test('index far above enum length returns system', () {
        final state = AppThemeState.fromJson({'mode': 999});
        expect(state.mode, UserThemeMode.system);
      });
    });
  });

  group('AppThemeBloc', () {
    late StreamController<UserThemeMode> controller;

    setUp(() {
      controller = StreamController<UserThemeMode>();
      addTearDown(controller.close);
    });

    blocTest<AppThemeBloc, AppThemeState>(
      'initial state is system when no theme stream value is emitted yet',
      build: () => AppThemeBloc(_TestThemeRepository(controller.stream)),
      act: (bloc) async {
        bloc.add(const AppThemeWatchStarted());
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => const [],
      verify: (bloc) {
        expect(bloc.state.mode, UserThemeMode.system);
      },
    );

    blocTest<AppThemeBloc, AppThemeState>(
      'reacts to theme mode updates from the repository stream',
      build: () => AppThemeBloc(_TestThemeRepository(controller.stream)),
      act: (bloc) async {
        bloc.add(const AppThemeWatchStarted());
        await Future<void>.delayed(Duration.zero);
        controller.add(UserThemeMode.dark);
        await Future<void>.delayed(Duration.zero);
        controller.add(UserThemeMode.light);
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<AppThemeState>().having((s) => s.mode, 'mode', UserThemeMode.dark),
        isA<AppThemeState>().having((s) => s.mode, 'mode', UserThemeMode.light),
      ],
    );

    blocTest<AppThemeBloc, AppThemeState>(
      'handles AppThemeModeChanged events dispatched directly',
      build: () => AppThemeBloc(_TestThemeRepository(controller.stream)),
      act: (bloc) async {
        bloc.add(const AppThemeWatchStarted());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const AppThemeModeChanged(UserThemeMode.dark));
        bloc.add(const AppThemeModeChanged(UserThemeMode.light));
        await Future<void>.delayed(Duration.zero);
      },
      expect: () => [
        isA<AppThemeState>().having((s) => s.mode, 'mode', UserThemeMode.dark),
        isA<AppThemeState>().having((s) => s.mode, 'mode', UserThemeMode.light),
      ],
    );

    blocTest<AppThemeBloc, AppThemeState>(
      'cancels the watch subscription on close',
      build: () => AppThemeBloc(_TestThemeRepository(controller.stream)),
      act: (bloc) async {
        bloc.add(const AppThemeWatchStarted());
        await Future<void>.delayed(Duration.zero);
        await bloc.close();
      },
      expect: () => const [],
      verify: (bloc) {
        expect(bloc.state.mode, UserThemeMode.system);
      },
    );
  });
}
