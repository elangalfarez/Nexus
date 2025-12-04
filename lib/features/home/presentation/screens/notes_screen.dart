// lib/features/home/presentation/screens/notes_screen.dart
// Notes list with grid/list toggle and folder navigation

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../notes/data/models/note_model.dart';
import '../../../notes/data/models/folder_model.dart';
import '../../../notes/presentation/providers/note_providers.dart';
import '../../../notes/presentation/providers/folder_providers.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../widgets/quick_capture_sheet.dart';

/// View mode for notes
final notesViewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.list);

/// Current folder ID (null = root)
final currentFolderIdProvider = StateProvider<int?>((ref) => null);

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final viewMode = ref.watch(notesViewModeProvider);
    final currentFolderId = ref.watch(currentFolderIdProvider);

    // Watch notes based on current folder
    final notesAsync = currentFolderId == null
        ? ref.watch(rootNotesProvider)
        : ref.watch(notesByFolderProvider(currentFolderId));

    final pinnedAsync = ref.watch(pinnedNotesProvider);
    final foldersAsync = currentFolderId == null
        ? ref.watch(rootFoldersProvider)
        : ref.watch(childFoldersProvider(currentFolderId));

    // Get current folder info if in subfolder
    final currentFolderAsync = currentFolderId != null
        ? ref.watch(folderByIdProvider(currentFolderId))
        : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            backgroundColor: isDark
                ? AppColors.backgroundDark
                : AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: currentFolderId != null
                ? IconButton(
                    onPressed: () {
                      // Go back to parent folder
                      final currentFolder = currentFolderAsync?.valueOrNull;
                      ref.read(currentFolderIdProvider.notifier).state =
                          currentFolder?.parentFolderId;
                    },
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurface,
                    ),
                  )
                : null,
            title: Text(
              currentFolderAsync?.valueOrNull?.name ?? 'Notes',
              style: AppTextStyles.headlineMedium.copyWith(
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
              ),
            ),
            actions: [
              // Search
              IconButton(
                onPressed: () {
                  // TODO: Navigate to search
                },
                icon: Icon(
                  Icons.search,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
              ),
              // View toggle
              IconButton(
                onPressed: () {
                  final current = ref.read(notesViewModeProvider);
                  ref.read(notesViewModeProvider.notifier).state =
                      current == ViewMode.list ? ViewMode.grid : ViewMode.list;
                },
                icon: Icon(
                  viewMode == ViewMode.list ? Icons.grid_view : Icons.view_list,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                tooltip: viewMode == ViewMode.list ? 'Grid view' : 'List view',
              ),
              // Add note
              IconButton(
                onPressed: () {
                  QuickCaptureSheet.show(
                    context,
                    initialType: CaptureType.note,
                    defaultFolderId: currentFolderId,
                  );
                },
                icon: Icon(
                  Icons.add,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                tooltip: 'New note',
              ),
              SizedBox(width: AppSpacing.xs),
            ],
          ),

          // Content
          _NotesContent(
            viewMode: viewMode,
            notesAsync: notesAsync,
            pinnedAsync: currentFolderId == null ? pinnedAsync : null,
            foldersAsync: foldersAsync,
            currentFolderId: currentFolderId,
          ),
        ],
      ),
    );
  }
}

/// Notes content builder
class _NotesContent extends ConsumerWidget {
  final ViewMode viewMode;
  final AsyncValue<List<Note>> notesAsync;
  final AsyncValue<List<Note>>? pinnedAsync;
  final AsyncValue<List<Folder>> foldersAsync;
  final int? currentFolderId;

