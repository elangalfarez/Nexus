// lib/features/notes/presentation/providers/note_providers.dart
// Riverpod providers for note state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/note_model.dart';
import '../../data/repositories/note_repository.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

// ============================================
// NOTE CRUD PROVIDERS
// ============================================

/// Get all notes (excluding deleted)
final allNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getAll();
});

/// Watch all notes (stream)
final watchAllNotesProvider = StreamProvider<List<Note>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.watchAll();
});

/// Get note by ID
final noteByIdProvider = FutureProvider.family<Note?, int>((ref, id) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getById(id);
});

/// Get notes in root folder (no folder)
final rootNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getRootNotes();
});

/// Watch root notes
final watchRootNotesProvider = StreamProvider<List<Note>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.watchRootNotes();
});

/// Get notes by folder ID
final notesByFolderProvider =
    FutureProvider.family<List<Note>, int?>((ref, folderId) async {
  final repo = ref.watch(noteRepositoryProvider);
  if (folderId == null) return repo.getRootNotes();
  return repo.getByFolder(folderId);
});

/// Watch notes by folder ID
final watchNotesByFolderProvider =
    StreamProvider.family<List<Note>, int?>((ref, folderId) {
  final repo = ref.watch(noteRepositoryProvider);
  if (folderId == null) return repo.watchRootNotes();
  return repo.watchByFolder(folderId);
});

/// Get pinned notes
final pinnedNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getPinned();
});

/// Watch pinned notes
final watchPinnedNotesProvider = StreamProvider<List<Note>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.watchPinned();
});

/// Get favorite notes
final favoriteNotesProvider = FutureProvider<List<Note>>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getFavorites();
});

/// Watch favorite notes
final watchFavoriteNotesProvider = StreamProvider<List<Note>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.watchFavorites();
});

/// Get recent notes (last viewed)
final recentNotesProvider =
    FutureProvider.family<List<Note>, int>((ref, limit) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.getRecent(limit: limit);
});

// ============================================
// SEARCH PROVIDERS
// ============================================

/// Search notes by query
final searchNotesProvider =
    FutureProvider.family<List<Note>, String>((ref, query) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.search(query);
});

// ============================================
// STATISTICS PROVIDERS
// ============================================

/// Get total note count
final noteCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.count();
});

/// Get note count by folder
final noteCountByFolderProvider =
    FutureProvider.family<int, int?>((ref, folderId) async {
  final repo = ref.watch(noteRepositoryProvider);
  if (folderId == null) return repo.countRootNotes();
  return repo.countByFolder(folderId);
});

// ============================================
// NOTE ACTIONS (StateNotifier for mutations)
// ============================================

final noteActionsProvider =
    StateNotifierProvider<NoteActionsNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return NoteActionsNotifier(repo);
});

class NoteActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final NoteRepository _repo;

  NoteActionsNotifier(this._repo) : super(const AsyncValue.data(null));

  /// Create a new note
  Future<Note?> createNote({
    required String title,
    String content = '',
    int? folderId,
    bool isPinned = false,
    bool isFavorite = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final note = Note.create(
        title: title,
        content: content,
        folderId: folderId,
        isPinned: isPinned,
        isFavorite: isFavorite,
      );

      final created = await _repo.create(note);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update a note
  Future<Note?> updateNote(Note note) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repo.update(note);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Toggle pin status
  Future<void> togglePin(int noteId) async {
    state = const AsyncValue.loading();
    try {
      final note = await _repo.getById(noteId);
      if (note != null) {
        await _repo.update(note.togglePinned());
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(int noteId) async {
    state = const AsyncValue.loading();
    try {
      final note = await _repo.getById(noteId);
      if (note != null) {
        await _repo.update(note.toggleFavorite());
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Move note to folder
  Future<void> moveToFolder(int noteId, int? folderId) async {
    state = const AsyncValue.loading();
    try {
      final note = await _repo.getById(noteId);
      if (note != null) {
        await _repo.update(note.copyWith(folderId: folderId, clearFolder: folderId == null));
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Update content
  Future<void> updateContent(int noteId, String content) async {
    state = const AsyncValue.loading();
    try {
      final note = await _repo.getById(noteId);
      if (note != null) {
        await _repo.update(note.copyWith(content: content));
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Soft delete note
  Future<void> deleteNote(int noteId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.softDelete(noteId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Hard delete note
  Future<void> permanentlyDeleteNote(int noteId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.hardDelete(noteId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Restore deleted note
  Future<void> restoreNote(int noteId) async {
    state = const AsyncValue.loading();
    try {
      final note = await _repo.getById(noteId);
      if (note != null && note.isDeleted) {
        await _repo.update(note.restore());
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
