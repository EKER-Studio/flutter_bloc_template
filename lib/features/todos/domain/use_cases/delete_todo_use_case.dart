import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/todo_repository.dart';

/// Use case that deletes a todo item.
@injectable
class DeleteTodoUseCase {
  /// Creates a [DeleteTodoUseCase] instance.
  const DeleteTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Deletes the todo item with the given [id].
  Future<(bool success, Failure? failure)> call({required int id}) {
    return _repository.delete(id: id);
  }
}