  const _NotesContent({
    required this.viewMode,
    required this.notesAsync,
    this.pinnedAsync,
    required this.foldersAsync,
    this.currentFolderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Loading state
    if (notesAsync.isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Error state
    if (notesAsync.hasError) {
      return SliverFillRemaining(
        child: ErrorState(
          message: notesAsync.error.toString(),
          onRetry: () {
            if (currentFolderId == null) {
              ref.invalidate(rootNotesProvider);
            } else {
              ref.invalidate(notesByFolderProvider(currentFolderId!));
            }
          },
        ),
      );
    }

    final notes = notesAsync.value ?? [];
    final pinnedNotes = pinnedAsync?.value ?? [];
    final folders = foldersAsync.value ?? [];

    // Filter out pinned from regular notes if showing pinned section
    final regularNotes = pinnedAsync != null
        ? notes.where((n) => !n.isPinned).toList()
        : notes;

    // Empty state
    if (notes.isEmpty && folders.isEmpty && pinnedNotes.isEmpty) {
      return SliverFillRemaining(
        child: EmptyState(
          type: currentFolderId == null
              ? EmptyStateType.notes
              : EmptyStateType.folder,
          actionLabel: 'Create note',
          onAction: () {
            QuickCaptureSheet.show(
              context,
              initialType: CaptureType.note,
              defaultFolderId: currentFolderId,
            );
          },
        ),
      );
    }

    if (viewMode == ViewMode.grid) {
      return _NotesGrid(
        pinnedNotes: pinnedNotes,
        folders: folders,
        notes: regularNotes,
      );
    }

    return _NotesList(
      pinnedNotes: pinnedNotes,
      folders: folders,
      notes: regularNotes,
    );
  }
}

/// List view for notes
class _NotesList extends ConsumerWidget {
  final List<Note> pinnedNotes;
  final List<Folder> folders;
  final List<Note> notes;

  const _NotesList({
    required this.pinnedNotes,
    required this.folders,
    required this.notes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SliverList(
      delegate: SliverChildListDelegate([
        // Pinned section
        if (pinnedNotes.isNotEmpty) ...[
          _SectionHeader(title: 'Pinned', icon: Icons.push_pin),
          ...pinnedNotes.map(
            (note) => NoteListCard(
              note: note,
              onTap: () {
                // TODO: Navigate to note
              },
              onLongPress: () {
                // TODO: Show note options
              },
            ),
          ),
          SizedBox(height: AppSpacing.md),
        ],

        // Folders
        if (folders.isNotEmpty) ...[
          _SectionHeader(title: 'Folders', icon: Icons.folder_outlined),
          ...folders.map((folder) => _FolderListItem(folder: folder)),
          SizedBox(height: AppSpacing.md),
        ],

        // Notes
        if (notes.isNotEmpty) ...[
          if (pinnedNotes.isNotEmpty || folders.isNotEmpty)
            _SectionHeader(title: 'Notes'),
          ...notes.map(
            (note) => NoteListCard(
              note: note,
              onTap: () {
                // TODO: Navigate to note
              },
              onLongPress: () {
                // TODO: Show note options
              },
            ),
          ),
        ],

        // Bottom padding
        SizedBox(height: AppSpacing.huge),
      ]),
    );
  }
}

/// Grid view for notes
class _NotesGrid extends ConsumerWidget {
  final List<Note> pinnedNotes;
  final List<Folder> folders;
  final List<Note> notes;

  const _NotesGrid({
    required this.pinnedNotes,
    required this.folders,
    required this.notes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: EdgeInsets.all(AppSpacing.md),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.85,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          // Pinned notes first
          if (index < pinnedNotes.length) {
            return NoteGridCard(
              note: pinnedNotes[index],
              onTap: () {
                // TODO: Navigate to note
              },
            );
          }

          // Then folders
          final folderIndex = index - pinnedNotes.length;
          if (folderIndex < folders.length) {
            return _FolderGridItem(folder: folders[folderIndex]);
          }

          // Then regular notes
          final noteIndex = index - pinnedNotes.length - folders.length;
          return NoteGridCard(
            note: notes[noteIndex],
            onTap: () {
              // TODO: Navigate to note
            },
          );
        }, childCount: pinnedNotes.length + folders.length + notes.length),
      ),
    );
  }
}

/// Section header
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;

  const _SectionHeader({required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.xs),
          ],
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Folder list item
class _FolderListItem extends ConsumerWidget {
  final Folder folder;

  const _FolderListItem({required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final folderColor = AppColors.getProjectColor(folder.colorIndex);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(currentFolderIdProvider.notifier).state = folder.id;
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: folderColor.withOpacity(0.15),
                  borderRadius: AppRadius.allSm,
                ),
                child: Icon(Icons.folder, size: 20, color: folderColor),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  folder.name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Folder grid item
class _FolderGridItem extends ConsumerWidget {
  final Folder folder;

  const _FolderGridItem({required this.folder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final folderColor = AppColors.getProjectColor(folder.colorIndex);

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surface,
      borderRadius: AppRadius.cardRadius,
      child: InkWell(
        onTap: () {
          ref.read(currentFolderIdProvider.notifier).state = folder.id;
        },
        borderRadius: AppRadius.cardRadius,
        child: Container(
          padding: AppSpacing.card,
          decoration: BoxDecoration(
            borderRadius: AppRadius.cardRadius,
            border: Border.all(
              color: isDark ? AppColors.outlineDark : AppColors.outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: folderColor.withOpacity(0.15),
                  borderRadius: AppRadius.allSm,
                ),
                child: Icon(Icons.folder, size: 24, color: folderColor),
              ),
              const Spacer(),
              Text(
                folder.name,
                style: AppTextStyles.titleSmall.copyWith(
                  color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
