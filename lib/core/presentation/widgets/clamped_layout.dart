import 'package:flutter/material.dart';

/// Responsive layout helper that clamps its [child] to a maximum width and centers it horizontally.
class ClampedLayout extends StatelessWidget {
  /// The widget content rendered within the constrained width.
  final Widget child;

  /// Optional uniform padding applied inside the clamped area.
  final EdgeInsetsGeometry? padding;

  /// Maximum allowed horizontal width.
  final double maxWidth;

  /// Alignment within the available parent space.
  final AlignmentGeometry alignment;

  /// Creates a [ClampedLayout].
  const ClampedLayout({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth = 600,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
