// lib/features/home/presentation/screens/today_screen.dart
// Today view - clean, simple, ADHD-friendly

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../tasks/data/models/project_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/task_list_item.dart';
import '../widgets/quick_capture_sheet.dart';
import '../widgets/task_detail_sheet.dart';

/// Task filter for Today screen
enum TodayFilter { all, pending, completed }

/// Current filter state
final todayFilterProvider = StateProvider<TodayFilter>((ref) => TodayFilter.all);

/// Selected date for calendar
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with greeting
          _TodayAppBar(),

          // Content
          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.xxxl),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Week Calendar Strip
                  _WeekCalendarStrip(),

                  SizedBox(height: AppSpacing.md),

                  // Progress Card
                  _ProgressCard(),

                  SizedBox(height: AppSpacing.md),

                  // Filter Tabs
                  _FilterTabs(),

                  SizedBox(height: AppSpacing.sm),

                  // Task Sections
                  _TaskSections(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Today app bar with greeting and date
class _TodayAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);

    final greeting = _getGreeting();
    final dateString = _formatDate(selectedDate);

    return SliverAppBar(
      floating: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 100,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.mdl,
            AppSpacing.xl,
            AppSpacing.mdl,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                greeting,
                style: AppTextStyles.headlineLarge.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                dateString,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => context.go('/search'),
          icon: Icon(
            Icons.search_rounded,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        IconButton(
          onPressed: () => context.go('/settings'),
          icon: Icon(
            Icons.settings_outlined,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(DateTime date) {
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June',
                        'July', 'August', 'September', 'October', 'November', 'December'];
    return '${dayNames[date.weekday - 1]}, ${monthNames[date.month - 1]} ${date.day}';
  }
}

/// Horizontal week calendar strip
class _WeekCalendarStrip extends ConsumerWidget {
  const _WeekCalendarStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();

    // Get the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdl),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedLg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: weekDays.map((date) {
          final isToday = _isSameDay(date, now);
          final isSelected = _isSameDay(date, selectedDate);

          return _DayItem(
            date: date,
            isToday: isToday,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(selectedDateProvider.notifier).state = date;
            },
          );
        }).toList(),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Individual day item in the week strip
