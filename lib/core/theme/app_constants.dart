// lib/core/theme/app_constants.dart
// Animation and timing constants

/// Algan Design System - Animation & Timing Constants
///
/// RULE: Never use magic Duration values in widgets.
/// Always use AppConstants.animMicro, AppConstants.animStandard, etc.
abstract final class AppConstants {
  // ═══════════════════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Micro animation - 100ms (quick state changes)
  static const Duration animMicro = Duration(milliseconds: 100);

  /// Fast animation - 150ms (subtle transitions)
  static const Duration animFast = Duration(milliseconds: 150);

  /// Standard animation - 200ms (default transitions)
  static const Duration animStandard = Duration(milliseconds: 200);

  /// Medium animation - 300ms (page transitions, modals)
  static const Duration animMedium = Duration(milliseconds: 300);

  /// Slow animation - 400ms (complex animations)
  static const Duration animSlow = Duration(milliseconds: 400);

  /// Extra slow animation - 500ms (emphasis animations)
  static const Duration animExtraSlow = Duration(milliseconds: 500);

  // ═══════════════════════════════════════════════════════════════════════════
  // DEBOUNCE DURATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Auto-save debounce - 1500ms
  static const int autoSaveDebounceMs = 1500;

  /// Search debounce - 300ms
  static const int searchDebounceMs = 300;
}

// ═══════════════════════════════════════════════════════════════════════════
// SHARED ENUMS
// ═══════════════════════════════════════════════════════════════════════════

/// View mode for displaying lists (projects, notes, etc.)
enum ViewMode { list, grid }