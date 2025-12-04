// lib/features/notes/presentation/providers/folder_providers.dart
// Riverpod providers for folder state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../../core/services/database_service.dart';
import '../../data/models/folder_model.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

/// Folder repository provider
final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepository();
});

/// Simple folder repository class
class FolderRepository {
  final Isar _db = DatabaseService.instance;

  // CRUD Operations
  Future<Folder> create(Folder folder) async {
    await _db.writeTxn(() async {
      await _db.folders.put(folder);
    });
    return folder;
  }

  Future<Folder?> getById(int id) => _db.folders.get(id);

  Future<Folder> update(Folder folder) async {
    folder.updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.folders.put(folder);
    });
    return folder;
  }

  Future<void> softDelete(int id) async {
    final folder = await getById(id);
    if (folder != null) {
      await update(folder.softDelete());
    }
  }

  // Queries
  Future<List<Folder>> getAll() {
    return _db.folders
        .filter()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  Stream<List<Folder>> watchAll() {
    return _db.folders
        .filter()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  Future<List<Folder>> getRootFolders() {
    return _db.folders
        .filter()
        .parentFolderIdIsNull()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  Stream<List<Folder>> watchRootFolders() {
    return _db.folders
        .filter()
        .parentFolderIdIsNull()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  Future<List<Folder>> getChildFolders(int parentId) {
    return _db.folders
        .filter()
        .parentFolderIdEqualTo(parentId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  Stream<List<Folder>> watchChildFolders(int parentId) {
    return _db.folders
        .filter()
        .parentFolderIdEqualTo(parentId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  Future<void> reorder(List<int> orderedIds) async {
    await _db.writeTxn(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        final folder = await _db.folders.get(orderedIds[i]);
        if (folder != null) {
          folder.sortOrder = i;
          folder.updatedAt = DateTime.now();
          await _db.folders.put(folder);
        }
      }
    });
  }
}

// ============================================
// FOLDER LIST PROVIDERS
// ============================================

/// All folders stream
final allFoldersProvider = StreamProvider<List<Folder>>((ref) {
  final repo = ref.watch(folderRepositoryProvider);
  return repo.watchAll();
});

/// Root folders stream (no parent)
final rootFoldersProvider = StreamProvider<List<Folder>>((ref) {
  final repo = ref.watch(folderRepositoryProvider);
  return repo.watchRootFolders();
});

/// Child folders by parent
final childFoldersProvider = StreamProvider.family<List<Folder>, int>((
  ref,
  parentId,
) {
  final repo = ref.watch(folderRepositoryProvider);
  return repo.watchChildFolders(parentId);
});

// ============================================
// SINGLE FOLDER PROVIDERS
// ============================================

/// Single folder by ID
final folderByIdProvider = FutureProvider.family<Folder?, int>((ref, id) {
  final repo = ref.watch(folderRepositoryProvider);
  return repo.getById(id);
});

// ============================================
// FOLDER ACTIONS (NOTIFIER)
// ============================================

/// Folder actions notifier for mutations
class FolderActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final FolderRepository _repo;

  FolderActionsNotifier(this._repo) : super(const AsyncValue.data(null));

  /// Create a new folder
  Future<Folder?> createFolder({
    required String name,
    int? parentFolderId,
    int colorIndex = 0,
    String iconName = 'folder',
  }) async {
    state = const AsyncValue.loading();
    try {
      final folder = Folder.create(
        name: name,
        parentFolderId: parentFolderId,
        colorIndex: colorIndex,
        iconName: iconName,
      );

      final created = await _repo.create(folder);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update a folder
  Future<Folder?> updateFolder(Folder folder) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repo.update(folder);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Toggle folder expanded state
  Future<void> toggleExpanded(int folderId) async {
    try {
      final folder = await _repo.getById(folderId);
      if (folder != null) {
        await _repo.update(folder.toggleExpanded());
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Delete a folder (soft)
  Future<void> deleteFolder(int folderId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.softDelete(folderId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reorder folders
  Future<void> reorderFolders(List<int> orderedIds) async {
    state = const AsyncValue.loading();
    try {
      await _repo.reorder(orderedIds);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Move folder to new parent
  Future<void> moveFolder(int folderId, int? newParentId) async {
    state = const AsyncValue.loading();
    try {
      final folder = await _repo.getById(folderId);
      if (folder != null) {
        await _repo.update(folder.copyWith(parentFolderId: newParentId));
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Folder actions provider
final folderActionsProvider =
    StateNotifierProvider<FolderActionsNotifier, AsyncValue<void>>((ref) {
      final repo = ref.watch(folderRepositoryProvider);
      return FolderActionsNotifier(repo);
    });

// ============================================
// SELECTED FOLDER STATE
// ============================================

/// Currently selected folder ID
final selectedFolderIdProvider = StateProvider<int?>((ref) => null);

/// Currently selected folder
final selectedFolderProvider = FutureProvider<Folder?>((ref) {
  final folderId = ref.watch(selectedFolderIdProvider);
  if (folderId == null) return Future.value(null);

  final repo = ref.watch(folderRepositoryProvider);
  return repo.getById(folderId);
});

// ============================================
// FOLDER TREE STATE
// ============================================

/// Folder tree item for display
class FolderTreeItem {
  final Folder folder;
  final int depth;
  final List<FolderTreeItem> children;

  const FolderTreeItem({
    required this.folder,
    required this.depth,
    this.children = const [],
  });
}

/// Build folder tree
final folderTreeProvider = FutureProvider<List<FolderTreeItem>>((ref) async {
  final repo = ref.watch(folderRepositoryProvider);
  final rootFolders = await repo.getRootFolders();

  Future<List<FolderTreeItem>> buildTree(
    List<Folder> folders,
    int depth,
  ) async {
    final items = <FolderTreeItem>[];
    for (final folder in folders) {
      final children = await repo.getChildFolders(folder.id);
      final childItems = await buildTree(children, depth + 1);
      items.add(
        FolderTreeItem(folder: folder, depth: depth, children: childItems),
      );
    }
    return items;
  }

  return buildTree(rootFolders, 0);
});
