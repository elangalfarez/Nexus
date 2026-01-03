// lib/features/home/presentation/screens/projects_screen.dart
// Projects list with grid/list toggle - ADHD-friendly design

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../tasks/data/models/project_model.dart';
import '../../../tasks/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/widgets/project_list_item.dart';
import '../widgets/create_project_sheet.dart';
import '../widgets/project_detail_sheet.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STATE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════

/// View mode for projects
final projectsViewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  /// Consistent horizontal padding - aligns with bottom navigation
  static const double _horizontalPadding = AppSpacing.mdl; // 20px

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final projectsAsync = ref.watch(activeProjectsProvider);
    final viewMode = ref.watch(projectsViewModeProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // Premium App Bar with consistent styling
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 64,
            titleSpacing: 0,
            title: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              child: Row(
                children: [
                  // Projects icon with premium glassmorphic effect
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.15),
                          AppColors.secondary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: AppRadius.roundedMd,
                      border: Border.all(
                        color: AppColors.secondary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.folder_copy_rounded,
                      size: 22,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.smd),
                  Text(
                    'Projects',
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
              // View toggle button with active indicator
              _ActionButton(
                icon: viewMode == ViewMode.list
                    ? Icons.grid_view_rounded
                    : Icons.view_list_rounded,
                tooltip: viewMode == ViewMode.list ? 'Grid view' : 'List view',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  final current = ref.read(projectsViewModeProvider);
                  ref.read(projectsViewModeProvider.notifier).state =
                      current == ViewMode.list ? ViewMode.grid : ViewMode.list;
                },
              ),
              // Add project button
              _ActionButton(
                icon: Icons.add_rounded,
                tooltip: 'New project',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  CreateProjectSheet.show(context);
                },
              ),
              const SizedBox(width: _horizontalPadding - AppSpacing.sm),
            ],
          ),

          // Content
          projectsAsync.when(
            data: (projects) {
              if (projects.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    type: EmptyStateType.projects,
                    actionLabel: 'Create project',
                    onAction: () => CreateProjectSheet.show(context),
                  ),
                );
              }

              // Separate favorites and regular
              final favorites = projects.where((p) => p.isFavorite).toList();
              final regular =
                  projects.where((p) => !p.isFavorite && !p.isInbox).toList();
              final inbox = projects.where((p) => p.isInbox).firstOrNull;

              if (viewMode == ViewMode.grid) {
                return _ProjectsGridView(
                  inbox: inbox,
                  favorites: favorites,
                  regular: regular,
                );
              }

              return _ProjectsListView(
                inbox: inbox,
                favorites: favorites,
                regular: regular,
              );
            },
            loading: () => SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ProjectCardSkeleton(
                      isFirst: index == 0,
                      showSectionHeader: index == 0 || index == 2,
                    ),
                  ),
                  childCount: 5,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(activeProjectsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTION BUTTON - Consistent with Inbox screen
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 22,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// LIST VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _ProjectsListView extends ConsumerWidget {
  final Project? inbox;
  final List<Project> favorites;
  final List<Project> regular;

  const _ProjectsListView({
    this.inbox,
    required this.favorites,
    required this.regular,
  });

  static const double _horizontalPadding = AppSpacing.mdl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: AppSpacing.sm),

          // Inbox section
          if (inbox != null) ...[
            const _SectionHeader(
              title: 'Inbox',
              icon: Icons.inbox_rounded,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.sm),
            _ProjectCard(project: inbox!, isInbox: true),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Favorites section
          if (favorites.isNotEmpty) ...[
            _SectionHeader(
              title: 'Favorites',
              icon: Icons.star_rounded,
              color: AppColors.tertiary,
              count: favorites.length,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...favorites.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom:
                      index < favorites.length - 1 ? AppSpacing.xs : 0,
                ),
                child: _ProjectCard(project: project),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Regular projects section
          if (regular.isNotEmpty) ...[
            _SectionHeader(
              title: 'Projects',
              icon: Icons.folder_rounded,
              color: AppColors.secondary,
              count: regular.length,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...regular.asMap().entries.map((entry) {
              final index = entry.key;
              final project = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < regular.length - 1 ? AppSpacing.xs : 0,
                ),
                child: _ProjectCard(project: project),
              );
            }),
          ],

          // Bottom padding for FAB clearance
          const SizedBox(height: 120),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GRID VIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _ProjectsGridView extends ConsumerWidget {
  final Project? inbox;
  final List<Project> favorites;
  final List<Project> regular;

  const _ProjectsGridView({
    this.inbox,
    required this.favorites,
    required this.regular,
  });

  static const double _horizontalPadding = AppSpacing.mdl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allProjects = [if (inbox != null) inbox!, ...favorites, ...regular];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const SizedBox(height: AppSpacing.sm),

          // Grid of projects
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.smd,
              crossAxisSpacing: AppSpacing.smd,
              childAspectRatio: 0.95,
            ),
            itemCount: allProjects.length,
            itemBuilder: (context, index) {
              final project = allProjects[index];
              return _ProjectGridCard(project: project);
            },
          ),

          // Bottom padding for FAB clearance
          const SizedBox(height: 120),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER - Consistent with Inbox screen
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int? count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Color accent bar
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.roundedFull,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Icon
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),

        // Title
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

        // Count badge
        if (count != null) ...[
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
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROJECT CARD - Premium list item design
// ═══════════════════════════════════════════════════════════════════════════════

class _ProjectCard extends ConsumerWidget {
  final Project project;
  final bool isInbox;

  const _ProjectCard({required this.project, this.isInbox = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch tasks for this project
    final tasksAsync = project.isInbox
        ? ref.watch(inboxTasksProvider)
        : ref.watch(tasksByProjectProvider(project.id));

    final taskCount = tasksAsync.valueOrNull?.length ?? 0;
    final completedCount =
        tasksAsync.valueOrNull?.where((t) => t.isCompleted).length ?? 0;
    final pendingCount = taskCount - completedCount;
    final progress = taskCount > 0 ? completedCount / taskCount : 0.0;
    final isAllComplete = pendingCount == 0 && completedCount > 0;

    final projectColor = AppColors.getProjectColor(project.colorIndex);

    return AnimatedContainer(
      duration: AppConstants.animFast,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isAllComplete
              ? AppColors.success.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ProjectDetailSheet.show(context, project);
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            ProjectDetailSheet.show(context, project);
          },
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Project icon
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: projectColor.withValues(alpha: 0.15),
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: Icon(
                        getProjectIcon(project.iconName),
                        size: 22,
                        color: projectColor,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smd),

                    // Title and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  project.name,
                                  style: AppTextStyles.titleMedium.copyWith(
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (project.isFavorite) ...[
                                const SizedBox(width: AppSpacing.xs),
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: AppColors.tertiary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xxs),

                          // Status text - ADHD-friendly
                          Text(
                            _getStatusText(
                                taskCount, completedCount, pendingCount),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isAllComplete
                                  ? AppColors.success
                                  : (isDark
                                      ? AppColors.textTertiaryDark
                                      : AppColors.textTertiaryLight),
                              fontWeight:
                                  isAllComplete ? FontWeight.w500 : null,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Chevron
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: isDark
                          ? AppColors.textDisabledDark
                          : AppColors.textDisabledLight,
                    ),
                  ],
                ),

                // Progress bar
                if (taskCount > 0) ...[
                  const SizedBox(height: AppSpacing.smd),
                  ClipRRect(
                    borderRadius: AppRadius.roundedFull,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: AppConstants.animSlow,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          backgroundColor: (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight)
                              .withValues(alpha: 0.5),
                          valueColor: AlwaysStoppedAnimation(
                            isAllComplete ? AppColors.success : projectColor,
                          ),
                          minHeight: 4,
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusText(int taskCount, int completedCount, int pendingCount) {
    if (taskCount == 0) return 'No tasks yet';
    if (pendingCount == 0 && completedCount > 0) return 'All done!';
    if (completedCount > 0) return '$completedCount done · $pendingCount to go';
    return '$pendingCount tasks';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROJECT GRID CARD - Premium grid item design
// ═══════════════════════════════════════════════════════════════════════════════

class _ProjectGridCard extends ConsumerWidget {
  final Project project;

  const _ProjectGridCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Watch tasks for this project
    final tasksAsync = project.isInbox
        ? ref.watch(inboxTasksProvider)
        : ref.watch(tasksByProjectProvider(project.id));

    final taskCount = tasksAsync.valueOrNull?.length ?? 0;
    final completedCount =
        tasksAsync.valueOrNull?.where((t) => t.isCompleted).length ?? 0;
    final pendingCount = taskCount - completedCount;
    final progress = taskCount > 0 ? completedCount / taskCount : 0.0;
    final isAllComplete = pendingCount == 0 && completedCount > 0;

    final projectColor = AppColors.getProjectColor(project.colorIndex);

    return AnimatedContainer(
      duration: AppConstants.animFast,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: isAllComplete
              ? AppColors.success.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.roundedLg,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            ProjectDetailSheet.show(context, project);
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            ProjectDetailSheet.show(context, project);
          },
          borderRadius: AppRadius.roundedLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Project icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: projectColor.withValues(alpha: 0.15),
                        borderRadius: AppRadius.roundedMd,
                      ),
                      child: Icon(
                        getProjectIcon(project.iconName),
                        size: 20,
                        color: projectColor,
                      ),
                    ),
                    const Spacer(),
                    if (project.isFavorite)
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.tertiary,
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.smd),

                // Title
                Text(
                  project.name,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Progress info - ADHD-friendly format
                _buildProgressInfo(
                  context,
                  taskCount,
                  completedCount,
                  pendingCount,
                  isAllComplete,
                ),

                const SizedBox(height: AppSpacing.sm),

                // Progress bar
                ClipRRect(
                  borderRadius: AppRadius.roundedFull,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: progress),
                    duration: AppConstants.animSlow,
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor:
                            (isDark ? AppColors.borderDark : AppColors.borderLight)
                                .withValues(alpha: 0.5),
                        valueColor: AlwaysStoppedAnimation(
                          isAllComplete ? AppColors.success : projectColor,
                        ),
                        minHeight: 4,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressInfo(
    BuildContext context,
    int taskCount,
    int completedCount,
    int pendingCount,
    bool isAllComplete,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (taskCount == 0) {
      return Text(
        'No tasks yet',
        style: AppTextStyles.bodySmall.copyWith(
          color:
              isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
      );
    }

    if (isAllComplete) {
      return Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            'All done!',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    // Progress fraction with visual hierarchy
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$completedCount/$taskCount',
          style: AppTextStyles.titleLarge.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'done',
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROJECT CARD SKELETON - Loading state
// ═══════════════════════════════════════════════════════════════════════════════

class _ProjectCardSkeleton extends StatelessWidget {
  final bool isFirst;
  final bool showSectionHeader;

  const _ProjectCardSkeleton({
    this.isFirst = false,
    this.showSectionHeader = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header skeleton
        if (showSectionHeader) ...[
          if (!isFirst) const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  color: shimmerBase,
                  borderRadius: AppRadius.roundedFull,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                height: 14,
                width: 80,
                decoration: BoxDecoration(
                  color: shimmerBase,
                  borderRadius: AppRadius.roundedXs,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.smd),
        ],

        // Card skeleton
        Container(
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
              // Icon placeholder
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: shimmerBase,
                  borderRadius: AppRadius.roundedMd,
                ),
              ),
              const SizedBox(width: AppSpacing.smd),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: shimmerBase,
                        borderRadius: AppRadius.roundedXs,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: shimmerBase.withValues(alpha: 0.6),
                        borderRadius: AppRadius.roundedXs,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.smd),
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: shimmerBase.withValues(alpha: 0.4),
                        borderRadius: AppRadius.roundedFull,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Chevron placeholder
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: shimmerBase.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
