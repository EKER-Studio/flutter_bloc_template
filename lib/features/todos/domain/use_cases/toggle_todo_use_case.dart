import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/todo_repository.dart';

/// Use case that toggles the completion status of a todo item.
@injectable
class ToggleTodoUseCase {
  /// Creates a [ToggleTodoUseCase] instance.
  const ToggleTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Toggles the completed status of the todo with the given [id].
  Future<(bool success, Failure? failure)> call({required int id}) {
    return _repository.toggleCompleted(id: id);
  }
}
