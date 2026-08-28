import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/todo.dart';
import '../shared/format.dart';

/// List item widget displaying a todo item.
class TodoListItem extends StatelessWidget {
  /// Creates a [TodoListItem].
  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  /// The todo item to display.
  final Todo todo;

  /// Callback to execute when the todo is toggled.
  final VoidCallback onToggle;

  /// Callback to execute when the todo is deleted.
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onError,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: () => context.push('/todo/${todo.id}'),
        leading: Semantics(
          label: todo.isCompleted
              ? l10n.markAsNotDone(todo.title)
              : l10n.markAsDone(todo.title),
          child: Checkbox(
            value: todo.isCompleted,
            onChanged: (_) => onToggle(),
          ),
        ),
        title: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: double.infinity),
          child: Text(
            todo.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
              color: todo.isCompleted
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : null,
            ),
          ),
        ),
        subtitle: Text(
          formatTodoDate(todo.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
