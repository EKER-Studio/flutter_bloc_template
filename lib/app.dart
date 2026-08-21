import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'core/presentation/bloc/app_theme_bloc.dart';
import 'core/presentation/bloc/app_theme_event.dart';
import 'core/presentation/bloc/app_theme_state.dart';
import 'core/presentation/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/domain/entities/user_preferences.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/todos/presentation/bloc/todo_bloc.dart';
import 'features/todos/presentation/bloc/todo_event.dart';
import 'l10n/app_localizations.dart';

/// Root widget that configures BLoCs, applies theme preferences, and hosts the
/// router configuration.
class App extends StatelessWidget {
  /// Creates an [App].
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TodoBloc>(
          create: (_) => GetIt.instance<TodoBloc>()..add(const WatchTodos()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) =>
              GetIt.instance<SettingsBloc>()..add(const SettingsWatchStarted()),
        ),
        BlocProvider<AppThemeBloc>(
          create: (_) =>
              GetIt.instance<AppThemeBloc>()..add(const AppThemeWatchStarted()),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppThemeBloc, AppThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Flutter BLoC Boilerplate',
          routerConfig: appRouter,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _mapThemeMode(state.mode),
        );
      },
    );
  }
}

ThemeMode _mapThemeMode(UserThemeMode mode) {
  return switch (mode) {
    UserThemeMode.light => ThemeMode.light,
    UserThemeMode.dark => ThemeMode.dark,
    UserThemeMode.system => ThemeMode.system,
  };
}
