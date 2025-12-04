// lib/core/theme/app_theme.dart
// Main theme configuration - Uses all semantic tokens

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_radius.dart';
import 'app_spacing.dart';

/// Nexus App Theme System
///
/// This file builds ThemeData using all our semantic tokens.
/// Light and dark themes are defined here.
abstract final class AppTheme {
  // ============================================
  // THEME DATA BUILDERS
  // ============================================

  /// Light theme configuration
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: _lightColorScheme,

      // Background colors
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.surface,
      cardColor: AppColors.surface,
      dialogBackgroundColor: AppColors.surface,

      // Typography
      textTheme: AppTextStyles.textThemeWithColor(AppColors.onSurface),
      primaryTextTheme: AppTextStyles.textThemeWithColor(AppColors.onPrimary),

      // App bar
      appBarTheme: _lightAppBarTheme,

      // Cards
      cardTheme: _lightCardTheme,

      // Buttons
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      iconButtonTheme: _iconButtonTheme,

      // Inputs
      inputDecorationTheme: _lightInputTheme,

      // Chips
      chipTheme: _lightChipTheme,

      // Bottom navigation
      bottomNavigationBarTheme: _lightBottomNavTheme,
      navigationBarTheme: _lightNavigationBarTheme,

      // Bottom sheet
      bottomSheetTheme: _lightBottomSheetTheme,

      // Dialog
      dialogTheme: _lightDialogTheme,

      // Snackbar
      snackBarTheme: _lightSnackBarTheme,

      // Dividers
      dividerTheme: _lightDividerTheme,
      dividerColor: AppColors.outline,

      // Floating action button
      floatingActionButtonTheme: _fabTheme,

      // Icons
      iconTheme: const IconThemeData(color: AppColors.onSurface, size: 24),
      primaryIconTheme: const IconThemeData(
        color: AppColors.onPrimary,
        size: 24,
      ),

      // Checkbox, radio, switch
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      switchTheme: _switchTheme,

      // Progress indicators
      progressIndicatorTheme: _progressTheme,

      // Tooltip
      tooltipTheme: _lightTooltipTheme,

      // List tile
      listTileTheme: _lightListTileTheme,

      // Tab bar
      tabBarTheme: _lightTabBarTheme,

      // Slider
      sliderTheme: _sliderTheme,

      // Page transitions
      pageTransitionsTheme: _pageTransitionsTheme,

      // Scrollbar
      scrollbarTheme: _scrollbarTheme,

      // Splash/ripple effects
      splashColor: AppColors.primary.withValues(alpha: 0.1),
      highlightColor: AppColors.primary.withValues(alpha: 0.05),
      hoverColor: AppColors.primary.withValues(alpha: 0.04),
      focusColor: AppColors.primary.withValues(alpha: 0.12),

      // Visual density
      visualDensity: VisualDensity.standard,

      // Material tap target size
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  /// Dark theme configuration
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: _darkColorScheme,

      // Background colors
      scaffoldBackgroundColor: AppColors.backgroundDark,
      canvasColor: AppColors.surfaceDark,
      cardColor: AppColors.surfaceDark,
      dialogBackgroundColor: AppColors.surfaceElevatedDark,

      // Typography
      textTheme: AppTextStyles.textThemeWithColor(AppColors.onSurfaceDark),
      primaryTextTheme: AppTextStyles.textThemeWithColor(AppColors.onPrimary),

      // App bar
      appBarTheme: _darkAppBarTheme,

      // Cards
      cardTheme: _darkCardTheme,

      // Buttons
      elevatedButtonTheme: _elevatedButtonTheme,
      filledButtonTheme: _filledButtonTheme,
      outlinedButtonTheme: _outlinedButtonThemeDark,
      textButtonTheme: _textButtonTheme,
      iconButtonTheme: _iconButtonTheme,

      // Inputs
      inputDecorationTheme: _darkInputTheme,

      // Chips
      chipTheme: _darkChipTheme,

      // Bottom navigation
      bottomNavigationBarTheme: _darkBottomNavTheme,
      navigationBarTheme: _darkNavigationBarTheme,

      // Bottom sheet
      bottomSheetTheme: _darkBottomSheetTheme,

      // Dialog
      dialogTheme: _darkDialogTheme,

      // Snackbar
      snackBarTheme: _darkSnackBarTheme,

      // Dividers
      dividerTheme: _darkDividerTheme,
      dividerColor: AppColors.outlineDark,

