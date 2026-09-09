import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';

void main() {
  group('Todo entity', () {
    final tDate = DateTime(2026, 1, 1, 10, 0);

    test('copyWith updates specified fields and preserves existing values', () {
      final todo = Todo(
        id: 1,
        title: 'Original Title',
        isCompleted: false,
        createdAt: tDate,
      );

      final updatedTitle = todo.copyWith(title: 'New Title');
      expect(updatedTitle.title, 'New Title');
      expect(updatedTitle.id, 1);
      expect(updatedTitle.isCompleted, isFalse);
      expect(updatedTitle.createdAt, tDate);

      final updatedCompleted = todo.copyWith(isCompleted: true);
      expect(updatedCompleted.isCompleted, isTrue);
      expect(updatedCompleted.title, 'Original Title');

      final updatedId = todo.copyWith(id: 2);
      expect(updatedId.id, 2);

      final newDate = DateTime(2026, 1, 2);
      final updatedDate = todo.copyWith(createdAt: newDate);
      expect(updatedDate.createdAt, newDate);

      final unchanged = todo.copyWith();
      expect(unchanged, equals(todo));
    });

    test('equality and hashCode verify value identity', () {
      final todoA = Todo(
        id: 1,
        title: 'Todo A',
        isCompleted: false,
        createdAt: tDate,
      );
      final todoB = Todo(
        id: 1,
        title: 'Todo A',
        isCompleted: false,
        createdAt: tDate,
      );
      final todoDifferentId = Todo(
        id: 2,
        title: 'Todo A',
        isCompleted: false,
        createdAt: tDate,
      );
      final todoDifferentTitle = Todo(
        id: 1,
        title: 'Todo B',
        isCompleted: false,
        createdAt: tDate,
      );
      final todoDifferentStatus = Todo(
        id: 1,
        title: 'Todo A',
        isCompleted: true,
        createdAt: tDate,
      );
      final todoDifferentDate = Todo(
        id: 1,
        title: 'Todo A',
        isCompleted: false,
        createdAt: DateTime(2026, 2, 1),
      );

      expect(todoA, equals(todoB));
      expect(todoA.hashCode, equals(todoB.hashCode));

      expect(todoA, isNot(equals(todoDifferentId)));
      expect(todoA, isNot(equals(todoDifferentTitle)));
      expect(todoA, isNot(equals(todoDifferentStatus)));
      expect(todoA, isNot(equals(todoDifferentDate)));
      expect(todoA, isNot(equals(Object())));
    });
  });
}
