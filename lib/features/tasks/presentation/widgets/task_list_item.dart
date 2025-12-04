// lib/features/tasks/presentation/widgets/task_list_item.dart
// Task list item widget with checkbox, title, and metadata

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/inputs/app_checkbox.dart';
import '../../../../shared/widgets/inputs/app_chip.dart';
import '../../data/models/task_model.dart';

/// Task list item widget
class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ValueChanged<bool>? onCompleteChanged;
  final String? projectName;
  final int? projectColorIndex;
  final bool showProject;
  final bool showDueDate;
  final bool showPriority;
  final bool selected;
  final bool draggable;

  const TaskListItem({
    super.key,
    required this.task,
    this.onTap,
    this.onLongPress,
    this.onCompleteChanged,
    this.projectName,
    this.projectColorIndex,
    this.showProject = true,
    this.showDueDate = true,
    this.showPriority = true,
    this.selected = false,
    this.draggable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isCompleted = task.isCompleted;

    // Text colors
    final titleColor = isCompleted
        ? (isDark
              ? AppColors.textDisabledDark
              : AppColors.textDisabledLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Material(
      color: selected
          ? AppColors.primary.withOpacity(0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress?.call();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle (if draggable)
              if (draggable) ...[
                Icon(
                  Icons.drag_indicator,
                  size: 20,
                  color: isDark
                      ? AppColors.textDisabledDark
                      : AppColors.textDisabledLight,
                ),
                SizedBox(width: AppSpacing.xs),
              ],

              // Checkbox
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: TaskCheckbox(
                  isCompleted: isCompleted,
                  priority: task.priority,
                  onChanged: onCompleteChanged,
                ),
              ),

              SizedBox(width: AppSpacing.sm),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      task.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: titleColor,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: titleColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description preview (if exists)
                    if (task.description != null &&
                        task.description!.isNotEmpty &&
                        !isCompleted) ...[
                      SizedBox(height: AppSpacing.xxs),
                      Text(
                        task.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: subtitleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Metadata row
                    if (_hasMetadata) ...[
                      SizedBox(height: AppSpacing.sm),
                      _buildMetadataRow(context, isDark),
                    ],
                  ],
                ),
              ),

              // Subtask indicator
              if (task.parentTaskId == null &&
                  task.linkedNoteIds.isNotEmpty) ...[
                SizedBox(width: AppSpacing.sm),
                Icon(Icons.link, size: 16, color: subtitleColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasMetadata {
    if (task.isCompleted) return false;
    return (showDueDate && task.dueDate != null) ||
        (showProject && projectName != null) ||
        (showPriority && task.priority < 4);
  }

  Widget _buildMetadataRow(BuildContext context, bool isDark) {
    final chips = <Widget>[];

    // Due date
    if (showDueDate && task.dueDate != null) {
      chips.add(DueDateChip(dueDate: task.dueDate, isOverdue: task.isOverdue));
    }

    // Priority (only show if high)
    if (showPriority && task.priority < 3) {
      chips.add(PriorityChip(priority: task.priority, showLabel: false));
    }

    // Project
    if (showProject && projectName != null) {
      chips.add(
        ProjectChip(
          projectName: projectName!,
          colorIndex: projectColorIndex ?? 0,
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips,
    );
  }
}

/// Compact task list item (for subtasks)
class CompactTaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompleteChanged;
  final int indentLevel;

  const CompactTaskListItem({
    super.key,
    required this.task,
    this.onTap,
    this.onCompleteChanged,
    this.indentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isCompleted = task.isCompleted;

    final titleColor = isCompleted
        ? (isDark
              ? AppColors.textDisabledDark
              : AppColors.textDisabledLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.md + (indentLevel * AppSpacing.lg),
          right: AppSpacing.md,
          top: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: Row(
          children: [
            TaskCheckbox(
              isCompleted: isCompleted,
              priority: task.priority,
              onChanged: onCompleteChanged,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                task.title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: titleColor,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Task list item skeleton for loading state
class TaskListItemSkeleton extends StatelessWidget {
  const TaskListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shimmerBase = isDark
        ? AppColors.shimmerBaseDark
        : AppColors.shimmerBase;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Checkbox placeholder
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.sm),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: AppRadius.roundedXs,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                // Subtitle
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: AppRadius.roundedXs,
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