      // Floating action button
      floatingActionButtonTheme: _fabTheme,

      // Icons
      iconTheme: const IconThemeData(color: AppColors.onSurfaceDark, size: 24),
      primaryIconTheme: const IconThemeData(
        color: AppColors.onPrimary,
        size: 24,
      ),

      // Checkbox, radio, switch
      checkboxTheme: _checkboxTheme,
      radioTheme: _radioTheme,
      switchTheme: _switchTheme,

      // Progress indicators
      progressIndicatorTheme: _progressTheme,

      // Tooltip
      tooltipTheme: _darkTooltipTheme,

      // List tile
      listTileTheme: _darkListTileTheme,

      // Tab bar
      tabBarTheme: _darkTabBarTheme,

      // Slider
      sliderTheme: _sliderTheme,

      // Page transitions
      pageTransitionsTheme: _pageTransitionsTheme,

      // Scrollbar
      scrollbarTheme: _scrollbarThemeDark,

      // Splash/ripple effects
      splashColor: AppColors.primary.withValues(alpha: 0.15),
      highlightColor: AppColors.primary.withValues(alpha: 0.08),
      hoverColor: AppColors.primary.withValues(alpha: 0.06),
      focusColor: AppColors.primary.withValues(alpha: 0.15),

      // Visual density
      visualDensity: VisualDensity.standard,

