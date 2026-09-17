import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/settings/data/models/user_preferences_model.dart';
import '../../features/todos/data/models/todo_model.dart';
import '../utils/crash_reporter.dart';

/// Database resilience and lifecycle helper providing auto-compaction and corruption recovery.
class DatabaseHelper {
  DatabaseHelper._();

  /// Default Isar database name.
  static const String defaultDbName = 'default';

  /// Initializes and opens the pre-resolved Isar database instance.
  static Future<Isar> initialize() async {
    final directory = await getApplicationDocumentsDirectory();
    final existing = Isar.getInstance(defaultDbName);
    if (existing != null && existing.isOpen) {
      return existing;
    }

    try {
      return await _openDatabase(directory.path);
    } catch (e, stack) {
      await AppCrashReporter.recordError(
        e,
        stack,
        reason:
            '[DatabaseModule] Failed to open Isar database, backing up and retrying',
        fatal: false,
      );

      await backupCorruptedDatabase(directory.path);

      try {
        return await _openDatabase(directory.path);
      } catch (retryError, retryStack) {
        await AppCrashReporter.recordError(
          retryError,
          retryStack,
          reason: '[DatabaseModule] Database recovery opening failed',
          fatal: true,
        );
        rethrow;
      }
    }
  }

  static Future<Isar> _openDatabase(String directoryPath) {
    return Isar.open(
      [TodoModelSchema, UserPreferencesModelSchema],
      directory: directoryPath,
      name: defaultDbName,
      compactOnLaunch: const CompactCondition(
        minFileSize: 10 * 1024 * 1024,
        minRatio: 1.25,
      ),
    );
  }

  /// Verifies database integrity when the app resumes from background execution.
  static Future<({Isar instance, bool reopened})>
  ensureInstanceIntegrity() async {
    final instance = Isar.getInstance(defaultDbName);
    if (instance == null || !instance.isOpen) {
      final directory = await getApplicationDocumentsDirectory();
      final reopenedInstance = await _openDatabase(directory.path);
      return (instance: reopenedInstance, reopened: true);
    }
    return (instance: instance, reopened: false);
  }

  /// Backs up corrupted database files to timestamped backup files before re-creating.
  @visibleForTesting
  static Future<void> backupCorruptedDatabase(String directoryPath) async {
    final dbFile = File('$directoryPath/$defaultDbName.isar');
    final lockFile = File('$directoryPath/$defaultDbName.isar.lock');

    if (await dbFile.exists()) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath =
          '$directoryPath/${defaultDbName}_corrupted_$timestamp.isar.bak';
      await dbFile.copy(backupPath);
      await dbFile.delete();
    }

    if (await lockFile.exists()) {
      await lockFile.delete();
    }
  }
}

/// Registers the pre-resolved [Isar] database singleton.
@module
abstract class DatabaseModule {
  /// Opens (or retrieves) the Isar instance with all registered model schemas.
  @preResolve
  @singleton
  Future<Isar> get isar => DatabaseHelper.initialize();
}
