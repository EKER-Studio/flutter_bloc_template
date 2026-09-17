import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/screens/app_initialization_error_screen.dart';
import 'package:flutter_bloc_boilerplate/l10n/app_localizations.dart';

void main() {
  group('AppInitializationErrorContent', () {
    testWidgets('renders error title and invokes onRetry when button tapped', (
      tester,
    ) async {
      var retryTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppInitializationErrorContent(
            error: Exception('Failed to open database'),
            onRetry: () {
              retryTapped = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Initialization Error'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Retry Startup'), findsOneWidget);

      await tester.tap(find.text('Retry Startup'));
      await tester.pumpAndSettle();

      expect(retryTapped, isTrue);
    });

    testWidgets('renders in Polish locale properly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('pl'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppInitializationErrorContent(
            error: Exception('Błąd bazy'),
            onRetry: () {},
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Błąd inicjalizacji'), findsOneWidget);
      expect(find.text('Ponów uruchamianie'), findsOneWidget);
    });
  });
}
