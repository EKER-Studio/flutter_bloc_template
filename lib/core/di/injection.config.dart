// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:isar_community/isar.dart' as _i214;

import '../../features/settings/data/repositories/user_preferences_repository_impl.dart'
    as _i969;
import '../../features/settings/domain/repositories/user_preferences_repository.dart'
    as _i1060;
import '../../features/settings/domain/use_cases/update_notifications_enabled_use_case.dart'
    as _i910;
import '../../features/settings/domain/use_cases/update_theme_mode_use_case.dart'
    as _i1057;
import '../../features/settings/domain/use_cases/watch_user_preferences_use_case.dart'
    as _i305;
import '../../features/settings/presentation/bloc/settings_bloc.dart' as _i585;
import '../../features/todos/data/repositories/todo_repository_impl.dart'
    as _i888;
import '../../features/todos/domain/repositories/todo_repository.dart' as _i408;
import '../../features/todos/domain/use_cases/add_todo_use_case.dart' as _i760;
import '../../features/todos/domain/use_cases/delete_todo_use_case.dart'
    as _i312;
import '../../features/todos/domain/use_cases/restore_todo_use_case.dart'
    as _i295;
import '../../features/todos/domain/use_cases/toggle_todo_use_case.dart'
    as _i121;
import '../../features/todos/domain/use_cases/watch_todos_use_case.dart'
    as _i311;
import '../../features/todos/presentation/bloc/todo_bloc.dart' as _i869;
import '../database/database_module.dart' as _i215;
import '../presentation/bloc/app_theme_bloc.dart' as _i464;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final databaseModule = _$DatabaseModule();
    await gh.singletonAsync<_i214.Isar>(
      () => databaseModule.isar,
      preResolve: true,
    );
    gh.lazySingleton<_i1060.UserPreferencesRepository>(
      () => _i969.UserPreferencesRepositoryImpl(gh<_i214.Isar>()),
    );
    gh.lazySingleton<_i408.TodoRepository>(
      () => _i888.TodoRepositoryImpl(gh<_i214.Isar>()),
    );
    gh.lazySingleton<_i464.AppThemeBloc>(
      () => _i464.AppThemeBloc(gh<_i1060.UserPreferencesRepository>()),
    );
    gh.factory<_i910.UpdateNotificationsEnabledUseCase>(
      () => _i910.UpdateNotificationsEnabledUseCase(
        gh<_i1060.UserPreferencesRepository>(),
      ),
    );
    gh.factory<_i1057.UpdateThemeModeUseCase>(
      () =>
          _i1057.UpdateThemeModeUseCase(gh<_i1060.UserPreferencesRepository>()),
    );
    gh.factory<_i305.WatchUserPreferencesUseCase>(
      () => _i305.WatchUserPreferencesUseCase(
        gh<_i1060.UserPreferencesRepository>(),
      ),
    );
    gh.factory<_i760.AddTodoUseCase>(
      () => _i760.AddTodoUseCase(gh<_i408.TodoRepository>()),
    );
    gh.factory<_i312.DeleteTodoUseCase>(
      () => _i312.DeleteTodoUseCase(gh<_i408.TodoRepository>()),
    );
    gh.factory<_i295.RestoreTodoUseCase>(
      () => _i295.RestoreTodoUseCase(gh<_i408.TodoRepository>()),
    );
    gh.factory<_i121.ToggleTodoUseCase>(
      () => _i121.ToggleTodoUseCase(gh<_i408.TodoRepository>()),
    );
    gh.factory<_i311.WatchTodosUseCase>(
      () => _i311.WatchTodosUseCase(gh<_i408.TodoRepository>()),
    );
    gh.factory<_i585.SettingsBloc>(
      () => _i585.SettingsBloc(
        gh<_i305.WatchUserPreferencesUseCase>(),
        gh<_i1057.UpdateThemeModeUseCase>(),
        gh<_i910.UpdateNotificationsEnabledUseCase>(),
      ),
    );
    gh.factory<_i869.TodoBloc>(
      () => _i869.TodoBloc(
        gh<_i311.WatchTodosUseCase>(),
        gh<_i760.AddTodoUseCase>(),
        gh<_i121.ToggleTodoUseCase>(),
        gh<_i312.DeleteTodoUseCase>(),
        gh<_i295.RestoreTodoUseCase>(),
      ),
    );
    return this;
  }
}

class _$DatabaseModule extends _i215.DatabaseModule {}
