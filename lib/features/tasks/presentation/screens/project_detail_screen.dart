// lib/features/tasks/presentation/screens/project_detail_screen.dart
// Project detail with sections and tasks

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../data/models/project_model.dart';
import '../../data/models/section_model.dart';
import '../../data/models/task_model.dart';
import '../providers/project_providers.dart';
import '../providers/task_providers.dart';
import '../widgets/task_list_item.dart';
import '../widgets/project_list_item.dart';
import '../../../home/presentation/widgets/quick_capture_sheet.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final int projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final projectAsync = ref.watch(projectByIdProvider(projectId));
    final tasksAsync = ref.watch(tasksByProjectProvider(projectId));
    final sectionsAsync = ref.watch(sectionsByProjectProvider(projectId));

    return projectAsync.when(
      data: (project) {
        if (project == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorState(message: 'Project not found'),
          );
        }

        return Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: CustomScrollView(
            slivers: [
              // App bar
              _ProjectAppBar(project: project),

              // Stats
              SliverToBoxAdapter(
                child: _ProjectStats(tasks: tasksAsync.valueOrNull ?? []),
              ),

              // Content
              _ProjectContent(
                project: project,
                tasksAsync: tasksAsync,
                sectionsAsync: sectionsAsync,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              QuickCaptureSheet.show(
                context,
                initialType: CaptureType.task,
                defaultProjectId: projectId,
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(projectByIdProvider(projectId)),
        ),
      ),
    );
  }
}

/// Project app bar
class _ProjectAppBar extends ConsumerWidget {
  final Project project;

  const _ProjectAppBar({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final projectColor = AppColors.getProjectColor(project.colorIndex);

    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 120,
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: projectColor.withValues(alpha: 0.15),
                borderRadius: AppRadius.roundedXs,
              ),
              child: Icon(
                project.isInbox ? Icons.inbox : Icons.folder,
                size: 16,
                color: projectColor,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                project.name,
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!project.isInbox) ...[
          IconButton(
            onPressed: () {
              ref
                  .read(projectActionsProvider.notifier)
                  .toggleFavorite(project.id);
            },
            icon: Icon(
              project.isFavorite ? Icons.star : Icons.star_outline,
              color: project.isFavorite
                  ? AppColors.tertiary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
            tooltip: project.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
          ),
        ],
        IconButton(
          onPressed: () {
            // TODO: Show project options
          },
          icon: Icon(
            Icons.more_vert,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

/// Project stats bar
class _ProjectStats extends StatelessWidget {
  final List<Task> tasks;

  const _ProjectStats({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final overdue = tasks.where((t) => t.isOverdue).length;
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Progress indicator
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$completed/$total',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'completed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: AppRadius.roundedFull,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight,
                    valueColor: const AlwaysStoppedAnimation(AppColors.success),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.lg),

          // Overdue badge
          if (overdue > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: AppRadius.roundedSm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber,
                      size: 16, color: AppColors.error),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '$overdue overdue',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Project content with sections and tasks
class _ProjectContent extends ConsumerWidget {
  final Project project;
  final AsyncValue<List<Task>> tasksAsync;
  final AsyncValue<List<Section>> sectionsAsync;

  const _ProjectContent({
    required this.project,
    required this.tasksAsync,
    required this.sectionsAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return tasksAsync.when(
      data: (tasks) {
        final sections = sectionsAsync.valueOrNull ?? [];
        final incompleteTasks = tasks.where((t) => !t.isCompleted).toList();
        final completedTasks = tasks.where((t) => t.isCompleted).toList();

        if (tasks.isEmpty) {
          return SliverFillRemaining(
            child: EmptyState(
              type: EmptyStateType.tasks,
              title: 'No tasks in ${project.name}',
              subtitle: 'Add your first task to get started',
              actionLabel: 'Add task',
              onAction: () {
                QuickCaptureSheet.show(
                  context,
                  initialType: CaptureType.task,
                  defaultProjectId: project.id,
                );
              },
            ),
          );
        }

        // Group tasks by section
        final unsectionedTasks =
            incompleteTasks.where((t) => t.sectionId == null).toList();

        return SliverList(
          delegate: SliverChildListDelegate([
            // Unsectioned tasks
            if (unsectionedTasks.isNotEmpty) ...[
              ...unsectionedTasks.map(
                (task) => TaskListItem(
                  task: task,
                  onTap: () {
                    // TODO: Navigate to task detail
                  },
                  onCompleteChanged: (completed) {
                    ref
                        .read(taskActionsProvider.notifier)
                        .toggleComplete(task.id);
                  },
                  showProject: false,
                ),
              ),
            ],

            // Sections
            ...sections.map((section) {
              final sectionTasks = incompleteTasks
                  .where((t) => t.sectionId == section.id)
                  .toList();

              return _SectionWidget(section: section, tasks: sectionTasks);
            }),

            // Completed tasks
            if (completedTasks.isNotEmpty)
              _CompletedSection(tasks: completedTasks),

            // Bottom padding
            const SizedBox(height: AppSpacing.xxxl + 56),
          ]),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) =>
          SliverFillRemaining(child: ErrorState(message: e.toString())),
    );
  }
}

/// Section widget with header and tasks
class _SectionWidget extends ConsumerStatefulWidget {
  final Section section;
  final List<Task> tasks;

  const _SectionWidget({required this.section, required this.tasks});

  @override
  ConsumerState<_SectionWidget> createState() => _SectionWidgetState();
}

class _SectionWidgetState extends ConsumerState<_SectionWidget> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.section.isCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: widget.section.name,
          taskCount: widget.tasks.length,
          isCollapsed: _isCollapsed,
          onToggle: () {
            setState(() => _isCollapsed = !_isCollapsed);
            ref
                .read(projectActionsProvider.notifier)
                .toggleSectionCollapsed(widget.section.id);
          },
          onAddTask: () {
            QuickCaptureSheet.show(
              context,
              initialType: CaptureType.task,
              defaultProjectId: widget.section.projectId,
            );
          },
        ),
        if (!_isCollapsed)
          ...widget.tasks.map(
            (task) => TaskListItem(
              task: task,
              onTap: () {
                // TODO: Navigate to task detail
              },
              onCompleteChanged: (completed) {
                ref.read(taskActionsProvider.notifier).toggleComplete(task.id);
              },
              showProject: false,
            ),
          ),
      ],
    );
  }
}

/// Completed tasks section
class _CompletedSection extends ConsumerStatefulWidget {
  final List<Task> tasks;

  const _CompletedSection({required this.tasks});

  @override
  ConsumerState<_CompletedSection> createState() => _CompletedSectionState();
}

class _CompletedSectionState extends ConsumerState<_CompletedSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _isExpanded ? 0 : -0.25,
                  duration: AppConstants.animMicro,
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Completed',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text(
                    '${widget.tasks.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          ...widget.tasks.map(
            (task) => TaskListItem(
              task: task,
              onTap: () {
                // TODO: Navigate to task detail
              },
              onCompleteChanged: (completed) {
                ref.read(taskActionsProvider.notifier).toggleComplete(task.id);
              },
              showProject: false,
            ),
          ),
      ],
    );
  }
}
