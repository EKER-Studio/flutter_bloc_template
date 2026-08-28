import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../shared/format.dart';

/// Screen displaying the details of a single todo item.
class TodoDetailScreen extends StatelessWidget {
  /// Creates a [TodoDetailScreen] for the todo identified by [todoId].
  const TodoDetailScreen({super.key, required this.todoId});

  /// The id of the todo to display.
  final int todoId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<TodoBloc, TodoState>(
      listenWhen: (previous, current) =>
          previous is TodoLoadSuccess &&
          previous.todos.any((t) => t.id == todoId) &&
          current is TodoLoadSuccess &&
          !current.todos.any((t) => t.id == todoId),
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.todoDeletedNotice)));
        Navigator.of(context).pop();
      },
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          Todo? todo;
          if (state is TodoLoadSuccess) {
            todo = state.todos.where((t) => t.id == todoId).firstOrNull;
          }

          if (todo == null) {
            return Scaffold(
              appBar: AppBar(title: Text(l10n.taskDetails)),
              body: Center(child: Text(l10n.todoNotFound)),
            );
          }

          return _buildDetails(context, todo);
        },
      ),
    );
  }

  Scaffold _buildDetails(BuildContext context, Todo todo) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(todo.title),
        actions: [
          IconButton(
            tooltip: l10n.delete,
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              context.read<TodoBloc>().add(TodoDeleted(todo));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text(l10n.completed),
              value: todo.isCompleted,
              onChanged: (_) {
                context.read<TodoBloc>().add(TodoToggled(todo.id));
              },
            ),
            const Divider(),
            Text(l10n.created, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(formatTodoDate(todo.createdAt)),
          ],
        ),
      ),
    );
  }
}
