// lib/features/home/presentation/screens/inbox_screen.dart
// Inbox view for uncategorized tasks

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/task_list_item.dart';
import '../widgets/quick_capture_sheet.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inboxAsync = ref.watch(inboxTasksProvider);

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
            title: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: AppRadius.allSm,
                  ),
                  child: Icon(Icons.inbox, size: 20, color: AppColors.primary),
                ),
                SizedBox(width: AppSpacing.sm),
                Text(
                  'Inbox',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                ),
              ],
            ),
            actions: [
              // Sort button
              IconButton(
                onPressed: () {
                  // TODO: Show sort options
                },
                icon: Icon(
                  Icons.sort,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                tooltip: 'Sort',
              ),
              // More options
              IconButton(
                onPressed: () {
                  // TODO: Show more options
                },
                icon: Icon(
                  Icons.more_vert,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
              ),
              SizedBox(width: AppSpacing.xs),
            ],
          ),

          // Content
          inboxAsync.when(
            data: (tasks) {
              // Separate completed and incomplete
              final incompleteTasks = tasks
                  .where((t) => !t.isCompleted)
                  .toList();
              final completedTasks = tasks.where((t) => t.isCompleted).toList();

              if (incompleteTasks.isEmpty && completedTasks.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    type: EmptyStateType.inbox,
                    actionLabel: 'Add task',
                    onAction: () => QuickCaptureSheet.show(context),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Stats bar
                  if (tasks.isNotEmpty)
                    _InboxStatsBar(
                      total: tasks.length,
                      completed: completedTasks.length,
                    ),

                  // Incomplete tasks
                  ...incompleteTasks.map(
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
                      showProject: false, // All inbox tasks
                    ),
                  ),

                  // Completed section
                  if (completedTasks.isNotEmpty) ...[
                    _CompletedHeader(count: completedTasks.length),
                    ...completedTasks.map(
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

                  // Bottom padding
                  SizedBox(height: AppSpacing.huge),
                ]),
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
                onRetry: () => ref.invalidate(inboxTasksProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stats bar showing task counts
class _InboxStatsBar extends StatelessWidget {
  final int total;
  final int completed;

  const _InboxStatsBar({required this.total, required this.completed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final pending = total - completed;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          _StatBadge(
            label: 'Pending',
            value: pending,
            color: AppColors.primary,
          ),
          SizedBox(width: AppSpacing.sm),
          _StatBadge(label: 'Done', value: completed, color: AppColors.success),
        ],
      ),
    );
  }
}

/// Stat badge widget
class _StatBadge extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.allSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: AppTextStyles.labelLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}

/// Completed section header
class _CompletedHeader extends StatefulWidget {
  final int count;

  const _CompletedHeader({required this.count});

  @override
  State<_CompletedHeader> createState() => _CompletedHeaderState();
}

class _CompletedHeaderState extends State<_CompletedHeader> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Padding(
        padding: EdgeInsets.symmetric(
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
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              'Completed',
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                borderRadius: AppRadius.allFull,
              ),
              child: Text(
                '${widget.count}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
