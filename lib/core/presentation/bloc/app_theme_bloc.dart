import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/repositories/user_preferences_repository.dart';

import 'app_theme_event.dart';
import 'app_theme_state.dart';

/// BLoC that follows the repository-backed theme mode stream, exposes the
/// runtime theme state used by the material app, and persists theme state via [HydratedBloc].
@lazySingleton
class AppThemeBloc extends HydratedBloc<AppThemeEvent, AppThemeState> {
  /// Creates a bloc backed by the given repository.
  AppThemeBloc(this._repository) : super(const AppThemeState.system()) {
    on<AppThemeWatchStarted>(_onWatchStarted);
    on<AppThemeModeChanged>(_onModeChanged);
  }

  final UserPreferencesRepository _repository;
  StreamSubscription<UserThemeMode>? _themeSubscription;

  void _onWatchStarted(
    AppThemeWatchStarted event,
    Emitter<AppThemeState> emit,
  ) {
    _themeSubscription?.cancel();
    _themeSubscription = _repository.watchThemeMode().listen((mode) {
      add(AppThemeModeChanged(mode));
    });
  }

  void _onModeChanged(AppThemeModeChanged event, Emitter<AppThemeState> emit) {
    emit(AppThemeState(event.mode));
  }

  @override
  AppThemeState? fromJson(Map<String, dynamic> json) =>
      AppThemeState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(AppThemeState state) => state.toJson();

  @override
  Future<void> close() {
    _themeSubscription?.cancel();
    return super.close();
  }
}
