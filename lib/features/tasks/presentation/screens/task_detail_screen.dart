// lib/features/tasks/presentation/screens/task_detail_screen.dart
// Full task detail view with all metadata

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/inputs/app_checkbox.dart';
import '../../../../shared/widgets/layout/app_bottom_sheet.dart';
import '../../data/models/task_model.dart';
import '../providers/task_providers.dart';
import '../providers/project_providers.dart';
import '../widgets/task_list_item.dart';
import '../widgets/date_picker_sheet.dart';
import '../widgets/priority_picker_sheet.dart';
import '../widgets/project_picker_sheet.dart';

class TaskDetailScreen extends ConsumerWidget {
  final int taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final taskAsync = ref.watch(taskByIdProvider(taskId));

    return taskAsync.when(
      data: (task) {
        if (task == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const ErrorState(message: 'Task not found'),
          );
        }

        return Scaffold(
          backgroundColor: isDark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          appBar: _TaskAppBar(task: task),
          body: _TaskDetailBody(task: task),
          bottomNavigationBar: _TaskBottomBar(task: task),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(taskByIdProvider(taskId)),
        ),
      ),
    );
  }
}

/// Task app bar
class _TaskAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Task task;

  const _TaskAppBar({required this.task});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.close,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      actions: [
        // Edit button
        IconButton(
          onPressed: () {
            // TODO: Navigate to edit screen
          },
          icon: Icon(
            Icons.edit_outlined,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          tooltip: 'Edit',
        ),
        // More options
        IconButton(
          onPressed: () => _showMoreOptions(context, ref),
          icon: Icon(
            Icons.more_vert,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
      ],
    );
  }

  void _showMoreOptions(BuildContext context, WidgetRef ref) {
    showActionSheet(
      context: context,
      title: 'Task options',
      actions: [
        ActionSheetItem(
          icon: Icons.copy,
          label: 'Duplicate task',
          onTap: () {
            Navigator.pop(context);
            // TODO: Duplicate task
          },
        ),
        ActionSheetItem(
          icon: Icons.move_to_inbox,
          label: 'Move to project',
          onTap: () {
            Navigator.pop(context);
            _showProjectPicker(context, ref);
          },
        ),
        ActionSheetItem(
          icon: Icons.link,
          label: 'Link to note',
          onTap: () {
            Navigator.pop(context);
            // TODO: Show note picker
          },
        ),
        ActionSheetItem(
          icon: Icons.delete_outline,
          label: 'Delete task',
          destructive: true,
          onTap: () {
            Navigator.pop(context);
            _confirmDelete(context, ref);
          },
        ),
      ],
    );
  }

  void _showProjectPicker(BuildContext context, WidgetRef ref) {
    ProjectPickerSheet.show(
      context,
      selectedProjectId: task.projectId,
      onProjectSelected: (projectId) {
        ref.read(taskActionsProvider.notifier).moveToProject([
          task.id,
        ], projectId);
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close detail screen
              ref.read(taskActionsProvider.notifier).deleteTask(task.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Task detail body
class _TaskDetailBody extends ConsumerWidget {
  final Task task;

  const _TaskDetailBody({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get project info
    final projectAsync = task.projectId != null
        ? ref.watch(projectByIdProvider(task.projectId!))
        : null;
    final project = projectAsync?.valueOrNull;

    // Get subtasks
    final subtasksAsync = ref.watch(subtasksProvider(task.id));

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion checkbox and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 4),
                child: TaskCheckbox(
                  isCompleted: task.isCompleted,
                  priority: task.priority,
                  onChanged: (completed) {
                    ref
                        .read(taskActionsProvider.notifier)
                        .toggleComplete(task.id);
                  },
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  task.title,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: task.isCompleted
                        ? (isDark
                              ? AppColors.textDisabledDark
                              : AppColors.textDisabledLight)
                        : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.lg),

          // Description
          if (task.description != null && task.description!.isNotEmpty) ...[
            _DetailSection(
              icon: Icons.notes,
              child: Text(
                task.description!,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),
          ],

          // Metadata rows
          _MetadataRow(
            icon: Icons.folder_outlined,
            label: 'Project',
            value: project?.name ?? 'Inbox',
            valueColor: project != null
                ? AppColors.getProjectColor(project.colorIndex)
                : null,
            onTap: () => _showProjectPicker(context, ref),
          ),

          _MetadataRow(
            icon: Icons.calendar_today,
            label: 'Due date',
            value: _formatDueDate(task),
            valueColor: task.isOverdue ? AppColors.error : null,
            onTap: () => _showDatePicker(context, ref),
          ),

          _MetadataRow(
            icon: Icons.flag_outlined,
            label: 'Priority',
            value: _getPriorityLabel(task.priority),
            valueColor: AppColors.getPriorityColor(task.priority),
            onTap: () => _showPriorityPicker(context, ref),
          ),

          if (task.recurrenceRule != null)
            _MetadataRow(
              icon: Icons.repeat,
              label: 'Repeat',
              value: task.recurrenceRule!,
              onTap: () {
                // TODO: Show recurrence picker
              },
            ),

          SizedBox(height: AppSpacing.lg),

          // Subtasks
          subtasksAsync.when(
            data: (subtasks) {
              if (subtasks.isEmpty) return const SizedBox.shrink();

              return _SubtasksSection(subtasks: subtasks, parentTask: task);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Add subtask button
          _AddSubtaskButton(parentTaskId: task.id),

          SizedBox(height: AppSpacing.lg),

          // Linked notes
          if (task.linkedNoteIds.isNotEmpty) ...[
            _LinkedNotesSection(noteIds: task.linkedNoteIdList),
            SizedBox(height: AppSpacing.lg),
          ],

          // Timestamps
          _TimestampsSection(task: task),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _showProjectPicker(BuildContext context, WidgetRef ref) {
    ProjectPickerSheet.show(
      context,
      selectedProjectId: task.projectId,
      onProjectSelected: (projectId) {
        ref.read(taskActionsProvider.notifier).moveToProject([
          task.id,
        ], projectId);
      },
    );
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) {
    DatePickerSheet.show(
      context,
      initialDate: task.dueDate,
      onDateSelected: (date) {
        ref
            .read(taskActionsProvider.notifier)
            .updateTask(task.id, dueDate: date);
      },
    );
  }

  void _showPriorityPicker(BuildContext context, WidgetRef ref) {
    PriorityPickerSheet.show(
      context,
      selectedPriority: task.priority,
      onPrioritySelected: (priority) {
        ref
            .read(taskActionsProvider.notifier)
            .updateTask(task.id, priority: priority);
      },
    );
  }

  String _formatDueDate(Task task) {
    if (task.dueDate == null) return 'No date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(
      task.dueDate!.year,
      task.dueDate!.month,
      task.dueDate!.day,
    );

    if (date == today) return 'Today';
    if (date == tomorrow) return 'Tomorrow';
    if (date.isBefore(today)) {
      final days = today.difference(date).inDays;
      return '$days day${days > 1 ? 's' : ''} overdue';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getPriorityLabel(int priority) => switch (priority) {
    1 => 'Urgent',
    2 => 'High',
    3 => 'Medium',
    4 => 'Low',
    _ => 'None',
  };
}

/// Detail section wrapper
class _DetailSection extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _DetailSection({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: child),
      ],
    );
  }
}

/// Metadata row
class _MetadataRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  const _MetadataRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.roundedSm,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color:
                    valueColor ??
                    (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ],
        ),
      ),
    );
  }
}

/// Subtasks section
class _SubtasksSection extends ConsumerWidget {
  final List<Task> subtasks;
  final Task parentTask;

  const _SubtasksSection({required this.subtasks, required this.parentTask});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final completed = subtasks.where((t) => t.isCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.checklist,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Subtasks',
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              '$completed/${subtasks.length}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        ...subtasks.map(
          (subtask) => CompactTaskListItem(
            task: subtask,
            onTap: () {
              // TODO: Navigate to subtask detail
            },
            onCompleteChanged: (completed) {
              ref.read(taskActionsProvider.notifier).toggleComplete(subtask.id);
            },
            indentLevel: 1,
          ),
        ),
      ],
    );
  }
}

