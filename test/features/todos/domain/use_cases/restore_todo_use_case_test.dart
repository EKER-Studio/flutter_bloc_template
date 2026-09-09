import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/use_cases/restore_todo_use_case.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepository;
  late RestoreTodoUseCase useCase;

  final tTodo = Todo(
    id: 1,
    title: 'Restored Todo',
    isCompleted: false,
    createdAt: DateTime(2026, 1, 1),
  );

  setUpAll(() {
    registerFallbackValue(tTodo);
  });

  setUp(() {
    mockRepository = MockTodoRepository();
    useCase = RestoreTodoUseCase(mockRepository);
  });

  group('RestoreTodoUseCase', () {
    test('forwards restore call to repository and returns success', () async {
      when(
        () => mockRepository.restore(any()),
      ).thenAnswer((_) async => (true, null));

      final result = await useCase(tTodo);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(() => mockRepository.restore(tTodo)).called(1);
    });

    test(
      'forwards restore call to repository and returns failure on error',
      () async {
        const failure = DatabaseFailure('failed to restore');
        when(
          () => mockRepository.restore(any()),
        ).thenAnswer((_) async => (false, failure));

        final result = await useCase(tTodo);

        expect(result.$1, isFalse);
        expect(result.$2, failure);
        verify(() => mockRepository.restore(tTodo)).called(1);
      },
    );
  });
}
