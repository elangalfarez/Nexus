// lib/core/utils/haptics.dart
// Haptic feedback utilities and patterns

import 'package:flutter/services.dart';

/// Haptic feedback utility class
class Haptics {
  Haptics._();

  /// Light impact - for subtle interactions
  /// Use for: toggles, selections, minor state changes
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact - for confirmations
  /// Use for: button taps, successful actions, deletions
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact - for significant actions
  /// Use for: important confirmations, errors, major state changes
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click - for picker selections
  /// Use for: dropdown selections, date picker, time picker
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate - for notifications and alerts
  /// Use sparingly for attention-grabbing moments
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  // ============================================
  // CONTEXTUAL HAPTICS
  // ============================================

  /// Tap feedback - general button press
  static void tap() => light();

  /// Toggle feedback - switch/checkbox toggle
  static void toggle() => light();

  /// Success feedback - action completed successfully
  static void success() => medium();

  /// Error feedback - action failed
  static void error() => heavy();

  /// Warning feedback - caution required
  static void warning() => medium();

  /// Delete feedback - item deleted
  static void delete() => medium();

  /// Drag start feedback - began dragging
  static void dragStart() => light();

  /// Drag end feedback - finished dragging
  static void dragEnd() => medium();

  /// Reorder feedback - item reordered
  static void reorder() => light();

  /// Pull to refresh feedback
  static void refresh() => medium();

  /// Navigation feedback - page transition
  static void navigate() => light();

  /// Modal open feedback
  static void modalOpen() => light();

  /// Modal close feedback
  static void modalClose() => light();

  /// Tab switch feedback
  static void tabSwitch() => light();

  /// Picker scroll feedback
  static void pickerScroll() => selection();

  /// Long press feedback
  static void longPress() => medium();

  /// Completion feedback - task completed
  static void complete() => medium();

  /// Notification received feedback
  static void notification() => vibrate();

  // ============================================
  // CONDITIONAL HAPTICS
  // ============================================

  /// Execute haptic only if enabled in settings
  /// TODO: Integrate with settings provider
  static void ifEnabled(void Function() hapticFn) {
    // For now, always enabled
    // In production, check settings:
    // if (SettingsService.hapticsEnabled) hapticFn();
    hapticFn();
  }

  /// Execute light haptic if enabled
  static void lightIfEnabled() => ifEnabled(light);

  /// Execute medium haptic if enabled
  static void mediumIfEnabled() => ifEnabled(medium);

  /// Execute heavy haptic if enabled
  static void heavyIfEnabled() => ifEnabled(heavy);
}

/// Extension for adding haptics to callbacks
extension HapticCallback on VoidCallback {
  /// Wrap callback with light haptic
  VoidCallback withLightHaptic() {
    return () {
      Haptics.light();
      this();
    };
  }

  /// Wrap callback with medium haptic
  VoidCallback withMediumHaptic() {
    return () {
      Haptics.medium();
      this();
    };
  }

  /// Wrap callback with heavy haptic
  VoidCallback withHeavyHaptic() {
    return () {
      Haptics.heavy();
      this();
    };
  }

  /// Wrap callback with tap haptic
  VoidCallback withTapHaptic() {
    return () {
      Haptics.tap();
      this();
    };
  }
}

/// Extension for nullable callbacks
extension NullableHapticCallback on VoidCallback? {
  /// Wrap nullable callback with light haptic
  VoidCallback? withLightHaptic() {
    if (this == null) return null;
    return () {
      Haptics.light();
      this!();
    };
  }

  /// Wrap nullable callback with medium haptic
  VoidCallback? withMediumHaptic() {
    if (this == null) return null;
    return () {
      Haptics.medium();
      this!();
    };
  }
}

/// Mixin for adding haptics to StatefulWidgets
mixin HapticsMixin<T extends StatefulWidget> on State<T> {
  /// Execute haptic feedback
  void haptic(void Function() hapticFn) {
    hapticFn();
  }

  /// Light haptic
  void hapticLight() => Haptics.light();

  /// Medium haptic
  void hapticMedium() => Haptics.medium();

  /// Heavy haptic
  void hapticHeavy() => Haptics.heavy();

  /// Selection haptic
  void hapticSelection() => Haptics.selection();
}
