// lib/features/settings/presentation/providers/settings_providers.dart
// App settings and preferences state management

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/database_service.dart';

// ============================================
// THEME SETTINGS
// ============================================

/// Theme mode notifier
class ThemeModeNotifier extends StateNotifier<AppThemeMode> {
  ThemeModeNotifier() : super(StorageService.getThemeMode());

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode mode) async {
    await StorageService.setThemeMode(mode);
    state = mode;
  }

  /// Toggle between light and dark (skips system)
  Future<void> toggleTheme() async {
    final newMode = state == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Get Flutter ThemeMode
  ThemeMode get flutterThemeMode => switch (state) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
}

/// Theme mode provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, AppThemeMode>((ref) {
      return ThemeModeNotifier();
    });

/// Flutter ThemeMode for MaterialApp
final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  final notifier = ref.watch(themeModeProvider.notifier);
  return notifier.flutterThemeMode;
});

// ============================================
// VIEW MODE SETTINGS
// ============================================

/// Task view mode
final taskViewModeProvider = StateProvider<ViewMode>((ref) {
  return StorageService.getTaskViewMode();
});

/// Note view mode
final noteViewModeProvider = StateProvider<ViewMode>((ref) {
  return StorageService.getNoteViewMode();
});

/// Set task view mode
Future<void> setTaskViewMode(WidgetRef ref, ViewMode mode) async {
  await StorageService.setTaskViewMode(mode);
  ref.read(taskViewModeProvider.notifier).state = mode;
}

/// Set note view mode
Future<void> setNoteViewMode(WidgetRef ref, ViewMode mode) async {
  await StorageService.setNoteViewMode(mode);
  ref.read(noteViewModeProvider.notifier).state = mode;
}

// ============================================
// SORT SETTINGS
// ============================================

/// Default sort option
final defaultSortProvider = StateProvider<SortOption>((ref) {
  return StorageService.getDefaultSort();
});

/// Set default sort
Future<void> setDefaultSort(WidgetRef ref, SortOption option) async {
  await StorageService.setDefaultSort(option);
  ref.read(defaultSortProvider.notifier).state = option;
}

// ============================================
// ONBOARDING
// ============================================

/// Onboarding completed state
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  return StorageService.isOnboardingCompleted();
});

/// Complete onboarding
Future<void> completeOnboarding(WidgetRef ref) async {
  await StorageService.completeOnboarding();
  ref.read(onboardingCompletedProvider.notifier).state = true;
}

/// Reset onboarding (for testing)
Future<void> resetOnboarding(WidgetRef ref) async {
  await StorageService.resetOnboarding();
  ref.read(onboardingCompletedProvider.notifier).state = false;
}

// ============================================
// APP STATISTICS
// ============================================

/// App statistics data
class AppStats {
  final int totalTasks;
  final int completedTasks;
  final int totalNotes;
  final int totalProjects;
  final int totalTags;
  final int totalWords;

  const AppStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.totalNotes,
    required this.totalProjects,
    required this.totalTags,
    required this.totalWords,
  });

  double get taskCompletionRate =>
      totalTasks > 0 ? completedTasks / totalTasks : 0;
}

/// App statistics provider
final appStatsProvider = FutureProvider<AppStats>((ref) async {
  final stats = await DatabaseService.getStats();

  // Get word count from notes
  final noteRepo = ref.read(noteRepositoryProvider);
  final noteStats = await noteRepo.getStats();

  return AppStats(
    totalTasks: stats['tasks'] ?? 0,
    completedTasks: 0, // Would need separate query
    totalNotes: stats['notes'] ?? 0,
    totalProjects: stats['projects'] ?? 0,
    totalTags: stats['tags'] ?? 0,
    totalWords: noteStats.totalWords,
  );
});

// Note repository provider import placeholder
final noteRepositoryProvider = Provider((ref) {
  throw UnimplementedError('Import from note_providers.dart');
});

// ============================================
// DATA MANAGEMENT
// ============================================

/// Data management actions
class DataManagementNotifier extends StateNotifier<AsyncValue<void>> {
  DataManagementNotifier() : super(const AsyncValue.data(null));

  /// Export all data
  Future<Map<String, dynamic>?> exportData() async {
    state = const AsyncValue.loading();
    try {
      final data = await DatabaseService.exportAll();
      state = const AsyncValue.data(null);
      return data;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Import data
  Future<bool> importData(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      await DatabaseService.importAll(data);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Clear all data
  Future<bool> clearAllData() async {
    state = const AsyncValue.loading();
    try {
      await DatabaseService.clearAll();
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}

/// Data management provider
final dataManagementProvider =
    StateNotifierProvider<DataManagementNotifier, AsyncValue<void>>((ref) {
      return DataManagementNotifier();
    });

// ============================================
// FLUTTER THEME MODE (Direct StateProvider)
// ============================================

/// Direct ThemeMode provider for simpler state management
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final appMode = StorageService.getThemeMode();
  return switch (appMode) {
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
    AppThemeMode.system => ThemeMode.system,
  };
});

/// Accent color index provider
final accentColorIndexProvider = StateProvider<int>((ref) => 0);

// ============================================
// TASK PREFERENCES
// ============================================

/// Show overdue tasks in Today view
final showOverdueInTodayProvider = StateProvider<bool>((ref) => true);

/// Default high priority for new tasks
final defaultHighPriorityProvider = StateProvider<bool>((ref) => false);

/// Default project ID for new tasks
final defaultProjectIdProvider = StateProvider<int?>((ref) => null);

// ============================================
// NOTE PREFERENCES
// ============================================

/// Spell check enabled
final spellCheckEnabledProvider = StateProvider<bool>((ref) => true);

/// Auto-continue lists in editor
final autoContinueListsProvider = StateProvider<bool>((ref) => true);

/// Show word count in editor
final showWordCountProvider = StateProvider<bool>((ref) => true);

// ============================================
// NOTIFICATION PREFERENCES
// ============================================

/// Reminders enabled
final remindersEnabledProvider = StateProvider<bool>((ref) => true);

/// Default reminder time
final defaultReminderTimeProvider = StateProvider<TimeOfDay>((ref) {
  return const TimeOfDay(hour: 9, minute: 0);
});

/// Daily digest enabled
final dailyDigestEnabledProvider = StateProvider<bool>((ref) => false);

/// Daily digest time
final dailyDigestTimeProvider = StateProvider<TimeOfDay>((ref) {
  return const TimeOfDay(hour: 8, minute: 0);
});

// ============================================
// APP INFO
// ============================================

/// App info provider
final appInfoProvider = Provider<Map<String, String>>((ref) {
  return {
    'name': AppConstants.appName,
    'tagline': AppConstants.appTagline,
    'version': AppConstants.appVersion,
    'buildNumber': AppConstants.buildNumber.toString(),
  };
});
