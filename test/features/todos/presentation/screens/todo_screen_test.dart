import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/l10n/app_localizations.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_event.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/bloc/todo_state.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/screens/todo_screen.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_state.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';

class MockTodoBloc extends MockBloc<TodoEvent, TodoState> implements TodoBloc {}

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

void main() {
  final dummyTodo = Todo(
    id: 1,
    title: 'Dummy',
    isCompleted: false,
    createdAt: DateTime.now(),
  );

  setUpAll(() {
    registerFallbackValue(const WatchTodos());
    registerFallbackValue(const TodoInitial());
    registerFallbackValue(const TodoToggled(1));
    registerFallbackValue(const TodoAdded(''));
    registerFallbackValue(TodoDeleted(dummyTodo));
    registerFallbackValue(TodoRestored(dummyTodo));
  });

  late MockTodoBloc mockTodoBloc;
  late MockSettingsBloc mockSettingsBloc;

  setUp(() {
    mockTodoBloc = MockTodoBloc();
    mockSettingsBloc = MockSettingsBloc();
    when(
      () => mockSettingsBloc.state,
    ).thenReturn(SettingsLoadSuccess(UserPreferences.defaults()));
  });

  Widget buildSubject() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoScreen(),
          routes: [
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<TodoBloc>.value(value: mockTodoBloc),
        BlocProvider<SettingsBloc>.value(value: mockSettingsBloc),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }

  group('TodoScreen', () {
    testWidgets('renders SizedBox.shrink when state is TodoInitial', (
      tester,
    ) async {
      when(() => mockTodoBloc.state).thenReturn(const TodoInitial());

      await tester.pumpWidget(buildSubject());

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(Scaffold), findsNothing);
    });

    testWidgets(
      'renders CircularProgressIndicator when state is TodoLoadInProgress',
      (tester) async {
        when(() => mockTodoBloc.state).thenReturn(const TodoLoadInProgress());

        await tester.pumpWidget(buildSubject());

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'renders "No todos yet" when state is TodoLoadSuccess and empty',
      (tester) async {
        when(
          () => mockTodoBloc.state,
        ).thenReturn(const TodoLoadSuccess(todos: []));

        await tester.pumpWidget(buildSubject());

        expect(find.text('No todos yet'), findsOneWidget);
      },
    );

    testWidgets('renders ListView with items when state is TodoLoadSuccess', (
      tester,
    ) async {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      when(() => mockTodoBloc.state).thenReturn(TodoLoadSuccess(todos: [todo]));

      await tester.pumpWidget(buildSubject());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Test Todo'), findsOneWidget);
    });

    testWidgets(
      'renders Error message and Retry button when state is TodoLoadFailure',
      (tester) async {
        when(
          () => mockTodoBloc.state,
        ).thenReturn(const TodoLoadFailure(DatabaseFailure('Test error')));

        await tester.pumpWidget(buildSubject());

        expect(
          find.text(
            'Error: Something went wrong while saving your data. Please try again.',
          ),
          findsOneWidget,
        );
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets('adds WatchTodos event when Retry is tapped', (tester) async {
      when(
        () => mockTodoBloc.state,
      ).thenReturn(const TodoLoadFailure(DatabaseFailure('Test error')));

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockTodoBloc.add(any(that: isA<WatchTodos>()))).called(1);
    });

    testWidgets('adds TodoToggled event when toggle is tapped on a list item', (
      tester,
    ) async {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      when(() => mockTodoBloc.state).thenReturn(TodoLoadSuccess(todos: [todo]));

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      verify(
        () => mockTodoBloc.add(
          any(that: isA<TodoToggled>().having((e) => e.id, 'id', 1)),
        ),
      ).called(1);
    });

    testWidgets('adds TodoDeleted event when delete is tapped on a list item', (
      tester,
    ) async {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      when(() => mockTodoBloc.state).thenReturn(TodoLoadSuccess(todos: [todo]));

      await tester.pumpWidget(buildSubject());

      await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      verify(
        () => mockTodoBloc.add(
          any(that: isA<TodoDeleted>().having((e) => e.todo.id, 'todo.id', 1)),
        ),
      ).called(1);
      expect(find.text('Deleted "Test Todo"'), findsOneWidget);
    });

    testWidgets('adds TodoRestored event when Undo is tapped in SnackBar', (
      tester,
    ) async {
      final todo = Todo(
        id: 1,
        title: 'Test Todo',
        isCompleted: false,
        createdAt: DateTime.now(),
      );
      when(() => mockTodoBloc.state).thenReturn(TodoLoadSuccess(todos: [todo]));

      await tester.pumpWidget(buildSubject());

      await tester.drag(find.byType(Dismissible), const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Undo'));
      await tester.pump();

      verify(
        () => mockTodoBloc.add(
          any(that: isA<TodoRestored>().having((e) => e.todo.id, 'todo.id', 1)),
        ),
      ).called(1);
    });

    testWidgets('shows SnackBar when state changes to TodoLoadFailure', (
      tester,
    ) async {
      whenListen(
        mockTodoBloc,
        Stream.fromIterable([
          const TodoLoadInProgress(),
          const TodoLoadFailure(DatabaseFailure('Async error')),
        ]),
        initialState: const TodoLoadInProgress(),
      );

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Something went wrong while saving your data. Please try again.',
        ),
        findsWidgets,
      );
    });

    testWidgets('adds TodoAdded event when FAB is used', (tester) async {
      when(
        () => mockTodoBloc.state,
      ).thenReturn(const TodoLoadSuccess(todos: []));

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'New Todo');
      await tester.pump();

      final addButton = find.byType(FilledButton);
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      verify(
        () => mockTodoBloc.add(
          any(
            that: isA<TodoAdded>().having((e) => e.title, 'title', 'New Todo'),
          ),
        ),
      ).called(1);
    });

    testWidgets('navigates to SettingsScreen when Settings icon is tapped', (
      tester,
    ) async {
      when(
        () => mockTodoBloc.state,
      ).thenReturn(const TodoLoadSuccess(todos: []));

      await tester.pumpWidget(buildSubject());

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsWidgets);
    });
  });
}
