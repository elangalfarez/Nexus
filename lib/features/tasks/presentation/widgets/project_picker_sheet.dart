// lib/features/tasks/presentation/widgets/project_picker_sheet.dart
// Project selection bottom sheet

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../data/models/project_model.dart';
import '../providers/project_providers.dart';

/// Project picker bottom sheet
class ProjectPickerSheet extends ConsumerStatefulWidget {
  final int? selectedProjectId;
  final ValueChanged<int> onProjectSelected;

  const ProjectPickerSheet({
    super.key,
    this.selectedProjectId,
    required this.onProjectSelected,
  });

  /// Show the project picker sheet
  static Future<void> show(
    BuildContext context, {
    int? selectedProjectId,
    required ValueChanged<int> onProjectSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => ProjectPickerSheet(
          selectedProjectId: selectedProjectId,
          onProjectSelected: onProjectSelected,
        ),
      ),
    );
  }

  @override
  ConsumerState<ProjectPickerSheet> createState() => _ProjectPickerSheetState();
}

class _ProjectPickerSheetState extends ConsumerState<ProjectPickerSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final projectsAsync = ref.watch(activeProjectsProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.onSurfaceDisabledDark
                    : AppColors.onSurfaceDisabled,
                borderRadius: AppRadius.allFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  'Move to project',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // TODO: Navigate to create project
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New'),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppSearchField(
              controller: _searchController,
              hint: 'Search projects...',
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Project list
          Expanded(
            child: projectsAsync.when(
              data: (projects) {
                // Filter projects
                final filteredProjects = _searchQuery.isEmpty
                    ? projects
                    : projects
                          .where(
                            (p) => p.name.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                if (filteredProjects.isEmpty) {
                  return Center(
                    child: Text(
                      'No projects found',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                // Group by favorites
                final inbox = filteredProjects.where((p) => p.isInbox).toList();
                final favorites = filteredProjects
                    .where((p) => p.isFavorite && !p.isInbox)
                    .toList();
                final regular = filteredProjects
                    .where((p) => !p.isFavorite && !p.isInbox)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    // Inbox
                    if (inbox.isNotEmpty)
                      ...inbox.map(
                        (p) => _ProjectOption(
                          project: p,
                          isSelected: p.id == widget.selectedProjectId,
                          onTap: () => _selectProject(p),
                        ),
                      ),

                    // Favorites
                    if (favorites.isNotEmpty) ...[
                      const _SectionLabel(label: 'Favorites'),
                      ...favorites.map(
                        (p) => _ProjectOption(
                          project: p,
                          isSelected: p.id == widget.selectedProjectId,
                          onTap: () => _selectProject(p),
                        ),
                      ),
                    ],

                    // Regular projects
                    if (regular.isNotEmpty) ...[
                      const _SectionLabel(label: 'Projects'),
                      ...regular.map(
                        (p) => _ProjectOption(
                          project: p,
                          isSelected: p.id == widget.selectedProjectId,
                          onTap: () => _selectProject(p),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.md),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error loading projects',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectProject(Project project) {
    HapticFeedback.lightImpact();
    widget.onProjectSelected(project.id);
    Navigator.of(context).pop();
  }
}

/// Section label
class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xs),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Project option row
class _ProjectOption extends StatelessWidget {
  final Project project;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProjectOption({
    required this.project,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final projectColor = AppColors.getProjectColor(project.colorIndex);

    return Material(
      color: isSelected ? projectColor.withOpacity(0.12) : Colors.transparent,
      borderRadius: AppRadius.allSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: projectColor.withOpacity(0.15),
                  borderRadius: AppRadius.allSm,
                ),
                child: Icon(
                  project.isInbox ? Icons.inbox : Icons.folder,
                  size: 18,
                  color: projectColor,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Name
              Expanded(
                child: Text(
                  project.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),

              // Favorite indicator
              if (project.isFavorite) ...[
                const Icon(Icons.star, size: 16, color: AppColors.tertiary),
                const SizedBox(width: AppSpacing.sm),
              ],

              // Selected indicator
              if (isSelected) Icon(Icons.check, size: 20, color: projectColor),
            ],
          ),
        ),
      ),
    );
  }
}
