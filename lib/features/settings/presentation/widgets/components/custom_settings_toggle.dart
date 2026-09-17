import 'package:flutter/material.dart';

/// A widget that represents an accessible settings list tile with an adaptive switch.
class CustomSettingsToggle extends StatefulWidget {
  /// Leading icon for the preference item.
  final IconData icon;

  /// Primary label of the toggle setting.
  final String title;

  /// Optional secondary description below the title.
  final String? subtitle;

  /// Current boolean state of the switch.
  final bool value;

  /// Callback invoked when the switch state changes.
  final ValueChanged<bool>? onChanged;

  /// Optional label used for screen reader semantic grouping.
  final String? sectionLabel;

  /// Creates a [CustomSettingsToggle].
  const CustomSettingsToggle({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    this.onChanged,
    this.sectionLabel,
  });

  @override
  State<CustomSettingsToggle> createState() => CustomSettingsToggleState();
}

/// State for [CustomSettingsToggle] managing focus and hover state listeners.
class CustomSettingsToggleState extends State<CustomSettingsToggle> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final labelParts = <String>[
      if (widget.sectionLabel != null) widget.sectionLabel!,
      widget.title,
      if (widget.subtitle != null) widget.subtitle!,
    ];

    final tile = Semantics(
      toggled: widget.value,
      label: labelParts.join(', '),
      child: Focus(
        focusNode: _focusNode,
        child: SwitchListTile.adaptive(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          secondary: ExcludeSemantics(
            child: Icon(widget.icon, color: colorScheme.onSurfaceVariant),
          ),
          title: Text(
            widget.title,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: widget.subtitle != null
              ? Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
          value: widget.value,
          onChanged: widget.onChanged,
        ),
      ),
    );

    if (_isFocused) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.primary, width: 2),
        ),
        child: tile,
      );
    }

    return tile;
  }
}
