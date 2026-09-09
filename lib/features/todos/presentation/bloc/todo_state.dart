import '../../../../core/errors/failure.dart';
import '../../domain/entities/todo.dart';

/// States emitted by [TodoBloc].
sealed class TodoState {
  const TodoState();
}

/// Initial state before [WatchTodos] is dispatched.
class TodoInitial extends TodoState {
  const TodoInitial();
}

/// Emitted while todos are being loaded.
class TodoLoadInProgress extends TodoState {
  const TodoLoadInProgress();
}

/// Emitted when todos were loaded or updated successfully.
class TodoLoadSuccess extends TodoState {
  const TodoLoadSuccess({required this.todos});

  /// The current list of todos.
  final List<Todo> todos;
}

/// Emitted when a todo operation failed.
class TodoLoadFailure extends TodoState {
  const TodoLoadFailure(this.failure);

  /// Describes what went wrong.
  final Failure failure;
}
