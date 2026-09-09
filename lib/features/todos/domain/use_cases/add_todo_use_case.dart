import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/todo_repository.dart';

/// Use case that adds a new todo item.
@injectable
class AddTodoUseCase {
  const AddTodoUseCase(this._repository);

  final TodoRepository _repository;

  /// Adds a new todo with the given [title].
  Future<(bool success, Failure? failure)> call({required String title}) {
    return _repository.add(title: title);
  }
}
