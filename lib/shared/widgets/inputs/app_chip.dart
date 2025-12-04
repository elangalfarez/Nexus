// lib/shared/widgets/inputs/app_chip.dart
// Chip components for tags, filters, and labels

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';

/// Chip variants
enum AppChipVariant { filled, outlined, tonal }

/// Base chip component
class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final AppChipVariant variant;
  final Color? color;
  final bool selected;
  final bool enabled;

  const AppChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.onDelete,
    this.variant = AppChipVariant.tonal,
    this.color,
    this.selected = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveColor = color ?? AppColors.primary;

    // Determine colors based on variant and state
    Color bgColor;
    Color fgColor;
    Color? borderColor;

    if (selected) {
      bgColor = effectiveColor;
      fgColor = Colors.white;
      borderColor = effectiveColor;
    } else {
      switch (variant) {
        case AppChipVariant.filled:
          bgColor = effectiveColor;
          fgColor = Colors.white;
          borderColor = null;
        case AppChipVariant.outlined:
          bgColor = Colors.transparent;
          fgColor = isDark ? AppColors.onSurfaceDark : AppColors.onSurface;
          borderColor = isDark ? AppColors.outlineDark : AppColors.outline;
        case AppChipVariant.tonal:
          bgColor = effectiveColor.withOpacity(0.12);
          fgColor = effectiveColor;
          borderColor = null;
      }
    }

    if (!enabled) {
      bgColor = bgColor.withOpacity(0.5);
      fgColor = fgColor.withOpacity(0.5);
    }

    return Material(
      color: bgColor,
      borderRadius: AppRadius.chipRadius,
      child: InkWell(
        onTap: enabled && onTap != null
            ? () {
                HapticFeedback.lightImpact();
                onTap?.call();
              }
            : null,
        borderRadius: AppRadius.chipRadius,
        child: Container(
          padding: AppSpacing.chip,
          decoration: borderColor != null
              ? BoxDecoration(
                  borderRadius: AppRadius.chipRadius,
                  border: Border.all(color: borderColor, width: 1),
                )
              : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fgColor),
                SizedBox(width: AppSpacing.xs),
              ],
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: fgColor),
              ),
              if (onDelete != null) ...[
                SizedBox(width: AppSpacing.xs),
                GestureDetector(
                  onTap: enabled
                      ? () {
                          HapticFeedback.lightImpact();
                          onDelete?.call();
                        }
                      : null,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: fgColor.withOpacity(0.7),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Tag chip with # prefix
class TagChip extends StatelessWidget {
  final String tagName;
  final int? colorIndex;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool selected;

  const TagChip({
    super.key,
    required this.tagName,
    this.colorIndex,
    this.onTap,
    this.onDelete,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = colorIndex != null
        ? AppColors.getProjectColor(colorIndex!)
        : AppColors.primary;

    return AppChip(
      label: '#$tagName',
      color: color,
      variant: AppChipVariant.tonal,
      onTap: onTap,
      onDelete: onDelete,
      selected: selected,
    );
  }
}

/// Priority chip
class PriorityChip extends StatelessWidget {
  final int priority;
  final VoidCallback? onTap;
  final bool showLabel;

  const PriorityChip({
    super.key,
    required this.priority,
    this.onTap,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = AppColors.getPriorityColor(priority);
    final label = _getPriorityLabel(priority);
    final icon = _getPriorityIcon(priority);

    return AppChip(
      label: showLabel ? label : '',
      icon: icon,
      color: color,
      variant: AppChipVariant.tonal,
      onTap: onTap,
    );
  }

  String _getPriorityLabel(int p) => switch (p) {
    1 => 'Urgent',
    2 => 'High',
    3 => 'Medium',
    4 => 'Low',
    _ => 'None',
  };

  IconData _getPriorityIcon(int p) => switch (p) {
    1 => Icons.priority_high,
    2 => Icons.keyboard_arrow_up,
    3 => Icons.remove,
    4 => Icons.keyboard_arrow_down,
    _ => Icons.remove,
  };
}

/// Due date chip
class DueDateChip extends StatelessWidget {
  final DateTime? dueDate;
  final bool isOverdue;
  final VoidCallback? onTap;

  const DueDateChip({
    super.key,
    this.dueDate,
    this.isOverdue = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (dueDate == null) return const SizedBox.shrink();

    final color = isOverdue ? AppColors.error : AppColors.info;
    final label = _formatDate(dueDate!);

    return AppChip(
      label: label,
      icon: Icons.calendar_today,
      color: color,
      variant: AppChipVariant.tonal,
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';
    if (dateOnly.isBefore(today)) {
      final days = today.difference(dateOnly).inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    }

    // Format as "Mon 15" or "Jan 15" depending on proximity
    final daysUntil = dateOnly.difference(today).inDays;
    if (daysUntil < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

/// Project chip
class ProjectChip extends StatelessWidget {
  final String projectName;
  final int colorIndex;
  final IconData? icon;
  final VoidCallback? onTap;

  const ProjectChip({
    super.key,
    required this.projectName,
    this.colorIndex = 0,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getProjectColor(colorIndex);

    return AppChip(
      label: projectName,
      icon: icon ?? Icons.folder_outlined,
      color: color,
      variant: AppChipVariant.tonal,
      onTap: onTap,
    );
  }
}

/// Filter chip group
class FilterChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<int> selectedIndices;
  final ValueChanged<int>? onSelected;
  final bool singleSelect;

  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selectedIndices,
    this.onSelected,
    this.singleSelect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(options.length, (index) {
        return AppChip(
          label: options[index],
          variant: AppChipVariant.outlined,
          selected: selectedIndices.contains(index),
          onTap: () => onSelected?.call(index),
        );
      }),
    );
  }
}
