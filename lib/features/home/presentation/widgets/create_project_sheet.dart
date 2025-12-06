// lib/features/home/presentation/widgets/create_project_sheet.dart
// World-class, ADHD-friendly project creation sheet

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../tasks/presentation/providers/project_providers.dart';

/// Project icon data with name mapping for storage
class ProjectIconData {
  final IconData icon;
  final String name;

  const ProjectIconData(this.icon, this.name);
}

/// Available project icons with their storage names
const List<ProjectIconData> projectIconOptions = [
  ProjectIconData(Icons.folder_rounded, 'folder'),
  ProjectIconData(Icons.work_rounded, 'work'),
  ProjectIconData(Icons.school_rounded, 'school'),
  ProjectIconData(Icons.home_rounded, 'home'),
  ProjectIconData(Icons.favorite_rounded, 'heart'),
  ProjectIconData(Icons.fitness_center_rounded, 'fitness'),
  ProjectIconData(Icons.shopping_bag_rounded, 'shopping'),
  ProjectIconData(Icons.flight_rounded, 'travel'),
  ProjectIconData(Icons.code_rounded, 'code'),
  ProjectIconData(Icons.brush_rounded, 'art'),
  ProjectIconData(Icons.music_note_rounded, 'music'),
  ProjectIconData(Icons.restaurant_rounded, 'food'),
];

/// Create Project Sheet - ADHD-optimized design
/// - Auto-focus on name field for immediate input
/// - Visual color picker (no dropdowns)
/// - Large touch targets
/// - Minimal required fields
/// - Instant feedback
class CreateProjectSheet extends ConsumerStatefulWidget {
  const CreateProjectSheet({super.key});

  /// Show the create project sheet
  static Future<bool?> show(BuildContext context) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateProjectSheet(),
    );
  }

  @override
  ConsumerState<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends ConsumerState<CreateProjectSheet> {
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();

  int _selectedColorIndex = 0;
  int _selectedIconIndex = 0;
  bool _isFavorite = false;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus for ADHD - immediate action
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _createProject() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isCreating = true);
    HapticFeedback.mediumImpact();

    final project = await ref.read(projectActionsProvider.notifier).createProject(
      name: name,
      colorIndex: _selectedColorIndex,
      iconName: projectIconOptions[_selectedIconIndex].name,
      isFavorite: _isFavorite,
    );

    if (mounted) {
      if (project != null) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop(true);
      } else {
        setState(() => _isCreating = false);
        HapticFeedback.heavyImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final selectedColor = AppColors.getProjectColor(_selectedColorIndex);

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.borderDark
                  : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with preview
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Row(
              children: [
                // Project icon preview - animated
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: selectedColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    projectIconOptions[_selectedIconIndex].icon,
                    color: selectedColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Project',
                        style: AppTextStyles.headlineSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Organize your tasks',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Favorite toggle
                _FavoriteButton(
                  isFavorite: _isFavorite,
                  onToggle: () {
                    HapticFeedback.lightImpact();
                    setState(() => _isFavorite = !_isFavorite);
                  },
                ),
              ],
            ),
          ),

          // Name input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              textCapitalization: TextCapitalization.sentences,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Project name',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: selectedColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) => _createProject(),
            ),
          ),

          const SizedBox(height: 20),

          // Color picker section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                _ColorPicker(
                  selectedIndex: _selectedColorIndex,
                  onSelect: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedColorIndex = index);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Icon picker section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Icon',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                _IconPicker(
                  selectedIndex: _selectedIconIndex,
                  selectedColor: selectedColor,
                  onSelect: (index) {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedIconIndex = index);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Create button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: _isCreating ? null : _createProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: selectedColor.withValues(alpha: 0.5),
                    elevation: 0,
                    shadowColor: selectedColor.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isCreating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Create Project',
                          style: AppTextStyles.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Favorite toggle button
class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onToggle;

  const _FavoriteButton({
    required this.isFavorite,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isFavorite
              ? AppColors.tertiary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: isFavorite
              ? AppColors.tertiary
              : Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
          size: 24,
        ),
      ),
    );
  }
}

/// Color picker - large touch targets for ADHD
class _ColorPicker extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const _ColorPicker({
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: AppColors.projectPalette.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final color = AppColors.projectPalette[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// Icon picker - visual grid selection
class _IconPicker extends StatelessWidget {
  final int selectedIndex;
  final Color selectedColor;
  final ValueChanged<int> onSelect;

  const _IconPicker({
    required this.selectedIndex,
    required this.selectedColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(projectIconOptions.length, (index) {
        final isSelected = index == selectedIndex;

        return GestureDetector(
          onTap: () => onSelect(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedColor.withValues(alpha: 0.15)
                  : isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? selectedColor
                    : isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Icon(
              projectIconOptions[index].icon,
              color: isSelected
                  ? selectedColor
                  : isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
              size: 22,
            ),
          ),
        );
      }),
    );
  }
}
