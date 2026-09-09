import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/use_cases/add_todo_use_case.dart';
import '../../domain/use_cases/delete_todo_use_case.dart';
import '../../domain/use_cases/restore_todo_use_case.dart';
import '../../domain/use_cases/toggle_todo_use_case.dart';
import '../../domain/use_cases/watch_todos_use_case.dart';
import 'todo_event.dart';
import 'todo_state.dart';

/// BLoC managing the todo list state via clean architecture use cases.
@injectable
class TodoBloc extends Bloc<TodoEvent, TodoState> {
  TodoBloc(
    this._watchTodos,
    this._addTodo,
    this._toggleTodo,
    this._deleteTodo,
    this._restoreTodo,
  ) : super(const TodoInitial()) {
    on<WatchTodos>(_onWatchTodos);
    on<TodoAdded>(_onTodoAdded);
    on<TodoToggled>(_onTodoToggled);
    on<TodoDeleted>(_onTodoDeleted);
    on<TodoRestored>(_onTodoRestored);
    on<TodoWatchFailed>(_onTodoWatchFailed);
    on<TodosUpdated>(_onTodosUpdated);
  }

  /// Convenience constructor wrapping a repository directly (e.g. for testing).
  TodoBloc.fromRepository(TodoRepository repository)
    : this(
        WatchTodosUseCase(repository),
        AddTodoUseCase(repository),
        ToggleTodoUseCase(repository),
        DeleteTodoUseCase(repository),
        RestoreTodoUseCase(repository),
      );

  final WatchTodosUseCase _watchTodos;
  final AddTodoUseCase _addTodo;
  final ToggleTodoUseCase _toggleTodo;
  final DeleteTodoUseCase _deleteTodo;
  final RestoreTodoUseCase _restoreTodo;

  StreamSubscription<List<Todo>>? _todosSubscription;

  void _onWatchTodos(WatchTodos event, Emitter<TodoState> emit) {
    emit(const TodoLoadInProgress());
    _todosSubscription?.cancel();
    _todosSubscription = _watchTodos().listen(
      (todos) => add(TodosUpdated(todos)),
      onError: (Object error) {
        final failure = error is Failure
            ? error
            : DatabaseFailure('Watch stream error: ${error.toString()}');
        add(TodoWatchFailed(failure));
      },
    );
  }

  void _onTodoWatchFailed(TodoWatchFailed event, Emitter<TodoState> emit) {
    emit(TodoLoadFailure(event.failure));
  }

  void _onTodosUpdated(TodosUpdated event, Emitter<TodoState> emit) {
    emit(TodoLoadSuccess(todos: event.todos));
  }

  Future<void> _onTodoAdded(TodoAdded event, Emitter<TodoState> emit) async {
    try {
      final result = await _addTodo(title: event.title);
      if (result.$2 != null) {
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      emit(TodoLoadFailure(DatabaseFailure('Add failed: ${e.toString()}')));
    }
  }

  Future<void> _onTodoToggled(
    TodoToggled event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final result = await _toggleTodo(id: event.id);
      if (result.$2 != null) {
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      emit(TodoLoadFailure(DatabaseFailure('Toggle failed: ${e.toString()}')));
    }
  }

  Future<void> _onTodoDeleted(
    TodoDeleted event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final result = await _deleteTodo(id: event.todo.id);
      if (result.$2 != null) {
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      emit(TodoLoadFailure(DatabaseFailure('Delete failed: ${e.toString()}')));
    }
  }

  Future<void> _onTodoRestored(
    TodoRestored event,
    Emitter<TodoState> emit,
  ) async {
    try {
      final result = await _restoreTodo(event.todo);
      if (result.$2 != null) {
        emit(TodoLoadFailure(result.$2!));
      }
    } catch (e) {
      emit(TodoLoadFailure(DatabaseFailure('Restore failed: ${e.toString()}')));
    }
  }

  @override
  Future<void> close() {
    _todosSubscription?.cancel();
    return super.close();
  }
}