/// Add subtask button
class _AddSubtaskButton extends ConsumerWidget {
  final int parentTaskId;

  const _AddSubtaskButton({required this.parentTaskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        // TODO: Show add subtask dialog
      },
      borderRadius: AppRadius.roundedSm,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(Icons.add, size: 20, color: AppColors.primary),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Add subtask',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Linked notes section
class _LinkedNotesSection extends StatelessWidget {
  final List<int> noteIds;

  const _LinkedNotesSection({required this.noteIds});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.link,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Linked notes',
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              '${noteIds.length}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        // TODO: Show linked note cards
        Text(
          'Note IDs: ${noteIds.join(", ")}',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

/// Timestamps section
class _TimestampsSection extends StatelessWidget {
  final Task task;

  const _TimestampsSection({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        SizedBox(height: AppSpacing.sm),
        Text(
          'Created ${_formatTimestamp(task.createdAt)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
          ),
        ),
        if (task.updatedAt != task.createdAt) ...[
          SizedBox(height: AppSpacing.xxs),
          Text(
            'Updated ${_formatTimestamp(task.updatedAt)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: isDark
                  ? AppColors.textDisabledDark
                  : AppColors.textDisabledLight,
            ),
          ),
        ],
        if (task.completedAt != null) ...[
          SizedBox(height: AppSpacing.xxs),
          Text(
            'Completed ${_formatTimestamp(task.completedAt!)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.success.withOpacity(0.7),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTimestamp(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Bottom action bar
class _TaskBottomBar extends ConsumerWidget {
  final Task task;

  const _TaskBottomBar({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Complete button
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(taskActionsProvider.notifier)
                        .toggleComplete(task.id);
                  },
                  icon: Icon(
                    task.isCompleted ? Icons.undo : Icons.check,
                    size: 20,
                  ),
                  label: Text(
                    task.isCompleted ? 'Mark incomplete' : 'Complete',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: task.isCompleted
                        ? (isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariantLight)
                        : AppColors.success,
                    foregroundColor: task.isCompleted
                        ? (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight)
                        : Colors.white,
                    minimumSize: Size(0, 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
