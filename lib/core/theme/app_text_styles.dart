// lib/core/theme/app_text_styles.dart
// Typography scale - Semantic text styles for consistent typography

import 'package:flutter/material.dart';

/// Nexus Design System - Typography Scale
///
/// RULE: Never hardcode font sizes, weights, or heights in widgets.
/// Always use AppTextStyles.headlineLarge, AppTextStyles.bodyMedium, etc.
abstract final class AppTextStyles {
  // ═══════════════════════════════════════════════════════════════════════════
  // FONT FAMILIES
  // ═══════════════════════════════════════════════════════════════════════════

  static const String fontFamilyPrimary = 'Inter';
  static const String fontFamilyMono = 'JetBrainsMono';

  // ═══════════════════════════════════════════════════════════════════════════
  // FONT WEIGHTS
  // ═══════════════════════════════════════════════════════════════════════════

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // ═══════════════════════════════════════════════════════════════════════════
  // DISPLAY STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 32,
    fontWeight: bold,
    height: 1.25,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 28,
    fontWeight: bold,
    height: 1.286,
    letterSpacing: -0.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.333,
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // HEADLINE STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 24,
    fontWeight: semiBold,
    height: 1.333,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 20,
    fontWeight: semiBold,
    height: 1.4,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.444,
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // TITLE STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 18,
    fontWeight: semiBold,
    height: 1.444,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: medium,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: medium,
    height: 1.429,
    letterSpacing: 0.1,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // BODY STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0.15,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: regular,
    height: 1.429,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12,
    fontWeight: regular,
    height: 1.333,
    letterSpacing: 0.4,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // LABEL STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: medium,
    height: 1.429,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 12,
    fontWeight: medium,
    height: 1.333,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 10,
    fontWeight: medium,
    height: 1.6,
    letterSpacing: 0.5,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // MONOSPACE STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle codeLarge = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 14,
    fontWeight: regular,
    height: 1.571,
    letterSpacing: 0,
  );

  static const TextStyle codeMedium = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 12,
    fontWeight: regular,
    height: 1.5,
    letterSpacing: 0,
  );

  static const TextStyle codeSmall = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: 10,
    fontWeight: regular,
    height: 1.4,
    letterSpacing: 0,
  );

  // ═══════════════════════════════════════════════════════════════════════════
  // SPECIAL STYLES
  // ═══════════════════════════════════════════════════════════════════════════

  static const TextStyle taskTitle = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 15,
    fontWeight: medium,
    height: 1.467,
    letterSpacing: 0,
  );

  static const TextStyle taskTitleCompleted = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 15,
    fontWeight: regular,
    height: 1.467,
    letterSpacing: 0,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle noteTitle = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 16,
    fontWeight: semiBold,
    height: 1.375,
    letterSpacing: 0,
  );

  static const TextStyle notePreview = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 13,
    fontWeight: regular,
    height: 1.462,
    letterSpacing: 0.1,
  );

  static const TextStyle wikiLink = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 14,
    fontWeight: medium,
    height: 1.429,
    letterSpacing: 0,
    decoration: TextDecoration.underline,
  );
}

extension TextStyleColorExtension on TextStyle {
  TextStyle withAppColor(Color color) => copyWith(color: color);
}
