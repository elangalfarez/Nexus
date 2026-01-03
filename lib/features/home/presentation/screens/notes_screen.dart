// lib/features/home/presentation/screens/notes_screen.dart
// Notes screen with world-class ADHD-friendly design
// Premium masonry grid and list views with smooth animations

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/models/folder_model.dart';
import '../../../notes/presentation/providers/note_providers.dart';
import '../../../notes/presentation/providers/folder_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STATE PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Notes view mode - Uses shared ViewMode enum from theme
final notesViewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

/// Current folder ID (null = all notes / root)
final currentFolderIdProvider = StateProvider<int?>((ref) => null);

/// Sort option for notes
enum NotesSortOption {
  recentlyEdited('Recently Edited', Icons.edit_rounded),
  recentlyCreated('Recently Created', Icons.add_circle_outline_rounded),
  alphabetical('A-Z', Icons.sort_by_alpha_rounded),
  pinned('Pinned First', Icons.push_pin_rounded);

  final String label;
  final IconData icon;
  const NotesSortOption(this.label, this.icon);
}

final notesSortOptionProvider =
    StateProvider<NotesSortOption>((ref) => NotesSortOption.recentlyEdited);

/// Search query for notes
final notesSearchQueryProvider = StateProvider<String>((ref) => '');

/// Is search mode active
final notesSearchActiveProvider = StateProvider<bool>((ref) => false);

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  /// Consistent horizontal padding - aligns with bottom navigation
  static const double _horizontalPadding = AppSpacing.mdl; // 20px

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final viewMode = ref.watch(notesViewModeProvider);
    final currentFolderId = ref.watch(currentFolderIdProvider);
    final sortOption = ref.watch(notesSortOptionProvider);
    final isSearchActive = ref.watch(notesSearchActiveProvider);
    final searchQuery = ref.watch(notesSearchQueryProvider);

    // Data streams
    final notesAsync = currentFolderId == null
        ? ref.watch(watchRootNotesProvider)
        : ref.watch(watchNotesByFolderProvider(currentFolderId));

    final foldersAsync = ref.watch(rootFoldersProvider);

    final currentFolderAsync = currentFolderId != null
        ? ref.watch(folderByIdProvider(currentFolderId))
        : null;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // Premium App Bar with consistent styling
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor:
                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 64,
            titleSpacing: 0,
            title: AnimatedSwitcher(
              duration: AppConstants.animStandard,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-0.05, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              ),
              child: currentFolderId == null
                  ? _buildRootTitle(context, isDark)
                  : _buildFolderTitle(
                      context,
                      isDark,
                      ref,
                      currentFolderAsync?.valueOrNull?.name ?? 'Folder',
                    ),
            ),
            actions: [
              // Search button
              _ActionButton(
                icon: Icons.search_rounded,
                tooltip: 'Search notes',
                isActive: isSearchActive,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(notesSearchActiveProvider.notifier).state =
                      !isSearchActive;
                },
              ),
              // View toggle
              _ActionButton(
                icon: viewMode == ViewMode.grid
                    ? Icons.view_agenda_rounded
                    : Icons.grid_view_rounded,
                tooltip: viewMode == ViewMode.grid ? 'List view' : 'Grid view',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(notesViewModeProvider.notifier).state =
                      viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
                },
              ),
              // Sort button
              _ActionButton(
                icon: Icons.swap_vert_rounded,
                tooltip: 'Sort',
                isActive: sortOption != NotesSortOption.recentlyEdited,
                onPressed: () => _showSortSheet(context, ref),
              ),
              const SizedBox(width: _horizontalPadding - AppSpacing.sm),
            ],
          ),

          // Search bar (animated)
          SliverToBoxAdapter(
            child: AnimatedCrossFade(
              firstChild: _SearchBar(ref: ref),
              secondChild: const SizedBox.shrink(),
              crossFadeState: isSearchActive
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: AppConstants.animStandard,
              sizeCurve: Curves.easeOutCubic,
            ),
          ),

          // Folder chips rail
          SliverToBoxAdapter(
            child: foldersAsync.when(
              data: (folders) => _FolderRail(
                folders: folders,
                currentFolderId: currentFolderId,
                onFolderSelected: (folderId) {
                  HapticFeedback.lightImpact();
                  ref.read(currentFolderIdProvider.notifier).state = folderId;
                },
              ),
              loading: () => const _FolderRailSkeleton(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Notes stats card
          SliverToBoxAdapter(
            child: notesAsync.when(
              data: (notes) {
                if (notes.isEmpty) return const SizedBox.shrink();
                final pinnedCount = notes.where((n) => n.isPinned).length;
                final favCount = notes.where((n) => n.isFavorite).length;
                return _NotesStatsCard(
                  totalNotes: notes.length,
                  pinnedCount: pinnedCount,
                  favoritesCount: favCount,
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // Notes content
          notesAsync.when(
            data: (notes) {
              // Filter by search query
              var filteredNotes = notes;
              if (searchQuery.isNotEmpty) {
                filteredNotes = notes
                    .where((n) =>
                        n.title
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()) ||
                        n.content
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                    .toList();
              }

              // Sort notes
              final sortedNotes = _sortNotes(filteredNotes, sortOption);

              if (sortedNotes.isEmpty) {
                return SliverFillRemaining(
                  child: EmptyState(
                    type: EmptyStateType.notes,
                    subtitle: searchQuery.isNotEmpty
                        ? 'No notes match "$searchQuery"'
                        : 'Capture your thoughts\nTap + to create a note',
                  ),
                );
              }

              // Separate pinned and regular notes
              final pinnedNotes =
                  sortedNotes.where((n) => n.isPinned).toList();
              final regularNotes =
                  sortedNotes.where((n) => !n.isPinned).toList();

              if (viewMode == ViewMode.grid) {
                return _NotesGridView(
                  pinnedNotes: pinnedNotes,
                  regularNotes: regularNotes,
                );
              }

              return _NotesListView(
                pinnedNotes: pinnedNotes,
                regularNotes: regularNotes,
              );
            },
            loading: () => SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: _horizontalPadding),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _NoteCardSkeleton(isGrid: viewMode == ViewMode.grid),
                  ),
                  childCount: 6,
                ),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: ErrorState(
                message: e.toString(),
                onRetry: () => ref.invalidate(watchRootNotesProvider),
              ),
            ),
          ),

          // Bottom padding for FAB clearance
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildRootTitle(BuildContext context, bool isDark) {
    return Padding(
      key: const ValueKey('root-title'),
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Row(
        children: [
          // Notes icon with premium glassmorphic effect
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.tertiary.withValues(alpha: 0.15),
                  AppColors.tertiary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: AppRadius.roundedMd,
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.sticky_note_2_rounded,
              size: 22,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          Text(
            'Notes',
            style: AppTextStyles.headlineMedium.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTitle(
    BuildContext context,
    bool isDark,
    WidgetRef ref,
    String folderName,
  ) {
    return Padding(
      key: const ValueKey('folder-title'),
      padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
      child: Row(
        children: [
          // Back button
          _ActionButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back to all notes',
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.read(currentFolderIdProvider.notifier).state = null;
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          // Folder icon
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.12),
              borderRadius: AppRadius.roundedMd,
            ),
            child: const Icon(
              Icons.folder_rounded,
              size: 18,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              folderName,
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Sort notes based on selected option
  List<Note> _sortNotes(List<Note> notes, NotesSortOption option) {
    final sorted = List<Note>.from(notes);

    switch (option) {
      case NotesSortOption.recentlyEdited:
        sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      case NotesSortOption.recentlyCreated:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case NotesSortOption.alphabetical:
        sorted.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
      case NotesSortOption.pinned:
        sorted.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          return b.updatedAt.compareTo(a.updatedAt);
        });
    }

    return sorted;
  }

  void _showSortSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SortOptionsSheet(ref: ref),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTION BUTTON - Consistent with other screens
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: isActive
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SEARCH BAR
// ═══════════════════════════════════════════════════════════════════════════════

class _SearchBar extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const _SearchBar({required this.ref});

  @override
  ConsumerState<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<_SearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        NotesScreen._horizontalPadding,
        AppSpacing.sm,
        NotesScreen._horizontalPadding,
        AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: TextField(
          controller: _controller,
          autofocus: true,
          style: AppTextStyles.bodyLarge.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _controller.clear();
                      widget.ref.read(notesSearchQueryProvider.notifier).state =
                          '';
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smd,
            ),
          ),
          onChanged: (value) {
            widget.ref.read(notesSearchQueryProvider.notifier).state = value;
            setState(() {});
          },
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FOLDER RAIL - Horizontal scrolling folder chips
// ═══════════════════════════════════════════════════════════════════════════════

class _FolderRail extends StatelessWidget {
  final List<Folder> folders;
  final int? currentFolderId;
  final ValueChanged<int?> onFolderSelected;

  const _FolderRail({
    required this.folders,
    this.currentFolderId,
    required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) return const SizedBox(height: AppSpacing.sm);

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: NotesScreen._horizontalPadding,
          vertical: AppSpacing.sm,
        ),
        itemCount: folders.length + 1, // +1 for "All Notes"
        itemBuilder: (context, index) {
          if (index == 0) {
            return _FolderChip(
              label: 'All Notes',
              icon: Icons.notes_rounded,
              isSelected: currentFolderId == null,
              color: AppColors.tertiary,
              onTap: () => onFolderSelected(null),
            );
          }

          final folder = folders[index - 1];
          return _FolderChip(
            label: folder.name,
            icon: Icons.folder_rounded,
            isSelected: currentFolderId == folder.id,
            color: AppColors.getProjectColor(folder.colorIndex),
            onTap: () => onFolderSelected(folder.id),
          );
        },
      ),
    );
  }
}

class _FolderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FolderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        curve: Curves.easeOutCubic,
        child: Material(
          color: isSelected
              ? color
              : (isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight),
          borderRadius: AppRadius.roundedFull,
          elevation: isSelected ? 2 : 0,
          shadowColor: isSelected ? color.withValues(alpha: 0.4) : null,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.roundedFull,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                borderRadius: AppRadius.roundedFull,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    label,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FolderRailSkeleton extends StatelessWidget {
  const _FolderRailSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;

    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: NotesScreen._horizontalPadding,
          vertical: AppSpacing.sm,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          width: index == 0 ? 100 : 80,
          decoration: BoxDecoration(
            color: shimmerBase,
            borderRadius: AppRadius.roundedFull,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTES STATS CARD - ADHD-friendly progress visualization
// ═══════════════════════════════════════════════════════════════════════════════

class _NotesStatsCard extends StatelessWidget {
  final int totalNotes;
  final int pinnedCount;
  final int favoritesCount;

  const _NotesStatsCard({
    required this.totalNotes,
    required this.pinnedCount,
    required this.favoritesCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: NotesScreen._horizontalPadding,
        vertical: AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.tertiary.withValues(alpha: 0.08),
              AppColors.tertiary.withValues(alpha: 0.04),
            ],
          ),
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: AppColors.tertiary.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            // Brain icon with pulse effect
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.smd),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.tertiary.withValues(alpha: 0.2),
                        AppColors.tertiary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    size: 28,
                    color: AppColors.tertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Second Brain',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '$totalNotes ${totalNotes == 1 ? 'thought' : 'thoughts'} captured',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),

            // Mini stats badges
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (pinnedCount > 0) ...[
                  _MiniStatBadge(
                    value: pinnedCount,
                    icon: Icons.push_pin_rounded,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                if (favoritesCount > 0)
                  _MiniStatBadge(
                    value: favoritesCount,
                    icon: Icons.star_rounded,
                    color: AppColors.warning,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatBadge extends StatelessWidget {
  final int value;
  final IconData icon;
  final Color color;

  const _MiniStatBadge({
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            '$value',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTES GRID VIEW - Premium masonry-style layout
// ═══════════════════════════════════════════════════════════════════════════════

class _NotesGridView extends StatelessWidget {
  final List<Note> pinnedNotes;
  final List<Note> regularNotes;

  const _NotesGridView({
    required this.pinnedNotes,
    required this.regularNotes,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: NotesScreen._horizontalPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Pinned section
          if (pinnedNotes.isNotEmpty) ...[
            _SectionHeader(
              title: 'Pinned',
              icon: Icons.push_pin_rounded,
              color: AppColors.primary,
              count: pinnedNotes.length,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildMasonryGrid(context, pinnedNotes),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Regular notes
          if (regularNotes.isNotEmpty) ...[
            if (pinnedNotes.isNotEmpty)
              _SectionHeader(
                title: 'Notes',
                icon: Icons.sticky_note_2_rounded,
                color: AppColors.tertiary,
                count: regularNotes.length,
              ),
            if (pinnedNotes.isNotEmpty) const SizedBox(height: AppSpacing.sm),
            _buildMasonryGrid(context, regularNotes),
          ],
        ]),
      ),
    );
  }

  Widget _buildMasonryGrid(BuildContext context, List<Note> notes) {
    // Create two columns for masonry effect
    final leftColumn = <Note>[];
    final rightColumn = <Note>[];

    for (var i = 0; i < notes.length; i++) {
      if (i % 2 == 0) {
        leftColumn.add(notes[i]);
      } else {
        rightColumn.add(notes[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn
                .map((note) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
                      child: _NoteGridCard(note: note),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(width: AppSpacing.smd),
        Expanded(
          child: Column(
            children: rightColumn
                .map((note) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.smd),
                      child: _NoteGridCard(note: note),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTES LIST VIEW - Clean vertical list
// ═══════════════════════════════════════════════════════════════════════════════

class _NotesListView extends StatelessWidget {
  final List<Note> pinnedNotes;
  final List<Note> regularNotes;

  const _NotesListView({
    required this.pinnedNotes,
    required this.regularNotes,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: NotesScreen._horizontalPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Pinned section
          if (pinnedNotes.isNotEmpty) ...[
            _SectionHeader(
              title: 'Pinned',
              icon: Icons.push_pin_rounded,
              color: AppColors.primary,
              count: pinnedNotes.length,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...pinnedNotes.asMap().entries.map((entry) {
              final index = entry.key;
              final note = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < pinnedNotes.length - 1 ? AppSpacing.xs : 0,
                ),
                child: _NoteListCard(note: note),
              );
            }),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Regular notes
          if (regularNotes.isNotEmpty) ...[
            if (pinnedNotes.isNotEmpty)
              _SectionHeader(
                title: 'Notes',
                icon: Icons.sticky_note_2_rounded,
                color: AppColors.tertiary,
                count: regularNotes.length,
              ),
            if (pinnedNotes.isNotEmpty) const SizedBox(height: AppSpacing.sm),
            ...regularNotes.asMap().entries.map((entry) {
              final index = entry.key;
              final note = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < regularNotes.length - 1 ? AppSpacing.xs : 0,
                ),
                child: _NoteListCard(note: note),
              );
            }),
          ],
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER - Consistent with other screens
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final int? count;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // Color accent bar
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.roundedFull,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),

        // Icon
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),

        // Title
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),

        // Count badge
        if (count != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.roundedFull,
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTE GRID CARD - Premium masonry card design
// ═══════════════════════════════════════════════════════════════════════════════

class _NoteGridCard extends StatelessWidget {
  final Note note;

  const _NoteGridCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPreview = note.preview.isNotEmpty;

    // Calculate dynamic height based on content
    final previewLines = hasPreview ? (note.preview.length ~/ 40).clamp(1, 6) : 0;

    return AnimatedContainer(
      duration: AppConstants.animFast,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: note.isPinned
              ? AppColors.primary.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: note.isPinned ? 1.5 : 1,
        ),
        boxShadow: note.isPinned
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.roundedLg,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to note detail
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            // TODO: Show note options
          },
          borderRadius: AppRadius.roundedLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with pin and favorite
                Row(
                  children: [
                    if (note.isPinned)
                      Icon(
                        Icons.push_pin_rounded,
                        size: 14,
                        color: AppColors.primary.withValues(alpha: 0.8),
                      ),
                    const Spacer(),
                    if (note.isFavorite)
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: AppColors.warning,
                      ),
                  ],
                ),
                if (note.isPinned || note.isFavorite)
                  const SizedBox(height: AppSpacing.sm),

                // Title
                Text(
                  note.title.isEmpty ? 'Untitled' : note.title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Preview
                if (hasPreview) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    note.preview,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      height: 1.5,
                    ),
                    maxLines: previewLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: AppSpacing.smd),

                // Footer with date and links
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 12,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Expanded(
                      child: Text(
                        _formatDate(note.updatedAt),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (note.linkedTaskIds.isNotEmpty)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.link_rounded,
                            size: 12,
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${note.linkedTaskIds.length}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary.withValues(alpha: 0.8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.month}/${date.day}/${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTE LIST CARD - Premium list item design
// ═══════════════════════════════════════════════════════════════════════════════

class _NoteListCard extends StatelessWidget {
  final Note note;

  const _NoteListCard({required this.note});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasPreview = note.preview.isNotEmpty;

    return AnimatedContainer(
      duration: AppConstants.animFast,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: note.isPinned
              ? AppColors.primary.withValues(alpha: 0.3)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to note detail
          },
          onLongPress: () {
            HapticFeedback.mediumImpact();
            // TODO: Show note options
          },
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Leading indicators
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (note.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: note.isFavorite
                            ? AppColors.warning
                            : AppColors.tertiary.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.smd),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        note.title.isEmpty ? 'Untitled' : note.title,
                        style: AppTextStyles.titleSmall.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Preview
                      if (hasPreview) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          note.preview,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: AppSpacing.sm),

                      // Metadata row
                      Row(
                        children: [
                          Text(
                            _formatDate(note.updatedAt),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                          if (note.linkedTaskIds.isNotEmpty) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Icon(
                              Icons.link_rounded,
                              size: 12,
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${note.linkedTaskIds.length} linked',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiaryLight,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isDark
                      ? AppColors.textDisabledDark
                      : AppColors.textDisabledLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.month}/${date.day}/${date.year}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// NOTE CARD SKELETON - Loading state
// ═══════════════════════════════════════════════════════════════════════════════

class _NoteCardSkeleton extends StatelessWidget {
  final bool isGrid;

  const _NoteCardSkeleton({this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase =
        isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;

    if (isGrid) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerBase,
                borderRadius: AppRadius.roundedXs,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: shimmerBase.withValues(alpha: 0.6),
                borderRadius: AppRadius.roundedXs,
              ),
            ),
            const Spacer(),
            Container(
              height: 10,
              width: 60,
              decoration: BoxDecoration(
                color: shimmerBase.withValues(alpha: 0.4),
                borderRadius: AppRadius.roundedXs,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: AppRadius.roundedXs,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 10,
                  width: 150,
                  decoration: BoxDecoration(
                    color: shimmerBase.withValues(alpha: 0.6),
                    borderRadius: AppRadius.roundedXs,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 10,
                  width: 80,
                  decoration: BoxDecoration(
                    color: shimmerBase.withValues(alpha: 0.4),
                    borderRadius: AppRadius.roundedXs,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: shimmerBase.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SORT OPTIONS SHEET
// ═══════════════════════════════════════════════════════════════════════════════

class _SortOptionsSheet extends StatelessWidget {
  final WidgetRef ref;

  const _SortOptionsSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSort = ref.watch(notesSortOptionProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.smd),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedMd,
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.tertiary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),
                Text(
                  'Sort Notes',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sort options
          ...NotesSortOption.values.map((option) {
            final isSelected = currentSort == option;
            return ListTile(
              leading: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.tertiary.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Icon(
                  option.icon,
                  size: 20,
                  color: isSelected
                      ? AppColors.tertiary
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
              title: Text(
                option.label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isSelected
                      ? AppColors.tertiary
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: AppColors.tertiary,
                      size: 20,
                    )
                  : null,
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(notesSortOptionProvider.notifier).state = option;
                Navigator.pop(context);
              },
            );
          }),

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}
