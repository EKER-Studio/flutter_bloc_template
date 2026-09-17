import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/navigation/adaptive_navigation_scaffold.dart';

void main() {
  group('AdaptiveNavigationScaffold', () {
    const destinations = [
      AdaptiveNavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      AdaptiveNavigationDestination(
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    testWidgets('renders bottom NavigationBar on compact portrait phone', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveNavigationScaffold(
            currentIndex: 0,
            destinations: destinations,
            onDestinationSelected: (_) {},
            body: const Text('Home Body'),
          ),
        ),
      );

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Home Body'), findsOneWidget);
    });

    testWidgets('renders side NavigationRail on tablet viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: AdaptiveNavigationScaffold(
            currentIndex: 0,
            destinations: destinations,
            onDestinationSelected: (_) {},
            body: const Text('Tablet Body'),
          ),
        ),
      );

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Tablet Body'), findsOneWidget);
    });
  });
}
