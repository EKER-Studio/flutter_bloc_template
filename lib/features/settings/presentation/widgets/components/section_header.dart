import 'package:flutter/material.dart';

/// A widget that renders an accessible section header label above settings groups.
class SectionHeader extends StatelessWidget {
  /// The section header text.
  final String label;

  /// Creates a [SectionHeader] with the provided [label].
  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 16, top: 16, bottom: 8),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
