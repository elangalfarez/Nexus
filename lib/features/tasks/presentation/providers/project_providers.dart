// lib/features/tasks/presentation/providers/project_providers.dart
// Riverpod providers for project state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project_model.dart';
import '../../data/models/section_model.dart';
import '../../data/repositories/project_repository.dart';

// ============================================
// REPOSITORY PROVIDERS
// ============================================

/// Project repository provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  return ProjectRepository();
});

/// Section repository provider
final sectionRepositoryProvider = Provider<SectionRepository>((ref) {
  return SectionRepository();
});

// ============================================
// PROJECT LIST PROVIDERS
// ============================================

/// All projects stream
final allProjectsProvider = StreamProvider<List<Project>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchAll();
});

/// Active projects stream (not archived)
final activeProjectsProvider = StreamProvider<List<Project>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchActive();
});

/// Favorite projects stream
final favoriteProjectsProvider = StreamProvider<List<Project>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.watchFavorites();
});

/// Archived projects
final archivedProjectsProvider = FutureProvider<List<Project>>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getArchived();
});

/// Inbox project
final inboxProjectProvider = FutureProvider<Project?>((ref) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getInbox();
});

// ============================================
// SINGLE PROJECT PROVIDERS
// ============================================

/// Single project by ID
final projectByIdProvider = FutureProvider.family<Project?, int>((ref, id) {
  final repo = ref.watch(projectRepositoryProvider);
  return repo.getById(id);
});

// ============================================
// SECTION PROVIDERS
// ============================================

/// Sections by project
final sectionsByProjectProvider = StreamProvider.family<List<Section>, int>((
  ref,
  projectId,
) {
  final repo = ref.watch(sectionRepositoryProvider);
  return repo.watchByProject(projectId);
});

// ============================================
// PROJECT ACTIONS (NOTIFIER)
// ============================================

/// Project actions notifier for mutations
class ProjectActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final ProjectRepository _repo;
  final SectionRepository _sectionRepo;
  final Ref _ref;

  ProjectActionsNotifier(this._repo, this._sectionRepo, this._ref)
    : super(const AsyncValue.data(null));

  /// Create a new project
  Future<Project?> createProject({
    required String name,
    String? description,
    int colorIndex = 0,
    String iconName = 'folder',
    bool isFavorite = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final project = Project.create(
        name: name,
        description: description,
        colorIndex: colorIndex,
        iconName: iconName,
        isFavorite: isFavorite,
      );

      final created = await _repo.create(project);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update a project
  Future<Project?> updateProject(Project project) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repo.update(project);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(int projectId) async {
    state = const AsyncValue.loading();
    try {
      final project = await _repo.getById(projectId);
      if (project != null) {
        await _repo.update(project.toggleFavorite());
      }
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Archive a project
  Future<void> archiveProject(int projectId) async {
    state = const AsyncValue.loading();
    try {
      final project = await _repo.getById(projectId);
      if (project != null && !project.isInbox) {
        await _repo.update(project.archive());
      }
      state = const AsyncValue.data(null);
      _ref.invalidate(archivedProjectsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Unarchive a project
  Future<void> unarchiveProject(int projectId) async {
    state = const AsyncValue.loading();
    try {
      final project = await _repo.getById(projectId);
      if (project != null) {
        await _repo.update(project.unarchive());
      }
      state = const AsyncValue.data(null);
      _ref.invalidate(archivedProjectsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Delete a project (soft)
  Future<void> deleteProject(int projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.softDelete(projectId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reorder projects
  Future<void> reorderProjects(List<int> orderedIds) async {
    state = const AsyncValue.loading();
    try {
      await _repo.reorder(orderedIds);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // ============================================
  // SECTION ACTIONS
  // ============================================

  /// Create a new section
  Future<Section?> createSection({
    required String name,
    required int projectId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final section = Section.create(name: name, projectId: projectId);

      final created = await _sectionRepo.create(section);
      state = const AsyncValue.data(null);
      return created;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update a section
  Future<Section?> updateSection(Section section) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _sectionRepo.update(section);
      state = const AsyncValue.data(null);
      return updated;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Toggle section collapsed state
  Future<void> toggleSectionCollapsed(int sectionId) async {
    try {
      final section = await _sectionRepo.getById(sectionId);
      if (section != null) {
        await _sectionRepo.update(section.toggleCollapsed());
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Delete a section
  Future<void> deleteSection(int sectionId) async {
    state = const AsyncValue.loading();
    try {
      await _sectionRepo.softDelete(sectionId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reorder sections
  Future<void> reorderSections(List<int> orderedIds) async {
    state = const AsyncValue.loading();
    try {
      await _sectionRepo.reorder(orderedIds);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Project actions provider
final projectActionsProvider =
    StateNotifierProvider<ProjectActionsNotifier, AsyncValue<void>>((ref) {
      final repo = ref.watch(projectRepositoryProvider);
      final sectionRepo = ref.watch(sectionRepositoryProvider);
      return ProjectActionsNotifier(repo, sectionRepo, ref);
    });

// ============================================
// SELECTED PROJECT STATE
// ============================================

/// Currently selected project ID
final selectedProjectIdProvider = StateProvider<int?>((ref) => null);

/// Currently selected project
final selectedProjectProvider = FutureProvider<Project?>((ref) {
  final projectId = ref.watch(selectedProjectIdProvider);
  if (projectId == null) return Future.value(null);

  final repo = ref.watch(projectRepositoryProvider);
  return repo.getById(projectId);
});

// ============================================
// PROJECT SEARCH
// ============================================

/// Project search query
final projectSearchQueryProvider = StateProvider<String>((ref) => '');

/// Project search results
final projectSearchResultsProvider = FutureProvider<List<Project>>((ref) {
  final query = ref.watch(projectSearchQueryProvider);
  if (query.isEmpty) return Future.value([]);

  final repo = ref.watch(projectRepositoryProvider);
  return repo.search(query);
});
