// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Todos';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notifications => 'Notifications';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String get retry => 'Retry';

  @override
  String get noTodos => 'No todos yet';

  @override
  String get noTodosDescription => 'Add a new task using the button below';

  @override
  String todoDeleted(String title) {
    return 'Deleted \"$title\"';
  }

  @override
  String get receivePushNotifications => 'Receive push notifications';

  @override
  String get newTask => 'New Task';

  @override
  String get title => 'Title';

  @override
  String get titleHint => 'E.g. Buy milk';

  @override
  String get titleEmptyError => 'Title cannot be empty';

  @override
  String get taskDetails => 'Task Details';

  @override
  String get todoNotFound => 'Todo not found';

  @override
  String get todoDeletedNotice => 'Todo was deleted';

  @override
  String get completed => 'Completed';

  @override
  String get created => 'Created';

  @override
  String markAsDone(String title) {
    return 'Mark \"$title\" as done';
  }

  @override
  String markAsNotDone(String title) {
    return 'Mark \"$title\" as not done';
  }
}
