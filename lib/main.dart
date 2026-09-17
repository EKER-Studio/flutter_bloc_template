import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/config/app_environment.dart';
import 'core/di/injection.dart';
import 'core/presentation/screens/app_initialization_error_screen.dart';
import 'core/utils/crash_reporter.dart';

/// Initializes dependency injection, HydratedBloc storage, and launches the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure true edge-to-edge mode and transparent system overlays for modern devices.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  Bloc.observer = const AppBlocObserver();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppCrashReporter.recordError(
      details.exception,
      details.stack,
      reason: 'FlutterError: ${details.context?.toDescription()}',
      fatal: true,
    );
  };

  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppCrashReporter.recordError(
      error,
      stack,
      reason: 'Unhandled asynchronous platform error',
      fatal: true,
    );
    return true;
  };

  try {
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: kIsWeb
          ? HydratedStorageDirectory.web
          : HydratedStorageDirectory(
              (await getApplicationDocumentsDirectory()).path,
            ),
    );

    await configureDependencies(AppConfig.injectableEnv);

    runApp(const App());
  } catch (error, stackTrace) {
    await AppCrashReporter.recordError(
      error,
      stackTrace,
      reason: 'App storage or dependency initialization failed',
      fatal: true,
    );

    runApp(AppInitializationErrorScreen(error: error, onRetry: () => main()));
  }
}
