import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Floating action button for adding a new todo item.
class AddTodoFab extends StatelessWidget {
  /// Creates an [AddTodoFab].
  const AddTodoFab({super.key, required this.onAdd});

  /// Callback to execute when a new todo is added.
  final Future<void> Function(String title) onAdd;

  Future<void> _showAddDialog(BuildContext context) async {
    final title = await showDialog<String>(
      context: context,
      builder: (context) => const _AddTodoDialog(),
    );

    if (title != null) {
      await onAdd(title);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FloatingActionButton.extended(
      onPressed: () => _showAddDialog(context),
      icon: const Icon(Icons.add),
      label: Text(l10n.add),
    );
  }
}

class _AddTodoDialog extends StatefulWidget {
  const _AddTodoDialog();

  @override
  State<_AddTodoDialog> createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<_AddTodoDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!mounted) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!mounted) return;
    Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.newTask),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.title,
            hintText: l10n.titleHint,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.titleEmptyError;
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.add)),
      ],
    );
  }
}
