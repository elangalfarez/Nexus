// lib/features/tasks/presentation/widgets/priority_picker_sheet.dart
// Priority selection bottom sheet

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';

/// Priority picker bottom sheet
class PriorityPickerSheet extends StatelessWidget {
  final int selectedPriority;
  final ValueChanged<int> onPrioritySelected;

  const PriorityPickerSheet({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  /// Show the priority picker sheet
  static Future<void> show(
    BuildContext context, {
    required int selectedPriority,
    required ValueChanged<int> onPrioritySelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PriorityPickerSheet(
        selectedPriority: selectedPriority,
        onPrioritySelected: onPrioritySelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  'Priority',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Priority options
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                _PriorityOption(
                  priority: 1,
                  label: 'Urgent',
                  description: 'Do it now',
                  color: AppColors.priorityUrgent,
                  icon: Icons.priority_high,
                  isSelected: selectedPriority == 1,
                  onTap: () => _selectPriority(context, 1),
                ),
                _PriorityOption(
                  priority: 2,
                  label: 'High',
                  description: 'Important',
                  color: AppColors.priorityHigh,
                  icon: Icons.keyboard_arrow_up,
                  isSelected: selectedPriority == 2,
                  onTap: () => _selectPriority(context, 2),
                ),
                _PriorityOption(
                  priority: 3,
                  label: 'Medium',
                  description: 'Normal',
                  color: AppColors.priorityMedium,
                  icon: Icons.remove,
                  isSelected: selectedPriority == 3,
                  onTap: () => _selectPriority(context, 3),
                ),
                _PriorityOption(
                  priority: 4,
                  label: 'Low',
                  description: 'When you have time',
                  color: AppColors.priorityLow,
                  icon: Icons.keyboard_arrow_down,
                  isSelected: selectedPriority == 4,
                  onTap: () => _selectPriority(context, 4),
                ),
                _PriorityOption(
                  priority: 5,
                  label: 'None',
                  description: 'No priority',
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                  icon: Icons.block,
                  isSelected: selectedPriority == 5,
                  onTap: () => _selectPriority(context, 5),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _selectPriority(BuildContext context, int priority) {
    HapticFeedback.lightImpact();
    onPrioritySelected(priority);
    Navigator.of(context).pop();
  }
}

/// Priority option row
class _PriorityOption extends StatelessWidget {
  final int priority;
  final String label;
  final String description;
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.priority,
    required this.label,
    required this.description,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
      borderRadius: AppRadius.allSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allSm,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Priority indicator
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(isSelected ? 0.2 : 0.12),
                  borderRadius: AppRadius.allSm,
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              SizedBox(width: AppSpacing.sm),

              // Labels
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              // Check indicator
              if (isSelected) Icon(Icons.check, size: 20, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Priority badge widget (for displaying in lists)
class PriorityBadge extends StatelessWidget {
  final int priority;
  final bool showLabel;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showLabel = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (priority >= 5) return const SizedBox.shrink();

    final color = AppColors.getPriorityColor(priority);
    final icon = _getIcon(priority);
    final label = _getLabel(priority);

    if (compact) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: AppRadius.allXs,
        ),
        child: Icon(icon, size: 14, color: color),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? AppSpacing.sm : AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: AppRadius.allSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          if (showLabel) ...[
            SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getIcon(int p) => switch (p) {
    1 => Icons.priority_high,
    2 => Icons.keyboard_arrow_up,
    3 => Icons.remove,
    4 => Icons.keyboard_arrow_down,
    _ => Icons.remove,
  };

  String _getLabel(int p) => switch (p) {
    1 => 'Urgent',
    2 => 'High',
    3 => 'Medium',
    4 => 'Low',
    _ => 'None',
  };
}
