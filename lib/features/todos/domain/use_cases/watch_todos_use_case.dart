import 'package:injectable/injectable.dart';

import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

/// Use case that streams all todo items.
@injectable
class WatchTodosUseCase {
  /// Creates a [WatchTodosUseCase] instance.
  const WatchTodosUseCase(this._repository);

  final TodoRepository _repository;

  /// Returns a stream of all todo items.
  Stream<List<Todo>> call() => _repository.watchAll();
}
