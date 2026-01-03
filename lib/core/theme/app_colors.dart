// lib/core/theme/app_colors.dart
// Semantic color tokens - THE ONLY FILE where hex values are allowed

import 'package:flutter/material.dart';

/// Algan Design System - Color Tokens
///
/// CRITICAL RULE: This is the ONLY file where hex values (Color(0xFF...)) are allowed.
/// All UI code must reference these semantic tokens, never raw hex values.
///
/// Usage in widgets: AppColors.primary, AppColors.surface
/// Theme-aware: context.colorScheme.primary
abstract final class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // BRAND COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Primary brand color - Deep indigo
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryContainer = Color(0xFFE0E7FF);
  static const Color primaryContainerDark = Color(0xFF312E81);

  /// Secondary brand color - Violet
  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFA78BFA);
  static const Color secondaryDark = Color(0xFF7C3AED);
  static const Color secondaryContainer = Color(0xFFEDE9FE);
  static const Color secondaryContainerDark = Color(0xFF4C1D95);

  /// Tertiary accent - Teal (for notes, success states)
  static const Color tertiary = Color(0xFF14B8A6);
  static const Color tertiaryLight = Color(0xFF2DD4BF);
  static const Color tertiaryDark = Color(0xFF0D9488);
  static const Color tertiaryContainer = Color(0xFFCCFBF1);
  static const Color tertiaryContainerDark = Color(0xFF134E4A);

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE - SURFACES & BACKGROUNDS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color surfaceTintLight = Color(0xFFE0E7FF);

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK MODE - SURFACES & BACKGROUNDS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceElevatedDark = Color(0xFF273449);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color surfaceTintDark = Color(0xFF312E81);

  // ═══════════════════════════════════════════════════════════════════════════
  // TEXT COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  // Light mode text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  // Dark mode text
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);

  // On-color text (text on primary/secondary surfaces)
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF3730A3);
  static const Color onPrimaryContainerDark = Color(0xFFE0E7FF);

  // ═══════════════════════════════════════════════════════════════════════════
  // SEMANTIC COLORS - STATUS & FEEDBACK
  // ═══════════════════════════════════════════════════════════════════════════

  // Success
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFF4ADE80);
  static const Color successDark = Color(0xFF16A34A);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color successContainerDark = Color(0xFF14532D);
  static const Color onSuccessContainer = Color(0xFF166534);
  static const Color onSuccessContainerDark = Color(0xFFDCFCE7);

  // Warning
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color warningContainerDark = Color(0xFF78350F);
  static const Color onWarningContainer = Color(0xFF92400E);
  static const Color onWarningContainerDark = Color(0xFFFEF3C7);

  // Error
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color errorContainerDark = Color(0xFF7F1D1D);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF991B1B);
  static const Color onErrorContainerDark = Color(0xFFFEE2E2);

  // Info
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoContainer = Color(0xFFDBEAFE);
  static const Color infoContainerDark = Color(0xFF1E3A8A);
  static const Color onInfoContainer = Color(0xFF1E40AF);
  static const Color onInfoContainerDark = Color(0xFFDBEAFE);

  // ═══════════════════════════════════════════════════════════════════════════
  // TASK PRIORITY COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Priority 1 - Urgent (Red)
  static const Color priorityP1 = Color(0xFFEF4444);
  static const Color priorityP1Surface = Color(0xFFFEE2E2);
  static const Color priorityP1SurfaceDark = Color(0xFF450A0A);

  /// Priority 2 - High (Orange)
  static const Color priorityP2 = Color(0xFFF97316);
  static const Color priorityP2Surface = Color(0xFFFFEDD5);
  static const Color priorityP2SurfaceDark = Color(0xFF431407);

  /// Priority 3 - Medium (Blue)
  static const Color priorityP3 = Color(0xFF3B82F6);
  static const Color priorityP3Surface = Color(0xFFDBEAFE);
  static const Color priorityP3SurfaceDark = Color(0xFF172554);

  /// Priority 4 - Low (Gray)
  static const Color priorityP4 = Color(0xFF94A3B8);
  static const Color priorityP4Surface = Color(0xFFF1F5F9);
  static const Color priorityP4SurfaceDark = Color(0xFF334155);

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER & DIVIDER COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderSubtleLight = Color(0xFFF1F5F9);
  static const Color borderDark = Color(0xFF334155);
  static const Color borderSubtleDark = Color(0xFF1E293B);

  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  // ═══════════════════════════════════════════════════════════════════════════
  // INTERACTIVE STATES
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color hoverLight = Color(0x0A000000);
  static const Color hoverDark = Color(0x0AFFFFFF);
  static const Color pressedLight = Color(0x14000000);
  static const Color pressedDark = Color(0x14FFFFFF);
  static const Color focusRing = Color(0xFF6366F1);
  static const Color rippleLight = Color(0x1A6366F1);
  static const Color rippleDark = Color(0x1A818CF8);

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL COLORS
  // ═══════════════════════════════════════════════════════════════════════════

  static const Color scrim = Color(0x52000000);
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Glassmorphism
  static const Color glassLight = Color(0xCCFFFFFF);
  static const Color glassDark = Color(0xCC1E293B);

  // Inverse (for tooltips, snackbars)
  static const Color inverseSurfaceLight = Color(0xFF1E293B);
  static const Color inverseSurfaceDark = Color(0xFFF1F5F9);
  static const Color onInverseSurfaceLight = Color(0xFFF1F5F9);
  static const Color onInverseSurfaceDark = Color(0xFF1E293B);
  static const Color inversePrimaryLight = Color(0xFFA5B4FC);
  static const Color inversePrimaryDark = Color(0xFF4F46E5);

  // ═══════════════════════════════════════════════════════════════════════════
  // PROJECT & TAG PALETTES
  // ═══════════════════════════════════════════════════════════════════════════

  static const List<Color> projectPalette = [
    Color(0xFF6366F1), // Indigo (default)
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF84CC16), // Lime
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Violet
    Color(0xFFA855F7), // Purple
    Color(0xFFEC4899), // Pink
  ];

  static const List<Color> tagPalette = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFF59E0B), // Amber
    Color(0xFF84CC16), // Lime
    Color(0xFF22C55E), // Green
    Color(0xFF14B8A6), // Teal
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
    Color(0xFF64748B), // Slate
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // ALIASES FOR CONVENIENCE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Alias for backgroundLight
  static const Color background = backgroundLight;

  /// Alias for surfaceLight
  static const Color surface = surfaceLight;

  /// Alias for surfaceVariantLight
  static const Color surfaceVariant = surfaceVariantLight;

  /// Alias for textPrimaryLight
  static const Color onSurface = textPrimaryLight;

  /// Alias for textPrimaryDark
  static const Color onSurfaceDark = textPrimaryDark;

  /// Alias for textSecondaryLight
  static const Color onSurfaceVariant = textSecondaryLight;

  /// Alias for textSecondaryDark
  static const Color onSurfaceVariantDark = textSecondaryDark;

  /// Alias for textDisabledLight
  static const Color onSurfaceDisabled = textDisabledLight;

  /// Alias for textDisabledDark
  static const Color onSurfaceDisabledDark = textDisabledDark;

  /// Alias for borderLight
  static const Color outline = borderLight;

  /// Alias for borderDark
  static const Color outlineDark = borderDark;

  /// Alias for priorityP1
  static const Color priorityUrgent = priorityP1;

  /// Alias for priorityP2
  static const Color priorityHigh = priorityP2;

  /// Alias for priorityP3
  static const Color priorityMedium = priorityP3;

  /// Alias for priorityP4
  static const Color priorityLow = priorityP4;

  /// Alias for surfaceElevatedLight
  static const Color surfaceElevated = surfaceElevatedLight;

  /// Alias for surfaceVariantLight (for input backgrounds)
  static const Color surfaceInput = surfaceVariantLight;

  /// Alias for surfaceVariantDark (for input backgrounds)
  static const Color surfaceInputDark = surfaceVariantDark;

  /// Shimmer base color for light mode
  static const Color shimmerBase = surfaceVariantLight;

  /// Shimmer base color for dark mode
  static const Color shimmerBaseDark = surfaceVariantDark;

  /// Shimmer highlight color for light mode
  static const Color shimmerHighlight = surfaceLight;

  /// Shimmer highlight color for dark mode
  static const Color shimmerHighlightDark = surfaceElevatedDark;

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Get priority color by level (1 = urgent, 4 = low)
  static Color getPriorityColor(int priority) {
    return switch (priority) {
      1 => priorityP1,
      2 => priorityP2,
      3 => priorityP3,
      4 => priorityP4,
      _ => priorityP4,
    };
  }

  /// Get priority surface color by level
  static Color getPrioritySurface(int priority, {bool isDark = false}) {
    if (isDark) {
      return switch (priority) {
        1 => priorityP1SurfaceDark,
        2 => priorityP2SurfaceDark,
        3 => priorityP3SurfaceDark,
        4 => priorityP4SurfaceDark,
        _ => priorityP4SurfaceDark,
      };
    }
    return switch (priority) {
      1 => priorityP1Surface,
      2 => priorityP2Surface,
      3 => priorityP3Surface,
      4 => priorityP4Surface,
      _ => priorityP4Surface,
    };
  }

  /// Get project color by index
  static Color getProjectColor(int index) {
    return projectPalette[index % projectPalette.length];
  }

  /// Get tag color by index
  static Color getTagColor(int index) {
    return tagPalette[index % tagPalette.length];
  }
}
