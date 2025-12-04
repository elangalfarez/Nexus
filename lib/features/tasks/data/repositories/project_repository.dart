// lib/features/tasks/data/repositories/project_repository.dart
// Repository for project CRUD operations with Isar

import 'package:isar/isar.dart';
import '../../../../core/services/database_service.dart';
import '../models/project_model.dart';
import '../models/section_model.dart';

/// Repository for project operations
class ProjectRepository {
  final Isar _db;

  ProjectRepository() : _db = DatabaseService.instance;

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  /// Create a new project
  Future<Project> create(Project project) async {
    await _db.writeTxn(() async {
      await _db.projects.put(project);
    });
    return project;
  }

  /// Get project by ID
  Future<Project?> getById(int id) {
    return _db.projects.get(id);
  }

  /// Get project by UID
  Future<Project?> getByUid(String uid) {
    return _db.projects.filter().uidEqualTo(uid).findFirst();
  }

  /// Update a project
  Future<Project> update(Project project) async {
    project.updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.projects.put(project);
    });
    return project;
  }

  /// Delete a project (soft delete)
  Future<void> softDelete(int id) async {
    final project = await getById(id);
    if (project != null && !project.isInbox) {
      await update(project.softDelete());
    }
  }

  /// Delete a project (hard delete)
  Future<void> hardDelete(int id) async {
    final project = await getById(id);
    if (project != null && !project.isInbox) {
      await _db.writeTxn(() async {
        await _db.projects.delete(id);
      });
    }
  }

  // ============================================
  // QUERIES - ALL PROJECTS
  // ============================================

  /// Get all projects (excluding deleted)
  Future<List<Project>> getAll() {
    return _db.projects
        .filter()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  /// Watch all projects
  Stream<List<Project>> watchAll() {
    return _db.projects
        .filter()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  /// Get active projects (not archived)
  Future<List<Project>> getActive() {
    return _db.projects
        .filter()
        .isArchivedEqualTo(false)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  /// Watch active projects
  Stream<List<Project>> watchActive() {
    return _db.projects
        .filter()
        .isArchivedEqualTo(false)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  /// Get project count
  Future<int> count() {
    return _db.projects.filter().isDeletedEqualTo(false).count();
  }

  // ============================================
  // QUERIES - SPECIAL
  // ============================================

  /// Get the Inbox project
  Future<Project?> getInbox() {
    return _db.projects.filter().isInboxEqualTo(true).findFirst();
  }

  /// Get favorite projects
  Future<List<Project>> getFavorites() {
    return _db.projects
        .filter()
        .isFavoriteEqualTo(true)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  /// Watch favorite projects
  Stream<List<Project>> watchFavorites() {
    return _db.projects
        .filter()
        .isFavoriteEqualTo(true)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  /// Get archived projects
  Future<List<Project>> getArchived() {
    return _db.projects
        .filter()
        .isArchivedEqualTo(true)
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  // ============================================
  // SEARCH
  // ============================================

  /// Search projects by name
  Future<List<Project>> search(String query) {
    if (query.isEmpty) return Future.value([]);

    return _db.projects
        .filter()
        .nameContains(query, caseSensitive: false)
        .isDeletedEqualTo(false)
        .sortByName()
        .findAll();
  }

  // ============================================
  // BATCH OPERATIONS
  // ============================================

  /// Reorder projects
  Future<void> reorder(List<int> orderedIds) async {
    await _db.writeTxn(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        final project = await _db.projects.get(orderedIds[i]);
        if (project != null) {
          project.sortOrder = i;
          project.updatedAt = DateTime.now();
          await _db.projects.put(project);
        }
      }
    });
  }
}

/// Repository for section operations
class SectionRepository {
  final Isar _db;

  SectionRepository() : _db = DatabaseService.instance;

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  /// Create a new section
  Future<Section> create(Section section) async {
    await _db.writeTxn(() async {
      await _db.sections.put(section);
    });
    return section;
  }

  /// Get section by ID
  Future<Section?> getById(int id) {
    return _db.sections.get(id);
  }

  /// Update a section
  Future<Section> update(Section section) async {
    section.updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.sections.put(section);
    });
    return section;
  }

  /// Delete a section (soft delete)
  Future<void> softDelete(int id) async {
    final section = await getById(id);
    if (section != null) {
      await update(section.softDelete());
    }
  }

  /// Delete a section (hard delete)
  Future<void> hardDelete(int id) async {
    await _db.writeTxn(() async {
      await _db.sections.delete(id);
    });
  }

  // ============================================
  // QUERIES
  // ============================================

  /// Get sections by project
  Future<List<Section>> getByProject(int projectId) {
    return _db.sections
        .filter()
        .projectIdEqualTo(projectId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  /// Watch sections by project
  Stream<List<Section>> watchByProject(int projectId) {
    return _db.sections
        .filter()
        .projectIdEqualTo(projectId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  // ============================================
  // BATCH OPERATIONS
  // ============================================

  /// Reorder sections within project
  Future<void> reorder(List<int> orderedIds) async {
    await _db.writeTxn(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        final section = await _db.sections.get(orderedIds[i]);
        if (section != null) {
          section.sortOrder = i;
          section.updatedAt = DateTime.now();
          await _db.sections.put(section);
        }
      }
    });
  }

  /// Delete all sections in a project
  Future<void> deleteByProject(int projectId) async {
    final sections = await getByProject(projectId);
    await _db.writeTxn(() async {
      for (final section in sections) {
        section.isDeleted = true;
        section.updatedAt = DateTime.now();
        await _db.sections.put(section);
      }
    });
  }
}
