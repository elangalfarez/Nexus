// lib/shared/widgets/feedback/loading_skeletons.dart
// Skeleton loading placeholders for all content types

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../animations/animated_widgets.dart';

/// Base skeleton box
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ShimmerEffect(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariant,
          borderRadius: borderRadius ?? AppRadius.allSm,
        ),
      ),
    );
  }
}

/// Skeleton circle
class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ShimmerEffect(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariant,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Skeleton line (text placeholder)
class SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const SkeletonLine({super.key, required this.width, this.height = 12});

  /// Full width line
  const SkeletonLine.full({super.key, this.height = 12})
    : width = double.infinity;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width,
      height: height,
      borderRadius: AppRadius.allXs,
    );
  }
}

/// Task list item skeleton
class TaskItemSkeleton extends StatelessWidget {
  const TaskItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Checkbox
          SkeletonCircle(size: 24),
          SizedBox(width: AppSpacing.sm),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 200, height: 14),
                SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    SkeletonBox(width: 60, height: 20),
                    SizedBox(width: AppSpacing.xs),
                    SkeletonBox(width: 80, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Task list skeleton (multiple items)
class TaskListSkeleton extends StatelessWidget {
  final int itemCount;

  const TaskListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const TaskItemSkeleton(),
    );
  }
}

/// Note card skeleton
class NoteCardSkeleton extends StatelessWidget {
  final bool isGrid;

  const NoteCardSkeleton({super.key, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isGrid) {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: AppRadius.allMd,
          border: Border.all(
            color: isDark ? AppColors.outlineDark : AppColors.outline,
            width: 0.5,
          ),
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonLine(width: 120, height: 16),
            SizedBox(height: AppSpacing.sm),
            SkeletonLine.full(height: 10),
            SizedBox(height: AppSpacing.xxs),
            SkeletonLine.full(height: 10),
            SizedBox(height: AppSpacing.xxs),
            SkeletonLine(width: 80, height: 10),
            const Spacer(),
            Row(
              children: [
                SkeletonBox(width: 50, height: 16),
                const Spacer(),
                SkeletonCircle(size: 16),
              ],
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 180, height: 16),
                SizedBox(height: AppSpacing.xs),
                SkeletonLine.full(height: 12),
                SizedBox(height: AppSpacing.xxs),
                SkeletonLine(width: 140, height: 12),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    SkeletonBox(width: 60, height: 16),
                    SizedBox(width: AppSpacing.sm),
                    SkeletonBox(width: 40, height: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Note list skeleton
class NoteListSkeleton extends StatelessWidget {
  final int itemCount;
  final bool isGrid;

  const NoteListSkeleton({super.key, this.itemCount = 4, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.md),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 0.85,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) => const NoteCardSkeleton(isGrid: true),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const NoteCardSkeleton(),
    );
  }
}

/// Project list item skeleton
class ProjectItemSkeleton extends StatelessWidget {
  const ProjectItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Icon
          SkeletonBox(width: 40, height: 40),
          SizedBox(width: AppSpacing.sm),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 140, height: 14),
                SizedBox(height: AppSpacing.xs),
                SkeletonLine(width: 60, height: 10),
              ],
            ),
          ),

          // Progress
          SkeletonBox(width: 100, height: 6),
        ],
      ),
    );
  }
}

/// Project list skeleton
class ProjectListSkeleton extends StatelessWidget {
  final int itemCount;

  const ProjectListSkeleton({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const ProjectItemSkeleton(),
    );
  }
}

/// Search result skeleton
class SearchResultSkeleton extends StatelessWidget {
  final int itemCount;

  const SearchResultSkeleton({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Alternate between task and note skeletons
        if (index % 2 == 0) {
          return const TaskItemSkeleton();
        }
        return const NoteCardSkeleton();
      },
    );
  }
}

/// Full screen loading skeleton
class FullScreenSkeleton extends StatelessWidget {
  final SkeletonType type;

  const FullScreenSkeleton({super.key, this.type = SkeletonType.tasks});

  @override
  Widget build(BuildContext context) {
    return switch (type) {
      SkeletonType.tasks => const TaskListSkeleton(itemCount: 8),
      SkeletonType.notes => const NoteListSkeleton(itemCount: 6),
      SkeletonType.notesGrid => const NoteListSkeleton(
        itemCount: 6,
        isGrid: true,
      ),
      SkeletonType.projects => const ProjectListSkeleton(itemCount: 5),
      SkeletonType.search => const SearchResultSkeleton(itemCount: 6),
    };
  }
}

enum SkeletonType { tasks, notes, notesGrid, projects, search }

/// Statistics card skeleton
class StatsCardSkeleton extends StatelessWidget {
  const StatsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) => _StatItemSkeleton()),
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (index) => _StatItemSkeleton()),
          ),
        ],
      ),
    );
  }
}

class _StatItemSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SkeletonCircle(size: 20),
        SizedBox(height: AppSpacing.xs),
        SkeletonBox(width: 40, height: 20),
        SizedBox(height: AppSpacing.xxs),
        SkeletonBox(width: 50, height: 10),
      ],
    );
  }
}

/// Profile/settings skeleton
class SettingsSkeleton extends StatelessWidget {
  const SettingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Section header
        SkeletonLine(width: 80, height: 12),
        SizedBox(height: AppSpacing.sm),

        // Settings card
        _SettingsCardSkeleton(),

        SizedBox(height: AppSpacing.lg),

        // Section header
        SkeletonLine(width: 60, height: 12),
        SizedBox(height: AppSpacing.sm),

        // Settings card
        _SettingsCardSkeleton(itemCount: 3),
      ],
    );
  }
}

class _SettingsCardSkeleton extends StatelessWidget {
  final int itemCount;

  const _SettingsCardSkeleton({this.itemCount = 2});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.allMd,
        border: Border.all(
          color: isDark ? AppColors.outlineDark : AppColors.outline,
          width: 0.5,
        ),
      ),
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                SkeletonCircle(size: 24),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLine(width: 120, height: 14),
                      SizedBox(height: AppSpacing.xxs),
                      SkeletonLine(width: 180, height: 10),
                    ],
                  ),
                ),
                SkeletonBox(
                  width: 48,
                  height: 28,
                  borderRadius: AppRadius.allFull,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
