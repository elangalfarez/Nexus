// lib/features/tasks/data/repositories/task_repository.dart
// Repository for task CRUD operations with Isar

import 'package:isar/isar.dart';
import '../../../../core/services/database_service.dart';
import '../models/task_model.dart';

/// Repository for task operations
class TaskRepository {
  final Isar _db;

  TaskRepository() : _db = DatabaseService.instance;

  // ============================================
  // CRUD OPERATIONS
  // ============================================

  /// Create a new task
  Future<Task> create(Task task) async {
    await _db.writeTxn(() async {
      await _db.tasks.put(task);
    });
    return task;
  }

  /// Get task by ID
  Future<Task?> getById(int id) {
    return _db.tasks.get(id);
  }

  /// Get task by UID
  Future<Task?> getByUid(String uid) {
    return _db.tasks.filter().uidEqualTo(uid).findFirst();
  }

  /// Update a task
  Future<Task> update(Task task) async {
    task.updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.tasks.put(task);
    });
    return task;
  }

  /// Delete a task (soft delete)
  Future<void> softDelete(int id) async {
    final task = await getById(id);
    if (task != null) {
      await update(task.softDelete());
    }
  }

  /// Delete a task (hard delete)
  Future<void> hardDelete(int id) async {
    await _db.writeTxn(() async {
      await _db.tasks.delete(id);
    });
  }

  /// Delete multiple tasks
  Future<void> deleteMany(List<int> ids) async {
    await _db.writeTxn(() async {
      await _db.tasks.deleteAll(ids);
    });
  }

  // ============================================
  // QUERIES - ALL TASKS
  // ============================================

  /// Get all tasks (excluding deleted)
  Future<List<Task>> getAll() {
    return _db.tasks
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Watch all tasks
  Stream<List<Task>> watchAll() {
    return _db.tasks
        .filter()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  /// Get task count
  Future<int> count() {
    return _db.tasks.filter().isDeletedEqualTo(false).count();
  }

  // ============================================
  // QUERIES - BY PROJECT
  // ============================================

  /// Get tasks by project
  Future<List<Task>> getByProject(int projectId) {
    return _db.tasks
        .filter()
        .projectIdEqualTo(projectId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  /// Watch tasks by project
  Stream<List<Task>> watchByProject(int projectId) {
    return _db.tasks
        .filter()
        .projectIdEqualTo(projectId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  /// Get incomplete tasks by project
  Future<List<Task>> getIncompleteByProject(int projectId) {
    return _db.tasks
        .filter()
        .projectIdEqualTo(projectId)
        .isCompletedEqualTo(false)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  // ============================================
  // QUERIES - BY SECTION
  // ============================================

  /// Get tasks by section
  Future<List<Task>> getBySection(int sectionId) {
    return _db.tasks
        .filter()
        .sectionIdEqualTo(sectionId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  /// Watch tasks by section
  Stream<List<Task>> watchBySection(int sectionId) {
    return _db.tasks
        .filter()
        .sectionIdEqualTo(sectionId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  // ============================================
  // QUERIES - INBOX
  // ============================================

  /// Get inbox tasks (no project)
  Future<List<Task>> getInbox() {
    return _db.tasks
        .filter()
        .projectIdIsNull()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  /// Watch inbox tasks
  Stream<List<Task>> watchInbox() {
    return _db.tasks
        .filter()
        .projectIdIsNull()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true);
  }

  // ============================================
  // QUERIES - TODAY
  // ============================================

  /// Get tasks due today
  Future<List<Task>> getDueToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db.tasks
        .filter()
        .dueDateBetween(startOfDay, endOfDay)
        .isDeletedEqualTo(false)
        .isCompletedEqualTo(false)
        .sortByPriority()
        .findAll();
  }

  /// Watch tasks due today
  Stream<List<Task>> watchDueToday() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _db.tasks
        .filter()
        .dueDateBetween(startOfDay, endOfDay)
        .isDeletedEqualTo(false)
        .isCompletedEqualTo(false)
        .sortByPriority()
        .watch(fireImmediately: true);
  }

  /// Get overdue tasks
  Future<List<Task>> getOverdue() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _db.tasks
        .filter()
        .dueDateLessThan(startOfDay)
        .isDeletedEqualTo(false)
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .findAll();
  }

  /// Watch overdue tasks
  Stream<List<Task>> watchOverdue() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    return _db.tasks
        .filter()
        .dueDateLessThan(startOfDay)
        .isDeletedEqualTo(false)
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .watch(fireImmediately: true);
  }

  // ============================================
  // QUERIES - UPCOMING
  // ============================================

  /// Get upcoming tasks (next 7 days)
  Future<List<Task>> getUpcoming({int days = 7}) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endDate = startOfDay.add(Duration(days: days));

    return _db.tasks
        .filter()
        .dueDateBetween(startOfDay, endDate)
        .isDeletedEqualTo(false)
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .findAll();
  }

  // ============================================
  // QUERIES - SUBTASKS
  // ============================================

  /// Get subtasks of a parent task
  Future<List<Task>> getSubtasks(int parentTaskId) {
    return _db.tasks
        .filter()
        .parentTaskIdEqualTo(parentTaskId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
  }

  /// Watch subtasks
  Stream<List<Task>> watchSubtasks(int parentTaskId) {
    return _db.tasks
        .filter()
        .parentTaskIdEqualTo(parentTaskId)
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .watch(fireImmediately: true);
  }

  /// Get root tasks only (no parent)
  Future<List<Task>> getRootTasks() {
    return _db.tasks
        .filter()
        .parentTaskIdIsNull()
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // ============================================
  // QUERIES - BY PRIORITY
  // ============================================

  /// Get tasks by priority
  Future<List<Task>> getByPriority(int priority) {
    return _db.tasks
        .filter()
        .priorityEqualTo(priority)
        .isDeletedEqualTo(false)
        .isCompletedEqualTo(false)
        .sortByDueDate()
        .findAll();
  }

  /// Get high priority tasks (1 and 2)
  Future<List<Task>> getHighPriority() {
    return _db.tasks
        .filter()
        .priorityLessThan(3)
        .isDeletedEqualTo(false)
        .isCompletedEqualTo(false)
        .sortByPriority()
        .thenByDueDate()
        .findAll();
  }

  // ============================================
  // QUERIES - COMPLETED
  // ============================================

  /// Get completed tasks
  Future<List<Task>> getCompleted({int limit = 50}) {
    return _db.tasks
        .filter()
        .isCompletedEqualTo(true)
        .isDeletedEqualTo(false)
        .sortByCompletedAtDesc()
        .limit(limit)
        .findAll();
  }

  /// Get recently completed (last 24 hours)
  Future<List<Task>> getRecentlyCompleted() {
    final yesterday = DateTime.now().subtract(const Duration(hours: 24));

    return _db.tasks
        .filter()
        .isCompletedEqualTo(true)
        .completedAtGreaterThan(yesterday)
        .isDeletedEqualTo(false)
        .sortByCompletedAtDesc()
        .findAll();
  }

  // ============================================
  // SEARCH
  // ============================================

  /// Search tasks by title
  Future<List<Task>> search(String query) {
    if (query.isEmpty) return Future.value([]);

    return _db.tasks
        .filter()
        .titleContains(query, caseSensitive: false)
        .isDeletedEqualTo(false)
        .sortByCreatedAtDesc()
        .findAll();
  }

  // ============================================
  // BATCH OPERATIONS
  // ============================================

  /// Complete multiple tasks
  Future<void> completeMany(List<int> ids) async {
    await _db.writeTxn(() async {
      for (final id in ids) {
        final task = await _db.tasks.get(id);
        if (task != null && !task.isCompleted) {
          await _db.tasks.put(task.complete());
        }
      }
    });
  }

  /// Move tasks to project
  Future<void> moveToProject(List<int> ids, int? projectId) async {
    await _db.writeTxn(() async {
      for (final id in ids) {
        final task = await _db.tasks.get(id);
        if (task != null) {
          task.projectId = projectId;
          task.sectionId = null; // Reset section when moving
          task.updatedAt = DateTime.now();
          await _db.tasks.put(task);
        }
      }
    });
  }

  /// Reorder tasks in a list
  Future<void> reorder(List<int> orderedIds) async {
    await _db.writeTxn(() async {
      for (var i = 0; i < orderedIds.length; i++) {
        final task = await _db.tasks.get(orderedIds[i]);
        if (task != null) {
          task.sortOrder = i;
          task.updatedAt = DateTime.now();
          await _db.tasks.put(task);
        }
      }
    });
  }

  // ============================================
  // STATISTICS
  // ============================================

  /// Get task statistics
  Future<TaskStats> getStats() async {
    final total = await _db.tasks.filter().isDeletedEqualTo(false).count();
    final completed = await _db.tasks
        .filter()
        .isCompletedEqualTo(true)
        .isDeletedEqualTo(false)
        .count();
    final overdue = await getOverdue().then((list) => list.length);
    final dueToday = await getDueToday().then((list) => list.length);

    return TaskStats(
      total: total,
      completed: completed,
      pending: total - completed,
      overdue: overdue,
      dueToday: dueToday,
    );
  }
}

/// Task statistics data class
class TaskStats {
  final int total;
  final int completed;
  final int pending;
  final int overdue;
  final int dueToday;

  const TaskStats({
    required this.total,
    required this.completed,
    required this.pending,
    required this.overdue,
    required this.dueToday,
  });

  double get completionRate => total > 0 ? completed / total : 0;
}
