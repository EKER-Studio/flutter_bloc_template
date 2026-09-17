import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_bloc_boilerplate/core/presentation/theme/app_theme.dart';
import 'package:flutter_bloc_boilerplate/l10n/app_localizations.dart';

/// Mock hydrated storage used for hermetic screenshot tests.
class MockHydratedStorage extends Mock implements HydratedStorage {}

/// Supported localization languages for screenshot generation.
const List<String> supportedScreenshotLocales = <String>['en', 'pl'];

/// Resolves the device screenshot output directory prefix from `--dart-define`.
String getScreenshotPrefix() {
  const device = String.fromEnvironment(
    'SCREENSHOT_DEVICE',
    defaultValue: 'android/phone',
  );
  return device.isNotEmpty ? '$device/' : '';
}

/// Resolves the effective locales to test against.
List<String> getEffectiveLocales() {
  const localeFilter = String.fromEnvironment(
    'SCREENSHOT_LOCALE',
    defaultValue: '',
  );
  if (localeFilter.isNotEmpty &&
      supportedScreenshotLocales.contains(localeFilter)) {
    return [localeFilter];
  }
  return supportedScreenshotLocales;
}

/// Prepares the test binding and mock storage for headless screenshot execution.
Future<void> initScreenshotEnvironment(
  IntegrationTestWidgetsFlutterBinding binding,
) async {
  await binding.convertFlutterSurfaceToImage();
  final storage = MockHydratedStorage();
  HydratedBloc.storage = storage;
  when(() => storage.read(any())).thenReturn(null);
  when(() => storage.write(any(), any())).thenAnswer((_) async {});
}

/// Wraps a [child] widget in a fully configured [MaterialApp] with [ScreenshotDeviceFrame].
Widget buildScreenshotAppWrapper({
  required Widget child,
  required Locale locale,
  required bool isDark,
  PreferredSizeWidget? appBar,
  bool includeSystemBars = true,
  bool showNotificationIcon = false,
}) {
  final content = Scaffold(
    appBar: appBar,
    body: SafeArea(child: child),
  );

  return MaterialApp(
    debugShowCheckedModeBanner: false,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
    home: includeSystemBars
        ? ScreenshotDeviceFrame(
            isDark: isDark,
            showNotificationIcon: showNotificationIcon,
            child: content,
          )
        : content,
  );
}

/// Device frame that emulates a realistic mobile status bar and bottom gesture navigation pill.
class ScreenshotDeviceFrame extends StatelessWidget {
  /// The underlying page content.
  final Widget child;

  /// Whether the frame is rendered in dark mode.
  final bool isDark;

  /// Whether to display a notification indicator on the status bar.
  final bool showNotificationIcon;

  /// Optional background color override for the status bar overlay.
  final Color? statusBarColor;

  /// Optional background color override for the navigation bar overlay.
  final Color? navigationBarColor;

  /// Creates a [ScreenshotDeviceFrame].
  const ScreenshotDeviceFrame({
    super.key,
    required this.child,
    required this.isDark,
    this.showNotificationIcon = false,
    this.statusBarColor,
    this.navigationBarColor,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = isDark ? Colors.white : const Color(0xFF1E1E1E);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        padding: const EdgeInsets.only(top: 36.0, bottom: 20.0),
        viewPadding: const EdgeInsets.only(top: 36.0, bottom: 20.0),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // App Content
          child,

          // Mock System Status Bar (Overlay)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 36.0,
            child: IgnorePointer(
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  color: statusBarColor ?? Colors.transparent,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left side: Time + Notification icon
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '09:41',
                            style: TextStyle(
                              color: fgColor,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              decoration: TextDecoration.none,
                            ),
                          ),
                          if (showNotificationIcon) ...[
                            const SizedBox(width: 6.0),
                            SizedBox(
                              width: 17.0,
                              height: 17.0,
                              child: Image.asset(
                                'assets/icon/app_icon_foreground.png',
                                width: 17.0,
                                height: 17.0,
                                color: fgColor.withValues(alpha: 0.9),
                                colorBlendMode: BlendMode.srcIn,
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(width: 17.0, height: 17.0),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Right side: Signal, Wi-Fi, Horizontal Battery
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.signal_cellular_alt,
                            color: fgColor,
                            size: 15.0,
                          ),
                          const SizedBox(width: 6.0),
                          Icon(Icons.wifi, color: fgColor, size: 15.0),
                          const SizedBox(width: 8.0),
                          // Horizontal battery icon
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20.0,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: fgColor,
                                    width: 1.2,
                                  ),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                                padding: const EdgeInsets.all(1.5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: fgColor,
                                    borderRadius: BorderRadius.circular(1.0),
                                  ),
                                ),
                              ),
                              Container(
                                width: 1.5,
                                height: 4.0,
                                decoration: BoxDecoration(
                                  color: fgColor.withValues(alpha: 0.8),
                                  borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(1.0),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Mock Bottom Gesture Navigation Bar (Overlay)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 20.0,
            child: IgnorePointer(
              child: Container(
                color: navigationBarColor ?? Colors.transparent,
                alignment: Alignment.center,
                child: Container(
                  width: 134.0,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: fgColor.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
