// lib/features/home/presentation/screens/inbox_screen.dart
// Inbox view for uncategorized tasks - ADHD-friendly design

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/inputs/app_checkbox.dart';
import '../../../../shared/widgets/inputs/app_chip.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../widgets/quick_capture_sheet.dart';
import '../widgets/task_detail_sheet.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STATE PROVIDERS - Inbox specific state management
// ═══════════════════════════════════════════════════════════════════════════════

/// Controls whether completed tasks section is expanded
final inboxCompletedExpandedProvider = StateProvider<bool>((ref) => true);

/// Sort option for inbox tasks
enum InboxSortOption {
  manual('Manual', Icons.drag_indicator_rounded),
  dateAdded('Date Added', Icons.schedule_rounded),
  dueDate('Due Date', Icons.event_rounded),
  priority('Priority', Icons.flag_rounded),
  alphabetical('A-Z', Icons.sort_by_alpha_rounded);

  final String label;
  final IconData icon;
  const InboxSortOption(this.label, this.icon);
}

final inboxSortOptionProvider =
    StateProvider<InboxSortOption>((ref) => InboxSortOption.manual);

/// Sort direction
final inboxSortAscendingProvider = StateProvider<bool>((ref) => true);

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  /// Consistent horizontal padding used across the screen
  /// This aligns with the bottom navigation bar padding
  static const double _horizontalPadding = AppSpacing.mdl; // 20px

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inboxAsync = ref.watch(inboxTasksProvider);
    final sortOption = ref.watch(inboxSortOptionProvider);
    final sortAscending = ref.watch(inboxSortAscendingProvider);
    final completedExpanded = ref.watch(inboxCompletedExpandedProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with refined spacing
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 64,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: Row(
                children: [
                  // Inbox icon with premium glassmorphic effect
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.primary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: AppRadius.roundedMd,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child:
                        const Icon(Icons.inbox_rounded, size: 22, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.smd),
                  Text(
                    'Inbox',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Sort button with active indicator
              _ActionButton(
                icon: Icons.swap_vert_rounded,
                tooltip: 'Sort',
                isActive: sortOption != InboxSortOption.manual,
                onPressed: () => _showSortSheet(context, ref),
              ),
              // More options
              _ActionButton(
                icon: Icons.more_horiz_rounded,
                tooltip: 'More options',
                onPressed: () => _showMoreOptionsSheet(context, ref),
              ),
              const SizedBox(width: _horizontalPadding - AppSpacing.sm),
            ],
          ),

          // Content
          inboxAsync.when(
            data: (tasks) {
              // Sort tasks based on current option
              final sortedTasks = _sortTasks(tasks, sortOption, sortAscending);

              // Separate completed and incomplete
              final incompleteTasks =
                  sortedTasks.where((t) => !t.isCompleted).toList();
              final completedTasks =
                  sortedTasks.where((t) => t.isCompleted).toList();

              if (incompleteTasks.isEmpty && completedTasks.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    type: EmptyStateType.inbox,
                    actionLabel: 'Add task',
                    onAction: () => QuickCaptureSheet.show(context),
                  ),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: _horizontalPadding),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats bar - ADHD-friendly progress visualization
                    if (tasks.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _InboxProgressCard(
                        total: tasks.length,
                        completed: completedTasks.length,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],

                    // Active tasks section header
                    if (incompleteTasks.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Active',
                        count: incompleteTasks.length,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],

                    // Incomplete tasks with refined cards
                    ...incompleteTasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < incompleteTasks.length - 1
                              ? AppSpacing.xs
                              : 0,
                        ),
                        child: _TaskCard(
                          task: task,
                          onTap: () => TaskDetailSheet.show(context, task),
                          onCompleteChanged: (completed) {
                            HapticFeedback.lightImpact();
                            ref
                                .read(taskActionsProvider.notifier)
                                .toggleComplete(task.id);
                          },
                        ),
                      );
                    }),

                    // Completed section with smooth collapse
                    if (completedTasks.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _CompletedSectionHeader(
                        count: completedTasks.length,
                        isExpanded: completedExpanded,
                        onToggle: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(inboxCompletedExpandedProvider.notifier)
                              .state = !completedExpanded;
                        },
                      ),
                      // Animated completed tasks
                      AnimatedCrossFade(
                        firstChild: Column(
                          children: [
                            const SizedBox(height: AppSpacing.sm),
                            ...completedTasks.asMap().entries.map((entry) {
                              final index = entry.key;
                              final task = entry.value;
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: index < completedTasks.length - 1
                                      ? AppSpacing.xs
                                      : 0,
                                ),
                                child: _TaskCard(
                                  task: task,
                                  isCompleted: true,
                                  onTap: () =>
                                      TaskDetailSheet.show(context, task),
                                  onCompleteChanged: (completed) {
                                    HapticFeedback.lightImpact();
                                    ref
                                        .read(taskActionsProvider.notifier)
                                        .toggleComplete(task.id);
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                        secondChild: const SizedBox.shrink(),
                        crossFadeState: completedExpanded
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                        duration: AppConstants.animStandard,
                        sizeCurve: Curves.easeOutCubic,
                      ),
                    ],

                    // Bottom padding for FAB clearance
                    const SizedBox(height: 120),
                  ]),
                ),
              );
            },
            loading: () => SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.xs),
                    child: _TaskCardSkeleton(),
                  ),
                  childCount: 5,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(inboxTasksProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sort tasks based on selected option
  List<Task> _sortTasks(
      List<Task> tasks, InboxSortOption option, bool ascending) {
    final sorted = List<Task>.from(tasks);

    switch (option) {
      case InboxSortOption.manual:
        sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      case InboxSortOption.dateAdded:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case InboxSortOption.dueDate:
        sorted.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case InboxSortOption.priority:
        sorted.sort((a, b) => a.priority.compareTo(b.priority));
      case InboxSortOption.alphabetical:
        sorted.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    if (!ascending && option != InboxSortOption.manual) {
      return sorted.reversed.toList();
    }
    return sorted;
  }

  /// Show sort options bottom sheet
  void _showSortSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SortOptionsSheet(ref: ref),
    );
  }

  /// Show more options bottom sheet
  void _showMoreOptionsSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MoreOptionsSheet(ref: ref),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTION BUTTON - Refined app bar action
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROGRESS CARD - ADHD-friendly visual progress
// ═══════════════════════════════════════════════════════════════════════════════

