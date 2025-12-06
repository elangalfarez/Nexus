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
import '../widgets/create_project_sheet.dart';
import '../widgets/project_detail_sheet.dart';

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
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.backgroundLight,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'Projects',
              style: AppTextStyles.headlineMedium.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                tooltip: viewMode == ViewMode.list ? 'Grid view' : 'List view',
              ),
              // Add project
              IconButton(
                onPressed: () => CreateProjectSheet.show(context),
                icon: Icon(
                  Icons.add,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                tooltip: 'New project',
              ),
              const SizedBox(width: AppSpacing.xs),
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
                    onAction: () => CreateProjectSheet.show(context),
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
            loading: () => const SliverFillRemaining(
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
    return SliverList(
      delegate: SliverChildListDelegate([
        // Inbox
        if (inbox != null) ...[
          const _SectionTitle(title: 'Inbox'),
          _ProjectListItemWithStats(project: inbox!),
          const SizedBox(height: AppSpacing.md),
        ],

        // Favorites
        if (favorites.isNotEmpty) ...[
          const _SectionTitle(title: 'Favorites', icon: Icons.star),
          ...favorites.map((p) => _ProjectListItemWithStats(project: p)),
          const SizedBox(height: AppSpacing.md),
        ],

        // Regular projects
        if (regular.isNotEmpty) ...[
          const _SectionTitle(title: 'Projects'),
          ...regular.map((p) => _ProjectListItemWithStats(project: p)),
        ],

        // Bottom padding
        const SizedBox(height: AppSpacing.xxxl),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.tertiary),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
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
    // Watch tasks - use inboxTasksProvider for Inbox (tasks have projectId = null)
    final tasksAsync = project.isInbox
        ? ref.watch(inboxTasksProvider)
        : ref.watch(tasksByProjectProvider(project.id));

    final taskCount = tasksAsync.valueOrNull?.length ?? 0;
    final completedCount =
        tasksAsync.valueOrNull?.where((t) => t.isCompleted).length ?? 0;

    return ProjectListItem(
      project: project,
      taskCount: taskCount,
      completedCount: completedCount,
      onTap: () => ProjectDetailSheet.show(context, project),
      onLongPress: () => ProjectDetailSheet.show(context, project),
    );
  }
}

/// Project grid item with task stats
class _ProjectGridItemWithStats extends ConsumerWidget {
  final Project project;

  const _ProjectGridItemWithStats({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch tasks - use inboxTasksProvider for Inbox (tasks have projectId = null)
    final tasksAsync = project.isInbox
        ? ref.watch(inboxTasksProvider)
        : ref.watch(tasksByProjectProvider(project.id));

    final taskCount = tasksAsync.valueOrNull?.length ?? 0;
    final completedCount =
        tasksAsync.valueOrNull?.where((t) => t.isCompleted).length ?? 0;

    return ProjectGridCard(
      project: project,
      taskCount: taskCount,
      completedCount: completedCount,
      onTap: () => ProjectDetailSheet.show(context, project),
      onLongPress: () => ProjectDetailSheet.show(context, project),
    );
  }
}
