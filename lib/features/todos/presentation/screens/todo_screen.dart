import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/presentation/widgets/app_empty_view.dart';
import '../../../../core/presentation/widgets/app_error_view.dart';
import '../../../../core/presentation/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/todo.dart';
import '../bloc/todo_bloc.dart';
import '../bloc/todo_event.dart';
import '../bloc/todo_state.dart';
import '../widgets/add_todo_fab.dart';
import '../widgets/todo_list_item.dart';

/// Screen displaying the list of todo items.
///
/// ## Dependency scope contract
///
/// Both [TodoBloc] and [SettingsBloc] are provided at the `App` level via
/// `MultiBlocProvider` in `lib/app.dart`. This ensures that navigating to the
/// settings screen (which sits outside the todo navigation stack) does not lose
/// BLoC context — the widgets remain within the same provider ancestry. The
/// same contract applies to any BLoC whose lifespan should span the entire
/// application session rather than a single route.
class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocListener<TodoBloc, TodoState>(
      listenWhen: (previous, current) =>
          current is TodoLoadFailure && previous is! TodoLoadFailure,
      listener: (context, state) {
        if (state is TodoLoadFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.toUserMessage(l10n))),
          );
        }
      },
      child: BlocBuilder<TodoBloc, TodoState>(
        builder: (context, state) {
          return switch (state) {
            TodoInitial() => const SizedBox.shrink(),
            TodoLoadInProgress() => _buildLoading(context),
            TodoLoadSuccess(:final todos) => _buildList(context, todos),
            TodoLoadFailure(:final failure) => _buildError(
              context,
              failure.toUserMessage(l10n),
            ),
          };
        },
      ),
    );
  }

  Scaffold _buildLoading(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).appTitle)),
      body: const AppLoadingIndicator(),
    );
  }

  Scaffold _buildList(BuildContext context, List<Todo> todos) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            tooltip: l10n.settings,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: todos.isEmpty
          ? AppEmptyView(
              title: l10n.noTodos,
              description: l10n.noTodosDescription,
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                return TodoListItem(
                  todo: todo,
                  onToggle: () =>
                      context.read<TodoBloc>().add(TodoToggled(todo.id)),
                  onDelete: () {
                    context.read<TodoBloc>().add(TodoDeleted(todo));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(l10n.todoDeleted(todo.title)),
                          action: SnackBarAction(
                            label: l10n.undo,
                            onPressed: () {
                              context.read<TodoBloc>().add(TodoRestored(todo));
                            },
                          ),
                        ),
                      );
                  },
                );
              },
            ),
      floatingActionButton: AddTodoFab(
        onAdd: (title) async {
          context.read<TodoBloc>().add(TodoAdded(title));
        },
      ),
    );
  }

  Scaffold _buildError(BuildContext context, String message) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: AppErrorView(
        message: message,
        retryLabel: l10n.retry,
        onRetry: () => context.read<TodoBloc>().add(const WatchTodos()),
      ),
    );
  }
}
