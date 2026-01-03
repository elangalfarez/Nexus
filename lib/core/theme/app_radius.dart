// lib/core/theme/app_radius.dart
// Border radius constants - Consistent corner styling

import 'package:flutter/material.dart';

/// Algan Design System - Border Radius Scale
///
/// RULE: Never use magic numbers like BorderRadius.circular(12).
/// Always use AppRadius.md, AppRadius.lg, etc.
abstract final class AppRadius {
  // ═══════════════════════════════════════════════════════════════════════════
  // RADIUS VALUES (raw doubles)
  // ═══════════════════════════════════════════════════════════════════════════

  /// 0px - No radius (sharp corners)
  static const double none = 0.0;

  /// 2px - Very subtle rounding
  static const double xxs = 2.0;

  /// 4px - Minimal rounding
  static const double xs = 4.0;

  /// 6px - Small elements (tags, badges)
  static const double sm = 6.0;

  /// 8px - Default radius (inputs, small cards)
  static const double md = 8.0;

  /// 12px - Medium radius (cards, modals)
  static const double lg = 12.0;

  /// 16px - Large radius (sheets, dialogs)
  static const double xl = 16.0;

  /// 20px - Extra large radius
  static const double xxl = 20.0;

  /// 24px - Very large radius
  static const double xxxl = 24.0;

  /// 9999px - Fully circular (pills, avatars)
  static const double full = 9999.0;

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS - All corners
  // ═══════════════════════════════════════════════════════════════════════════

  /// No radius
  static const BorderRadius roundedNone = BorderRadius.zero;

  /// XXS radius - 2px all corners
  static const BorderRadius roundedXxs = BorderRadius.all(Radius.circular(xxs));

  /// XS radius - 4px all corners
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(xs));

  /// SM radius - 6px all corners
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));

  /// MD radius - 8px all corners
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));

  /// LG radius - 12px all corners
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));

  /// XL radius - 16px all corners
  static const BorderRadius roundedXl = BorderRadius.all(Radius.circular(xl));

  /// XXL radius - 20px all corners
  static const BorderRadius roundedXxl = BorderRadius.all(Radius.circular(xxl));

  /// XXXL radius - 24px all corners
  static const BorderRadius roundedXxxl = BorderRadius.all(
    Radius.circular(xxxl),
  );

  /// Full circular radius
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(full),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS - Top only (for sheets, modals)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Top corners only - LG radius (12px)
  static const BorderRadius topLg = BorderRadius.vertical(
    top: Radius.circular(lg),
  );

  /// Top corners only - XL radius (16px)
  static const BorderRadius topXl = BorderRadius.vertical(
    top: Radius.circular(xl),
  );

  /// Top corners only - XXL radius (20px)
  static const BorderRadius topXxl = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// Top corners only - XXXL radius (24px)
  static const BorderRadius topXxxl = BorderRadius.vertical(
    top: Radius.circular(xxxl),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BORDER RADIUS - Bottom only
  // ═══════════════════════════════════════════════════════════════════════════

  /// Bottom corners only - LG radius (12px)
  static const BorderRadius bottomLg = BorderRadius.vertical(
    bottom: Radius.circular(lg),
  );

  /// Bottom corners only - XL radius (16px)
  static const BorderRadius bottomXl = BorderRadius.vertical(
    bottom: Radius.circular(xl),
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON UI PATTERNS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Card radius - 12px
  static const BorderRadius card = roundedLg;

  /// Input field radius - 8px
  static const BorderRadius input = roundedMd;

  /// Button radius - 8px
  static const BorderRadius button = roundedMd;

  /// Button pill radius - full
  static const BorderRadius buttonPill = roundedFull;

  /// Chip/Tag radius - 6px
  static const BorderRadius chip = roundedSm;

  /// Chip pill radius - full
  static const BorderRadius chipPill = roundedFull;

  /// Bottom sheet radius - 24px top
  static const BorderRadius bottomSheet = topXxxl;

  /// Modal/Dialog radius - 16px
  static const BorderRadius dialog = roundedXl;

  /// Image radius - 8px
  static const BorderRadius image = roundedMd;

  /// Avatar radius - full circle
  static const BorderRadius avatar = roundedFull;

  /// FAB radius - full circle
  static const BorderRadius fab = roundedFull;

  /// Menu/Dropdown radius - 12px
  static const BorderRadius menu = roundedLg;

  /// Toast/Snackbar radius - 8px
  static const BorderRadius toast = roundedMd;

  // ═══════════════════════════════════════════════════════════════════════════
  // ALIASES FOR CONVENIENCE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Alias for roundedXxs
  static const BorderRadius allXxs = roundedXxs;

  /// Alias for roundedXs
  static const BorderRadius allXs = roundedXs;

  /// Alias for roundedSm
  static const BorderRadius allSm = roundedSm;

  /// Alias for roundedMd
  static const BorderRadius allMd = roundedMd;

  /// Alias for roundedLg
  static const BorderRadius allLg = roundedLg;

  /// Alias for roundedXl
  static const BorderRadius allXl = roundedXl;

  /// Alias for roundedXxl
  static const BorderRadius allXxl = roundedXxl;

  /// Alias for roundedFull
  static const BorderRadius allFull = roundedFull;

  /// Alias for bottomSheet
  static const BorderRadius bottomSheetRadius = bottomSheet;

  /// Alias for card
  static const BorderRadius cardRadius = card;

  /// Alias for button
  static const BorderRadius buttonRadius = button;

  /// Alias for chip
  static const BorderRadius chipRadius = chip;

  /// Alias for input
  static const BorderRadius inputRadius = input;

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER - Get Radius object
  // ═══════════════════════════════════════════════════════════════════════════

  static Radius circular(double radius) => Radius.circular(radius);
}
