import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/core/presentation/theme/app_layout_tokens.dart';

void main() {
  group('AppLayoutTokens & ContextLayout', () {
    testWidgets('identifies compact phone viewport', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isTablet;
      late bool isMultiColumn;
      late double padding;
      late double maxWidth;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isTablet = context.isTablet;
              isMultiColumn = context.isMultiColumn;
              padding = context.contentHorizontalPadding;
              maxWidth = context.standardContentMaxWidth;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isTablet, isFalse);
      expect(isMultiColumn, isFalse);
      expect(padding, 16.0);
      expect(maxWidth, AppLayoutTokens.compactContentMaxWidth);
    });

    testWidgets('identifies tablet multi-column viewport', (tester) async {
      tester.view.physicalSize = const Size(1000, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      late bool isTablet;
      late bool isMultiColumn;
      late double padding;
      late double maxWidth;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              isTablet = context.isTablet;
              isMultiColumn = context.isMultiColumn;
              padding = context.contentHorizontalPadding;
              maxWidth = context.standardContentMaxWidth;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(isTablet, isTrue);
      expect(isMultiColumn, isTrue);
      expect(padding, 24.0);
      expect(maxWidth, AppLayoutTokens.expandedContentMaxWidth);
    });
  });
}
