import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/widgets/clamped_layout.dart';

void main() {
  group('ClampedLayout', () {
    testWidgets('constrains child width within specified maxWidth', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClampedLayout(
              maxWidth: 500,
              child: SizedBox(
                key: Key('child'),
                width: double.infinity,
                height: 100,
              ),
            ),
          ),
        ),
      );

      final box = tester.getRect(find.byKey(const Key('child')));
      expect(box.width, 500.0);
    });
  });
}
