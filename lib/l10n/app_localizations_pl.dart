// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Zadania';

  @override
  String get settings => 'Ustawienia';

  @override
  String get theme => 'Motyw';

  @override
  String get themeSystem => 'Domyślny systemowy';

  @override
  String get themeLight => 'Jasny';

  @override
  String get themeDark => 'Ciemny';

  @override
  String get notifications => 'Powiadomienia';

  @override
  String get add => 'Dodaj';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get undo => 'Cofnij';

  @override
  String get retry => 'Ponów';

  @override
  String get noTodos => 'Brak zadań';

  @override
  String get noTodosDescription =>
      'Dodaj nowe zadanie za pomocą przycisku poniżej';

  @override
  String todoDeleted(String title) {
    return 'Usunięto \"$title\"';
  }

  @override
  String get receivePushNotifications => 'Otrzymuj powiadomienia push';

  @override
  String get newTask => 'Nowe zadanie';

  @override
  String get title => 'Tytuł';

  @override
  String get titleHint => 'Np. Kupić mleko';

  @override
  String get titleEmptyError => 'Tytuł nie może być pusty';

  @override
  String get taskDetails => 'Szczegóły zadania';

  @override
  String get todoNotFound => 'Nie znaleziono zadania';

  @override
  String get todoDeletedNotice => 'Zadanie zostało usunięte';

  @override
  String get completed => 'Ukończone';

  @override
  String get created => 'Utworzono';

  @override
  String markAsDone(String title) {
    return 'Oznacz \"$title\" jako wykonane';
  }

  @override
  String markAsNotDone(String title) {
    return 'Oznacz \"$title\" jako niewykonane';
  }
}
