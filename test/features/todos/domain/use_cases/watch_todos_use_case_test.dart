import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/use_cases/watch_todos_use_case.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepository;
  late WatchTodosUseCase useCase;

  final tTodos = [
    Todo(
      id: 1,
      title: 'First Todo',
      isCompleted: false,
      createdAt: DateTime(2026, 1, 1),
    ),
  ];

  setUp(() {
    mockRepository = MockTodoRepository();
    useCase = WatchTodosUseCase(mockRepository);
  });

  group('WatchTodosUseCase', () {
    test('returns todos stream from repository', () {
      when(
        () => mockRepository.watchAll(),
      ).thenAnswer((_) => Stream.value(tTodos));

      expect(useCase(), emitsInOrder([tTodos, emitsDone]));
      verify(() => mockRepository.watchAll()).called(1);
    });

    test('forwards errors emitted by the repository stream', () {
      const failure = DatabaseFailure('watch error');
      when(
        () => mockRepository.watchAll(),
      ).thenAnswer((_) => Stream.error(failure));

      expect(useCase(), emitsError(failure));
      verify(() => mockRepository.watchAll()).called(1);
    });
  });
}
