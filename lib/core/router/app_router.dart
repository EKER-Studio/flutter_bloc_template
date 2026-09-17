import 'package:go_router/go_router.dart';

import '../../features/settings/presentation/screens/licenses_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/todos/presentation/screens/todo_screen.dart';
import '../../features/todos/presentation/screens/todo_screen_detail.dart';

/// Central application router using [GoRouter] for declarative navigation.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'todos',
      builder: (context, state) => const TodoScreen(),
      routes: [
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'licenses',
              name: 'licenses',
              builder: (context, state) => const LicensesScreen(),
            ),
            GoRoute(
              path: 'privacy-policy',
              name: 'privacy-policy',
              builder: (context, state) => const PrivacyPolicyScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'todo/:id',
          name: 'todo-detail',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return TodoDetailScreen(todoId: id);
          },
        ),
      ],
    ),
  ],
);
