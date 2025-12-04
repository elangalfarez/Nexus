// lib/features/organization/presentation/providers/tag_providers.dart
// Riverpod providers for tag state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../../core/services/database_service.dart';
import '../../data/models/tag_model.dart';

// ============================================
// REPOSITORY
// ============================================

/// Tag repository
class TagRepository {
  final Isar _db = DatabaseService.instance;

  // CRUD
  Future<Tag> create(Tag tag) async {
    await _db.writeTxn(() async {
      await _db.tags.put(tag);
    });
    return tag;
  }

  Future<Tag?> getById(int id) => _db.tags.get(id);

  Future<Tag?> getByName(String name) {
    return _db.tags
        .filter()
        .nameEqualTo(name.toLowerCase(), caseSensitive: false)
        .findFirst();
  }

  Future<Tag> update(Tag tag) async {
    tag.updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.tags.put(tag);
    });
    return tag;
  }

  Future<void> softDelete(int id) async {
    final tag = await getById(id);
    if (tag != null) {
      await update(tag.softDelete());
    }
  }

  // Queries
  Future<List<Tag>> getAll() {
    return _db.tags
        .filter()
        .isDeletedEqualTo(false)
        .sortByUsageCountDesc()
        .findAll();
  }

  Stream<List<Tag>> watchAll() {
    return _db.tags
        .filter()
        .isDeletedEqualTo(false)
        .sortByUsageCountDesc()
        .watch(fireImmediately: true);
  }

  Future<List<Tag>> search(String query) {
    if (query.isEmpty) return Future.value([]);
    return _db.tags
        .filter()
        .nameContains(query, caseSensitive: false)
        .isDeletedEqualTo(false)
        .sortByUsageCountDesc()
        .findAll();
  }

  Future<Tag> getOrCreate(String name) async {
    final existing = await getByName(name);
    if (existing != null) return existing;

    final tag = Tag.create(name: name);
    return create(tag);
  }

  Future<void> incrementUsage(int id) async {
    final tag = await getById(id);
    if (tag != null) {
      await update(tag.incrementUsage());
    }
  }

  Future<void> decrementUsage(int id) async {
    final tag = await getById(id);
    if (tag != null) {
      await update(tag.decrementUsage());
    }
  }
}

/// Tag repository provider
final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepository();
});

// ============================================
// PROVIDERS
// ============================================

/// All tags stream
final allTagsProvider = StreamProvider<List<Tag>>((ref) {
  final repo = ref.watch(tagRepositoryProvider);
  return repo.watchAll();
});

/// Tag by ID
final tagByIdProvider = FutureProvider.family<Tag?, int>((ref, id) {
  final repo = ref.watch(tagRepositoryProvider);
  return repo.getById(id);
});

/// Tag search
final tagSearchQueryProvider = StateProvider<String>((ref) => '');

final tagSearchResultsProvider = FutureProvider<List<Tag>>((ref) {
  final query = ref.watch(tagSearchQueryProvider);
  final repo = ref.watch(tagRepositoryProvider);
  return repo.search(query);
});

// ============================================
// ACTIONS
// ============================================

class TagActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final TagRepository _repo;

  TagActionsNotifier(this._repo) : super(const AsyncValue.data(null));

  Future<Tag?> createTag({required String name, int colorIndex = 0}) async {
    state = const AsyncValue.loading();
    try {
      final tag = Tag.create(name: name, colorIndex: colorIndex);
      final created = await _repo.create(tag);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  Future<Tag?> getOrCreateTag(String name) async {
    try {
      return await _repo.getOrCreate(name);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateTag(Tag tag) async {
    state = const AsyncValue.loading();
    try {
      await _repo.update(tag);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteTag(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.softDelete(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final tagActionsProvider =
    StateNotifierProvider<TagActionsNotifier, AsyncValue<void>>((ref) {
      final repo = ref.watch(tagRepositoryProvider);
      return TagActionsNotifier(repo);
    });

// ============================================
// SELECTED TAGS
// ============================================

/// Currently selected tag IDs (for filtering)
final selectedTagIdsProvider = StateProvider<Set<int>>((ref) => {});

/// Toggle tag selection
void toggleTagSelection(WidgetRef ref, int tagId) {
  final currentSelection = ref.read(selectedTagIdsProvider);
  final newSelection = Set<int>.from(currentSelection);

  if (newSelection.contains(tagId)) {
    newSelection.remove(tagId);
  } else {
    newSelection.add(tagId);
  }

  ref.read(selectedTagIdsProvider.notifier).state = newSelection;
}

/// Clear tag selection
void clearTagSelection(WidgetRef ref) {
  ref.read(selectedTagIdsProvider.notifier).state = {};
}
