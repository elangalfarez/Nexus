// lib/core/router/app_router.dart
// GoRouter configuration with navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/storage_service.dart';
import '../../features/home/presentation/screens/home_shell.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/data_management_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/tasks/presentation/screens/task_detail_screen.dart';
import '../../features/tasks/presentation/screens/task_edit_screen.dart';
import '../../features/tasks/presentation/screens/project_detail_screen.dart';
import '../../features/notes/presentation/screens/note_editor_screen.dart';

/// Route names
class AppRoutes {
  static const splash = 'splash';
  static const onboarding = 'onboarding';
  static const home = 'home';
  static const today = 'today';
  static const inbox = 'inbox';
  static const projects = 'projects';
  static const notes = 'notes';
  static const taskDetail = 'task-detail';
  static const taskEdit = 'task-edit';
  static const taskCreate = 'task-create';
  static const projectDetail = 'project-detail';
  static const projectEdit = 'project-edit';
  static const projectCreate = 'project-create';
  static const noteDetail = 'note-detail';
  static const noteEdit = 'note-edit';
  static const noteCreate = 'note-create';
  static const search = 'search';
  static const graph = 'graph';
  static const settings = 'settings';
  static const about = 'about';
}

/// Route paths
class AppPaths {
  static const home = '/';
  static const onboarding = '/onboarding';
  static const today = '/today';
  static const inbox = '/inbox';
  static const projects = '/projects';
  static const notes = '/notes';
  static const taskDetail = '/task/:id';
  static const taskEdit = '/task/:id/edit';
  static const taskCreate = '/task/new';
  static const projectDetail = '/project/:id';
  static const projectEdit = '/project/:id/edit';
  static const projectCreate = '/project/new';
  static const noteDetail = '/note/:id';
  static const noteEdit = '/note/:id/edit';
  static const noteCreate = '/note/new';
  static const search = '/search';
  static const graph = '/graph';
  static const settings = '/settings';
  static const about = '/settings/about';
}

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppPaths.home,
    debugLogDiagnostics: true,

    // Redirect logic
    redirect: (context, state) {
      // Check onboarding status
      final hasCompletedOnboarding = StorageService.isOnboardingCompleted();

      final isOnboarding = state.matchedLocation == AppPaths.onboarding;

      // If not completed onboarding and not on onboarding page, redirect
      if (!hasCompletedOnboarding && !isOnboarding) {
        return AppPaths.onboarding;
      }

      // If completed onboarding and on onboarding page, redirect to home
      if (hasCompletedOnboarding && isOnboarding) {
        return AppPaths.home;
      }

      return null;
    },

    // Routes
    routes: [
      // Onboarding
      GoRoute(
        path: AppPaths.onboarding,
        name: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Home shell with bottom navigation
      GoRoute(
        path: AppPaths.home,
        name: AppRoutes.home,
        builder: (context, state) => const HomeShell(),
        routes: [
          // Task routes
          GoRoute(
            path: 'task/new',
            name: AppRoutes.taskCreate,
            builder: (context, state) {
              final projectId = state.uri.queryParameters['projectId'];
              return TaskEditScreen(
                initialProjectId: projectId != null
                    ? int.tryParse(projectId)
                    : null,
              );
            },
          ),
          GoRoute(
            path: 'task/:id',
            name: AppRoutes.taskDetail,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return TaskDetailScreen(taskId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: AppRoutes.taskEdit,
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return TaskEditScreen(taskId: id);
                },
              ),
            ],
          ),

          // Project routes
          GoRoute(
            path: 'project/new',
            name: AppRoutes.projectCreate,
            builder: (context, state) => const _PlaceholderScreen(
              title: 'New Project',
              icon: Icons.create_new_folder,
            ),
          ),
          GoRoute(
            path: 'project/:id',
            name: AppRoutes.projectDetail,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return ProjectDetailScreen(projectId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: AppRoutes.projectEdit,
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return _PlaceholderScreen(
                    title: 'Edit Project',
                    icon: Icons.edit,
                    subtitle: 'ID: $id',
                  );
                },
              ),
            ],
          ),

          // Note routes
          GoRoute(
            path: 'note/new',
            name: AppRoutes.noteCreate,
            builder: (context, state) {
              final folderId = state.uri.queryParameters['folderId'];
              return NoteEditorScreen(
                folderId: folderId != null ? int.tryParse(folderId) : null,
              );
            },
          ),
          GoRoute(
            path: 'note/:id',
            name: AppRoutes.noteDetail,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return NoteEditorScreen(noteId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: AppRoutes.noteEdit,
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  return NoteEditorScreen(noteId: id);
                },
              ),
            ],
          ),

          // Search
          GoRoute(
            path: 'search',
            name: AppRoutes.search,
            builder: (context, state) => const SearchScreen(),
          ),

          // Graph view
          GoRoute(
            path: 'graph',
            name: AppRoutes.graph,
            builder: (context, state) => const _PlaceholderScreen(
              title: 'Knowledge Graph',
              icon: Icons.hub,
            ),
          ),

          // Settings
          GoRoute(
            path: 'settings',
            name: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'about',
                name: AppRoutes.about,
                builder: (context, state) => const AboutScreen(),
              ),
              GoRoute(
                path: 'data',
                builder: (context, state) => const DataManagementScreen(),
              ),
            ],
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => _ErrorScreen(error: state.error),
  );
});

/// Navigation extensions
extension NavigationExtensions on BuildContext {
  void goToTask(int id) => go('/task/$id');
  void goToEditTask(int id) => go('/task/$id/edit');
  void goToCreateTask() => go('/task/new');

  void goToProject(int id) => go('/project/$id');
  void goToEditProject(int id) => go('/project/$id/edit');
  void goToCreateProject() => go('/project/new');

  void goToNote(int id) => go('/note/$id');
  void goToEditNote(int id) => go('/note/$id/edit');
  void goToCreateNote() => go('/note/new');

  void goToSearch() => go('/search');
  void goToGraph() => go('/graph');
  void goToSettings() => go('/settings');
  void goToAbout() => go('/settings/about');
}

/// Placeholder screen for unimplemented routes
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineSmall),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Error screen
class _ErrorScreen extends StatelessWidget {
  final Exception? error;

  const _ErrorScreen({this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Oops! Something went wrong',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'Page not found',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(AppPaths.home),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
