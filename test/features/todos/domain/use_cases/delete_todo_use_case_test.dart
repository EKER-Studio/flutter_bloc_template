import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/use_cases/delete_todo_use_case.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepository;
  late DeleteTodoUseCase useCase;

  setUp(() {
    mockRepository = MockTodoRepository();
    useCase = DeleteTodoUseCase(mockRepository);
  });

  group('DeleteTodoUseCase', () {
    const tId = 42;

    test('forwards delete call to repository and returns success', () async {
      when(
        () => mockRepository.delete(id: any(named: 'id')),
      ).thenAnswer((_) async => (true, null));

      final result = await useCase(id: tId);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(() => mockRepository.delete(id: tId)).called(1);
    });

    test(
      'forwards delete call to repository and returns failure on error',
      () async {
        const failure = NotFoundFailure('Todo not found');
        when(
          () => mockRepository.delete(id: any(named: 'id')),
        ).thenAnswer((_) async => (false, failure));

        final result = await useCase(id: tId);

        expect(result.$1, isFalse);
        expect(result.$2, failure);
        verify(() => mockRepository.delete(id: tId)).called(1);
      },
    );
  });
}
