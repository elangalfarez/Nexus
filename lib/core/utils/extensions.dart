// lib/core/utils/extensions.dart
// Dart extensions for cleaner code and context access

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Context extensions for easy access to theme and media query
extension BuildContextExtensions on BuildContext {
  // ============================================
  // THEME ACCESS
  // ============================================

  /// Get current theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Check if dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if light mode
  bool get isLightMode => theme.brightness == Brightness.light;

  // ============================================
  // MEDIA QUERY ACCESS
  // ============================================

  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get device pixel ratio
  double get pixelRatio => mediaQuery.devicePixelRatio;

  /// Get safe area padding
  EdgeInsets get safeArea => mediaQuery.padding;

  /// Get view insets (keyboard)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get status bar height
  double get statusBarHeight => safeArea.top;

  /// Get bottom safe area height
  double get bottomSafeArea => safeArea.bottom;

  // ============================================
  // RESPONSIVE BREAKPOINTS
  // ============================================

  /// Mobile breakpoint (<600)
  bool get isMobile => screenWidth < 600;

  /// Tablet breakpoint (600-1024)
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  /// Desktop breakpoint (>=1024)
  bool get isDesktop => screenWidth >= 1024;

  /// Small phone (<375)
  bool get isSmallPhone => screenWidth < 375;

  /// Large phone (375-428)
  bool get isLargePhone => screenWidth >= 375 && screenWidth < 428;

  // ============================================
  // ACCESSIBILITY
  // ============================================

  /// Check if reduced motion is preferred
  bool get prefersReducedMotion => mediaQuery.disableAnimations;

  /// Check if high contrast is preferred
  bool get prefersHighContrast => mediaQuery.highContrast;

  /// Get text scale factor
  double get textScaleFactor => mediaQuery.textScaler.scale(1.0);

  /// Check if text is scaled up
  bool get isTextScaled => textScaleFactor > 1.0;

  /// Check if bold text is preferred
  bool get prefersBoldText => mediaQuery.boldText;

  // ============================================
  // ORIENTATION
  // ============================================

  /// Check if portrait
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  /// Check if landscape
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  // ============================================
  // SNACKBAR & DIALOGS
  // ============================================

  /// Show snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: AppColors.success);
  }

  /// Hide current snackbar
  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }

  // ============================================
  // NAVIGATION
  // ============================================

  /// Pop current route
  void pop<T>([T? result]) => Navigator.of(this).pop(result);

  /// Check if can pop
  bool get canPop => Navigator.of(this).canPop();

  /// Pop until first route
  void popToFirst() => Navigator.of(this).popUntil((route) => route.isFirst);

  // ============================================
  // FOCUS
  // ============================================

  /// Unfocus current focus (dismiss keyboard)
  void unfocus() => FocusScope.of(this).unfocus();

  /// Request focus on node
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);
}

/// String extensions
extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Check if string is numeric
  bool get isNumeric => double.tryParse(this) != null;

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Remove all whitespace
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Convert to slug (URL-friendly)
  String get toSlug {
    return toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }
}

/// DateTime extensions
extension DateTimeExtensions on DateTime {
  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Get difference in days from now
  int get daysFromNow {
    final now = DateTime.now();
    return DateTime(
      year,
      month,
      day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  /// Format as relative string (Today, Yesterday, etc.)
  String get relativeString {
    if (isToday) return 'Today';
    if (isYesterday) return 'Yesterday';
    if (isTomorrow) return 'Tomorrow';
    if (isThisWeek) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[weekday - 1];
    }
    return '$month/$day/$year';
  }
}

/// Nullable extensions
extension NullableStringExtensions on String? {
  /// Check if null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Check if not null and not empty
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Return value or default
  String orDefault([String defaultValue = '']) => this ?? defaultValue;
}

/// List extensions
extension ListExtensions<T> on List<T> {
  /// Get element at index or null
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Separate list into chunks
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

/// Duration extensions
extension DurationExtensions on Duration {
  /// Format as MM:SS
  String get mmss {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format as HH:MM:SS
  String get hhmmss {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

/// Number extensions
extension IntExtensions on int {
  /// Convert to Duration in milliseconds
  Duration get ms => Duration(milliseconds: this);

  /// Convert to Duration in seconds
  Duration get seconds => Duration(seconds: this);

  /// Convert to Duration in minutes
  Duration get minutes => Duration(minutes: this);

  /// Convert to Duration in hours
  Duration get hours => Duration(hours: this);
}

/// Color extensions
extension ColorExtensions on Color {
  /// Darken color by percentage (0.0 - 1.0)
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final newLightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }

  /// Lighten color by percentage (0.0 - 1.0)
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final newLightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(newLightness).toColor();
  }

  /// Get contrasting text color (black or white)
  Color get contrastingColor {
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

/// TextStyle extensions
extension TextStyleExtensions on TextStyle {
  /// Make text bold
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Make text semi-bold
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);

  /// Make text medium weight
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);

  /// Make text italic
  TextStyle get italic => copyWith(fontStyle: FontStyle.italic);

  /// Add underline
  TextStyle get underlined => copyWith(decoration: TextDecoration.underline);

  /// Add strikethrough
  TextStyle get strikethrough =>
      copyWith(decoration: TextDecoration.lineThrough);

  /// Change color
  TextStyle withColor(Color color) => copyWith(color: color);

  /// Change size
  TextStyle withSize(double size) => copyWith(fontSize: size);
}
