// lib/features/notes/data/repositories/note_repository.dart
// Repository for note CRUD operations with Isar

import 'package:isar/isar.dart';
import '../../../../core/services/database_service.dart';
import '../models/note_model.dart';

/// Repository for note operations
class NoteRepository {
  final Isar _db;

  NoteRepository() : _db = DatabaseService.instance;

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  /// Create a new note
  Future<Note> create(Note note) async {
    await _db.writeTxn(() async {
      await _db.notes.put(note);
    });
    return note;
  }

  /// Get note by ID
  Future<Note?> getById(int id) {
    return _db.notes.get(id);
  }

  /// Get note by UID
  Future<Note?> getByUid(String uid) {
    return _db.notes.filter().uidEqualTo(uid).findFirst();
  }

  /// Get note by title (for wiki linking)
  Future<Note?> getByTitle(String title) {
    return _db.notes
        .filter()
        .titleEqualTo(title, caseSensitive: false)
        .isDeletedEqualTo(false)
        .findFirst();
  }

  /// Update a note
  Future<Note> update(Note note) async {
    note.updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.notes.put(note);
    });
    return note;
  }

  /// Delete a note (soft delete)
  Future<void> softDelete(int id) async {
    final note = await getById(id);
    if (note != null) {
      await update(note.softDelete());
    }
  }

  /// Delete a note (hard delete)
  Future<void> hardDelete(int id) async {
    await _db.writeTxn(() async {
      await _db.notes.delete(id);
    });
  }

  /// Delete multiple notes
  Future<void> deleteMany(List<int> ids) async {
    await _db.writeTxn(() async {
      await _db.notes.deleteAll(ids);
    });
  }

  // ============================================
  // QUERIES - ALL NOTES
  // ============================================

  /// Get all notes (excluding deleted)
  Future<List<Note>> getAll() {
    return _db.notes
        .filter()
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Watch all notes
  Stream<List<Note>> watchAll() {
    return _db.notes
        .filter()
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Get note count
  Future<int> count() {
    return _db.notes
        .filter()
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .count();
  }

  // ============================================
  // QUERIES - BY FOLDER
  // ============================================

  /// Get notes by folder
  Future<List<Note>> getByFolder(int folderId) {
    return _db.notes
        .filter()
        .folderIdEqualTo(folderId)
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Watch notes by folder
  Stream<List<Note>> watchByFolder(int folderId) {
    return _db.notes
        .filter()
        .folderIdEqualTo(folderId)
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Get root notes (no folder)
  Future<List<Note>> getRootNotes() {
    return _db.notes
        .filter()
        .folderIdIsNull()
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Watch root notes
  Stream<List<Note>> watchRootNotes() {
    return _db.notes
        .filter()
        .folderIdIsNull()
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  // ============================================
  // QUERIES - PINNED & FAVORITES
  // ============================================

  /// Get pinned notes
  Future<List<Note>> getPinned() {
    return _db.notes
        .filter()
        .isPinnedEqualTo(true)
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Watch pinned notes
  Stream<List<Note>> watchPinned() {
    return _db.notes
        .filter()
        .isPinnedEqualTo(true)
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Get favorite notes
  Future<List<Note>> getFavorites() {
    return _db.notes
        .filter()
        .isFavoriteEqualTo(true)
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  // ============================================
  // QUERIES - RECENT
  // ============================================

  /// Get recently updated notes
  Future<List<Note>> getRecent({int limit = 10}) {
    return _db.notes
        .filter()
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// Get recently viewed notes
  Future<List<Note>> getRecentlyViewed({int limit = 10}) {
    return _db.notes
        .filter()
        .lastViewedAtIsNotNull()
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByLastViewedAtDesc()
        .limit(limit)
        .findAll();
  }

  // ============================================
  // QUERIES - TEMPLATES
  // ============================================

  /// Get all templates
  Future<List<Note>> getTemplates() {
    return _db.notes
        .filter()
        .isTemplateEqualTo(true)
        .isDeletedEqualTo(false)
        .sortByTitle()
        .findAll();
  }

  /// Watch templates
  Stream<List<Note>> watchTemplates() {
    return _db.notes
        .filter()
        .isTemplateEqualTo(true)
        .isDeletedEqualTo(false)
        .sortByTitle()
        .watch(fireImmediately: true);
  }

  // ============================================
  // SEARCH
  // ============================================

  /// Search notes by title
  Future<List<Note>> searchByTitle(String query) {
    if (query.isEmpty) return Future.value([]);

    return _db.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Search notes by content
  Future<List<Note>> searchByContent(String query) {
    if (query.isEmpty) return Future.value([]);

    return _db.notes
        .filter()
        .contentContains(query, caseSensitive: false)
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  /// Full search (title + content)
  Future<List<Note>> search(String query) async {
    if (query.isEmpty) return [];

    // Search both title and content
    final byTitle = await searchByTitle(query);
    final byContent = await searchByContent(query);

    // Merge and deduplicate
    final results = <int, Note>{};
    for (final note in byTitle) {
      results[note.id] = note;
    }
    for (final note in byContent) {
      results[note.id] = note;
    }

    // Sort by updated date
    final list = results.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  /// Find notes that link to a specific title (for suggestions)
  Future<List<Note>> findByWikiLink(String targetTitle) async {
    final pattern = '[[${targetTitle.toLowerCase()}]]';
    return _db.notes
        .filter()
        .contentContains(pattern, caseSensitive: false)
        .isDeletedEqualTo(false)
        .findAll();
  }

  // ============================================
  // WIKI LINKING
  // ============================================

  /// Get or create note by title (for wiki linking)
  Future<Note> getOrCreateByTitle(String title) async {
    final existing = await getByTitle(title);
    if (existing != null) return existing;

    // Create new note with this title
    final note = Note.create(title: title);
    return create(note);
  }

  /// Find notes with similar titles (for autocomplete)
  Future<List<Note>> findSimilarTitles(String query, {int limit = 5}) {
    if (query.isEmpty) return Future.value([]);

    return _db.notes
        .filter()
        .titleContains(query, caseSensitive: false)
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .sortByTitle()
        .limit(limit)
        .findAll();
  }

  // ============================================
  // BATCH OPERATIONS
  // ============================================

  /// Move notes to folder
  Future<void> moveToFolder(List<int> ids, int? folderId) async {
    await _db.writeTxn(() async {
      for (final id in ids) {
        final note = await _db.notes.get(id);
        if (note != null) {
          note.folderId = folderId;
          note.updatedAt = DateTime.now();
          await _db.notes.put(note);
        }
      }
    });
  }

  /// Pin multiple notes
  Future<void> pinMany(List<int> ids) async {
    await _db.writeTxn(() async {
      for (final id in ids) {
        final note = await _db.notes.get(id);
        if (note != null && !note.isPinned) {
          note.isPinned = true;
          note.updatedAt = DateTime.now();
          await _db.notes.put(note);
        }
      }
    });
  }

  /// Unpin multiple notes
  Future<void> unpinMany(List<int> ids) async {
    await _db.writeTxn(() async {
      for (final id in ids) {
        final note = await _db.notes.get(id);
        if (note != null && note.isPinned) {
          note.isPinned = false;
          note.updatedAt = DateTime.now();
          await _db.notes.put(note);
        }
      }
    });
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Get note statistics
  Future<NoteStats> getStats() async {
    final total = await _db.notes
        .filter()
        .isDeletedEqualTo(false)
        .isTemplateEqualTo(false)
        .count();

    final pinned = await _db.notes
        .filter()
        .isPinnedEqualTo(true)
        .isDeletedEqualTo(false)
        .count();

    final notes = await getAll();
    final totalWords = notes.fold<int>(0, (sum, n) => sum + n.wordCount);

    return NoteStats(total: total, pinned: pinned, totalWords: totalWords);
  }
}

/// Note statistics data class
class NoteStats {
  final int total;
  final int pinned;
  final int totalWords;

  const NoteStats({
    required this.total,
    required this.pinned,
    required this.totalWords,
  });
}
