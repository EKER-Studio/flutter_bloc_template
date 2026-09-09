import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/use_cases/toggle_todo_use_case.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepository;
  late ToggleTodoUseCase useCase;

  setUp(() {
    mockRepository = MockTodoRepository();
    useCase = ToggleTodoUseCase(mockRepository);
  });

  group('ToggleTodoUseCase', () {
    const tId = 10;

    test('forwards toggle call to repository and returns success', () async {
      when(
        () => mockRepository.toggleCompleted(id: any(named: 'id')),
      ).thenAnswer((_) async => (true, null));

      final result = await useCase(id: tId);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(() => mockRepository.toggleCompleted(id: tId)).called(1);
    });

    test(
      'forwards toggle call to repository and returns failure on error',
      () async {
        const failure = NotFoundFailure('Todo not found');
        when(
          () => mockRepository.toggleCompleted(id: any(named: 'id')),
        ).thenAnswer((_) async => (false, failure));

        final result = await useCase(id: tId);

        expect(result.$1, isFalse);
        expect(result.$2, failure);
        verify(() => mockRepository.toggleCompleted(id: tId)).called(1);
      },
    );
  });
}
