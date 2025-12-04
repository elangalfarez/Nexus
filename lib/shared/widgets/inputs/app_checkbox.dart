// lib/shared/widgets/inputs/app_checkbox.dart
// Checkbox and toggle components

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';

/// Custom checkbox with animation
class AppCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? checkColor;
  final double size;
  final bool circular;
  final bool hapticFeedback;

  const AppCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.checkColor,
    this.size = 24,
    this.circular = false,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveActiveColor = activeColor ?? AppColors.primary;
    final effectiveCheckColor = checkColor ?? Colors.white;
    final borderColor = isDark ? AppColors.outlineDark : AppColors.outline;

    return GestureDetector(
      onTap: () {
        if (hapticFeedback) {
          HapticFeedback.lightImpact();
        }
        onChanged?.call(!value);
      },
      child: AnimatedContainer(
        duration: AppConstants.animMicro,
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: value ? effectiveActiveColor : Colors.transparent,
          borderRadius: circular
              ? BorderRadius.circular(size / 2)
              : AppRadius.allXs,
          border: Border.all(
            color: value ? effectiveActiveColor : borderColor,
            width: 2,
          ),
        ),
        child: AnimatedOpacity(
          duration: AppConstants.animMicro,
          opacity: value ? 1 : 0,
          child: Icon(
            Icons.check,
            size: size * 0.65,
            color: effectiveCheckColor,
          ),
        ),
      ),
    );
  }
}

/// Task completion checkbox with strikethrough animation
class TaskCheckbox extends StatelessWidget {
  final bool isCompleted;
  final int priority;
  final ValueChanged<bool>? onChanged;

  const TaskCheckbox({
    super.key,
    required this.isCompleted,
    this.priority = 4,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Get priority color
    final priorityColor = AppColors.getPriorityColor(priority);
    final borderColor = isCompleted
        ? (isDark
              ? AppColors.onSurfaceDisabledDark
              : AppColors.onSurfaceDisabled)
        : priorityColor;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onChanged?.call(!isCompleted);
      },
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        curve: Curves.easeOutBack,
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: isCompleted
              ? borderColor.withOpacity(0.3)
              : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: isCompleted ? 0 : 2),
        ),
        child: AnimatedScale(
          duration: AppConstants.animMicro,
          scale: isCompleted ? 1 : 0,
          child: Icon(
            Icons.check,
            size: 14,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Custom switch/toggle
class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final bool enabled;

  const AppSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? AppColors.primary;

    return Switch(
      value: value,
      onChanged: enabled
          ? (newValue) {
              HapticFeedback.lightImpact();
              onChanged?.call(newValue);
            }
          : null,
      activeColor: effectiveActiveColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Checkbox with label
class AppCheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? subtitle;
  final bool enabled;

  const AppCheckboxTile({
    super.key,
    required this.value,
    this.onChanged,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onChanged?.call(!value);
            }
          : null,
      borderRadius: AppRadius.allSm,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            AppCheckbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              hapticFeedback: false,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: enabled
                          ? (isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurface)
                          : (isDark
                                ? AppColors.onSurfaceDisabledDark
                                : AppColors.onSurfaceDisabled),
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Switch with label
class AppSwitchTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String label;
  final String? subtitle;
  final bool enabled;

  const AppSwitchTile({
    super.key,
    required this.value,
    this.onChanged,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onChanged?.call(!value);
            }
          : null,
      borderRadius: AppRadius.allSm,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: enabled
                          ? (isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurface)
                          : (isDark
                                ? AppColors.onSurfaceDisabledDark
                                : AppColors.onSurfaceDisabled),
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            AppSwitch(
              value: value,
              onChanged: enabled ? onChanged : null,
              enabled: enabled,
            ),
          ],
        ),
      ),
    );
  }
}
