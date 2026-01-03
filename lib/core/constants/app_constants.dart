// lib/core/constants/app_constants.dart
// App-wide constants and configuration values

/// Algan App Constants
///
/// Centralized configuration for the entire app.
/// Update values here to change behavior app-wide.
abstract final class AppConstants {
  // ============================================
  // APP INFO
  // ============================================

  /// App name
  static const String appName = 'Algan';

  /// App tagline
  static const String appTagline = 'Tasks & Second Brain';

  /// App description
  static const String appDescription =
      'A unified productivity workspace combining powerful task management '
      'with networked note-taking.';

  /// Current app version
  static const String appVersion = '1.0.0';

  /// Build number
  static const int buildNumber = 1;

  /// App bundle ID (Android)
  static const String androidBundleId = 'com.alganapp.algan';

  /// App bundle ID (iOS)
  static const String iosBundleId = 'com.alganapp.algan';

  // ============================================
  // STORAGE KEYS
  // ============================================

  /// Key for theme mode preference
  static const String themeKey = 'algan_theme_mode';

  /// Key for onboarding completion
  static const String onboardingKey = 'algan_onboarding_completed';

  /// Key for last sync timestamp
  static const String lastSyncKey = 'algan_last_sync';

  /// Key for default project ID
  static const String defaultProjectKey = 'algan_default_project';

  /// Key for default folder ID
  static const String defaultFolderKey = 'algan_default_folder';

  /// Key for sorting preferences
  static const String sortPreferenceKey = 'algan_sort_preference';

  /// Key for view mode preferences
  static const String viewModeKey = 'algan_view_mode';

  /// Key for recent searches
  static const String recentSearchesKey = 'algan_recent_searches';

  // ============================================
  // DATABASE
  // ============================================

  /// Isar database name
  static const String databaseName = 'algan_db';

  /// Database schema version
  static const int databaseVersion = 1;

  /// Maximum recent searches to store
  static const int maxRecentSearches = 10;

  /// Maximum undo history items
  static const int maxUndoHistory = 50;

  // ============================================
  // LIMITS & CONSTRAINTS
  // ============================================

  /// Maximum task title length
  static const int maxTaskTitleLength = 500;

  /// Maximum note title length
  static const int maxNoteTitleLength = 200;

  /// Maximum project name length
  static const int maxProjectNameLength = 100;

  /// Maximum tag name length
  static const int maxTagNameLength = 50;

  /// Maximum subtask depth
  static const int maxSubtaskDepth = 3;

  /// Maximum tags per item
  static const int maxTagsPerItem = 10;

  /// Maximum pinned notes
  static const int maxPinnedNotes = 5;

  /// Maximum favorite projects
  static const int maxFavoriteProjects = 10;

  /// Minimum search query length
  static const int minSearchQueryLength = 2;

  /// Maximum search results
  static const int maxSearchResults = 100;

  // ============================================
  // ANIMATION DURATIONS (milliseconds)
  // ============================================

  /// Micro animation (button press, toggle)
  static const int animMicro = 150;

  /// Fast animation (quick feedback)
  static const int animFast = 200;

  /// Standard animation (most transitions)
  static const int animStandard = 300;

  /// Emphasized animation (page transitions)
  static const int animEmphasized = 400;

  /// Dramatic animation (onboarding, celebrations)
  static const int animDramatic = 600;

  /// Stagger delay for list animations
  static const int animStaggerDelay = 50;

  // ============================================
  // DEBOUNCE & THROTTLE
  // ============================================

  /// Search debounce delay
  static const int searchDebounceMs = 300;

  /// Auto-save debounce delay
  static const int autoSaveDebounceMs = 1000;

  /// Scroll throttle delay
  static const int scrollThrottleMs = 16;

  /// Refresh cooldown
  static const int refreshCooldownMs = 30000;

  // ============================================
  // DEFAULTS
  // ============================================

  /// Default priority level
  static const int defaultPriority = 4;

  /// Default task view mode
  static const String defaultTaskView = 'list';

  /// Default note view mode
  static const String defaultNoteView = 'list';

  /// Default sort order
  static const String defaultSortOrder = 'created_desc';

  /// Inbox project name
  static const String inboxProjectName = 'Inbox';

