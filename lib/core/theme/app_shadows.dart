// lib/core/theme/app_shadows.dart
// Shadow/elevation constants - Consistent depth and elevation

import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Nexus Design System - Shadow/Elevation Scale
///
/// RULE: Never hardcode BoxShadow values in widgets.
/// Always use AppShadows.sm, AppShadows.lg, etc.
abstract final class AppShadows {
  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT MODE SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  /// No shadow
  static const List<BoxShadow> none = [];

  /// XS elevation - Subtle lift
  static const List<BoxShadow> xs = [
    BoxShadow(color: Color(0x08000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// SM elevation - Cards
  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x05000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  /// MD elevation - Elevated cards
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  /// LG elevation - Modals
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 3)),
  ];

  /// XL elevation - Dialogs
  static const List<BoxShadow> xl = [
    BoxShadow(color: Color(0x19000000), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  /// XXL elevation - FAB
  static const List<BoxShadow> xxl = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 32, offset: Offset(0, 16)),
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 6)),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // DARK MODE SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static const List<BoxShadow> xsDark = [
    BoxShadow(color: Color(0x33000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> smDark = [
    BoxShadow(color: Color(0x40000000), blurRadius: 4, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 2, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> mdDark = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 8, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x26000000), blurRadius: 4, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> lgDark = [
    BoxShadow(color: Color(0x59000000), blurRadius: 16, offset: Offset(0, 8)),
    BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3)),
  ];

  static const List<BoxShadow> xlDark = [
    BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 4)),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORED SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> primarySm = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> primaryMd = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> successSm = [
    BoxShadow(
      color: AppColors.success.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> errorSm = [
    BoxShadow(
      color: AppColors.error.withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // INNER SHADOWS
  // ═══════════════════════════════════════════════════════════════════════════

  static const List<BoxShadow> innerSm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON UI PATTERNS
  // ═══════════════════════════════════════════════════════════════════════════

  static const List<BoxShadow> card = sm;
  static const List<BoxShadow> cardElevated = md;
  static const List<BoxShadow> button = xs;
  static const List<BoxShadow> fab = lg;
  static const List<BoxShadow> dropdown = md;
  static const List<BoxShadow> modal = xl;
  static const List<BoxShadow> bottomSheet = xl;
  static const List<BoxShadow> toast = md;

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  static List<BoxShadow> getElevation(int level, {bool isDark = false}) {
    if (isDark) {
      return switch (level) {
        0 => none,
        1 => xsDark,
        2 => smDark,
        3 => mdDark,
        4 => lgDark,
        5 => xlDark,
        _ => smDark,
      };
    }
    return switch (level) {
      0 => none,
      1 => xs,
      2 => sm,
      3 => md,
      4 => lg,
      5 => xl,
      _ => sm,
    };
  }
}
