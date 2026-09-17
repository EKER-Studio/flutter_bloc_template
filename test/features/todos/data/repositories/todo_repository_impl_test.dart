import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc_boilerplate/core/errors/failure.dart';
import 'package:flutter_bloc_boilerplate/features/todos/data/models/todo_model.dart';
import 'package:flutter_bloc_boilerplate/features/todos/data/repositories/todo_repository_impl.dart';
import 'package:flutter_bloc_boilerplate/features/todos/domain/entities/todo.dart';

class MockIsar extends Mock implements Isar {}

class MockTodoCollection extends Mock implements IsarCollection<TodoModel> {}

class MockQuery extends Mock implements Query<TodoModel> {}

class _TestTodoCollection extends Fake implements IsarCollection<TodoModel> {
  _TestTodoCollection(this._inner, this._query);

  final MockTodoCollection _inner;
  final Query<TodoModel> _query;

  @override
  Future<Id> put(TodoModel object) => _inner.put(object);

  @override
  Future<TodoModel?> get(Id id) => _inner.get(id);

  @override
  Future<bool> delete(Id id) => _inner.delete(id);

  @override
  Stream<TodoModel?> watchObject(Id id, {bool fireImmediately = false}) =>
      _inner.watchObject(id, fireImmediately: fireImmediately);

  @override
  QueryBuilder<TodoModel, TodoModel, QWhere> where({
    bool distinct = false,
    Sort sort = Sort.asc,
  }) {
    return QueryBuilder(
      QueryBuilderInternal(
        collection: this,
        whereDistinct: distinct,
        whereSort: sort,
      ),
    );
  }

  @override
  Query<R> buildQuery<R>({
    List<WhereClause> whereClauses = const [],
    bool whereDistinct = false,
    Sort whereSort = Sort.asc,
    FilterOperation? filter,
    List<SortProperty> sortBy = const [],
    List<DistinctProperty> distinctBy = const [],
    int? offset,
    int? limit,
    String? property,
  }) {
    return _query as Query<R>;
  }
}

