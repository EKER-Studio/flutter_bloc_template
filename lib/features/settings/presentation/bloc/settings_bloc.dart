import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC managing user preferences state.
@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  /// Creates a bloc backed by the given repository.
  SettingsBloc(this._repository) : super(const SettingsInitial()) {
    on<SettingsWatchStarted>(_onWatchStarted);
    on<SettingsThemeModeUpdated>(_onThemeModeUpdated);
    on<SettingsNotificationsUpdated>(_onNotificationsUpdated);
    on<SettingsPreferencesUpdated>(_onPreferencesUpdated);
    on<SettingsWatchFailed>(_onWatchFailed);
  }

  final UserPreferencesRepository _repository;
  StreamSubscription<UserPreferences>? _prefsSubscription;
  UserPreferences? _lastKnownPreferences;
  UserPreferences? _latestEmitted;

  void _onWatchStarted(
    SettingsWatchStarted event,
    Emitter<SettingsState> emit,
  ) {
    emit(const SettingsLoadInProgress());
    _prefsSubscription?.cancel();
    _prefsSubscription = _repository.watch().listen(
      (prefs) {
        _lastKnownPreferences = prefs;
        if (_latestEmitted != prefs) {
          _latestEmitted = prefs;
          add(SettingsPreferencesUpdated(prefs));
        }
      },
      onError: (Object error) {
        add(SettingsWatchFailed(DatabaseFailure(error.toString())));
      },
    );
  }

  void _onPreferencesUpdated(
    SettingsPreferencesUpdated event,
    Emitter<SettingsState> emit,
  ) {
    emit(SettingsLoadSuccess(event.preferences));
  }

  /// Persists the selected theme mode and relies on the repository stream to
  /// propagate the change to the state. Reverts to the last known preferences
  /// on failure so the UI does not get stuck in an error state.
  Future<void> _onThemeModeUpdated(
    SettingsThemeModeUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    final snapshot = _lastKnownPreferences;
    final result = await _repository.updateThemeMode(event.mode);
    if (result.$1) {
      return;
    } else if (snapshot != null) {
      _latestEmitted = snapshot;
      emit(SettingsLoadSuccess(snapshot));
    } else {
      emit(SettingsLoadFailure(result.$2!));
    }
  }

  /// Persists the notifications toggle and immediately emits the updated
  /// preference, avoiding reliance on the Isar watch stream alone. Reverts to
  /// the last known preferences on failure. Dedupes against [_latestEmitted]
  /// so the repository's own stream re-emission of the same value is not
  /// surfaced twice, regardless of delivery order.
  Future<void> _onNotificationsUpdated(
    SettingsNotificationsUpdated event,
    Emitter<SettingsState> emit,
  ) async {
    final snapshot = _lastKnownPreferences;
    final result = await _repository.updateNotificationsEnabled(event.enabled);
    if (result.$1) {
      final updatedPreferences = (snapshot ?? UserPreferences.defaults())
          .copyWith(isNotificationsEnabled: event.enabled);
      _lastKnownPreferences = updatedPreferences;
      if (_latestEmitted != updatedPreferences) {
        _latestEmitted = updatedPreferences;
        emit(SettingsLoadSuccess(updatedPreferences));
      }
    } else if (result.$2 != null) {
      if (snapshot != null) {
        _latestEmitted = snapshot;
        emit(SettingsLoadSuccess(snapshot));
      } else {
        emit(SettingsLoadFailure(result.$2!));
      }
    }
  }

  void _onWatchFailed(SettingsWatchFailed event, Emitter<SettingsState> emit) {
    if (_lastKnownPreferences != null) {
      emit(SettingsLoadSuccess(_lastKnownPreferences!));
    } else {
      emit(SettingsLoadFailure(event.failure));
    }
  }

  @override
  Future<void> close() {
    _prefsSubscription?.cancel();
    return super.close();
  }
}
