import 'package:flutter_bloc/flutter_bloc.dart';

import '../utils/crash_reporter.dart';

/// Global [BlocObserver] intercepting unhandled errors across all BLoCs.
class AppBlocObserver extends BlocObserver {
  /// Creates an [AppBlocObserver].
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    AppCrashReporter.recordError(
      error,
      stackTrace,
      reason: 'Unhandled error in ${bloc.runtimeType}',
      fatal: false,
    );
  }
}
