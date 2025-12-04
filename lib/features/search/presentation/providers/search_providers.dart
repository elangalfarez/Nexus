// lib/features/search/presentation/providers/search_providers.dart
// Global unified search across tasks and notes

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/data/repositories/task_repository.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/repositories/note_repository.dart';
import '../../../../core/services/storage_service.dart';

// ============================================
// SEARCH QUERY STATE
// ============================================

/// Global search query
final globalSearchQueryProvider = StateProvider<String>((ref) => '');

/// Search is active (focused/typing)
final searchIsActiveProvider = StateProvider<bool>((ref) => false);

// ============================================
// SEARCH RESULTS
// ============================================

/// Search result item (union type)
sealed class SearchResult {
  final DateTime updatedAt;
  final String title;
  final String? preview;

  const SearchResult({
    required this.updatedAt,
    required this.title,
    this.preview,
  });
}

class TaskSearchResult extends SearchResult {
  final Task task;

  TaskSearchResult(this.task)
    : super(
        updatedAt: task.updatedAt,
        title: task.title,
        preview: task.description,
      );
}

class NoteSearchResult extends SearchResult {
  final Note note;

  NoteSearchResult(this.note)
    : super(
        updatedAt: note.updatedAt,
        title: note.title,
        preview: note.preview,
      );
}

/// Global search results (combined tasks + notes)
final globalSearchResultsProvider = FutureProvider<List<SearchResult>>((
  ref,
) async {
  final query = ref.watch(globalSearchQueryProvider);

  if (query.length < 2) return [];

  final taskRepo = TaskRepository();
  final noteRepo = NoteRepository();

  // Search both in parallel
  final results = await Future.wait([
    taskRepo.search(query),
    noteRepo.search(query),
  ]);

  final tasks = results[0] as List<Task>;
  final notes = results[1] as List<Note>;

  // Combine and sort by relevance (updatedAt for now)
  final combined = <SearchResult>[
    ...tasks.map((t) => TaskSearchResult(t)),
    ...notes.map((n) => NoteSearchResult(n)),
  ];

  // Sort by most recently updated
  combined.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  return combined;
});

/// Task-only search results
final taskOnlySearchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.length < 2) return [];

  final taskRepo = TaskRepository();
  final tasks = await taskRepo.search(query);
  return tasks.map((t) => TaskSearchResult(t)).toList();
});

/// Note-only search results
final noteOnlySearchResultsProvider = FutureProvider<List<SearchResult>>((ref) async {
  final query = ref.watch(globalSearchQueryProvider);
  if (query.length < 2) return [];

  final noteRepo = NoteRepository();
  final notes = await noteRepo.search(query);
  return notes.map((n) => NoteSearchResult(n)).toList();
});

// ============================================
// RECENT SEARCHES
// ============================================

/// Recent search queries
final recentSearchesProvider = StateProvider<List<String>>((ref) {
  return StorageService.getRecentSearches();
});

/// Recent searches actions notifier
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super(StorageService.getRecentSearches());

  /// Add a search query
  Future<void> addSearch(String query) async {
    if (query.isEmpty) return;

    await StorageService.addRecentSearch(query);
    state = StorageService.getRecentSearches();
  }

  /// Remove a search query
  Future<void> removeSearch(String query) async {
    final searches = List<String>.from(state);
    searches.remove(query);

    // Re-save
    await StorageService.prefs.setStringList('recent_searches', searches);
    state = searches;
  }

  /// Clear all searches
  Future<void> clearAll() async {
    await StorageService.clearRecentSearches();
    state = [];
  }
}

/// Recent searches notifier provider
final recentSearchesNotifierProvider =
    StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
      return RecentSearchesNotifier();
    });

// ============================================
// SEARCH FILTERS
// ============================================

/// Search filter type
enum SearchFilterType { all, tasks, notes }

/// Current search filter
final searchFilterProvider = StateProvider<SearchFilterType>(
  (ref) => SearchFilterType.all,
);

/// Filtered search results based on filter type
final filteredSearchResultsProvider = FutureProvider<List<SearchResult>>((
  ref,
) async {
  final filter = ref.watch(searchFilterProvider);
  final allResults = await ref.watch(globalSearchResultsProvider.future);

  return switch (filter) {
    SearchFilterType.all => allResults,
    SearchFilterType.tasks => allResults.whereType<TaskSearchResult>().toList(),
    SearchFilterType.notes => allResults.whereType<NoteSearchResult>().toList(),
  };
});

// ============================================
// SEARCH SUGGESTIONS
// ============================================

/// Search suggestions (recent + popular)
final searchSuggestionsProvider = FutureProvider<List<String>>((ref) async {
  final recentSearches = ref.watch(recentSearchesProvider);

  // For now, just return recent searches
  // Later, can add popular tags, project names, etc.
  return recentSearches;
});
