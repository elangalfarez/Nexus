// lib/features/tasks/presentation/widgets/project_list_item.dart
// Project list and grid item widgets

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/project_model.dart';

/// Project list item widget
class ProjectListItem extends StatelessWidget {
  final Project project;
  final int taskCount;
  final int completedCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool showProgress;

  const ProjectListItem({
    super.key,
    required this.project,
    this.taskCount = 0,
    this.completedCount = 0,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final projectColor = AppColors.getProjectColor(project.colorIndex);
    final titleColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurface;
    final subtitleColor = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariant;
    final bgColor = selected
        ? AppColors.primary.withOpacity(0.08)
        : Colors.transparent;

    final pendingCount = taskCount - completedCount;
    final progress = taskCount > 0 ? completedCount / taskCount : 0.0;

    return Material(
      color: bgColor,
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
            children: [
              // Color indicator and icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: projectColor.withOpacity(0.15),
                  borderRadius: AppRadius.allSm,
                ),
                child: Icon(
                  _getIcon(project.iconName),
                  size: 20,
                  color: projectColor,
                ),
              ),

              SizedBox(width: AppSpacing.sm),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: titleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (project.isFavorite)
                          Padding(
                            padding: EdgeInsets.only(left: AppSpacing.xs),
                            child: Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.tertiary,
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: AppSpacing.xxs),

                    // Task count
                    Text(
                      pendingCount == 0
                          ? 'No pending tasks'
                          : '$pendingCount task${pendingCount != 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: subtitleColor,
                      ),
                    ),

                    // Progress bar
                    if (showProgress && taskCount > 0) ...[
                      SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: AppRadius.allFull,
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(projectColor),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Chevron
              Icon(Icons.chevron_right, size: 20, color: subtitleColor),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    return switch (iconName) {
      'inbox' => Icons.inbox,
      'folder' => Icons.folder_outlined,
      'work' => Icons.work_outlined,
      'home' => Icons.home_outlined,
      'star' => Icons.star_outline,
      'heart' => Icons.favorite_outline,
      'school' => Icons.school_outlined,
      'fitness' => Icons.fitness_center_outlined,
      'shopping' => Icons.shopping_cart_outlined,
      'travel' => Icons.flight_outlined,
      'finance' => Icons.account_balance_outlined,
      'health' => Icons.local_hospital_outlined,
      _ => Icons.folder_outlined,
    };
  }
}

/// Project grid card widget
class ProjectGridCard extends StatelessWidget {
  final Project project;
  final int taskCount;
  final int completedCount;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  const ProjectGridCard({
    super.key,
    required this.project,
    this.taskCount = 0,
    this.completedCount = 0,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final projectColor = AppColors.getProjectColor(project.colorIndex);
    final titleColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurface;
    final subtitleColor = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariant;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = selected
        ? AppColors.primary
        : (isDark ? AppColors.outlineDark : AppColors.outline);

    final pendingCount = taskCount - completedCount;
    final progress = taskCount > 0 ? completedCount / taskCount : 0.0;

    return Material(
      color: bgColor,
      borderRadius: AppRadius.cardRadius,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress?.call();
        },
        borderRadius: AppRadius.cardRadius,
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardRadius,
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: projectColor.withOpacity(0.15),
                      borderRadius: AppRadius.allSm,
                    ),
                    child: Icon(
                      _getIcon(project.iconName),
                      size: 18,
                      color: projectColor,
                    ),
                  ),
                  const Spacer(),
                  if (project.isFavorite)
                    Icon(Icons.star, size: 16, color: AppColors.tertiary),
                ],
              ),

              SizedBox(height: AppSpacing.sm),

              // Title
              Text(
                project.name,
                style: AppTextStyles.titleSmall.copyWith(color: titleColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // Footer
              Row(
                children: [
                  Text(
                    '$pendingCount',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: titleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xxs),
                  Text(
                    'tasks',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                ],
              ),

              SizedBox(height: AppSpacing.sm),

              // Progress bar
              ClipRRect(
                borderRadius: AppRadius.allFull,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: isDark
                      ? AppColors.surfaceVariantDark
                      : AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation(projectColor),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    return switch (iconName) {
      'inbox' => Icons.inbox,
      'folder' => Icons.folder_outlined,
      'work' => Icons.work_outlined,
      'home' => Icons.home_outlined,
      'star' => Icons.star_outline,
      'heart' => Icons.favorite_outline,
      'school' => Icons.school_outlined,
      'fitness' => Icons.fitness_center_outlined,
      'shopping' => Icons.shopping_cart_outlined,
      'travel' => Icons.flight_outlined,
      'finance' => Icons.account_balance_outlined,
      'health' => Icons.local_hospital_outlined,
      _ => Icons.folder_outlined,
    };
  }
}

/// Section header widget
class SectionHeader extends StatelessWidget {
  final String title;
  final int? taskCount;
  final bool isCollapsed;
  final VoidCallback? onToggle;
  final VoidCallback? onAddTask;

  const SectionHeader({
    super.key,
    required this.title,
    this.taskCount,
    this.isCollapsed = false,
    this.onToggle,
    this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurface;
    final subtitleColor = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariant;

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            // Collapse indicator
            AnimatedRotation(
              turns: isCollapsed ? -0.25 : 0,
              duration: AppConstants.animMicro,
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: subtitleColor,
              ),
            ),

            SizedBox(width: AppSpacing.xs),

            // Title
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.labelLarge.copyWith(color: titleColor),
              ),
            ),

            // Task count
            if (taskCount != null) ...[
              Text(
                '$taskCount',
                style: AppTextStyles.labelMedium.copyWith(color: subtitleColor),
              ),
              SizedBox(width: AppSpacing.sm),
            ],

            // Add button
            if (onAddTask != null)
              IconButton(
                onPressed: onAddTask,
                icon: Icon(Icons.add, size: 20, color: subtitleColor),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
