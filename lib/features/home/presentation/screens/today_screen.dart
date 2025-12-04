// lib/features/home/presentation/screens/today_screen.dart
// Today view with overdue and due today tasks

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/task_list_item.dart';
import '../widgets/quick_capture_sheet.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final overdueAsync = ref.watch(overdueTasksProvider);
    final todayAsync = ref.watch(todayTasksProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar
          _TodayAppBar(),

          // Content
          SliverPadding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  _DateHeader(),

                  // Overdue section
                  overdueAsync.when(
                    data: (overdueTasks) {
                      if (overdueTasks.isEmpty) return const SizedBox.shrink();
                      return _TaskSection(
                        title: 'Overdue',
                        tasks: overdueTasks,
                        titleColor: AppColors.error,
                        icon: Icons.warning_amber_rounded,
                      );
                    },
                    loading: () => _LoadingSection(),
                    error: (e, _) => _ErrorSection(message: e.toString()),
                  ),

                  // Today section
                  todayAsync.when(
                    data: (todayTasks) {
                      if (todayTasks.isEmpty &&
                          overdueAsync.valueOrNull?.isEmpty == true) {
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xl),
                          child: EmptyState(
                            type: EmptyStateType.today,
                            actionLabel: 'Add task',
                            onAction: () => QuickCaptureSheet.show(context),
                          ),
                        );
                      }

                      if (todayTasks.isEmpty) {
                        return _EmptyTodaySection();
                      }

                      return _TaskSection(
                        title: 'Today',
                        tasks: todayTasks,
                        icon: Icons.today,
                      );
                    },
                    loading: () => _LoadingSection(),
                    error: (e, _) => _ErrorSection(message: e.toString()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Today app bar with greeting
class _TodayAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final greeting = _getGreeting();

    return SliverAppBar(
      floating: true,
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      title: Text(
        greeting,
        style: AppTextStyles.headlineMedium.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Navigate to search
          },
          icon: Icon(
            Icons.search,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Navigate to settings
          },
          icon: Icon(
            Icons.settings_outlined,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
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
}

/// Date header showing today's date
class _DateHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final dayName = dayNames[now.weekday - 1];
    final monthName = monthNames[now.month - 1];
    final dateString = '$dayName, $monthName ${now.day}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Text(
        dateString,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

/// Task section with header and list
class _TaskSection extends ConsumerWidget {
  final String title;
  final List<Task> tasks;
  final Color? titleColor;
  final IconData? icon;

  const _TaskSection({
    required this.title,
    required this.tasks,
    this.titleColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveTitleColor =
        titleColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: effectiveTitleColor),
                const SizedBox(width: AppSpacing.xs),
              ],
              Text(
                title,
                style: AppTextStyles.titleSmall.copyWith(
                  color: effectiveTitleColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: effectiveTitleColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text(
                  '${tasks.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: effectiveTitleColor,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Task list
        ...tasks.map(
          (task) => TaskListItem(
            task: task,
            onTap: () {
              // TODO: Navigate to task detail
            },
            onCompleteChanged: (completed) {
              ref.read(taskActionsProvider.notifier).toggleComplete(task.id);
            },
            showProject: true,
            showDueDate: false, // Already in today view
          ),
        ),
      ],
    );
  }
}

/// Empty today section
class _EmptyTodaySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 48,
            color: AppColors.success.withValues(alpha: 0.6),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'All caught up for today!',
            style: AppTextStyles.titleSmall.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
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
    );
  }
}

/// Loading section placeholder
class _LoadingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
          strokeWidth: 2,
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Text(
          'Error: $message',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
        ),
      ),
    );
  }
}
