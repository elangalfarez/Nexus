// lib/core/theme/app_spacing.dart
// Spacing constants - Consistent layout spacing throughout the app

import 'package:flutter/material.dart';

/// Algan Design System - Spacing Scale
///
/// RULE: Never use magic numbers like EdgeInsets.all(16).
/// Always use AppSpacing.md, AppSpacing.lg, etc.
///
/// Base unit: 4px
/// Scale: xxs(2), xs(4), sm(8), md(16), lg(24), xl(32), xxl(48), xxxl(64)
abstract final class AppSpacing {
  // ═══════════════════════════════════════════════════════════════════════════
  // SPACING VALUES (raw doubles)
  // ═══════════════════════════════════════════════════════════════════════════

  /// 2px - Tightest spacing
  static const double xxs = 2.0;

  /// 4px - Icon padding, tight spacing
  static const double xs = 4.0;

  /// 8px - Compact elements, small gaps
  static const double sm = 8.0;

  /// 12px - Between-element spacing
  static const double smd = 12.0;

  /// 16px - Standard padding, default spacing
  static const double md = 16.0;

  /// 20px - Slightly larger than standard
  static const double mdl = 20.0;

  /// 24px - Section spacing, card padding
  static const double lg = 24.0;

  /// 32px - Screen horizontal padding
  static const double xl = 32.0;

  /// 48px - Major section gaps
  static const double xxl = 48.0;

  /// 64px - Extra large spacing
  static const double xxxl = 64.0;

  /// Alias for xxxl (64px)
  static const double huge = xxxl;

  // ═══════════════════════════════════════════════════════════════════════════
  // EDGE INSETS - Symmetric
  // ═══════════════════════════════════════════════════════════════════════════

  /// All sides - xxs (2px)
  static const EdgeInsets allXxs = EdgeInsets.all(xxs);

  /// All sides - xs (4px)
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// All sides - sm (8px)
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// All sides - smd (12px)
  static const EdgeInsets allSmd = EdgeInsets.all(smd);

  /// All sides - md (16px)
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// All sides - lg (24px)
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// All sides - xl (32px)
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  // ═══════════════════════════════════════════════════════════════════════════
  // EDGE INSETS - Horizontal only
  // ═══════════════════════════════════════════════════════════════════════════

  /// Horizontal - xs (4px)
  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);

  /// Horizontal - sm (8px)
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);

  /// Horizontal - md (16px)
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);

  /// Horizontal - lg (24px)
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// Horizontal - xl (32px)
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  // ═══════════════════════════════════════════════════════════════════════════
  // EDGE INSETS - Vertical only
  // ═══════════════════════════════════════════════════════════════════════════

  /// Vertical - xs (4px)
  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);

  /// Vertical - sm (8px)
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// Vertical - md (16px)
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// Vertical - lg (24px)
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// Vertical - xl (32px)
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  // ═══════════════════════════════════════════════════════════════════════════
  // COMMON LAYOUT PATTERNS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Screen padding - horizontal: 20px, vertical: 16px
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: mdl,
    vertical: md,
  );

  /// Screen horizontal padding only
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: mdl,
  );

  /// Card padding - 16px all around
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Card padding compact - 12px all around
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(smd);

  /// List item padding - horizontal: 16px, vertical: 12px
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: smd,
  );

  /// List item padding compact - horizontal: 12px, vertical: 8px
  static const EdgeInsets listItemPaddingCompact = EdgeInsets.symmetric(
    horizontal: smd,
    vertical: sm,
  );

  /// Button padding - horizontal: 24px, vertical: 12px
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: smd,
  );

  /// Button padding compact - horizontal: 16px, vertical: 8px
  static const EdgeInsets buttonPaddingCompact = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Chip padding - horizontal: 12px, vertical: 6px
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: smd,
    vertical: 6,
  );

  /// Input field padding - horizontal: 16px, vertical: 14px
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: 14,
  );

  /// Modal/Sheet padding - 24px all around
  static const EdgeInsets sheetPadding = EdgeInsets.all(lg);

  /// Dialog padding - 24px all around
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);

  // ═══════════════════════════════════════════════════════════════════════════
  // SIZED BOXES - Vertical gaps
  // ═══════════════════════════════════════════════════════════════════════════

  /// Vertical gap - xxs (2px)
  static const SizedBox gapXxs = SizedBox(height: xxs);

  /// Vertical gap - xs (4px)
  static const SizedBox gapXs = SizedBox(height: xs);

  /// Vertical gap - sm (8px)
  static const SizedBox gapSm = SizedBox(height: sm);

  /// Vertical gap - smd (12px)
  static const SizedBox gapSmd = SizedBox(height: smd);

  /// Vertical gap - md (16px)
  static const SizedBox gapMd = SizedBox(height: md);

  /// Vertical gap - lg (24px)
  static const SizedBox gapLg = SizedBox(height: lg);

  /// Vertical gap - xl (32px)
  static const SizedBox gapXl = SizedBox(height: xl);

  /// Vertical gap - xxl (48px)
  static const SizedBox gapXxl = SizedBox(height: xxl);

  // ═══════════════════════════════════════════════════════════════════════════
  // SIZED BOXES - Horizontal gaps
  // ═══════════════════════════════════════════════════════════════════════════

  /// Horizontal gap - xxs (2px)
  static const SizedBox hGapXxs = SizedBox(width: xxs);

  /// Horizontal gap - xs (4px)
  static const SizedBox hGapXs = SizedBox(width: xs);

  /// Horizontal gap - sm (8px)
  static const SizedBox hGapSm = SizedBox(width: sm);

  /// Horizontal gap - smd (12px)
  static const SizedBox hGapSmd = SizedBox(width: smd);

  /// Horizontal gap - md (16px)
  static const SizedBox hGapMd = SizedBox(width: md);

  /// Horizontal gap - lg (24px)
  static const SizedBox hGapLg = SizedBox(width: lg);

  /// Horizontal gap - xl (32px)
  static const SizedBox hGapXl = SizedBox(width: xl);

  // ═══════════════════════════════════════════════════════════════════════════
  // SLIVER SPACING
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sliver gap - sm (8px)
  static SliverToBoxAdapter get sliverGapSm =>
      const SliverToBoxAdapter(child: gapSm);

  /// Sliver gap - md (16px)
  static SliverToBoxAdapter get sliverGapMd =>
      const SliverToBoxAdapter(child: gapMd);

  /// Sliver gap - lg (24px)
  static SliverToBoxAdapter get sliverGapLg =>
      const SliverToBoxAdapter(child: gapLg);

  /// Sliver gap - xl (32px)
  static SliverToBoxAdapter get sliverGapXl =>
      const SliverToBoxAdapter(child: gapXl);

  // ═══════════════════════════════════════════════════════════════════════════
  // ALIASES FOR CONVENIENCE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Alias for cardPadding
  static const EdgeInsets card = cardPadding;

  /// Alias for chipPadding
  static const EdgeInsets chip = chipPadding;

  /// Alias for inputPadding
  static const EdgeInsets input = inputPadding;
}
