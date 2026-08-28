import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/widgets/add_todo_fab.dart';
import 'package:flutter_bloc_boilerplate/l10n/app_localizations.dart';

void main() {
  testWidgets('AddTodoFab shows dialog and calls onAdd on submit', (
    tester,
  ) async {
    String? addedTitle;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AddTodoFab(
            onAdd: (title) async {
              addedTitle = title;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Buy milk');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(addedTitle, 'Buy milk');
    expect(find.text('New Task'), findsNothing);
  });

  testWidgets('AddTodoFab validation fails for empty title', (tester) async {
    bool onAddCalled = false;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AddTodoFab(
            onAdd: (title) async {
              onAddCalled = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Title cannot be empty'), findsOneWidget);
    expect(onAddCalled, isFalse);

    await tester.enterText(find.byType(TextFormField), '   ');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(find.text('Title cannot be empty'), findsOneWidget);
    expect(onAddCalled, isFalse);
  });

  testWidgets('AddTodoFab dialog closes on cancel', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AddTodoFab(onAdd: (title) async {})),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('New Task'), findsNothing);
  });
}
