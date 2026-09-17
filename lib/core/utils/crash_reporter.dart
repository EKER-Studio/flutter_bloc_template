import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:path_provider/path_provider.dart';

import 'crash_log.dart';

/// Centralized crash reporting and diagnostic exception logging utility.
///
/// Dispatches errors to structured logs and appends entries to the on-device
/// [crashLogFileName] with size-based rotation.
class AppCrashReporter {
  AppCrashReporter._();

  static const int _maxCrashLogBytes = 1024 * 1024;

  /// Records an error with optional stack trace and context reason.
  ///
  /// [error] The exception or failure object.
  /// [stack] Optional stack trace associated with the error.
  /// [reason] Optional contextual description of where the error occurred.
  /// [fatal] Indicates whether the error caused a terminal crash.
  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    dynamic reason,
    bool fatal = false,
  }) async {
    final effectiveStack = stack ?? StackTrace.current;
    final reasonStr = reason != null ? ' [Reason: $reason]' : '';

    developer.log(
      '${fatal ? "FATAL" : "NON-FATAL"}$reasonStr: $error',
      error: error,
      stackTrace: effectiveStack,
      name: 'AppCrashReporter',
    );

    await writeCrashLog(error, effectiveStack, reason: reason);
  }

  /// Appends an uncaught error to the on-device crash log file.
  ///
  /// [error] The error object to record.
  /// [stack] The stack trace associated with the error.
  /// [reason] Optional diagnostic message.
  static Future<void> writeCrashLog(
    Object error,
    StackTrace stack, {
    dynamic reason,
  }) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$crashLogFileName');
      final reasonStr = reason != null ? ' [Reason: $reason]' : '';
      final entry =
          '${DateTime.now().toIso8601String()}$reasonStr\n$error\n$stack\n\n';

      if (await file.exists() && await file.length() > _maxCrashLogBytes) {
        await _trimCrashLog(file);
      }

      await file.writeAsString(entry, mode: FileMode.append, flush: true);
    } catch (e) {
      if (e is! MissingPluginException && kDebugMode) {
        developer.log(
          'writeCrashLog failed',
          error: e,
          name: 'AppCrashReporter',
        );
      }
    }
  }

  /// Removes the oldest half of [file] to avoid unbounded log growth.
  static Future<void> _trimCrashLog(File file) async {
    try {
      final content = await file.readAsString();
      final tail = content.substring(content.length ~/ 2);
      final firstEntryStart = tail.indexOf('\n\n');
      final kept = firstEntryStart == -1
          ? ''
          : tail.substring(firstEntryStart + 2);
      await file.writeAsString(kept, flush: true);
    } catch (e) {
      if (e is! MissingPluginException && kDebugMode) {
        developer.log(
          '_trimCrashLog failed',
          error: e,
          name: 'AppCrashReporter',
        );
      }
    }
  }
}
