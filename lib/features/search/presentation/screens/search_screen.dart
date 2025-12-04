// lib/features/search/presentation/screens/search_screen.dart
// Global search with tabs for all, tasks, notes

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../providers/search_providers.dart';
import '../../../tasks/presentation/widgets/task_list_item.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notes/presentation/widgets/note_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late TabController _tabController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this);
    _focusNode = FocusNode();

    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    // Sync tab with filter provider
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final filter = switch (_tabController.index) {
          0 => SearchFilterType.all,
          1 => SearchFilterType.tasks,
          2 => SearchFilterType.notes,
          _ => SearchFilterType.all,
        };
        ref.read(searchFilterProvider.notifier).state = filter;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final query = ref.watch(globalSearchQueryProvider);
    final resultsAsync = ref.watch(filteredSearchResultsProvider);
    final recentSearches = ref.watch(recentSearchesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            onChanged: (value) {
              ref.read(globalSearchQueryProvider.notifier).state = value;
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                ref
                    .read(recentSearchesNotifierProvider.notifier)
                    .addSearch(value.trim());
              }
            },
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: 'Search tasks and notes...',
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        ref.read(globalSearchQueryProvider.notifier).state = '';
                      },
                      icon: Icon(
                        Icons.close,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        bottom: query.isNotEmpty
            ? TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Tasks'),
                  Tab(text: 'Notes'),
                ],
              )
            : null,
      ),
      body: query.isEmpty
          ? _RecentSearches(
              searches: recentSearches,
              onSearchTap: (search) {
                _searchController.text = search;
                ref.read(globalSearchQueryProvider.notifier).state = search;
              },
              onClearAll: () {
                ref.read(recentSearchesNotifierProvider.notifier).clearAll();
              },
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _SearchResults(resultsAsync: resultsAsync),
                _SearchResults(
                  resultsAsync: ref.watch(taskOnlySearchResultsProvider),
                ),
                _SearchResults(
                  resultsAsync: ref.watch(noteOnlySearchResultsProvider),
                ),
              ],
            ),
    );
  }
}

/// Recent searches list
class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onSearchTap;
  final VoidCallback onClearAll;

  const _RecentSearches({
    required this.searches,
    required this.onSearchTap,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (searches.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: isDark
                  ? AppColors.textSecondaryDark.withOpacity(0.5)
                  : AppColors.textSecondaryLight.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Search tasks and notes',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // Header
        Row(
          children: [
            Text(
              'Recent searches',
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: onClearAll,
              child: Text(
                'Clear all',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // Search items
        ...searches.map(
          (search) => ListTile(
            leading: Icon(
              Icons.history,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            title: Text(
              search,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            onTap: () => onSearchTap(search),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }
}

/// Search results list
class _SearchResults extends ConsumerWidget {
  final AsyncValue<List<SearchResult>> resultsAsync;

  const _SearchResults({required this.resultsAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return const EmptySearchResults(query: '');
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];

            return switch (result) {
              TaskSearchResult(:final task) => TaskListItem(
                task: task,
                onTap: () {
                  // TODO: Navigate to task
                },
                onCompleteChanged: (completed) {
                  ref
                      .read(taskActionsProvider.notifier)
                      .toggleComplete(task.id);
                },
              ),
              NoteSearchResult(:final note) => NoteListCard(
                note: note,
                onTap: () {
                  // TODO: Navigate to note
                },
              ),
            };
          },
        );
      },
      loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      error: (e, _) => ErrorState(message: e.toString()),
    );
  }
}
