@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/core/presentation/bloc/app_theme_bloc.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/bloc/app_theme_event.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/theme/app_theme.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/screens/todo_screen.dart';
import 'package:flutter_bloc_boilerplate/l10n/app_localizations.dart';

import '../../../../helpers/fake_todo_repository.dart';
import '../../../../helpers/fake_user_preferences_repository.dart';

void main() {
  testWidgets('TodoScreen Golden Test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final themeRepo = FakeUserPreferencesRepository();
    final todoRepo = FakeTodoRepository();
    final settingsRepo = FakeUserPreferencesRepository();
    addTearDown(themeRepo.dispose);
    addTearDown(todoRepo.dispose);
    addTearDown(settingsRepo.dispose);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AppThemeBloc>(
            create: (_) =>
                AppThemeBloc(themeRepo)..add(const AppThemeWatchStarted()),
          ),
          BlocProvider<TodoBloc>(
            create: (_) =>
                TodoBloc.fromRepository(todoRepo)..add(const WatchTodos()),
          ),
          BlocProvider<SettingsBloc>(
            create: (_) =>
                SettingsBloc.fromRepository(settingsRepo)
                  ..add(const SettingsWatchStarted()),
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: const TodoScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/todo_screen.png'),
    );
  }, skip: !Platform.isMacOS);
}
