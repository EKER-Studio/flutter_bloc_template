import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/bloc/settings_event.dart';
import 'package:flutter_bloc_boilerplate/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_bloc_boilerplate/l10n/app_localizations.dart';

import '../../../../helpers/fake_user_preferences_repository.dart';

void main() {
  testWidgets('Settings screen renders with preferences', (tester) async {
    final fakeRepo = FakeUserPreferencesRepository();
    addTearDown(fakeRepo.dispose);
    final bloc = SettingsBloc(fakeRepo)..add(const SettingsWatchStarted());

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('System default'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);

    bloc.close();
  });
}
