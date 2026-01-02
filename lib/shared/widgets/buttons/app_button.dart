// lib/shared/widgets/buttons/app_button.dart
// Primary button component with variants and states

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';

/// Button variants
enum AppButtonVariant {
  primary, // Filled with primary color
  secondary, // Outlined
  ghost, // Text only
  danger, // Red for destructive actions
}

/// Button sizes
enum AppButtonSize {
  small, // 36px height
  medium, // 44px height (default)
  large, // 52px height
}

/// Reusable button component
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;
  final bool hapticFeedback;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on variant
    final (bgColor, fgColor, borderColor) = _getColors(isDark);

    // Determine size
    final (height, horizontalPadding, textStyle) = _getSize(theme);

    // Build button content
    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(fgColor),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (leadingIcon != null) ...[
          Icon(leadingIcon, size: 18, color: fgColor),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(label, style: textStyle.copyWith(color: fgColor)),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(trailingIcon, size: 18, color: fgColor),
        ],
      ],
    );

    // Wrap with appropriate button widget
    Widget button;

    switch (variant) {
      case AppButtonVariant.primary:
        button = FilledButton(
          onPressed: isLoading ? null : _handlePress,
          style: FilledButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          ),
          child: content,
        );

      case AppButtonVariant.secondary:
        button = OutlinedButton(
          onPressed: isLoading ? null : _handlePress,
          style: OutlinedButton.styleFrom(
            foregroundColor: fgColor,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            side: BorderSide(color: borderColor, width: 1.5),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          ),
          child: content,
        );

      case AppButtonVariant.ghost:
        button = TextButton(
          onPressed: isLoading ? null : _handlePress,
          style: TextButton.styleFrom(
            foregroundColor: fgColor,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          ),
          child: content,
        );

      case AppButtonVariant.danger:
        button = FilledButton(
          onPressed: isLoading ? null : _handlePress,
          style: FilledButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: fgColor,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          ),
          child: content,
        );
    }

    return button;
  }

  void _handlePress() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onPressed?.call();
  }

  (Color, Color, Color) _getColors(bool isDark) {
    return switch (variant) {
      AppButtonVariant.primary => (
        AppColors.primary,
        Colors.white,
        AppColors.primary,
      ),
      AppButtonVariant.secondary => (
        Colors.transparent,
        isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
        isDark ? AppColors.outlineDark : AppColors.outline,
      ),
      AppButtonVariant.ghost => (
        Colors.transparent,
        AppColors.primary,
        Colors.transparent,
      ),
      AppButtonVariant.danger => (
        AppColors.error,
        Colors.white,
        AppColors.error,
      ),
    };
  }

  (double, double, TextStyle) _getSize(ThemeData theme) {
    return switch (size) {
      AppButtonSize.small => (36.0, AppSpacing.md, AppTextStyles.labelMedium),
      AppButtonSize.medium => (44.0, AppSpacing.lg, AppTextStyles.labelLarge),
      AppButtonSize.large => (
        52.0,
        AppSpacing.xl,
        AppTextStyles.labelLarge.copyWith(fontSize: 16),
      ),
    };
  }
}

/// Icon button with consistent styling
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final bool hapticFeedback;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size = 24,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveColor =
        color ??
        (isDark ? AppColors.onSurfaceVariantDark : AppColors.onSurfaceVariant);

    Widget button = IconButton(
      onPressed: onPressed != null ? _handlePress : null,
      icon: Icon(icon, size: size, color: effectiveColor),
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(message: tooltip!, child: button);
    }

    return button;
  }

  void _handlePress() {
    if (hapticFeedback) {
      HapticFeedback.lightImpact();
    }
    onPressed?.call();
  }
}

/// Floating action button variant
class AppFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool extended;
  final String? label;
  final bool mini;

  const AppFab({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.extended = false,
    this.label,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: () {
          HapticFeedback.mediumImpact();
          onPressed?.call();
        },
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
      );
    }

    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed?.call();
      },
      tooltip: tooltip,
      mini: mini,
      child: Icon(icon),
    );
  }
}
