import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/screens/todo_screen.dart';
import 'package:flutter_bloc_boilerplate/l10n/app_localizations.dart';

import 'helpers/fake_todo_repository.dart';
import 'helpers/fake_user_preferences_repository.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    final prefsRepo = FakeUserPreferencesRepository();
    addTearDown(prefsRepo.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<TodoBloc>(
            create: (_) =>
                TodoBloc(FakeTodoRepository())..add(const WatchTodos()),
          ),
          BlocProvider<SettingsBloc>(
            create: (_) =>
                SettingsBloc(prefsRepo)..add(const SettingsWatchStarted()),
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TodoScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
