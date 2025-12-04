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
      scaffoldBackgroundColor: AppColors.backgroundLight,
      canvasColor: AppColors.surfaceLight,
      cardColor: AppColors.surfaceLight,

      // Typography
      textTheme: _lightTextTheme,
      primaryTextTheme: _primaryTextTheme,

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
      dividerColor: AppColors.dividerLight,

      // Floating action button
      floatingActionButtonTheme: _fabTheme,

      // Icons
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryLight,
        size: 24,
      ),
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
      splashColor: AppColors.rippleLight,
      highlightColor: AppColors.hoverLight,
      hoverColor: AppColors.hoverLight,
      focusColor: AppColors.focusRing.withValues(alpha: 0.12),

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

      // Typography
      textTheme: _darkTextTheme,
      primaryTextTheme: _primaryTextTheme,

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
      dividerColor: AppColors.dividerDark,

      // Floating action button
      floatingActionButtonTheme: _fabTheme,

      // Icons
      iconTheme: const IconThemeData(
        color: AppColors.textPrimaryDark,
        size: 24,
      ),
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
      splashColor: AppColors.rippleDark,
      highlightColor: AppColors.hoverDark,
      hoverColor: AppColors.hoverDark,
      focusColor: AppColors.focusRing.withValues(alpha: 0.15),

      // Visual density
      visualDensity: VisualDensity.standard,

      // Material tap target size
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  // ============================================
  // TEXT THEMES
  // ============================================

  static TextTheme get _lightTextTheme => TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.textPrimaryLight),
        displayMedium: AppTextStyles.displayMedium
            .copyWith(color: AppColors.textPrimaryLight),
        displaySmall: AppTextStyles.displaySmall
            .copyWith(color: AppColors.textPrimaryLight),
        headlineLarge: AppTextStyles.headlineLarge
            .copyWith(color: AppColors.textPrimaryLight),
        headlineMedium: AppTextStyles.headlineMedium
            .copyWith(color: AppColors.textPrimaryLight),
        headlineSmall: AppTextStyles.headlineSmall
            .copyWith(color: AppColors.textPrimaryLight),
        titleLarge: AppTextStyles.titleLarge
            .copyWith(color: AppColors.textPrimaryLight),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.textPrimaryLight),
        titleSmall: AppTextStyles.titleSmall
            .copyWith(color: AppColors.textPrimaryLight),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textPrimaryLight),
        bodySmall: AppTextStyles.bodySmall
            .copyWith(color: AppColors.textSecondaryLight),
        labelLarge: AppTextStyles.labelLarge
            .copyWith(color: AppColors.textPrimaryLight),
        labelMedium: AppTextStyles.labelMedium
            .copyWith(color: AppColors.textSecondaryLight),
        labelSmall: AppTextStyles.labelSmall
            .copyWith(color: AppColors.textSecondaryLight),
      );

  static TextTheme get _darkTextTheme => TextTheme(
        displayLarge: AppTextStyles.displayLarge
            .copyWith(color: AppColors.textPrimaryDark),
        displayMedium: AppTextStyles.displayMedium
            .copyWith(color: AppColors.textPrimaryDark),
        displaySmall: AppTextStyles.displaySmall
            .copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: AppTextStyles.headlineLarge
            .copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: AppTextStyles.headlineMedium
            .copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: AppTextStyles.headlineSmall
            .copyWith(color: AppColors.textPrimaryDark),
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: AppTextStyles.titleMedium
            .copyWith(color: AppColors.textPrimaryDark),
        titleSmall:
            AppTextStyles.titleSmall.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge:
            AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
        bodySmall: AppTextStyles.bodySmall
            .copyWith(color: AppColors.textSecondaryDark),
        labelLarge:
            AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: AppTextStyles.labelMedium
            .copyWith(color: AppColors.textSecondaryDark),
        labelSmall: AppTextStyles.labelSmall
            .copyWith(color: AppColors.textSecondaryDark),
      );

  static TextTheme get _primaryTextTheme => TextTheme(
        displayLarge:
            AppTextStyles.displayLarge.copyWith(color: AppColors.onPrimary),
        displayMedium:
            AppTextStyles.displayMedium.copyWith(color: AppColors.onPrimary),
        displaySmall:
            AppTextStyles.displaySmall.copyWith(color: AppColors.onPrimary),
        headlineLarge:
            AppTextStyles.headlineLarge.copyWith(color: AppColors.onPrimary),
        headlineMedium:
            AppTextStyles.headlineMedium.copyWith(color: AppColors.onPrimary),
        headlineSmall:
            AppTextStyles.headlineSmall.copyWith(color: AppColors.onPrimary),
        titleLarge:
            AppTextStyles.titleLarge.copyWith(color: AppColors.onPrimary),
        titleMedium:
            AppTextStyles.titleMedium.copyWith(color: AppColors.onPrimary),
        titleSmall:
            AppTextStyles.titleSmall.copyWith(color: AppColors.onPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: AppColors.onPrimary),
        bodyMedium:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.onPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.onPrimary),
        labelLarge:
            AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary),
        labelMedium:
            AppTextStyles.labelMedium.copyWith(color: AppColors.onPrimary),
        labelSmall:
            AppTextStyles.labelSmall.copyWith(color: AppColors.onPrimary),
      );

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
    onSecondaryContainer: AppColors.onPrimaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.textPrimaryLight,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.surfaceVariantLight,
    onSurfaceVariant: AppColors.textSecondaryLight,
    outline: AppColors.borderLight,
    outlineVariant: AppColors.borderSubtleLight,
    scrim: AppColors.scrim,
    shadow: AppColors.shadow,
    inverseSurface: AppColors.inverseSurfaceLight,
    onInverseSurface: AppColors.onInverseSurfaceLight,
    inversePrimary: AppColors.inversePrimaryLight,
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
    onSecondaryContainer: AppColors.onPrimaryContainerDark,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainerDark,
    onTertiaryContainer: AppColors.textPrimaryDark,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainerDark,
    onErrorContainer: AppColors.onErrorContainerDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.surfaceVariantDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    outline: AppColors.borderDark,
    outlineVariant: AppColors.borderSubtleDark,
    scrim: AppColors.scrim,
    shadow: AppColors.shadowDark,
    inverseSurface: AppColors.inverseSurfaceDark,
    onInverseSurface: AppColors.onInverseSurfaceDark,
    inversePrimary: AppColors.inversePrimaryDark,
  );

  // ============================================
  // APP BAR THEMES
  // ============================================

  static const AppBarTheme _lightAppBarTheme = AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.surfaceLight,
    foregroundColor: AppColors.textPrimaryLight,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleSpacing: AppSpacing.md,
    toolbarHeight: 56,
    iconTheme: IconThemeData(
      color: AppColors.textPrimaryLight,
      size: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.textPrimaryLight,
      size: 24,
    ),
    titleTextStyle: TextStyle(
      fontFamily: AppTextStyles.fontFamilyPrimary,
      fontSize: 18,
      fontWeight: AppTextStyles.semiBold,
      color: AppColors.textPrimaryLight,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  static const AppBarTheme _darkAppBarTheme = AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 1,
    backgroundColor: AppColors.surfaceDark,
    foregroundColor: AppColors.textPrimaryDark,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    titleSpacing: AppSpacing.md,
    toolbarHeight: 56,
    iconTheme: IconThemeData(
      color: AppColors.textPrimaryDark,
      size: 24,
    ),
    actionsIconTheme: IconThemeData(
      color: AppColors.textPrimaryDark,
      size: 24,
    ),
    titleTextStyle: TextStyle(
      fontFamily: AppTextStyles.fontFamilyPrimary,
      fontSize: 18,
      fontWeight: AppTextStyles.semiBold,
      color: AppColors.textPrimaryDark,
    ),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // ============================================
  // CARD THEMES
  // ============================================

  static final CardThemeData _lightCardTheme = CardThemeData(
    elevation: 0,
    color: AppColors.surfaceLight,
    shadowColor: AppColors.shadow,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: const BorderSide(color: AppColors.borderLight, width: 1),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  );

  static final CardThemeData _darkCardTheme = CardThemeData(
    elevation: 0,
    color: AppColors.surfaceDark,
    shadowColor: AppColors.shadowDark,
    shape: RoundedRectangleBorder(
      borderRadius: AppRadius.card,
      side: const BorderSide(color: AppColors.borderDark, width: 1),
    ),
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
  );

  // ============================================
  // BUTTON THEMES
  // ============================================

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: AppSpacing.buttonPadding,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      disabledBackgroundColor: AppColors.textDisabledLight,
      disabledForegroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: AppTextStyles.labelLarge,
      minimumSize: const Size(64, 48),
    ),
  );

  static final FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: AppSpacing.buttonPadding,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      disabledBackgroundColor: AppColors.textDisabledLight,
      disabledForegroundColor: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: AppTextStyles.labelLarge,
      minimumSize: const Size(64, 48),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: AppSpacing.buttonPadding,
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textDisabledLight,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      side: const BorderSide(color: AppColors.primary, width: 1.5),
      textStyle: AppTextStyles.labelLarge,
      minimumSize: const Size(64, 48),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonThemeDark =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: AppSpacing.buttonPadding,
      foregroundColor: AppColors.primaryLight,
      disabledForegroundColor: AppColors.textDisabledDark,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
      textStyle: AppTextStyles.labelLarge,
      minimumSize: const Size(64, 48),
    ),
  );

  static final TextButtonThemeData _textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: AppSpacing.buttonPaddingCompact,
      foregroundColor: AppColors.primary,
      disabledForegroundColor: AppColors.textDisabledLight,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.button),
      textStyle: AppTextStyles.labelLarge,
      minimumSize: const Size(48, 40),
    ),
  );

  static final IconButtonThemeData _iconButtonTheme = IconButtonThemeData(
    style: IconButton.styleFrom(
      foregroundColor: AppColors.textSecondaryLight,
      disabledForegroundColor: AppColors.textDisabledLight,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
      minimumSize: const Size(48, 48),
    ),
  );

  // ============================================
  // INPUT THEMES
  // ============================================

  static final InputDecorationTheme _lightInputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariantLight,
    contentPadding: AppSpacing.inputPadding,
    border: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    hintStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiaryLight),
    labelStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
    floatingLabelStyle:
        AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
    errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
    prefixIconColor: AppColors.textSecondaryLight,
    suffixIconColor: AppColors.textSecondaryLight,
  );

  static final InputDecorationTheme _darkInputTheme = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceVariantDark,
    contentPadding: AppSpacing.inputPadding,
    border: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: const BorderSide(color: AppColors.error, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    hintStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiaryDark),
    labelStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
    floatingLabelStyle:
        AppTextStyles.labelMedium.copyWith(color: AppColors.primaryLight),
    errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
    prefixIconColor: AppColors.textSecondaryDark,
    suffixIconColor: AppColors.textSecondaryDark,
  );

  // ============================================
  // CHIP THEMES
  // ============================================

  static final ChipThemeData _lightChipTheme = ChipThemeData(
    backgroundColor: AppColors.surfaceVariantLight,
    selectedColor: AppColors.primaryContainer,
    disabledColor: AppColors.surfaceVariantLight,
    padding: AppSpacing.chipPadding,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
    labelStyle:
        AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimaryLight),
    secondaryLabelStyle:
        AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
    showCheckmark: false,
  );

  static final ChipThemeData _darkChipTheme = ChipThemeData(
    backgroundColor: AppColors.surfaceVariantDark,
    selectedColor: AppColors.primaryContainerDark,
    disabledColor: AppColors.surfaceVariantDark,
    padding: AppSpacing.chipPadding,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
    labelStyle:
        AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimaryDark),
    secondaryLabelStyle:
        AppTextStyles.labelMedium.copyWith(color: AppColors.primaryLight),
    showCheckmark: false,
  );

  // ============================================
  // BOTTOM NAVIGATION THEMES
  // ============================================

  static final BottomNavigationBarThemeData _lightBottomNavTheme =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondaryLight,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  );

  static final BottomNavigationBarThemeData _darkBottomNavTheme =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    selectedItemColor: AppColors.primaryLight,
    unselectedItemColor: AppColors.textSecondaryDark,
    type: BottomNavigationBarType.fixed,
    elevation: 0,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  );

  static final NavigationBarThemeData _lightNavigationBarTheme =
      NavigationBarThemeData(
    backgroundColor: AppColors.surfaceLight,
    indicatorColor: AppColors.primaryContainer,
    height: 80,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.primary, size: 24);
      }
      return const IconThemeData(color: AppColors.textSecondaryLight, size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppTextStyles.labelSmall.copyWith(color: AppColors.primary);
      }
      return AppTextStyles.labelSmall
          .copyWith(color: AppColors.textSecondaryLight);
    }),
  );

  static final NavigationBarThemeData _darkNavigationBarTheme =
      NavigationBarThemeData(
    backgroundColor: AppColors.surfaceDark,
    indicatorColor: AppColors.primaryContainerDark,
    height: 80,
    labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
    iconTheme: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: AppColors.primaryLight, size: 24);
      }
      return const IconThemeData(color: AppColors.textSecondaryDark, size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppTextStyles.labelSmall.copyWith(color: AppColors.primaryLight);
      }
      return AppTextStyles.labelSmall
          .copyWith(color: AppColors.textSecondaryDark);
    }),
  );

  // ============================================
  // BOTTOM SHEET THEMES
  // ============================================

  static final BottomSheetThemeData _lightBottomSheetTheme =
      BottomSheetThemeData(
    backgroundColor: AppColors.surfaceLight,
    modalBackgroundColor: AppColors.surfaceLight,
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
    clipBehavior: Clip.antiAlias,
    dragHandleColor: AppColors.borderLight,
    dragHandleSize: const Size(32, 4),
  );

  static final BottomSheetThemeData _darkBottomSheetTheme =
      BottomSheetThemeData(
    backgroundColor: AppColors.surfaceElevatedDark,
    modalBackgroundColor: AppColors.surfaceElevatedDark,
    elevation: 0,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
    clipBehavior: Clip.antiAlias,
    dragHandleColor: AppColors.borderDark,
    dragHandleSize: const Size(32, 4),
  );

  // ============================================
  // DIALOG THEMES
  // ============================================

  static final DialogThemeData _lightDialogTheme = DialogThemeData(
    backgroundColor: AppColors.surfaceLight,
    elevation: 8,
    shadowColor: AppColors.shadow,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
    titleTextStyle:
        AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryLight),
    contentTextStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
  );

  static final DialogThemeData _darkDialogTheme = DialogThemeData(
    backgroundColor: AppColors.surfaceElevatedDark,
    elevation: 8,
    shadowColor: AppColors.shadowDark,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
    titleTextStyle:
        AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimaryDark),
    contentTextStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
  );

  // ============================================
  // SNACKBAR THEMES
  // ============================================

  static final SnackBarThemeData _lightSnackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.inverseSurfaceLight,
    contentTextStyle: AppTextStyles.bodyMedium
        .copyWith(color: AppColors.onInverseSurfaceLight),
    actionTextColor: AppColors.inversePrimaryLight,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.toast),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    insetPadding: AppSpacing.allMd,
  );

  static final SnackBarThemeData _darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: AppColors.surfaceElevatedDark,
    contentTextStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimaryDark),
    actionTextColor: AppColors.primaryLight,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.toast),
    behavior: SnackBarBehavior.floating,
    elevation: 0,
    insetPadding: AppSpacing.allMd,
  );

  // ============================================
  // DIVIDER THEMES
  // ============================================

  static const DividerThemeData _lightDividerTheme = DividerThemeData(
    color: AppColors.dividerLight,
    thickness: 1,
    space: 1,
  );

  static const DividerThemeData _darkDividerTheme = DividerThemeData(
    color: AppColors.dividerDark,
    thickness: 1,
    space: 1,
  );

  // ============================================
  // FAB THEME
  // ============================================

  static final FloatingActionButtonThemeData _fabTheme =
      FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: AppColors.onPrimary,
    elevation: 4,
    focusElevation: 6,
    hoverElevation: 8,
    highlightElevation: 12,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.fab),
  );

  // ============================================
  // CHECKBOX, RADIO, SWITCH THEMES
  // ============================================

  static final CheckboxThemeData _checkboxTheme = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return Colors.transparent;
    }),
    checkColor: WidgetStateProperty.all(AppColors.onPrimary),
    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedXs),
    side: const BorderSide(color: AppColors.borderLight, width: 2),
  );

  static final RadioThemeData _radioTheme = RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.borderLight;
    }),
  );

  static final SwitchThemeData _switchTheme = SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.onPrimary;
      }
      return AppColors.textSecondaryLight;
    }),
    trackColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return AppColors.primary;
      }
      return AppColors.borderLight;
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

  static final TooltipThemeData _lightTooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.inverseSurfaceLight,
      borderRadius: AppRadius.roundedSm,
    ),
    textStyle: AppTextStyles.bodySmall
        .copyWith(color: AppColors.onInverseSurfaceLight),
    padding: AppSpacing.allSm,
  );

  static final TooltipThemeData _darkTooltipTheme = TooltipThemeData(
    decoration: BoxDecoration(
      color: AppColors.surfaceElevatedDark,
      borderRadius: AppRadius.roundedSm,
    ),
    textStyle:
        AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimaryDark),
    padding: AppSpacing.allSm,
  );

  // ============================================
  // LIST TILE THEMES
  // ============================================

  static final ListTileThemeData _lightListTileTheme = ListTileThemeData(
    contentPadding: AppSpacing.listItemPadding,
    minVerticalPadding: AppSpacing.sm,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
    titleTextStyle:
        AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryLight),
    subtitleTextStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
    leadingAndTrailingTextStyle:
        AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryLight),
    iconColor: AppColors.textSecondaryLight,
  );

  static final ListTileThemeData _darkListTileTheme = ListTileThemeData(
    contentPadding: AppSpacing.listItemPadding,
    minVerticalPadding: AppSpacing.sm,
    shape: RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
    titleTextStyle:
        AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimaryDark),
    subtitleTextStyle:
        AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondaryDark),
    leadingAndTrailingTextStyle:
        AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondaryDark),
    iconColor: AppColors.textSecondaryDark,
  );

  // ============================================
  // TAB BAR THEMES
  // ============================================

  static final TabBarThemeData _lightTabBarTheme = TabBarThemeData(
    labelColor: AppColors.primary,
    unselectedLabelColor: AppColors.textSecondaryLight,
    labelStyle: AppTextStyles.labelLarge,
    unselectedLabelStyle: AppTextStyles.labelLarge,
    indicatorColor: AppColors.primary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
  );

  static final TabBarThemeData _darkTabBarTheme = TabBarThemeData(
    labelColor: AppColors.primaryLight,
    unselectedLabelColor: AppColors.textSecondaryDark,
    labelStyle: AppTextStyles.labelLarge,
    unselectedLabelStyle: AppTextStyles.labelLarge,
    indicatorColor: AppColors.primaryLight,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: Colors.transparent,
  );

  // ============================================
  // SLIDER THEME
  // ============================================

  static final SliderThemeData _sliderTheme = SliderThemeData(
    activeTrackColor: AppColors.primary,
    inactiveTrackColor: AppColors.primaryContainer,
    thumbColor: AppColors.primary,
    overlayColor: AppColors.primary.withValues(alpha: 0.12),
    valueIndicatorColor: AppColors.primary,
    valueIndicatorTextStyle:
        AppTextStyles.labelMedium.copyWith(color: AppColors.onPrimary),
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

  static final ScrollbarThemeData _scrollbarTheme = ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(
        AppColors.textSecondaryLight.withValues(alpha: 0.4)),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    radius: const Radius.circular(AppRadius.full),
    thickness: WidgetStateProperty.all(6.0),
  );

  static final ScrollbarThemeData _scrollbarThemeDark = ScrollbarThemeData(
    thumbColor: WidgetStateProperty.all(
        AppColors.textSecondaryDark.withValues(alpha: 0.4)),
    trackColor: WidgetStateProperty.all(Colors.transparent),
    radius: const Radius.circular(AppRadius.full),
    thickness: WidgetStateProperty.all(6.0),
  );

  // ============================================
  // SYSTEM UI OVERLAY
  // ============================================

  /// Light mode system UI style
  static const SystemUiOverlayStyle lightSystemUI = SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.surfaceLight,
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
