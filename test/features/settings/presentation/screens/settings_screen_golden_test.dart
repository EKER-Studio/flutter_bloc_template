@Tags(['golden'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/core/presentation/theme/app_theme.dart';
import 'package:flutter_bloc_boilerplate/features/settings/domain/entities/user_preferences.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_bloc_boilerplate/l10n/app_localizations.dart';

import '../../../../helpers/fake_user_preferences_repository.dart';

void main() {
  testWidgets('Settings screen golden test', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;

    final fakeRepo = FakeUserPreferencesRepository(
      initialPreferences: const UserPreferences(
        themeMode: UserThemeMode.system,
        isNotificationsEnabled: true,
      ),
    );
    addTearDown(fakeRepo.dispose);
    final bloc = SettingsBloc.fromRepository(fakeRepo)
      ..add(const SettingsWatchStarted());

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.lightTheme,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings_screen.png'),
    );

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();

    bloc.close();
  }, skip: !Platform.isMacOS);
}
