import 'package:flutter/material.dart';

/// Centered message presentation widget with icon, title, subtitle, and optional CTA button.
class StateMessageCard extends StatelessWidget {
  /// The icon displayed in the central circle.
  final IconData icon;

  /// The icon color.
  final Color iconColor;

  /// Background fill color for the icon container circle.
  final Color iconContainerColor;

  /// Headline title text.
  final String title;

  /// Informational subtitle text.
  final String subtitle;

  /// Optional text label for the action button.
  final String? buttonLabel;

  /// Optional callback invoked when the action button is pressed.
  final VoidCallback? onButtonPressed;

  /// Optional icon placed inside the action button.
  final IconData? buttonIcon;

  /// Creates a [StateMessageCard].
  const StateMessageCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconContainerColor,
    required this.title,
    required this.subtitle,
    this.buttonLabel,
    this.onButtonPressed,
    this.buttonIcon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: iconColor),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 340),
                child: Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              if (buttonLabel != null && onButtonPressed != null) ...[
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onButtonPressed,
                  icon: Icon(buttonIcon ?? Icons.add, size: 20),
                  label: Text(
                    buttonLabel!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
