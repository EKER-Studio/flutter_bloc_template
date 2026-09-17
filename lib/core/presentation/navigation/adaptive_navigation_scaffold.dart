import 'package:flutter/material.dart';

import '../theme/app_layout_tokens.dart';

/// Destination specification for [AdaptiveNavigationScaffold].
class AdaptiveNavigationDestination {
  /// Icon displayed in the destination.
  final Widget icon;

  /// Optional icon displayed when the destination is selected.
  final Widget? selectedIcon;

  /// Text label for the destination.
  final String label;

  /// Creates an [AdaptiveNavigationDestination].
  const AdaptiveNavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}

/// Adaptive layout scaffold switching between a bottom NavigationBar and side NavigationRail.
class AdaptiveNavigationScaffold extends StatelessWidget {
  /// The active body widget.
  final Widget body;

  /// Index of currently selected destination.
  final int currentIndex;

  /// Destinations rendered in the navigation bar and rail.
  final List<AdaptiveNavigationDestination> destinations;

  /// Callback invoked when a destination is selected.
  final ValueChanged<int> onDestinationSelected;

  /// Creates an [AdaptiveNavigationScaffold].
  const AdaptiveNavigationScaffold({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isWide =
        context.isTablet ||
        MediaQuery.orientationOf(context) == Orientation.landscape;

    if (isWide) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                selectedIndex: currentIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                destinations: destinations
                    .map(
                      (d) => NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                      ),
                    )
                    .toList(),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