void main() {
  late MockIsar mockIsar;
  late MockTodoCollection mockInnerCollection;
  late MockQuery mockQuery;
  late _TestTodoCollection testCollection;
  late TodoRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(TodoModel());
  });

  setUp(() {
    mockIsar = MockIsar();
    mockInnerCollection = MockTodoCollection();
    mockQuery = MockQuery();
    testCollection = _TestTodoCollection(mockInnerCollection, mockQuery);

    when(() => mockIsar.collection<TodoModel>()).thenReturn(testCollection);

    when(() => mockIsar.writeTxn<void>(any())).thenAnswer((invocation) async {
      final callback = invocation.positionalArguments[0] as Function;
      await callback();
    });
    when(() => mockIsar.writeTxn<dynamic>(any())).thenAnswer((
      invocation,
    ) async {
      final callback = invocation.positionalArguments[0] as Function;
      return await callback();
    });

    repository = TodoRepositoryImpl(mockIsar);
  });

  group('TodoRepositoryImpl.add', () {
    test('trims title and persists new todo model', () async {
      when(() => mockInnerCollection.put(any())).thenAnswer((_) async => 1);

      final result = await repository.add(title: '  Buy groceries  ');

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(
        () => mockInnerCollection.put(
          any(
            that: isA<TodoModel>().having(
              (m) => m.title,
              'title',
              'Buy groceries',
            ),
          ),
        ),
      ).called(1);
    });

    test('returns failure when IsarError is thrown during add', () async {
      when(
        () => mockInnerCollection.put(any()),
      ).thenThrow(IsarError('write error'));

      final result = await repository.add(title: 'Task');

      expect(result.$1, isFalse);
      expect(result.$2, isA<DatabaseFailure>());
      expect(result.$2!.message, 'write error');
    });

    test('returns failure when unexpected error occurs during add', () async {
      when(
        () => mockInnerCollection.put(any()),
      ).thenThrow(Exception('unexpected'));

      final result = await repository.add(title: 'Task');

      expect(result.$1, isFalse);
      expect(result.$2, isA<DatabaseFailure>());
      expect(result.$2!.message, contains('unexpected'));
    });
  });

  group('TodoRepositoryImpl.toggleCompleted', () {
    test('toggles completed from false to true when todo exists', () async {
      final model = TodoModel()
        ..id = 1
        ..title = 'Task'
        ..isCompleted = false
        ..createdAt = DateTime(2026);

      when(() => mockInnerCollection.get(1)).thenAnswer((_) async => model);
      when(() => mockInnerCollection.put(any())).thenAnswer((_) async => 1);

      final result = await repository.toggleCompleted(id: 1);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(
        () => mockInnerCollection.put(
          any(
            that: isA<TodoModel>().having(
              (m) => m.isCompleted,
              'isCompleted',
              true,
            ),
          ),
        ),
      ).called(1);
    });

    test('returns NotFoundFailure when todo does not exist', () async {
      when(() => mockInnerCollection.get(999)).thenAnswer((_) async => null);

      final result = await repository.toggleCompleted(id: 999);

      expect(result.$1, isFalse);
      expect(result.$2, isA<NotFoundFailure>());
    });

    test('returns DatabaseFailure when IsarError is thrown', () async {
      when(
        () => mockInnerCollection.get(1),
      ).thenThrow(IsarError('read failure'));

      final result = await repository.toggleCompleted(id: 1);

      expect(result.$1, isFalse);
      expect(result.$2, isA<DatabaseFailure>());
    });
  });

  group('TodoRepositoryImpl.delete', () {
    test('deletes todo by id and returns success', () async {
      when(() => mockInnerCollection.delete(1)).thenAnswer((_) async => true);

      final result = await repository.delete(id: 1);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(() => mockInnerCollection.delete(1)).called(1);
    });

    test(
      'returns DatabaseFailure when IsarError is thrown during delete',
      () async {
        when(
          () => mockInnerCollection.delete(1),
        ).thenThrow(IsarError('delete lock'));

        final result = await repository.delete(id: 1);

        expect(result.$1, isFalse);
        expect(result.$2, isA<DatabaseFailure>());
        expect(result.$2!.message, 'delete lock');
      },
    );
  });

  group('TodoRepositoryImpl.restore', () {
    final tTodo = Todo(
      id: 5,
      title: 'Restored Task',
      isCompleted: true,
      createdAt: DateTime(2026, 1, 1),
    );

    test('persists restored todo with original properties', () async {
      when(() => mockInnerCollection.put(any())).thenAnswer((_) async => 5);

      final result = await repository.restore(tTodo);

      expect(result.$1, isTrue);
      expect(result.$2, isNull);
      verify(
        () => mockInnerCollection.put(
          any(
            that: isA<TodoModel>()
                .having((m) => m.id, 'id', 5)
                .having((m) => m.title, 'title', 'Restored Task')
                .having((m) => m.isCompleted, 'isCompleted', true)
                .having((m) => m.createdAt, 'createdAt', DateTime(2026, 1, 1)),
          ),
        ),
      ).called(1);
    });

    test('returns DatabaseFailure when restore fails', () async {
      when(
        () => mockInnerCollection.put(any()),
      ).thenThrow(IsarError('restore error'));

      final result = await repository.restore(tTodo);

      expect(result.$1, isFalse);
      expect(result.$2, isA<DatabaseFailure>());
    });
  });

  group('TodoRepositoryImpl.watchById', () {
    test('streams mapped todo when found', () async {
      final model = TodoModel()
        ..id = 1
        ..title = 'Streamed Todo'
        ..isCompleted = false
        ..createdAt = DateTime(2026);

      when(
        () => mockInnerCollection.watchObject(1, fireImmediately: true),
      ).thenAnswer((_) => Stream.value(model));

      final stream = repository.watchById(1);
      final emitted = await stream.first;

      expect(emitted, isNotNull);
      expect(emitted!.id, 1);
      expect(emitted.title, 'Streamed Todo');
    });

    test('streams null when todo not found', () async {
      when(
        () => mockInnerCollection.watchObject(2, fireImmediately: true),
      ).thenAnswer((_) => Stream.value(null));

      final stream = repository.watchById(2);
      final emitted = await stream.first;

      expect(emitted, isNull);
    });
  });

  group('TodoRepositoryImpl.getAll and watchAll', () {
    test('getAll queries collection and returns mapped list', () async {
      final model = TodoModel()
        ..id = 1
        ..title = 'All task'
        ..isCompleted = false
        ..createdAt = DateTime(2026);

      when(() => mockQuery.findAll()).thenAnswer((_) async => [model]);

      final result = await repository.getAll();

      expect(result.length, 1);
      expect(result.first.title, 'All task');
    });

    test('watchAll queries collection and streams mapped list', () async {
      final model = TodoModel()
        ..id = 1
        ..title = 'Watched task'
        ..isCompleted = false
        ..createdAt = DateTime(2026);

      when(
        () => mockQuery.watch(fireImmediately: true),
      ).thenAnswer((_) => Stream.value([model]));

      final stream = repository.watchAll();
      final emitted = await stream.first;

      expect(emitted.length, 1);
      expect(emitted.first.title, 'Watched task');
    });
  });
}
