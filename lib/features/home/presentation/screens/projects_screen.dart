// lib/features/home/presentation/screens/projects_screen.dart
// Projects list with grid/list toggle

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../tasks/data/models/project_model.dart';
import '../../../tasks/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/project_list_item.dart';

/// View mode for projects
final projectsViewModeProvider = StateProvider<ViewMode>(
  (ref) => ViewMode.list,
);

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final projectsAsync = ref.watch(activeProjectsProvider);
    final viewMode = ref.watch(projectsViewModeProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.background,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Projects',
              style: AppTextStyles.headlineMedium.copyWith(
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
              ),
            ),
            actions: [
              // View toggle
              IconButton(
                onPressed: () {
                  final current = ref.read(projectsViewModeProvider);
                  ref.read(projectsViewModeProvider.notifier).state =
                      current == ViewMode.list ? ViewMode.grid : ViewMode.list;
                },
                icon: Icon(
                  viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                tooltip: viewMode == ViewMode.list ? 'Grid view' : 'List view',
              ),
              // Add project
              IconButton(
                onPressed: () {
                  // TODO: Navigate to create project
                },
                icon: Icon(
                  Icons.add,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                tooltip: 'New project',
              ),
              SizedBox(width: AppSpacing.xs),
            ],
          ),

          // Content
          projectsAsync.when(
            data: (projects) {
              if (projects.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    type: EmptyStateType.projects,
                    actionLabel: 'Create project',
                    onAction: () {
                      // TODO: Navigate to create project
                    },
                  ),
                );
              }

              // Separate favorites and regular
              final favorites = projects.where((p) => p.isFavorite).toList();
              final regular = projects
                  .where((p) => !p.isFavorite && !p.isInbox)
                  .toList();
              final inbox = projects.where((p) => p.isInbox).firstOrNull;

              if (viewMode == ViewMode.grid) {
                return _GridView(
                  inbox: inbox,
                  favorites: favorites,
                  regular: regular,
                );
              }

              return _ListView(
                inbox: inbox,
                favorites: favorites,
                regular: regular,
              );
            },
            loading: () => SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(activeProjectsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// List view for projects
class _ListView extends ConsumerWidget {
  final Project? inbox;
  final List<Project> favorites;
  final List<Project> regular;

  const _ListView({this.inbox, required this.favorites, required this.regular});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverList(
      delegate: SliverChildListDelegate([
        // Inbox
        if (inbox != null) ...[
          _SectionTitle(title: 'Inbox'),
          _ProjectListItemWithStats(project: inbox!),
          SizedBox(height: AppSpacing.md),
        ],

        // Favorites
        if (favorites.isNotEmpty) ...[
          _SectionTitle(title: 'Favorites', icon: Icons.star),
          ...favorites.map((p) => _ProjectListItemWithStats(project: p)),
          SizedBox(height: AppSpacing.md),
        ],

        // Regular projects
        if (regular.isNotEmpty) ...[
          _SectionTitle(title: 'Projects'),
          ...regular.map((p) => _ProjectListItemWithStats(project: p)),
        ],

        // Bottom padding
        SizedBox(height: AppSpacing.huge),
      ]),
    );
  }
}

/// Grid view for projects
class _GridView extends ConsumerWidget {
  final Project? inbox;
  final List<Project> favorites;
  final List<Project> regular;

  const _GridView({this.inbox, required this.favorites, required this.regular});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProjects = [if (inbox != null) inbox!, ...favorites, ...regular];

    return SliverPadding(
      padding: EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.1,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final project = allProjects[index];
          return _ProjectGridItemWithStats(project: project);
        }, childCount: allProjects.length),
      ),
    );
  }
}

/// Section title
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const _SectionTitle({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.tertiary),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Project list item with task stats
class _ProjectListItemWithStats extends ConsumerWidget {
  final Project project;

  const _ProjectListItemWithStats({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch tasks for this project to get counts
    final tasksAsync = ref.watch(tasksByProjectProvider(project.id));

    final taskCount = tasksAsync.valueOrNull?.length ?? 0;
    final completedCount =
        tasksAsync.valueOrNull?.where((t) => t.isCompleted).length ?? 0;

    return ProjectListItem(
      project: project,
      taskCount: taskCount,
      completedCount: completedCount,
      onTap: () {
        // TODO: Navigate to project detail
      },
      onLongPress: () {
        // TODO: Show project options
      },
    );
  }
}

/// Project grid item with task stats
class _ProjectGridItemWithStats extends ConsumerWidget {
  final Project project;

  const _ProjectGridItemWithStats({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksByProjectProvider(project.id));

    final taskCount = tasksAsync.valueOrNull?.length ?? 0;
    final completedCount =
        tasksAsync.valueOrNull?.where((t) => t.isCompleted).length ?? 0;

    return ProjectGridCard(
      project: project,
      taskCount: taskCount,
      completedCount: completedCount,
      onTap: () {
        // TODO: Navigate to project detail
      },
      onLongPress: () {
        // TODO: Show project options
      },
    );
  }
}
