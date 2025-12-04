// lib/core/services/storage_service.dart
// SharedPreferences wrapper for app settings and preferences

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Storage service for app settings using SharedPreferences
class StorageService {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;

  /// Private constructor
  StorageService._();

  /// Check if storage is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the storage service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;

      if (kDebugMode) {
        debugPrint('Storage service initialized');
      }
    } catch (e) {
      debugPrint('Failed to initialize storage: $e');
      rethrow;
    }
  }

  /// Get SharedPreferences instance
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError(
        'Storage not initialized. Call StorageService.initialize() first.',
      );
    }
    return _prefs!;
  }

  // ============================================
  // THEME SETTINGS
  // ============================================

  /// Get theme mode
  static AppThemeMode getThemeMode() {
    final value = prefs.getString(AppConstants.themeKey);
    return AppThemeMode.fromValue(value ?? 'system');
  }

  /// Set theme mode
  static Future<bool> setThemeMode(AppThemeMode mode) {
    return prefs.setString(AppConstants.themeKey, mode.value);
  }

  // ============================================
  // ONBOARDING
  // ============================================

  /// Check if onboarding is completed
  static bool isOnboardingCompleted() {
    return prefs.getBool(AppConstants.onboardingKey) ?? false;
  }

  /// Mark onboarding as completed
  static Future<bool> completeOnboarding() {
    return prefs.setBool(AppConstants.onboardingKey, true);
  }

  /// Reset onboarding
  static Future<bool> resetOnboarding() {
    return prefs.setBool(AppConstants.onboardingKey, false);
  }

  // ============================================
  // VIEW PREFERENCES
  // ============================================

  /// Get task view mode
  static ViewMode getTaskViewMode() {
    final value = prefs.getString('${AppConstants.viewModeKey}_task');
    return ViewMode.values.firstWhere(
      (v) => v.name == value,
      orElse: () => ViewMode.list,
    );
  }

  /// Set task view mode
  static Future<bool> setTaskViewMode(ViewMode mode) {
    return prefs.setString('${AppConstants.viewModeKey}_task', mode.name);
  }

  /// Get note view mode
  static ViewMode getNoteViewMode() {
    final value = prefs.getString('${AppConstants.viewModeKey}_note');
    return ViewMode.values.firstWhere(
      (v) => v.name == value,
      orElse: () => ViewMode.list,
    );
  }

  /// Set note view mode
  static Future<bool> setNoteViewMode(ViewMode mode) {
    return prefs.setString('${AppConstants.viewModeKey}_note', mode.name);
  }

  // ============================================
  // SORT PREFERENCES
  // ============================================

  /// Get default sort option
  static SortOption getDefaultSort() {
    final value = prefs.getString(AppConstants.sortPreferenceKey);
    return SortOption.fromValue(value ?? 'created_desc');
  }

  /// Set default sort option
  static Future<bool> setDefaultSort(SortOption option) {
    return prefs.setString(AppConstants.sortPreferenceKey, option.value);
  }

  // ============================================
  // RECENT SEARCHES
  // ============================================

  /// Get recent searches
  static List<String> getRecentSearches() {
    final json = prefs.getString(AppConstants.recentSearchesKey);
    if (json == null) return [];

    try {
      final list = jsonDecode(json) as List;
      return list.cast<String>();
    } catch (e) {
      return [];
    }
  }

  /// Add a recent search
  static Future<bool> addRecentSearch(String query) async {
    final searches = getRecentSearches();

    // Remove if already exists
    searches.remove(query);

    // Add to front
    searches.insert(0, query);

    // Limit to max
    if (searches.length > AppConstants.maxRecentSearches) {
      searches.removeLast();
    }

    return prefs.setString(
      AppConstants.recentSearchesKey,
      jsonEncode(searches),
    );
  }

  /// Clear recent searches
  static Future<bool> clearRecentSearches() {
    return prefs.remove(AppConstants.recentSearchesKey);
  }

  // ============================================
  // DEFAULT SELECTIONS
  // ============================================

  /// Get default project ID
  static int? getDefaultProjectId() {
    return prefs.getInt(AppConstants.defaultProjectKey);
  }

  /// Set default project ID
  static Future<bool> setDefaultProjectId(int projectId) {
    return prefs.setInt(AppConstants.defaultProjectKey, projectId);
  }

  /// Get default folder ID
  static int? getDefaultFolderId() {
    return prefs.getInt(AppConstants.defaultFolderKey);
  }

  /// Set default folder ID
  static Future<bool> setDefaultFolderId(int folderId) {
    return prefs.setInt(AppConstants.defaultFolderKey, folderId);
  }

  // ============================================
  // SYNC
  // ============================================

  /// Get last sync timestamp
  static DateTime? getLastSyncTime() {
    final millis = prefs.getInt(AppConstants.lastSyncKey);
    if (millis == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(millis);
  }

  /// Set last sync timestamp
  static Future<bool> setLastSyncTime(DateTime time) {
    return prefs.setInt(AppConstants.lastSyncKey, time.millisecondsSinceEpoch);
  }

  // ============================================
  // GENERIC HELPERS
  // ============================================

  /// Get string value
  static String? getString(String key) => prefs.getString(key);

  /// Set string value
  static Future<bool> setString(String key, String value) {
    return prefs.setString(key, value);
  }

  /// Get int value
  static int? getInt(String key) => prefs.getInt(key);

  /// Set int value
  static Future<bool> setInt(String key, int value) {
    return prefs.setInt(key, value);
  }

  /// Get bool value
  static bool? getBool(String key) => prefs.getBool(key);

  /// Set bool value
  static Future<bool> setBool(String key, bool value) {
    return prefs.setBool(key, value);
  }

  /// Get double value
  static double? getDouble(String key) => prefs.getDouble(key);

  /// Set double value
  static Future<bool> setDouble(String key, double value) {
    return prefs.setDouble(key, value);
  }

  /// Get string list value
  static List<String>? getStringList(String key) => prefs.getStringList(key);

  /// Set string list value
  static Future<bool> setStringList(String key, List<String> value) {
    return prefs.setStringList(key, value);
  }

  /// Remove a key
  static Future<bool> remove(String key) => prefs.remove(key);

  /// Clear all preferences
  static Future<bool> clearAll() => prefs.clear();

  /// Check if key exists
  static bool containsKey(String key) => prefs.containsKey(key);

  /// Get all keys
  static Set<String> getKeys() => prefs.getKeys();
}
