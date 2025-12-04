// lib/shared/widgets/layout/app_card.dart
// Card container components

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Base card component
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool selected;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBgColor =
        backgroundColor ?? (isDark ? AppColors.surfaceDark : AppColors.surface);

    final effectiveBorderColor = selected
        ? AppColors.primary
        : (borderColor ?? (isDark ? AppColors.outlineDark : AppColors.outline));

    Widget content = Container(
      padding: padding ?? AppSpacing.card,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: borderRadius ?? AppRadius.cardRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: selected ? 2 : 1,
        ),
        boxShadow: elevation != null && elevation! > 0
            ? (isDark ? AppShadows.smDark : AppShadows.sm)
            : null,
      ),
      child: child,
    );

    if (onTap != null || onLongPress != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: borderRadius ?? AppRadius.cardRadius,
          child: content,
        ),
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}

/// Elevated card with shadow
class ElevatedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const ElevatedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDark
                ? AppColors.surfaceElevatedDark
                : AppColors.surfaceElevated),
        borderRadius: AppRadius.cardRadius,
        boxShadow: isDark ? AppShadows.mdDark : AppShadows.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.cardRadius,
          child: Padding(padding: padding ?? AppSpacing.card, child: child),
        ),
      ),
    );
  }
}

/// Glass morphism card
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassDark : AppColors.glassLight,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.cardRadius,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.cardRadius,
            child: Padding(padding: padding ?? AppSpacing.card, child: child),
          ),
        ),
      ),
    );
  }
}

/// Section card with header
class SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onHeaderTap;
  final EdgeInsetsGeometry? contentPadding;

  const SectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.onHeaderTap,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.lg),
              topRight: Radius.circular(AppRadius.lg),
            ),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.titleMedium.copyWith(
                            color: isDark
                                ? AppColors.onSurfaceDark
                                : AppColors.onSurface,
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
                  if (trailing != null) trailing!,
                ],
              ),
            ),
          ),

          // Divider
          Divider(
            height: 1,
            color: isDark ? AppColors.outlineDark : AppColors.outline,
          ),

          // Content
          Padding(
            padding: contentPadding ?? EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Stat card for dashboard
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveColor = color ?? AppColors.primary;

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.12),
                    borderRadius: AppRadius.allSm,
                  ),
                  child: Icon(icon, size: 20, color: effectiveColor),
                ),
                SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.stat.copyWith(
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
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
    );
  }
}