class _InboxProgressCard extends StatelessWidget {
  final int total;
  final int completed;

  const _InboxProgressCard({required this.total, required this.completed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pending = total - completed;
    final progress = total > 0 ? completed / total : 0.0;
    final isAllComplete = pending == 0 && total > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isAllComplete
              ? [
                  AppColors.success.withValues(alpha: 0.12),
                  AppColors.success.withValues(alpha: 0.06),
                ]
              : [
                  (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                  (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                ],
        ),
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: isAllComplete
              ? AppColors.success.withValues(alpha: 0.3)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Progress ring
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                CircularProgressIndicator(
                  value: 1,
                  strokeWidth: 4,
                  backgroundColor: (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight)
                      .withValues(alpha: 0.5),
                  valueColor: AlwaysStoppedAnimation(
                    (isDark ? AppColors.borderDark : AppColors.borderLight)
                        .withValues(alpha: 0.5),
                  ),
                ),
                // Progress ring
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: AppConstants.animSlow,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 4,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation(
                        isAllComplete ? AppColors.success : AppColors.primary,
                      ),
                    );
                  },
                ),
                // Percentage text
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isAllComplete
                        ? AppColors.success
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Stats
          Expanded(
            child: Row(
              children: [
                _MiniStatBadge(
                  value: pending,
                  label: 'Pending',
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.smd),
                _MiniStatBadge(
                  value: completed,
                  label: 'Done',
                  color: AppColors.success,
                ),
              ],
            ),
          ),

