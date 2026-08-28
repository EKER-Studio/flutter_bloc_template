import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc_boilerplate/features/todos/data/mappers/todo_mapper.dart';
import 'package:flutter_bloc_boilerplate/features/todos/data/models/todo_model.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';

void main() {
  final tDate = DateTime(2024, 1, 1, 12, 0);
  const tId = 1;
  const tTitle = 'Test Todo';
  const tIsCompleted = false;

  group('TodoMapper', () {
    test('toEntity() converts TodoModel to Todo entity correctly', () {
      final model = TodoModel()
        ..id = tId
        ..title = tTitle
        ..isCompleted = tIsCompleted
        ..createdAt = tDate;

      final entity = model.toEntity();

      expect(entity, isA<Todo>());
      expect(entity.id, tId);
      expect(entity.title, tTitle);
      expect(entity.isCompleted, tIsCompleted);
      expect(entity.createdAt, tDate);
    });

    test('toModel() converts Todo entity to TodoModel correctly', () {
      final entity = Todo(
        id: tId,
        title: tTitle,
        isCompleted: tIsCompleted,
        createdAt: tDate,
      );

      final model = entity.toModel();

      expect(model, isA<TodoModel>());
      expect(model.id, tId);
      expect(model.title, tTitle);
      expect(model.isCompleted, tIsCompleted);
      expect(model.createdAt, tDate);
    });
  });
}
