import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/features/todos/presentation/shared/format.dart';

void main() {
  group('formatTodoDate', () {
    test('formats DateTime as yyyy-MM-dd HH:mm with zero-padding', () {
      final date = DateTime(2026, 3, 5, 9, 4);
      expect(formatTodoDate(date), '2026-03-05 09:04');
    });

    test('formats afternoon/evening DateTime in 24-hour format', () {
      final date = DateTime(2026, 12, 31, 23, 59);
      expect(formatTodoDate(date), '2026-12-31 23:59');
    });

    test('formats midnight correctly', () {
      final date = DateTime(2026, 1, 1, 0, 0);
      expect(formatTodoDate(date), '2026-01-01 00:00');
    });
  });
}
