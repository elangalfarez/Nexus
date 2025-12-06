// lib/features/home/presentation/widgets/project_detail_sheet.dart
// World-class, ADHD-friendly project detail sheet

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../tasks/data/models/project_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/project_list_item.dart';
import '../../../tasks/presentation/widgets/task_list_item.dart';
import 'create_project_sheet.dart';
import 'task_detail_sheet.dart';

/// Project Detail Sheet - ADHD-optimized design
/// - Clear visual hierarchy with project color theming
/// - Quick actions with large touch targets
/// - Tasks grouped by date for easy scanning
/// - Smooth animations for satisfying feedback
class ProjectDetailSheet extends ConsumerStatefulWidget {
  final Project project;

  const ProjectDetailSheet({super.key, required this.project});

  /// Show the project detail sheet
  static Future<void> show(BuildContext context, Project project) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectDetailSheet(project: project),
    );
  }

  @override
  ConsumerState<ProjectDetailSheet> createState() => _ProjectDetailSheetState();
}

class _ProjectDetailSheetState extends ConsumerState<ProjectDetailSheet> {
  late TextEditingController _nameController;
  bool _isEditing = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.project.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    HapticFeedback.lightImpact();
    await ref.read(projectActionsProvider.notifier).toggleFavorite(widget.project.id);
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == widget.project.name) {
      setState(() => _isEditing = false);
      return;
    }

    HapticFeedback.lightImpact();
    final updated = widget.project.copyWith(name: newName);
    await ref.read(projectActionsProvider.notifier).updateProject(updated);
    setState(() => _isEditing = false);
  }

  Future<void> _deleteProject() async {
    // Show confirmation dialog
    final projectColor = AppColors.getProjectColor(widget.project.colorIndex);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmDialog(
        projectName: widget.project.name,
        projectColor: projectColor,
      ),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      HapticFeedback.mediumImpact();
      await ref.read(projectActionsProvider.notifier).deleteProject(widget.project.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _editProjectDetails() async {
    final result = await EditProjectSheet.show(context, widget.project);
    if (result == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Watch active projects stream for real-time updates (more reactive than FutureProvider)
    final projectsAsync = ref.watch(activeProjectsProvider);
    final currentProject = projectsAsync.when(
      data: (projects) => projects.firstWhere(
        (p) => p.id == widget.project.id,
        orElse: () => widget.project,
      ),
      loading: () => widget.project,
      error: (_, __) => widget.project,
    );

    // Use current project's color for reactive updates
    final projectColor = AppColors.getProjectColor(currentProject.colorIndex);

    // Watch tasks - use inboxTasksProvider for Inbox (projectId is null for inbox tasks)
    final tasksAsync = currentProject.isInbox
        ? ref.watch(inboxTasksProvider)
        : ref.watch(tasksByProjectProvider(widget.project.id));

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Project Header
          _ProjectHeader(
            project: currentProject,
            projectColor: projectColor,
            isEditing: _isEditing,
            nameController: _nameController,
            onEditTap: () {
              HapticFeedback.lightImpact();
              setState(() => _isEditing = true);
            },
            onSaveName: _saveName,
            onCancelEdit: () => setState(() {
              _isEditing = false;
              _nameController.text = currentProject.name;
            }),
          ),

          // Quick Actions Row
          _QuickActionsRow(
            project: currentProject,
            projectColor: projectColor,
            onFavoriteTap: _toggleFavorite,
            onEditTap: _editProjectDetails,
            onDeleteTap: currentProject.isInbox ? null : _deleteProject,
            isDeleting: _isDeleting,
          ),

          const SizedBox(height: 8),

          // Divider
          Divider(
            height: 1,
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),

          // Tasks Section
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => _TasksSection(
                tasks: tasks,
                projectColor: projectColor,
                projectId: widget.project.id,
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Center(
                child: Text('Error loading tasks: $e'),
              ),
            ),
          ),

          // Safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

/// Project header with icon, name, and edit capability
class _ProjectHeader extends StatelessWidget {
  final Project project;
  final Color projectColor;
  final bool isEditing;
  final TextEditingController nameController;
  final VoidCallback onEditTap;
  final VoidCallback onSaveName;
  final VoidCallback onCancelEdit;

  const _ProjectHeader({
    required this.project,
    required this.projectColor,
    required this.isEditing,
    required this.nameController,
    required this.onEditTap,
    required this.onSaveName,
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // Project icon with color
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: projectColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              getProjectIcon(project.iconName),
              color: projectColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Name (editable or static)
          Expanded(
            child: isEditing
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: nameController,
                          autofocus: true,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: projectColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: projectColor, width: 2),
                            ),
                          ),
                          onSubmitted: (_) => onSaveName(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: onSaveName,
                        icon: Icon(Icons.check_rounded, color: AppColors.success),
                        tooltip: 'Save',
                      ),
                      IconButton(
                        onPressed: onCancelEdit,
                        icon: Icon(
                          Icons.close_rounded,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                        tooltip: 'Cancel',
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: project.isInbox ? null : onEditTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                project.name,
                                style: AppTextStyles.headlineSmall.copyWith(
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!project.isInbox) ...[
                              const SizedBox(width: 8),
                              Icon(
                                Icons.edit_rounded,
                                size: 18,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                            ],
                          ],
                        ),
                        // Only show edit hint for non-Inbox projects
                        if (!project.isInbox) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Tap to edit name',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),

          // Favorite indicator
          if (project.isFavorite)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.star_rounded,
                color: AppColors.tertiary,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}

/// Quick actions row with large touch targets and smooth animations
class _QuickActionsRow extends StatelessWidget {
  final Project project;
  final Color projectColor;
  final VoidCallback onFavoriteTap;
  final VoidCallback onEditTap;
  final VoidCallback? onDeleteTap;
  final bool isDeleting;

  const _QuickActionsRow({
    required this.project,
    required this.projectColor,
    required this.onFavoriteTap,
    required this.onEditTap,
    this.onDeleteTap,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Favorite toggle - disabled for Inbox
          Expanded(
            child: project.isInbox
                ? _ActionButton(
                    icon: Icons.star_outline_rounded,
                    label: 'Favorite',
                    onTap: null,
                    enabled: false, // Inbox can't be favorited
                  )
                : _FavoriteActionButton(
                    isFavorite: project.isFavorite,
                    onTap: onFavoriteTap,
                  ),
          ),
          const SizedBox(width: 12),

          // Edit style - always available
          Expanded(
            child: _ActionButton(
              icon: Icons.palette_outlined,
              label: 'Edit Style',
              color: projectColor,
              onTap: onEditTap,
            ),
          ),
          const SizedBox(width: 12),

          // Delete (not for Inbox)
          Expanded(
            child: _ActionButton(
              icon: isDeleting
                  ? Icons.hourglass_empty_rounded
                  : Icons.delete_outline_rounded,
              label: isDeleting ? 'Deleting...' : 'Delete',
              color: onDeleteTap != null ? AppColors.error : null,
              onTap: onDeleteTap,
              enabled: onDeleteTap != null && !isDeleting,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated favorite button with smooth state transitions
class _FavoriteActionButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _FavoriteActionButton({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isFavorite ? AppColors.tertiary : null;
    final effectiveColor = color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isFavorite
              ? AppColors.tertiary.withValues(alpha: 0.12)
              : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFavorite
                ? AppColors.tertiary.withValues(alpha: 0.3)
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated icon with scale effect
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: isFavorite ? 1.0 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Icon(
                    isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    key: ValueKey(isFavorite),
                    color: effectiveColor,
                    size: 24,
                  ),
                );
              },
            ),
            const SizedBox(height: 6),
            // Animated label
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                isFavorite ? 'Unfavorite' : 'Favorite',
                key: ValueKey(isFavorite),
                style: AppTextStyles.labelSmall.copyWith(
                  color: effectiveColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual action button with icon and label
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = enabled
        ? (color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))
        : (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight);

    return GestureDetector(
      onTap: enabled ? () {
        HapticFeedback.lightImpact();
        onTap?.call();
      } : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: enabled && color != null
              ? color!.withValues(alpha: 0.08)
              : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: effectiveColor, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: effectiveColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tasks section grouped by date
class _TasksSection extends ConsumerWidget {
  final List<Task> tasks;
  final Color projectColor;
  final int projectId;

  const _TasksSection({
    required this.tasks,
    required this.projectColor,
    required this.projectId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tasks.isEmpty) {
      return _EmptyTasksState(projectColor: projectColor);
    }

    // Separate completed and pending tasks
    final pendingTasks = tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = tasks.where((t) => t.isCompleted).toList();

    // Sort pending by due date (nulls last), then by priority
    pendingTasks.sort((a, b) {
      // First by due date
      if (a.dueDate == null && b.dueDate == null) {
        return a.priority.compareTo(b.priority);
      }
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      final dateCompare = a.dueDate!.compareTo(b.dueDate!);
      if (dateCompare != 0) return dateCompare;
      // Then by priority
      return a.priority.compareTo(b.priority);
    });

    // Group pending tasks by date
    final Map<String, List<Task>> groupedTasks = {};
    for (final task in pendingTasks) {
      final key = _getDateKey(task.dueDate);
      groupedTasks.putIfAbsent(key, () => []).add(task);
    }

    return ListView(
      padding: const EdgeInsets.only(top: 16),
      children: [
        // Stats row
        _TaskStatsRow(
          total: tasks.length,
          completed: completedTasks.length,
          projectColor: projectColor,
        ),

        const SizedBox(height: 16),

        // Pending tasks by date group
        ...groupedTasks.entries.map((entry) => _TaskDateGroup(
          dateLabel: entry.key,
          tasks: entry.value,
          projectColor: projectColor,
          onTaskComplete: (task) {
            ref.read(taskActionsProvider.notifier).toggleComplete(task.id);
          },
        )),

        // Completed section (collapsible)
        if (completedTasks.isNotEmpty)
          _CompletedSection(
            tasks: completedTasks,
            projectColor: projectColor,
            onTaskComplete: (task) {
              ref.read(taskActionsProvider.notifier).toggleComplete(task.id);
            },
          ),

        const SizedBox(height: 32),
      ],
    );
  }

  String _getDateKey(DateTime? date) {
    if (date == null) return 'No date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final diff = taskDate.difference(today).inDays;

    if (diff < 0) return 'Overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 7) {
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday - 1];
    }

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Stats row showing completion progress
class _TaskStatsRow extends StatelessWidget {
  final int total;
  final int completed;
  final Color projectColor;

  const _TaskStatsRow({
    required this.total,
    required this.completed,
    required this.projectColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pending = total - completed;
    final progress = total > 0 ? completed / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: projectColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: projectColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // Progress circle - larger container to prevent text overflow
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: projectColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(projectColor),
                      strokeWidth: 4,
                    ),
                  ),
                  // Percentage text - compact styling
                  Text(
                    '${(progress * 100).round()}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: projectColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),

            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$pending pending · $completed done',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$total total tasks',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Task group by date
class _TaskDateGroup extends StatelessWidget {
  final String dateLabel;
  final List<Task> tasks;
  final Color projectColor;
  final ValueChanged<Task> onTaskComplete;

  const _TaskDateGroup({
    required this.dateLabel,
    required this.tasks,
    required this.projectColor,
    required this.onTaskComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOverdue = dateLabel == 'Overdue';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date label
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOverdue
                      ? AppColors.error.withValues(alpha: 0.12)
                      : projectColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dateLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isOverdue ? AppColors.error : projectColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${tasks.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
              ),
            ],
          ),
        ),

        // Tasks
        ...tasks.map((task) => TaskListItem(
          task: task,
          showProject: false,
          showDueDate: false,
          onTap: () => TaskDetailSheet.show(context, task),
          onCompleteChanged: (_) => onTaskComplete(task),
        )),
      ],
    );
  }
}

/// Completed tasks section (collapsible)
class _CompletedSection extends StatefulWidget {
  final List<Task> tasks;
  final Color projectColor;
  final ValueChanged<Task> onTaskComplete;

  const _CompletedSection({
    required this.tasks,
    required this.projectColor,
    required this.onTaskComplete,
  });

  @override
  State<_CompletedSection> createState() => _CompletedSectionState();
}

class _CompletedSectionState extends State<_CompletedSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (tappable to expand)
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isExpanded = !_isExpanded);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Completed',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.tasks.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tasks (if expanded) - show completion dates for ADHD context
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: widget.tasks.map((task) => _CompletedTaskItem(
              task: task,
              onToggle: () => widget.onTaskComplete(task),
            )).toList(),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}

/// Completed task item with completion date - ADHD-friendly
/// Shows when the task was completed for better context and satisfaction
class _CompletedTaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;

  const _CompletedTaskItem({
    required this.task,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiaryLight;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completed checkbox
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onToggle();
            },
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.success,
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Task content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with strikethrough
                Text(
                  task.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    decoration: TextDecoration.lineThrough,
                    decorationColor: textColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Completion date
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      size: 12,
                      color: AppColors.success.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatCompletionDate(task.completedAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.success.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format the completion date in a human-friendly way
  String _formatCompletionDate(DateTime? completedAt) {
    if (completedAt == null) return 'Completed';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final completedDate = DateTime(
      completedAt.year,
      completedAt.month,
      completedAt.day,
    );
    final diff = today.difference(completedDate).inDays;

    if (diff == 0) {
      // Today - show time
      final hour = completedAt.hour;
      final minute = completedAt.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return 'Today at $displayHour:$minute $period';
    } else if (diff == 1) {
      return 'Yesterday';
    } else if (diff < 7) {
      return '$diff days ago';
    } else {
      // Format as date
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[completedAt.month - 1]} ${completedAt.day}';
    }
  }
}

/// Empty tasks state
class _EmptyTasksState extends StatelessWidget {
  final Color projectColor;

  const _EmptyTasksState({required this.projectColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: projectColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 40,
                color: projectColor,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No tasks yet',
              style: AppTextStyles.titleMedium.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first task to get started',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Delete confirmation dialog
class _DeleteConfirmDialog extends StatelessWidget {
  final String projectName;
  final Color projectColor;

  const _DeleteConfirmDialog({
    required this.projectName,
    required this.projectColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Delete Project?',
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
      content: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyMedium.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          children: [
            const TextSpan(text: 'This will permanently delete '),
            TextSpan(
              text: '"$projectName"',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: projectColor,
              ),
            ),
            const TextSpan(text: ' and move all its tasks to Inbox. This cannot be undone.'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            Navigator.of(context).pop(true);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}

/// Edit Project Sheet for color and icon changes
class EditProjectSheet extends ConsumerStatefulWidget {
  final Project project;

  const EditProjectSheet({super.key, required this.project});

  static Future<bool?> show(BuildContext context, Project project) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProjectSheet(project: project),
    );
  }

  @override
  ConsumerState<EditProjectSheet> createState() => _EditProjectSheetState();
}

class _EditProjectSheetState extends ConsumerState<EditProjectSheet> {
  late int _selectedColorIndex;
  late int _selectedIconIndex;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedColorIndex = widget.project.colorIndex;
    _selectedIconIndex = _getIconIndex(widget.project.iconName);
  }

  int _getIconIndex(String iconName) {
    final index = projectIconOptions.indexWhere((o) => o.name == iconName);
    return index >= 0 ? index : 0;
  }

  Future<void> _saveChanges() async {
    if (_selectedColorIndex == widget.project.colorIndex &&
        projectIconOptions[_selectedIconIndex].name == widget.project.iconName) {
      Navigator.of(context).pop(false);
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    final updated = widget.project.copyWith(
      colorIndex: _selectedColorIndex,
      iconName: projectIconOptions[_selectedIconIndex].name,
    );
    await ref.read(projectActionsProvider.notifier).updateProject(updated);

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final selectedColor = AppColors.getProjectColor(_selectedColorIndex);

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with preview
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    projectIconOptions[_selectedIconIndex].icon,
                    color: selectedColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Style',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.project.name,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Color picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppColors.projectPalette.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final color = AppColors.projectPalette[index];
                      final isSelected = index == _selectedColorIndex;

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedColorIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: 3,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Icon picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Icon',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: List.generate(projectIconOptions.length, (index) {
                    final isSelected = index == _selectedIconIndex;

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedIconIndex = index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withValues(alpha: 0.15)
                              : isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? selectedColor
                                : isDark
                                    ? AppColors.borderDark
                                    : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          projectIconOptions[index].icon,
                          color: isSelected
                              ? selectedColor
                              : isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                          size: 22,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: selectedColor.withValues(alpha: 0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
