import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import 'crash_reporter.dart';

/// Log severity levels for structured application logging.
enum LogLevel {
  /// Verbose diagnostic information during development.
  debug(500),

  /// General operational information about normal application flow.
  info(800),

  /// Potentially harmful situations or unexpected conditions that were handled.
  warning(900),

  /// Error events that might still allow the application to continue running.
  error(1000);

  const LogLevel(this.value);

  /// Numeric log severity value for [developer.log].
  final int value;
}

/// Centralized structured logger for the application.
///
/// Wraps [developer.log] to ensure consistent tagging, formatting, and severity
/// filtering across debug and release builds.
class AppLogger {
  AppLogger._();

  /// Logs a debug message with level 500, suppressed in release mode.
  ///
  /// [message] The descriptive log message.
  /// [tag] Optional category or component name (defaults to 'App').
  /// [error] Optional error or exception associated with the log.
  /// [stackTrace] Optional stack trace associated with the log.
  static void debug(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (kReleaseMode) return;
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs an informational message with level 800.
  ///
  /// [message] The operational log message.
  /// [tag] Optional category or component name (defaults to 'App').
  static void info(String message, {String tag = 'App'}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Logs a warning message with level 900.
  ///
  /// [message] The warning description.
  /// [tag] Optional category or component name (defaults to 'App').
  /// [error] Optional error or exception associated with the warning.
  /// [stackTrace] Optional stack trace associated with the warning.
  static void warning(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Logs an error message with level 1000 and optionally records it via [AppCrashReporter].
  ///
  /// [message] The error description.
  /// [tag] Optional category or component name (defaults to 'App').
  /// [error] The error or exception object.
  /// [stackTrace] The stack trace associated with the error.
  /// [recordToCrashReporter] If true, appends error to on-device crash log file (defaults to true).
  static void error(
    String message, {
    String tag = 'App',
    Object? error,
    StackTrace? stackTrace,
    bool recordToCrashReporter = true,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );

    if (recordToCrashReporter && error != null) {
      AppCrashReporter.recordError(
        error,
        stackTrace,
        reason: '[$tag] $message',
        fatal: false,
      );
    }
  }

  static void _log(
    LogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: tag,
      level: level.value,
      error: error,
      stackTrace: stackTrace,
    );
  }
}
