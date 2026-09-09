import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/repositories/todo_repository.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/use_cases/add_todo_use_case.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepository;
  late AddTodoUseCase useCase;

  setUp(() {
    mockRepository = MockTodoRepository();
    useCase = AddTodoUseCase(mockRepository);
  });

  group('AddTodoUseCase', () {
    const tTitle = 'Buy groceries';

    test('forwards add call to repository and returns success', () async {
      when(
        () => mockRepository.add(title: any(named: 'title')),
      ).thenAnswer((_) async => (true, null));

      final result = await useCase(title: tTitle);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(() => mockRepository.add(title: tTitle)).called(1);
    });

    test(
      'forwards add call to repository and returns failure on error',
      () async {
        const failure = DatabaseFailure('failed to add todo');
        when(
          () => mockRepository.add(title: any(named: 'title')),
        ).thenAnswer((_) async => (false, failure));

        final result = await useCase(title: tTitle);

        expect(result.$1, isFalse);
        expect(result.$2, failure);
        verify(() => mockRepository.add(title: tTitle)).called(1);
      },
    );
  });
}
