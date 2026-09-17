import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/widgets/state_message_card.dart';

void main() {
  group('StateMessageCard', () {
    testWidgets(
      'renders icon, title, subtitle and triggers callback on button tap',
      (tester) async {
        var buttonPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StateMessageCard(
                icon: Icons.inbox_outlined,
                iconColor: Colors.blue,
                iconContainerColor: Colors.blue.withAlpha(30),
                title: 'Empty Inbox',
                subtitle: 'You have no new messages',
                buttonLabel: 'Create Message',
                onButtonPressed: () {
                  buttonPressed = true;
                },
              ),
            ),
          ),
        );

        expect(find.text('Empty Inbox'), findsOneWidget);
        expect(find.text('You have no new messages'), findsOneWidget);
        expect(find.text('Create Message'), findsOneWidget);

        await tester.tap(find.text('Create Message'));
        await tester.pumpAndSettle();

        expect(buttonPressed, isTrue);
      },
    );
  });
}
