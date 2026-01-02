// lib/shared/widgets/feedback/empty_state.dart
// Empty state illustrations and messages

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../buttons/app_button.dart';

/// Empty state variants
enum EmptyStateType {
  inbox,
  today,
  tasks,
  notes,
  projects,
  search,
  folder,
  tags,
  generic,
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final EmptyStateType type;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;
  final bool compact;

  const EmptyState({
    super.key,
    required this.type,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final config = _getConfig(type);
    final effectiveTitle = title ?? config.title;
    final effectiveSubtitle = subtitle ?? config.subtitle;
    final effectiveIcon = icon ?? config.icon;

    final iconColor = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariant;
    final titleColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurface;
    final subtitleColor = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariant;

    if (compact) {
      return _buildCompact(
        context,
        effectiveTitle,
        effectiveSubtitle,
        effectiveIcon,
        iconColor,
        titleColor,
        subtitleColor,
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                effectiveIcon,
                size: 48,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              effectiveTitle,
              style: AppTextStyles.headlineSmall.copyWith(color: titleColor),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            // Subtitle
            Text(
              effectiveSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(color: subtitleColor),
              textAlign: TextAlign.center,
            ),

            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                leadingIcon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color titleColor,
    Color subtitleColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: AppTextStyles.titleSmall.copyWith(color: titleColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: subtitleColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  _EmptyStateConfig _getConfig(EmptyStateType type) {
    return switch (type) {
      EmptyStateType.inbox => const _EmptyStateConfig(
        title: 'Inbox Zero!',
        subtitle: 'All caught up. Add a new task or enjoy the moment.',
        icon: Icons.inbox_outlined,
      ),
      EmptyStateType.today => const _EmptyStateConfig(
        title: 'Nothing due today',
        subtitle: 'Your schedule is clear. Plan ahead or take a break.',
        icon: Icons.today_outlined,
      ),
      EmptyStateType.tasks => const _EmptyStateConfig(
        title: 'No tasks yet',
        subtitle: 'Create your first task to get started.',
        icon: Icons.task_outlined,
      ),
      EmptyStateType.notes => const _EmptyStateConfig(
        title: 'No notes yet',
        subtitle: 'Start capturing your thoughts and ideas.',
        icon: Icons.note_outlined,
      ),
      EmptyStateType.projects => const _EmptyStateConfig(
        title: 'No projects',
        subtitle: 'Create a project to organize your tasks.',
        icon: Icons.folder_outlined,
      ),
      EmptyStateType.search => const _EmptyStateConfig(
        title: 'No results found',
        subtitle: 'Try a different search term or create something new.',
        icon: Icons.search_off_outlined,
      ),
      EmptyStateType.folder => const _EmptyStateConfig(
        title: 'Folder is empty',
        subtitle: 'Add notes to this folder or create new ones.',
        icon: Icons.folder_open_outlined,
      ),
      EmptyStateType.tags => const _EmptyStateConfig(
        title: 'No tags yet',
        subtitle: 'Tags help you organize and find items quickly.',
        icon: Icons.label_outline,
      ),
      EmptyStateType.generic => const _EmptyStateConfig(
        title: 'Nothing here',
        subtitle: 'This space is waiting for your content.',
        icon: Icons.inbox_outlined,
      ),
    };
  }
}

class _EmptyStateConfig {
  final String title;
  final String subtitle;
  final IconData icon;

  const _EmptyStateConfig({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

/// Empty search results
class EmptySearchResults extends StatelessWidget {
  final String query;
  final VoidCallback? onClear;

  const EmptySearchResults({super.key, required this.query, this.onClear});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      type: EmptyStateType.search,
      subtitle: 'No results for "$query"',
      actionLabel: onClear != null ? 'Clear search' : null,
      onAction: onClear,
    );
  }
}

/// Loading state placeholder
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              message!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state
class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;

  const ErrorState({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: AppTextStyles.headlineSmall.copyWith(
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: 'Try again',
                onPressed: onRetry,
                leadingIcon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
