// lib/features/home/presentation/widgets/task_detail_sheet.dart
// World-class, ADHD-optimized task detail sheet
// Follows cognitive load reduction, time blindness compensation,
// and dopamine design principles for ADHD users

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/widgets/date_picker_sheet.dart';
import '../../../tasks/presentation/widgets/priority_picker_sheet.dart';
import '../../../tasks/presentation/widgets/project_picker_sheet.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/presentation/providers/note_providers.dart';

/// Task Detail Sheet - ADHD-optimized bottom sheet for task management
///
/// Design Principles Applied:
/// - Hick's Law: Progressive disclosure, minimal initial choices
/// - Time Blindness Compensation: Prominent time context throughout
/// - Cognitive Load Reduction: Clear visual hierarchy, chunked information
/// - Dopamine Design: Satisfying animations, micro-celebrations
/// - Working Memory Support: All context visible in one place
class TaskDetailSheet extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailSheet({super.key, required this.task});

  /// Show the task detail sheet from any context
  static Future<void> show(BuildContext context, Task task) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskDetailSheet(task: task),
    );
  }

  @override
  ConsumerState<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends ConsumerState<TaskDetailSheet>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  bool _isEditingTitle = false;
  bool _isDeleting = false;

  // Animation controller for completion celebration
  late AnimationController _celebrationController;
  late Animation<double> _celebrationScale;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _celebrationScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _celebrationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _showFeedback(String message, {bool isSuccess = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.info_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _saveTitle() async {
    final newTitle = _titleController.text.trim();
    if (newTitle.isEmpty) {
      _titleController.text = widget.task.title;
      setState(() => _isEditingTitle = false);
      return;
    }

    if (newTitle != widget.task.title) {
      HapticFeedback.lightImpact();
      await ref.read(taskActionsProvider.notifier).updateTask(
        widget.task.id,
        title: newTitle,
      );
      _showFeedback('Title updated');
    }
    setState(() => _isEditingTitle = false);
  }

  Future<void> _toggleComplete() async {
    HapticFeedback.mediumImpact();

    // Play celebration animation if completing
    if (!widget.task.isCompleted) {
      _celebrationController.forward(from: 0);
      _showFeedback('Great job! Task completed');
    } else {
      _showFeedback('Task reopened');
    }

    await ref.read(taskActionsProvider.notifier).toggleComplete(widget.task.id);
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmDialog(taskTitle: widget.task.title),
    );

    if (confirmed == true) {
      setState(() => _isDeleting = true);
      HapticFeedback.mediumImpact();
      await ref.read(taskActionsProvider.notifier).deleteTask(widget.task.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    // Watch task for real-time updates (now using StreamProvider)
    final taskAsync = ref.watch(taskByIdProvider(widget.task.id));
    final currentTask = taskAsync.valueOrNull ?? widget.task;

    // Handle deleted task
    if (taskAsync.valueOrNull == null && taskAsync.hasValue) {
      // Task was deleted, close the sheet
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }

    // Get project info
    final projectAsync = currentTask.projectId != null
        ? ref.watch(projectByIdProvider(currentTask.projectId!))
        : null;
    final project = projectAsync?.valueOrNull;

    final priorityColor = AppColors.getPriorityColor(currentTask.priority);

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Main content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Checkbox + Title
                  _TaskHeader(
                    task: currentTask,
                    priorityColor: priorityColor,
                    project: project,
                    isEditingTitle: _isEditingTitle,
                    titleController: _titleController,
                    celebrationScale: _celebrationScale,
                    onToggleComplete: _toggleComplete,
                    onEditTitle: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isEditingTitle = true);
                    },
                    onSaveTitle: _saveTitle,
                    onCancelEdit: () => setState(() {
                      _isEditingTitle = false;
                      _titleController.text = currentTask.title;
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Time Context Section - Critical for ADHD
                  _TimeContextSection(task: currentTask),

                  const SizedBox(height: 20),

                  // Quick Actions Row
                  _QuickActionsRow(
                    task: currentTask,
                    project: project,
                    priorityColor: priorityColor,
                    onFeedback: _showFeedback,
                  ),

                  const SizedBox(height: 16),

                  Divider(
                    height: 1,
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),

                  const SizedBox(height: 16),

                  // Linked Notes Section (2nd Brain integration)
                  _LinkedNotesSection(task: currentTask),

                  const SizedBox(height: 16),

                  // Subtasks Section - Only for root tasks (no nested subtasks)
                  if (!currentTask.isSubtask) ...[
                    _SubtasksSection(task: currentTask),
                    const SizedBox(height: 24),
                  ],

                  // Danger Zone - Delete
                  _DangerZone(
                    isDeleting: _isDeleting,
                    onDelete: _deleteTask,
                  ),

                  // Bottom safe area
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Task header with ADHD-friendly completion checkbox
/// Large, obvious tap target with clear visual feedback
class _TaskHeader extends StatelessWidget {
  final Task task;
  final Color priorityColor;
  final dynamic project;
  final bool isEditingTitle;
  final TextEditingController titleController;
  final Animation<double> celebrationScale;
  final VoidCallback onToggleComplete;
  final VoidCallback onEditTitle;
  final VoidCallback onSaveTitle;
  final VoidCallback onCancelEdit;

  const _TaskHeader({
    required this.task,
    required this.priorityColor,
    required this.project,
    required this.isEditingTitle,
    required this.titleController,
    required this.celebrationScale,
    required this.onToggleComplete,
    required this.onEditTitle,
    required this.onSaveTitle,
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ADHD-friendly completion checkbox
        // Large tap target, clear state, satisfying animation
        ScaleTransition(
          scale: celebrationScale,
          child: GestureDetector(
            onTap: onToggleComplete,
            child: Tooltip(
              message: task.isCompleted ? 'Mark as incomplete' : 'Mark as done',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.success
                      : priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: task.isCompleted ? AppColors.success : priorityColor,
                    width: task.isCompleted ? 0 : 2.5,
                  ),
                  boxShadow: task.isCompleted
                      ? [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                  child: task.isCompleted
                      ? const Icon(
                          Icons.check_rounded,
                          key: ValueKey('completed'),
                          color: Colors.white,
                          size: 28,
                        )
                      : Icon(
                          Icons.radio_button_unchecked_rounded,
                          key: const ValueKey('incomplete'),
                          color: priorityColor,
                          size: 28,
                        ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Title and project badge
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editable title
              if (isEditingTitle)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: titleController,
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
                            borderSide: BorderSide(color: priorityColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: priorityColor, width: 2),
                          ),
                        ),
                        onSubmitted: (_) => onSaveTitle(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onSaveTitle,
                      icon: const Icon(Icons.check_rounded),
                      color: AppColors.success,
                      iconSize: 22,
                    ),
                    IconButton(
                      onPressed: onCancelEdit,
                      icon: const Icon(Icons.close_rounded),
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      iconSize: 22,
                    ),
                  ],
                )
              else
                GestureDetector(
                  onTap: task.isCompleted ? null : onEditTitle,
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
                      decorationColor: isDark
                          ? AppColors.textDisabledDark
                          : AppColors.textDisabledLight,
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Project badge
              if (project != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.getProjectColor(project.colorIndex)
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.folder_rounded,
                        size: 14,
                        color: AppColors.getProjectColor(project.colorIndex),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        project.name,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.getProjectColor(project.colorIndex),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_rounded,
                        size: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Inbox',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Time context section - Critical for ADHD time blindness
class _TimeContextSection extends StatelessWidget {
  final Task task;

  const _TimeContextSection({required this.task});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceVariantDark.withValues(alpha: 0.5)
            : AppColors.surfaceVariantLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _TimeItem(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Created',
                  value: _formatRelativeTime(task.createdAt),
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
              ),
              Expanded(
                child: task.isCompleted
                    ? _TimeItem(
                        icon: Icons.check_circle_rounded,
                        label: 'Completed',
                        value: task.completedAt != null
                            ? _formatRelativeTime(task.completedAt!)
                            : 'Done',
                        color: AppColors.success,
                      )
                    : task.dueDate != null
                        ? _TimeItem(
                            icon: task.isOverdue
                                ? Icons.warning_rounded
                                : Icons.event_rounded,
                            label: task.isOverdue ? 'Overdue' : 'Due',
                            value: _formatDueTime(task.dueDate!),
                            color: task.isOverdue
                                ? AppColors.error
                                : task.isDueToday
                                    ? AppColors.warning
                                    : AppColors.primary,
                          )
                        : _TimeItem(
                            icon: Icons.event_rounded,
                            label: 'Due',
                            value: 'No date',
                            color: isDark
                                ? AppColors.textDisabledDark
                                : AppColors.textDisabledLight,
                          ),
              ),
            ],
          ),
          if (!task.isCompleted && task.dueDate != null && (task.isOverdue || task.isDueToday)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (task.isOverdue ? AppColors.error : AppColors.warning)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    task.isOverdue ? Icons.warning_rounded : Icons.schedule_rounded,
                    size: 16,
                    color: task.isOverdue ? AppColors.error : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    task.isOverdue
                        ? _getOverdueMessage(task.dueDate!)
                        : 'Due today – you got this!',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: task.isOverdue ? AppColors.error : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _formatDueTime(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (due == today) return 'Today';
    if (due == tomorrow) return 'Tomorrow';
    if (due.isBefore(today)) {
      final days = today.difference(due).inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    }
    final days = due.difference(today).inDays;
    if (days < 7) return 'In $days day${days > 1 ? 's' : ''}';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dueDate.month - 1]} ${dueDate.day}';
  }

  String _getOverdueMessage(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final days = today.difference(due).inDays;
    if (days == 1) return 'Overdue by 1 day – still doable!';
    if (days < 7) return 'Overdue by $days days';
    return 'Overdue – let\'s get it done!';
  }
}

class _TimeItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _TimeItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 6),
        Text(label, style: AppTextStyles.labelSmall.copyWith(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        )),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.labelMedium.copyWith(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Quick actions row with visual feedback
class _QuickActionsRow extends ConsumerWidget {
  final Task task;
  final dynamic project;
  final Color priorityColor;
  final void Function(String, {bool isSuccess}) onFeedback;

  const _QuickActionsRow({
    required this.task,
    required this.project,
    required this.priorityColor,
    required this.onFeedback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.calendar_today_rounded,
            label: task.dueDate != null ? _formatShortDate(task.dueDate!) : 'Add date',
            color: task.isOverdue ? AppColors.error : task.dueDate != null ? AppColors.primary : null,
            onTap: () => _showDatePicker(context, ref),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.flag_rounded,
            label: _getPriorityLabel(task.priority),
            color: priorityColor,
            onTap: () => _showPriorityPicker(context, ref),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.folder_rounded,
            label: project?.name ?? 'Inbox',
            color: project != null ? AppColors.getProjectColor(project.colorIndex) : null,
            onTap: () => _showProjectPicker(context, ref),
          ),
        ),
      ],
    );
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) {
    DatePickerSheet.show(context, initialDate: task.dueDate, onDateSelected: (date) {
      HapticFeedback.lightImpact();
      ref.read(taskActionsProvider.notifier).updateTask(task.id, dueDate: date);
      onFeedback(date != null ? 'Due date updated' : 'Due date removed');
    });
  }

  void _showPriorityPicker(BuildContext context, WidgetRef ref) {
    PriorityPickerSheet.show(context, selectedPriority: task.priority, onPrioritySelected: (priority) {
      HapticFeedback.lightImpact();
      ref.read(taskActionsProvider.notifier).updateTask(task.id, priority: priority);
      onFeedback('Priority changed to ${_getPriorityLabel(priority)}');
    });
  }

  void _showProjectPicker(BuildContext context, WidgetRef ref) {
    ProjectPickerSheet.show(context, selectedProjectId: task.projectId, onProjectSelected: (projectId) {
      HapticFeedback.lightImpact();
      ref.read(taskActionsProvider.notifier).moveToProject([task.id], projectId);
      onFeedback('Moved to project');
    });
  }

  String _formatShortDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == tomorrow) return 'Tomorrow';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getPriorityLabel(int priority) => switch (priority) {
    1 => 'Urgent',
    2 => 'High',
    3 => 'Medium',
    _ => 'Low',
  };
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _QuickActionButton({required this.icon, required this.label, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = color ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color != null ? color!.withValues(alpha: 0.08) : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color != null ? color!.withValues(alpha: 0.3) : (isDark ? AppColors.borderDark : AppColors.borderLight)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: effectiveColor),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.labelSmall.copyWith(color: effectiveColor, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

/// Linked Notes Section - 2nd Brain integration
class _LinkedNotesSection extends ConsumerWidget {
  final Task task;

  const _LinkedNotesSection({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final linkedNoteIds = task.linkedNoteIdList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.note_alt_outlined, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            const SizedBox(width: 10),
            Text('Linked Notes', style: AppTextStyles.titleSmall.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
            const Spacer(),
            GestureDetector(
              onTap: () => _showLinkNoteSheet(context, ref),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_link_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Link', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (linkedNoteIds.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.3) : AppColors.surfaceVariantLight.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline_rounded, size: 20, color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight),
                const SizedBox(width: 12),
                Expanded(child: Text('Link notes to add context without clutter', style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight))),
              ],
            ),
          )
        else
          ...linkedNoteIds.map((noteId) => _LinkedNoteItem(noteId: noteId, taskId: task.id)),
      ],
    );
  }

  void _showLinkNoteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (context) => _NoteLinkPickerSheet(task: task));
  }
}

class _LinkedNoteItem extends ConsumerWidget {
  final int noteId;
  final int taskId;

  const _LinkedNoteItem({required this.noteId, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final noteAsync = ref.watch(noteByIdProvider(noteId));

    return noteAsync.when(
      data: (note) {
        if (note == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceVariantDark.withValues(alpha: 0.5) : AppColors.surfaceVariantLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              children: [
                const Icon(Icons.description_outlined, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(note.title, style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (note.preview.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(note.preview, style: AppTextStyles.bodySmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _unlinkNote(ref, note),
                  icon: Icon(Icons.link_off_rounded, size: 18, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _unlinkNote(WidgetRef ref, Note note) {
    HapticFeedback.lightImpact();
    // Use StreamProvider (taskByIdProvider) for live data, NOT FutureProvider (stale data)
    final task = ref.read(taskByIdProvider(taskId)).valueOrNull;
    if (task != null) {
      ref.read(taskActionsProvider.notifier).updateTaskModel(task.unlinkNote(noteId));
    }
  }
}

class _NoteLinkPickerSheet extends ConsumerWidget {
  final Task task;

  const _NoteLinkPickerSheet({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notesAsync = ref.watch(allNotesProvider);
    final linkedIds = task.linkedNoteIdList;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(child: Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: isDark ? AppColors.borderDark : AppColors.borderLight, borderRadius: BorderRadius.circular(2)))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Link a Note', style: AppTextStyles.titleLarge.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const Spacer(),
                TextButton.icon(onPressed: () => _createAndLinkNote(context, ref), icon: const Icon(Icons.add, size: 18), label: const Text('New Note')),
              ],
            ),
          ),
          Flexible(
            child: notesAsync.when(
              data: (notes) {
                final unlinkedNotes = notes.where((n) => !linkedIds.contains(n.id)).toList();
                if (unlinkedNotes.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.note_add_outlined, size: 48, color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight),
                        const SizedBox(height: 16),
                        Text(notes.isEmpty ? 'No notes yet' : 'All notes are already linked', style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: unlinkedNotes.length,
                  itemBuilder: (context, index) {
                    final note = unlinkedNotes[index];
                    return ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(note.title),
                      subtitle: note.preview.isNotEmpty ? Text(note.preview, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                      onTap: () => _linkNote(context, ref, note),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading notes')),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  void _linkNote(BuildContext context, WidgetRef ref, Note note) {
    HapticFeedback.lightImpact();
    ref.read(taskActionsProvider.notifier).updateTaskModel(task.linkNote(note.id));
    Navigator.of(context).pop();
  }

  void _createAndLinkNote(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final newNote = await ref.read(noteActionsProvider.notifier).createNote(title: 'Notes for: ${task.title}');
    if (newNote != null) {
      ref.read(taskActionsProvider.notifier).updateTaskModel(task.linkNote(newNote.id));
    }
    if (context.mounted) Navigator.of(context).pop();
  }
}

/// Subtasks section - Only for root tasks (no nested subtasks - ADHD-friendly)
class _SubtasksSection extends ConsumerWidget {
  final Task task;

  const _SubtasksSection({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtasksAsync = ref.watch(subtasksProvider(task.id));

    return subtasksAsync.when(
      data: (subtasks) {
        if (subtasks.isEmpty) return _AddSubtaskRow(parentTaskId: task.id);

        final completed = subtasks.where((t) => t.isCompleted).length;
        final progress = subtasks.isNotEmpty ? completed / subtasks.length : 0.0;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist_rounded, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                const SizedBox(width: 10),
                Text('Subtasks', style: AppTextStyles.titleSmall.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
                const SizedBox(width: 10),
                Text('$completed/${subtasks.length}', style: AppTextStyles.labelMedium.copyWith(color: completed == subtasks.length ? AppColors.success : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight), fontWeight: FontWeight.w600)),
                const Spacer(),
                SizedBox(
                  width: 60,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: progress, backgroundColor: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight, valueColor: AlwaysStoppedAnimation(completed == subtasks.length ? AppColors.success : AppColors.primary), minHeight: 6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...subtasks.map((subtask) => _SubtaskItem(subtask: subtask, onToggle: () { HapticFeedback.lightImpact(); ref.read(taskActionsProvider.notifier).toggleComplete(subtask.id); })),
            const SizedBox(height: 8),
            _AddSubtaskRow(parentTaskId: task.id),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _SubtaskItem extends StatelessWidget {
  final Task subtask;
  final VoidCallback onToggle;

  const _SubtaskItem({required this.subtask, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: subtask.isCompleted ? AppColors.success.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: subtask.isCompleted ? AppColors.success : (isDark ? AppColors.borderDark : AppColors.borderLight), width: 1.5),
              ),
              child: subtask.isCompleted ? const Icon(Icons.check_rounded, size: 16, color: AppColors.success) : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(subtask.title, style: AppTextStyles.bodyMedium.copyWith(color: subtask.isCompleted ? (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight) : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight), decoration: subtask.isCompleted ? TextDecoration.lineThrough : null)),
          ),
        ],
      ),
    );
  }
}

class _AddSubtaskRow extends ConsumerStatefulWidget {
  final int parentTaskId;

  const _AddSubtaskRow({required this.parentTaskId});

  @override
  ConsumerState<_AddSubtaskRow> createState() => _AddSubtaskRowState();
}

class _AddSubtaskRowState extends ConsumerState<_AddSubtaskRow> {
  bool _isAdding = false;
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  Future<void> _addSubtask() async {
    final title = _controller.text.trim();
    if (title.isEmpty) { setState(() => _isAdding = false); return; }
    HapticFeedback.lightImpact();
    await ref.read(taskActionsProvider.notifier).createTask(title: title, parentTaskId: widget.parentTaskId);
    _controller.clear();
    setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isAdding) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(width: 24, height: 24, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight, width: 1.5))),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                autofocus: true,
                style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                decoration: InputDecoration(
                  hintText: 'Add subtask...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                ),
                onSubmitted: (_) => _addSubtask(),
              ),
            ),
            IconButton(onPressed: _addSubtask, icon: const Icon(Icons.check_rounded), color: AppColors.primary, iconSize: 20),
            IconButton(onPressed: () { _controller.clear(); setState(() => _isAdding = false); }, icon: const Icon(Icons.close_rounded), color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, iconSize: 20),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); setState(() => _isAdding = true); },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [const Icon(Icons.add_rounded, size: 20, color: AppColors.primary), const SizedBox(width: 10), Text('Add subtask', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500))]),
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  final bool isDeleting;
  final VoidCallback onDelete;

  const _DangerZone({required this.isDeleting, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDeleting ? null : onDelete,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.error.withValues(alpha: 0.2))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isDeleting) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
            else const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
            const SizedBox(width: 10),
            Text(isDeleting ? 'Deleting...' : 'Delete task', style: AppTextStyles.labelLarge.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  final String taskTitle;

  const _DeleteConfirmDialog({required this.taskTitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 24)),
          const SizedBox(width: 14),
          Text('Delete task?', style: AppTextStyles.titleLarge.copyWith(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)),
        ],
      ),
      content: Text('This will permanently delete "$taskTitle". This action cannot be undone.', style: AppTextStyles.bodyMedium.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight))),
        FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Delete')),
      ],
    );
  }
}