  /// Uncategorized folder name
  static const String uncategorizedFolderName = 'Uncategorized';

  // ============================================
  // LINK PATTERNS
  // ============================================

  /// Wiki link pattern [[note title]]
  static final RegExp wikiLinkPattern = RegExp(r'\[\[([^\]]+)\]\]');

  /// Task link pattern {{task title}}
  static final RegExp taskLinkPattern = RegExp(r'\{\{([^\}]+)\}\}');

  /// URL pattern
  static final RegExp urlPattern = RegExp(
    r'https?://[^\s<>\[\]{}|\\^`]+',
    caseSensitive: false,
  );

  /// Hashtag pattern
  static final RegExp hashtagPattern = RegExp(r'#(\w+)');

  // ============================================
  // QUICK CAPTURE
  // ============================================

  /// Quick capture default type
  static const String quickCaptureDefaultType = 'task';

  /// Quick note placeholder
  static const String quickNotePlaceholder = 'Capture a thought...';

  /// Quick task placeholder
  static const String quickTaskPlaceholder = 'Add a task...';

  // ============================================
  // PLATFORM CHANNELS (for future native features)
  // ============================================

  /// Widget channel name
  static const String widgetChannel = 'com.alganapp.algan/widget';

  /// Notifications channel name
  static const String notificationsChannel = 'com.alganapp.algan/notifications';

  /// Share channel name
  static const String shareChannel = 'com.alganapp.algan/share';

  // ============================================
  // SUPPORT & LINKS
  // ============================================

  /// Support email
  static const String supportEmail = 'support@algan.id';

  /// Privacy policy URL
  static const String privacyPolicyUrl = 'https://algan.id/privacy';

  /// Terms of service URL
  static const String termsUrl = 'https://algan.id/terms';

  /// Website URL
  static const String websiteUrl = 'https://algan.id';

  /// Twitter/X handle
  static const String twitterHandle = '@alganapp';

  // ============================================
  // MONETIZATION (for future Pro features)
  // ============================================

  /// Monthly subscription ID
  static const String monthlySubId = 'algan_pro_monthly';

  /// Yearly subscription ID
  static const String yearlySubId = 'algan_pro_yearly';

  /// Lifetime purchase ID
  static const String lifetimeId = 'algan_pro_lifetime';

  /// Monthly price
  static const String monthlyPrice = '\$4.99';

  /// Yearly price
  static const String yearlyPrice = '\$39.99';

  /// Lifetime price
  static const String lifetimePrice = '\$79.99';
}

/// Priority levels enum for type safety
enum TaskPriority {
  urgent(1, 'Urgent', '🔴'),
  high(2, 'High', '🟠'),
  medium(3, 'Medium', '🟡'),
  low(4, 'Low', '🔵'),
  none(5, 'None', '⚪');

  const TaskPriority(this.value, this.label, this.emoji);

  final int value;
  final String label;
  final String emoji;

  static TaskPriority fromValue(int value) {
    return TaskPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => TaskPriority.none,
    );
  }
}

/// View modes for lists
enum ViewMode {
  list,
  grid,
  compact,
  board;

  String get label {
    return switch (this) {
      ViewMode.list => 'List',
      ViewMode.grid => 'Grid',
      ViewMode.compact => 'Compact',
      ViewMode.board => 'Board',
    };
  }
}

/// Sort options
enum SortOption {
  createdDesc('created_desc', 'Newest first'),
  createdAsc('created_asc', 'Oldest first'),
  updatedDesc('updated_desc', 'Recently updated'),
  alphabetical('alphabetical', 'Alphabetical'),
  priority('priority', 'Priority'),
  dueDate('due_date', 'Due date');

  const SortOption(this.value, this.label);

  final String value;
  final String label;

  static SortOption fromValue(String value) {
    return SortOption.values.firstWhere(
      (s) => s.value == value,
      orElse: () => SortOption.createdDesc,
    );
  }
}

/// Theme mode
enum AppThemeMode {
  system('system', 'System'),
  light('light', 'Light'),
  dark('dark', 'Dark');

  const AppThemeMode(this.value, this.label);

  final String value;
  final String label;

  static AppThemeMode fromValue(String value) {
    return AppThemeMode.values.firstWhere(
      (t) => t.value == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