class _DayItem extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayItem({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayLabel = dayNames[date.weekday - 1];

    final bgColor = isSelected
        ? AppColors.primary
        : (isToday ? AppColors.primary.withValues(alpha: 0.12) : Colors.transparent);

    final textColor = isSelected
        ? Colors.white
        : (isToday
            ? AppColors.primary
            : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight));

    final labelColor = isSelected
        ? Colors.white.withValues(alpha: 0.8)
        : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.roundedMd,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${date.day}',
              style: AppTextStyles.titleMedium.copyWith(
                color: textColor,
                fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Progress card - simple version
/// Only counts tasks for the SELECTED DATE, not overdue tasks
class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final isViewingToday = _isSameDay(selectedDate, now);

    // Get tasks for selected date ONLY (progress is calculated from this)
    final tasksAsync = ref.watch(tasksByDateProvider(selectedDate));

    return tasksAsync.when(
      data: (dateTasks) {
        // Progress only counts tasks for the selected date
        // Overdue tasks are shown separately but don't affect progress
        if (dateTasks.isEmpty) {
          return const SizedBox.shrink();
        }

        final completedCount = dateTasks.where((t) => t.isCompleted).length;
        final totalCount = dateTasks.length;
        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
        final percentage = (progress * 100).round();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.mdl),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.roundedLg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isViewingToday ? "Today's Progress" : "Progress",
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      '$completedCount of $totalCount tasks completed',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Progress bar
                    ClipRRect(
                      borderRadius: AppRadius.roundedFull,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: isDark
                            ? AppColors.surfaceVariantDark
                            : AppColors.surfaceVariantLight,
                        valueColor: AlwaysStoppedAnimation(
                          percentage == 100 ? AppColors.success : AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Percentage
              Text(
                '$percentage%',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: percentage == 100 ? AppColors.success : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Filter tabs for All/Pending/Completed - with subtle animation
class _FilterTabs extends ConsumerWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(todayFilterProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdl),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.roundedFull,
        ),
        child: Row(
          children: [
            Expanded(
              child: _FilterTab(
                label: 'All',
                isSelected: currentFilter == TodayFilter.all,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(todayFilterProvider.notifier).state = TodayFilter.all;
                },
              ),
            ),
            Expanded(
              child: _FilterTab(
                label: 'Pending',
                isSelected: currentFilter == TodayFilter.pending,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(todayFilterProvider.notifier).state = TodayFilter.pending;
                },
              ),
            ),
            Expanded(
              child: _FilterTab(
                label: 'Completed',
                isSelected: currentFilter == TodayFilter.completed,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(todayFilterProvider.notifier).state = TodayFilter.completed;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual filter tab with subtle animation
class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.roundedFull,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

/// Task sections - uses selected date
class _TaskSections extends ConsumerWidget {
  const _TaskSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final isViewingToday = _isSameDay(selectedDate, now);
    final filter = ref.watch(todayFilterProvider);

    // Get tasks for the selected date
    final tasksAsync = ref.watch(tasksByDateProvider(selectedDate));

    // Only show overdue when viewing today
    final overdueAsync = isViewingToday
        ? ref.watch(overdueTasksRelativeProvider(selectedDate))
        : const AsyncValue<List<Task>>.data([]);

    return tasksAsync.when(
      data: (dateTasks) {
        final overdueTasks = overdueAsync.valueOrNull ?? [];

        // Apply filter
        final filteredDateTasks = _applyFilter(dateTasks, filter);
        final filteredOverdue = _applyFilter(overdueTasks, filter);

        // Check if completely empty
        final hasNoTasks = dateTasks.isEmpty && overdueTasks.isEmpty;
        final hasNoFilteredTasks = filteredDateTasks.isEmpty && filteredOverdue.isEmpty;

        if (hasNoTasks) {
          final emptyStateContent = _getDateAwareEmptyState(selectedDate, now);
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyState(
              type: EmptyStateType.today,
              title: emptyStateContent.title,
              subtitle: emptyStateContent.subtitle,
              actionLabel: 'Add task',
              onAction: () => QuickCaptureSheet.show(
                context,
                defaultDate: selectedDate,
              ),
            ),
          );
        }

        if (hasNoFilteredTasks) {
          return _FilteredEmptyState(filter: filter);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overdue section (only when viewing today)
            if (filteredOverdue.isNotEmpty && isViewingToday)
              _TaskSection(
                title: 'Overdue',
                tasks: filteredOverdue,
                icon: Icons.schedule,
                accentColor: AppColors.error,
              ),

            // Date tasks section
            if (filteredDateTasks.isNotEmpty)
              _TaskSection(
                title: isViewingToday ? 'Today' : _formatSectionTitle(selectedDate),
                tasks: filteredDateTasks,
                icon: Icons.wb_sunny_outlined,
                accentColor: AppColors.primary,
              ),

            // Show "All caught up" only when date tasks are empty but overdue exists
            if (filteredDateTasks.isEmpty && filteredOverdue.isNotEmpty && isViewingToday)
              _AllCaughtUpBanner(),
          ],
        );
      },
      loading: () => _LoadingSection(),
      error: (e, _) => _ErrorSection(message: e.toString()),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatSectionTitle(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (_isSameDay(date, tomorrow)) return 'Tomorrow';
    if (_isSameDay(date, yesterday)) return 'Yesterday';

    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${monthNames[date.month - 1]} ${date.day}';
  }

  List<Task> _applyFilter(List<Task> tasks, TodayFilter filter) {
    return switch (filter) {
      TodayFilter.all => tasks,
      TodayFilter.pending => tasks.where((t) => !t.isCompleted).toList(),
      TodayFilter.completed => tasks.where((t) => t.isCompleted).toList(),
    };
  }

  /// Get ADHD-friendly empty state copy based on selected date
  /// - Clear and specific about which date
  /// - Not emotionally heavy or guilt-inducing
  /// - Encouraging without being patronizing
  _DateEmptyState _getDateAwareEmptyState(DateTime selectedDate, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final difference = selected.difference(today).inDays;

    // Today
    if (difference == 0) {
      return const _DateEmptyState(
        title: 'All clear for today',
        subtitle: 'Your day is open. Add a task or enjoy the space.',
      );
    }

    // Yesterday
    if (difference == -1) {
      return const _DateEmptyState(
        title: 'Nothing was due',
        subtitle: 'Yesterday was clear. No worries here.',
      );
    }

    // Past (2+ days ago)
    if (difference < -1) {
      return const _DateEmptyState(
        title: 'Nothing was scheduled',
        subtitle: 'This day was free. All good.',
      );
    }

    // Tomorrow
    if (difference == 1) {
      return const _DateEmptyState(
        title: "Tomorrow's open",
        subtitle: 'Nothing planned yet. Add tasks or keep it flexible.',
      );
    }

    // Future (2+ days ahead)
    return const _DateEmptyState(
      title: 'Day is open',
      subtitle: "Schedule ahead when you're ready.",
    );
  }
}

/// Helper class for date-aware empty state content
class _DateEmptyState {
  final String title;
  final String subtitle;

  const _DateEmptyState({
    required this.title,
    required this.subtitle,
  });
}

/// Reusable task section with ADHD-friendly project indicators
/// - Shows project color accent + name for instant visual grouping
/// - Color-coded left bar for quick project recognition at a glance
class _TaskSection extends ConsumerWidget {
  final String title;
  final List<Task> tasks;
  final IconData icon;
  final Color accentColor;

  const _TaskSection({
    required this.title,
    required this.tasks,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Watch all active projects to build a lookup map
    // This enables instant project info lookup for each task
    final projectsAsync = ref.watch(activeProjectsProvider);
    final projectMap = _buildProjectMap(projectsAsync);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.mdl,
        AppSpacing.md,
        AppSpacing.mdl,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.smd,
              AppSpacing.md,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedFull,
                  ),
                  child: Text(
                    '${tasks.length}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Task list with project info
          ...tasks.map((task) {
            // Look up project info for this task
            final project = task.projectId != null
                ? projectMap[task.projectId]
                : null;

            return TaskListItem(
              task: task,
              onTap: () => TaskDetailSheet.show(context, task),
              onCompleteChanged: (completed) {
                ref.read(taskActionsProvider.notifier).toggleComplete(task.id);
              },
              showProject: true,
              showDueDate: title == 'Overdue',
              // Pass project info for visual indicator
              projectName: project?.name,
              projectColorIndex: project?.colorIndex,
            );
          }),

          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }

  /// Build a lookup map from project ID to Project
  /// Returns empty map if projects are still loading
  Map<int, Project> _buildProjectMap(AsyncValue<List<Project>> projectsAsync) {
    return projectsAsync.when(
      data: (projects) => {for (var p in projects) p.id: p},
      loading: () => <int, Project>{},
      error: (_, __) => <int, Project>{},
    );
  }
}

/// Filtered empty state
class _FilteredEmptyState extends StatelessWidget {
  final TodayFilter filter;

  const _FilteredEmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final message = switch (filter) {
      TodayFilter.all => 'No tasks for this day',
      TodayFilter.pending => 'No pending tasks',
      TodayFilter.completed => 'No completed tasks',
    };

    final icon = switch (filter) {
      TodayFilter.all => Icons.inbox_outlined,
      TodayFilter.pending => Icons.pending_actions,
      TodayFilter.completed => Icons.task_alt,
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "All caught up" banner
class _AllCaughtUpBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.mdl),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 24,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All caught up for today!',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'No tasks scheduled for today',
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
    );
  }
}

/// Loading section
class _LoadingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 3,
        ),
      ),
    );
  }
}

/// Error section
class _ErrorSection extends StatelessWidget {
  final String message;

  const _ErrorSection({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 32,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
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