      // Material tap target size
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  // ============================================
  // COLOR SCHEMES
  // ============================================

  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onPrimary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onSurface,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
    shadow: AppColors.overlay,
    scrim: AppColors.overlay,
    inverseSurface: AppColors.onSurface,
    onInverseSurface: AppColors.surface,
    inversePrimary: AppColors.primaryContainer,
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainerDark,
    onPrimaryContainer: AppColors.onPrimaryContainerDark,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainerDark,
    onSecondaryContainer: AppColors.onSecondaryContainerDark,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onPrimary,
    tertiaryContainer: AppColors.tertiaryContainerDark,
    onTertiaryContainer: AppColors.onSurfaceDark,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainerDark,
    onErrorContainer: AppColors.errorContainer,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    outline: AppColors.outlineDark,
    outlineVariant: AppColors.outlineVariantDark,
    shadow: AppColors.overlay,
    scrim: AppColors.overlay,
    inverseSurface: AppColors.onSurfaceDark,
    onInverseSurface: AppColors.surfaceDark,
    inversePrimary: AppColors.primaryContainerDark,
  );

  // ============================================
  // APP BAR THEMES
  // ============================================

  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.onSurface,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: AppTextStyles.titleLarge,
    toolbarHeight: 56,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.onSurfaceDark,
    elevation: 0,
    scrolledUnderElevation: 1,
    centerTitle: true,
    titleTextStyle: AppTextStyles.titleLarge,
    toolbarHeight: 56,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // ============================================
  // CARD THEMES
  // ============================================

  static CardTheme _lightCardTheme = CardTheme(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardRadius,
      side: const BorderSide(color: AppColors.outline, width: 1),
    ),
    margin: EdgeInsets.zero,
  );

  static CardTheme _darkCardTheme = CardTheme(
    color: AppColors.surfaceDark,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.cardRadius,
      side: const BorderSide(color: AppColors.outlineDark, width: 1),
    ),
    margin: EdgeInsets.zero,
  );

  // ============================================
  // BUTTON THEMES
  // ============================================

  static ElevatedButtonThemeData _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      elevation: 0,
      padding: AppSpacing.button,
      minimumSize: const Size(88, 48),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      textStyle: AppTextStyles.labelLarge,
    ),
  );

  static FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      padding: AppSpacing.button,
      minimumSize: const Size(88, 48),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      textStyle: AppTextStyles.labelLarge,
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: AppSpacing.button,
      minimumSize: const Size(88, 48),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      textStyle: AppTextStyles.labelLarge,
    ),
  );

  static OutlinedButtonThemeData _outlinedButtonThemeDark =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.button,
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.labelLarge,
        ),
      );

  static TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      minimumSize: const Size(64, 40),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.buttonRadius),
      textStyle: AppTextStyles.labelLarge,
    ),
  );

  static IconButtonThemeData _iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColors.onSurfaceVariant,
      minimumSize: const Size(48, 48),
      padding: const EdgeInsets.all(AppSpacing.sm),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.allMd),
    ),
  );

  // ============================================
  // INPUT THEMES
  // ============================================

  static InputDecorationTheme _lightInputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceInput,
    contentPadding: AppSpacing.input,
    border: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    hintStyle: AppTextStyles.bodyLarge.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
    labelStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
    errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
    prefixIconColor: AppColors.onSurfaceVariant,
    suffixIconColor: AppColors.onSurfaceVariant,
  );

  static InputDecorationTheme _darkInputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceInputDark,
    contentPadding: AppSpacing.input,
    border: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.inputRadius,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    hintStyle: AppTextStyles.bodyLarge.copyWith(
      color: AppColors.onSurfaceVariantDark,
    ),
    labelStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceVariantDark,
    ),
    errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
    prefixIconColor: AppColors.onSurfaceVariantDark,
    suffixIconColor: AppColors.onSurfaceVariantDark,
  );

  // ============================================
  // CHIP THEMES
  // ============================================

  static ChipThemeData _lightChipTheme = ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primaryContainer,
    disabledColor: AppColors.surfaceVariant,
    labelStyle: AppTextStyles.labelMedium,
    padding: AppSpacing.chip,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
    side: BorderSide.none,
  );

  static ChipThemeData _darkChipTheme = ChipThemeData(
    backgroundColor: AppColors.surfaceVariantDark,
    selectedColor: AppColors.primaryContainerDark,
    disabledColor: AppColors.surfaceVariantDark,
    labelStyle: AppTextStyles.labelMedium,
    padding: AppSpacing.chip,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chipRadius),
    side: BorderSide.none,
  );

  // ============================================
  // NAVIGATION THEMES
  // ============================================

  static BottomNavigationBarThemeData _lightBottomNavTheme =
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      );

  static BottomNavigationBarThemeData _darkBottomNavTheme =
      const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariantDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      );

  static NavigationBarThemeData _lightNavigationBarTheme =
      NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        height: AppSpacing.bottomNavHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(
            color: AppColors.onSurfaceVariant,
            size: 24,
          );
        }),
      );

  static NavigationBarThemeData _darkNavigationBarTheme =
      NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryContainerDark,
        height: AppSpacing.bottomNavHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(
            color: AppColors.onSurfaceVariantDark,
            size: 24,
          );
        }),
      );

  // ============================================
  // BOTTOM SHEET THEMES
  // ============================================

  static BottomSheetThemeData _lightBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    modalBackgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: AppRadius.bottomSheetRadius,
    ),
    dragHandleColor: AppColors.outline,
    dragHandleSize: const Size(32, 4),
  );

  static BottomSheetThemeData _darkBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: AppColors.surfaceElevatedDark,
    modalBackgroundColor: AppColors.surfaceElevatedDark,
    shape: const RoundedRectangleBorder(
      borderRadius: AppRadius.bottomSheetRadius,
    ),
    dragHandleColor: AppColors.outlineDark,
    dragHandleSize: const Size(32, 4),
  );

  // ============================================
  // DIALOG THEMES
  // ============================================

  static DialogTheme _lightDialogTheme = DialogTheme(
    backgroundColor: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
    titleTextStyle: AppTextStyles.headlineSmall.copyWith(
      color: AppColors.onSurface,
    ),
    contentTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
  );

  static DialogTheme _darkDialogTheme = DialogTheme(
    backgroundColor: AppColors.surfaceElevatedDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.dialogRadius),
    titleTextStyle: AppTextStyles.headlineSmall.copyWith(
      color: AppColors.onSurfaceDark,
    ),
    contentTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceVariantDark,
    ),
  );

  // ============================================
  // SNACKBAR THEMES
  // ============================================

  static SnackBarThemeData _lightSnackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.onSurface,
    contentTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.surface,
    ),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.snackbarRadius),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    insetPadding: AppSpacing.allMd,
  );

  static SnackBarThemeData _darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.surfaceElevatedDark,
    contentTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceDark,
    ),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.snackbarRadius),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    insetPadding: AppSpacing.allMd,
  );

  // ============================================
  // DIVIDER THEMES
  // ============================================

  static const DividerThemeData _lightDividerTheme = DividerThemeData(
    color: AppColors.outline,
    thickness: 1,
    space: 1,
  );

  static const DividerThemeData _darkDividerTheme = DividerThemeData(
    color: AppColors.outlineDark,
    thickness: 1,
    space: 1,
  );

  // ============================================
  // FAB THEME
  // ============================================

  static FloatingActionButtonThemeData _fabTheme =
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        focusElevation: 6,
        hoverElevation: 8,
        highlightElevation: 12,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fabRadius),
      );

  // ============================================
  // CHECKBOX, RADIO, SWITCH THEMES
  // ============================================

  static CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.onPrimary),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.allXs),
    side: const BorderSide(color: AppColors.outline, width: 2),
  );

  static RadioThemeData _radioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.outline;
    }),
  );

  static SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.onPrimary;
      }
      return AppColors.onSurfaceVariant;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.outline;
    }),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  );

  // ============================================
  // PROGRESS INDICATOR THEME
  // ============================================

  static const ProgressIndicatorThemeData _progressTheme =
      ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      );

  // ============================================
  // TOOLTIP THEMES
  // ============================================

  static TooltipThemeData _lightTooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.onSurface,
      borderRadius: AppRadius.allSm,
    ),
    textStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.surface),
    padding: AppSpacing.allSm,
  );

  static TooltipThemeData _darkTooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.surfaceElevatedDark,
      borderRadius: AppRadius.allSm,
    ),
    textStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceDark),
    padding: AppSpacing.allSm,
  );

  // ============================================
  // LIST TILE THEMES
  // ============================================

  static ListTileThemeData _lightListTileTheme = ListTileThemeData(
    contentPadding: AppSpacing.listItem,
    minVerticalPadding: AppSpacing.sm,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.allMd),
    titleTextStyle: AppTextStyles.titleMedium.copyWith(
      color: AppColors.onSurface,
    ),
    subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
    leadingAndTrailingTextStyle: AppTextStyles.bodySmall.copyWith(
      color: AppColors.onSurfaceVariant,
    ),
    iconColor: AppColors.onSurfaceVariant,
  );

  static ListTileThemeData _darkListTileTheme = ListTileThemeData(
    contentPadding: AppSpacing.listItem,
    minVerticalPadding: AppSpacing.sm,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.allMd),
    titleTextStyle: AppTextStyles.titleMedium.copyWith(
      color: AppColors.onSurfaceDark,
    ),
    subtitleTextStyle: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.onSurfaceVariantDark,
    ),
    leadingAndTrailingTextStyle: AppTextStyles.bodySmall.copyWith(
      color: AppColors.onSurfaceVariantDark,
    ),
    iconColor: AppColors.onSurfaceVariantDark,
  );

  // ============================================
  // TAB BAR THEMES
  // ============================================

  static TabBarTheme _lightTabBarTheme = TabBarTheme(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.onSurfaceVariant,
    labelStyle: AppTextStyles.labelLarge,
    unselectedLabelStyle: AppTextStyles.labelLarge,
    indicatorColor: AppColors.primary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
  );

  static TabBarTheme _darkTabBarTheme = TabBarTheme(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.onSurfaceVariantDark,
    labelStyle: AppTextStyles.labelLarge,
    unselectedLabelStyle: AppTextStyles.labelLarge,
    indicatorColor: AppColors.primary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
  );

  // ============================================
  // SLIDER THEME
  // ============================================

  static SliderThemeData _sliderTheme = SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.primaryContainer,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primary.withValues(alpha: 0.12),
    valueIndicatorColor: AppColors.primary,
    valueIndicatorTextStyle: AppTextStyles.labelMedium.copyWith(
      color: AppColors.onPrimary,
    ),
  );

  // ============================================
  // PAGE TRANSITIONS
  // ============================================

  static const PageTransitionsTheme _pageTransitionsTheme =
      PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      );

  // ============================================
  // SCROLLBAR THEMES
  // ============================================

  static ScrollbarThemeData _scrollbarTheme = ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(
      AppColors.onSurfaceVariant.withValues(alpha: 0.4),
    ),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    radius: const Radius.circular(AppRadius.full),
    thickness: WidgetStateProperty.all(6),
  );

  static ScrollbarThemeData _scrollbarThemeDark = ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(
      AppColors.onSurfaceVariantDark.withValues(alpha: 0.4),
    ),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    radius: const Radius.circular(AppRadius.full),
    thickness: WidgetStateProperty.all(6),
  );

  // ============================================
  // SYSTEM UI OVERLAY
  // ============================================

  /// Light mode system UI style
  static const SystemUiOverlayStyle lightSystemUI = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surface,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Colors.transparent,
  );

  /// Dark mode system UI style
  static const SystemUiOverlayStyle darkSystemUI = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.surfaceDark,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: Colors.transparent,
  );
}