          // Celebration indicator when all complete
          if (isAllComplete)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 20,
                color: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStatBadge extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _MiniStatBadge({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.roundedFull,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.roundedFull,
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMPLETED SECTION HEADER - Collapsible
// ═══════════════════════════════════════════════════════════════════════════════

class _CompletedSectionHeader extends StatelessWidget {
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CompletedSectionHeader({
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onToggle,
      borderRadius: AppRadius.roundedMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            // Animated chevron
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: AppConstants.animFast,
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Completed',
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
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
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            // Visual hint that it's tappable
            Icon(
              isExpanded
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              size: 16,
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

// ═══════════════════════════════════════════════════════════════════════════════
// TASK CARD - Premium card-based task display
// ═══════════════════════════════════════════════════════════════════════════════

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompleteChanged;
  final bool isCompleted;

  const _TaskCard({
    required this.task,
    this.onTap,
    this.onCompleteChanged,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed = isCompleted || task.isCompleted;

    // Text colors
    final titleColor = completed
        ? (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AnimatedContainer(
      duration: AppConstants.animFast,
      decoration: BoxDecoration(
        color: completed
            ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                .withValues(alpha: 0.5)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.borderLight)
              .withValues(alpha: completed ? 0.3 : 0.6),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smd,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: TaskCheckbox(
                    isCompleted: completed,
                    priority: task.priority,
                    onChanged: onCompleteChanged,
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),

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
                          decoration:
                              completed ? TextDecoration.lineThrough : null,
                          decorationColor: titleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description preview
                      if (task.description != null &&
                          task.description!.isNotEmpty &&
                          !completed) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          task.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Metadata row (due date, priority)
                      if (!completed && _hasMetadata) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _buildMetadataRow(context),
                      ],
                    ],
                  ),
                ),

                // Linked notes indicator
                if (task.linkedNoteIds.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.link_rounded, size: 16, color: subtitleColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasMetadata {
    return task.dueDate != null || task.priority < 4;
  }

  Widget _buildMetadataRow(BuildContext context) {
    final chips = <Widget>[];

    // Due date
    if (task.dueDate != null) {
      chips.add(DueDateChip(dueDate: task.dueDate, isOverdue: task.isOverdue));
    }

    // Priority (only show if high)
    if (task.priority < 3) {
      chips.add(PriorityChip(priority: task.priority, showLabel: false));
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TASK CARD SKELETON - Loading state
// ═══════════════════════════════════════════════════════════════════════════════

class _TaskCardSkeleton extends StatelessWidget {
  const _TaskCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: AppRadius.roundedXs,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 10,
                  width: 100,
                  decoration: BoxDecoration(
                    color: shimmerBase.withValues(alpha: 0.6),
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

// ═══════════════════════════════════════════════════════════════════════════════
// SORT OPTIONS SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _SortOptionsSheet extends StatelessWidget {
  final WidgetRef ref;

  const _SortOptionsSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSort = ref.watch(inboxSortOptionProvider);
    final sortAscending = ref.watch(inboxSortAscendingProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.smd),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.swap_vert_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.smd),
                Text(
                  'Sort Tasks',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sort options
          ...InboxSortOption.values.map((option) {
            final isSelected = currentSort == option;
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Icon(
                  option.icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
              title: Text(
                option.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.primary,
                      size: 20,
                    )
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(inboxSortOptionProvider.notifier).state = option;
              },
            );
          }),

          // Sort direction toggle (if not manual)
          if (currentSort != InboxSortOption.manual) ...[
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Icon(
                  sortAscending
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                sortAscending ? 'Ascending' : 'Descending',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              trailing: Switch.adaptive(
                value: sortAscending,
                onChanged: (value) {
                  HapticFeedback.selectionClick();
                  ref.read(inboxSortAscendingProvider.notifier).state = value;
                },
                activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                activeThumbColor: AppColors.primary,
              ),
            ),
          ],

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MORE OPTIONS SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _MoreOptionsSheet extends StatelessWidget {
  final WidgetRef ref;

  const _MoreOptionsSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedExpanded = ref.watch(inboxCompletedExpandedProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.smd),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.smd),
                Text(
                  'More Options',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Toggle completed visibility
          _OptionTile(
            icon: completedExpanded
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            title: completedExpanded ? 'Hide Completed' : 'Show Completed',
            subtitle: 'Toggle completed tasks visibility',
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(inboxCompletedExpandedProvider.notifier).state =
                  !completedExpanded;
              Navigator.pop(context);
            },
          ),

          // Clear completed
          _OptionTile(
            icon: Icons.cleaning_services_rounded,
            title: 'Clear Completed',
            subtitle: 'Remove all completed tasks',
            onTap: () {
              HapticFeedback.mediumImpact();
              _showClearCompletedDialog(context, ref);
            },
            color: AppColors.warning,
          ),

          // Select all (future feature hint)
          _OptionTile(
            icon: Icons.select_all_rounded,
            title: 'Select Multiple',
            subtitle: 'Bulk edit tasks',
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Multi-select coming soon!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context, WidgetRef ref) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedLg),
          title: Text(
            'Clear Completed Tasks?',
            style: AppTextStyles.titleLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          content: Text(
            'This will permanently delete all completed tasks in your inbox. This action cannot be undone.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final tasks =
                    await ref.read(inboxTasksProvider.future);
                final completedTasks =
                    tasks.where((t) => t.isCompleted).toList();
                for (final task in completedTasks) {
                  await ref
                      .read(taskActionsProvider.notifier)
                      .deleteTask(task.id);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('Cleared ${completedTasks.length} completed tasks'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ??
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: AppRadius.roundedSm,
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color:
              isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textTertiaryDark
              : AppColors.textTertiaryLight,
        ),
      ),
      onTap: onTap,
    );
  }
}
