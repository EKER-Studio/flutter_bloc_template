import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../entities/todo.dart';
import '../repositories/todo_repository.dart';

/// Use case that restores a previously deleted todo item.
@injectable
class RestoreTodoUseCase {
  /// Creates a [RestoreTodoUseCase] instance.
  const RestoreTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Restores the deleted [todo].
  Future<(bool success, Failure? failure)> call(Todo todo) {
    return _repository.restore(todo);
  }
}
