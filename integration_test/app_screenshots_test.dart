@Tags(['screenshot'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/screens/todo_screen.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/fake_todo_repository.dart';
import '../test/helpers/fake_user_preferences_repository.dart';
import 'helpers/screenshot_test_helper.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await initScreenshotEnvironment(binding);
  });

  group('App Screenshots', () {
    final prefix = getScreenshotPrefix();
    final locales = getEffectiveLocales();

    for (final localeStr in locales) {
      final locale = Locale(localeStr);

      testWidgets('Capture Todo and Settings screens ($localeStr)', (
        tester,
      ) async {
        final todoRepo = FakeTodoRepository(
          initialTodos: [
            Todo(
              id: 1,
              title: localeStr == 'pl'
                  ? 'Kupić świeże pieczywo'
                  : 'Buy fresh bread',
              isCompleted: false,
              createdAt: DateTime.now().subtract(const Duration(hours: 2)),
            ),
            Todo(
              id: 2,
              title: localeStr == 'pl'
                  ? 'Napisać testy integracyjne'
                  : 'Write integration tests',
              isCompleted: true,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
            Todo(
              id: 3,
              title: localeStr == 'pl'
                  ? 'Przejrzeć architekturę BLoC'
                  : 'Review BLoC architecture',
              isCompleted: false,
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
            ),
          ],
        );

        final prefsRepo = FakeUserPreferencesRepository(
          initialPreferences: const UserPreferences(
            themeMode: UserThemeMode.system,
            isNotificationsEnabled: true,
          ),
        );

        final todoBloc = TodoBloc.fromRepository(todoRepo)
          ..add(const WatchTodos());
        final settingsBloc = SettingsBloc.fromRepository(prefsRepo)
          ..add(const SettingsWatchStarted());

        try {
          // 1. Todo Screen (Light)
          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<TodoBloc>.value(value: todoBloc),
                BlocProvider<SettingsBloc>.value(value: settingsBloc),
              ],
              child: buildScreenshotAppWrapper(
                locale: locale,
                isDark: false,
                child: const TodoScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await binding.takeScreenshot('${prefix}01_todos_light_$localeStr');

          // 2. Settings Screen (Dark)
          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<TodoBloc>.value(value: todoBloc),
                BlocProvider<SettingsBloc>.value(value: settingsBloc),
              ],
              child: buildScreenshotAppWrapper(
                locale: locale,
                isDark: true,
                child: const SettingsScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          await binding.takeScreenshot('${prefix}02_settings_dark_$localeStr');
        } finally {
          await todoBloc.close();
          await settingsBloc.close();
          todoRepo.dispose();
          prefsRepo.dispose();
        }
      });
    }
  });
}
