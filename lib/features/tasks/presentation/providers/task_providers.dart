// lib/features/tasks/presentation/providers/task_providers.dart
// Riverpod providers for task state management

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';

// ============================================
// REPOSITORY PROVIDER
// ============================================

/// Task repository provider
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

// ============================================
// TASK LIST PROVIDERS
// ============================================

/// All tasks stream
final allTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchAll();
});

/// Inbox tasks stream
final inboxTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchInbox();
});

/// Today's tasks stream
final todayTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchDueToday();
});

/// Overdue tasks stream
final overdueTasksProvider = StreamProvider<List<Task>>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchOverdue();
});

/// Tasks by project
final tasksByProjectProvider = StreamProvider.family<List<Task>, int>((
  ref,
  projectId,
) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchByProject(projectId);
});

/// Tasks by section
final tasksBySectionProvider = StreamProvider.family<List<Task>, int>((
  ref,
  sectionId,
) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchBySection(sectionId);
});

/// Subtasks of a task
final subtasksProvider = StreamProvider.family<List<Task>, int>((
  ref,
  parentId,
) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.watchSubtasks(parentId);
});

// ============================================
// SINGLE TASK PROVIDERS
// ============================================

/// Single task by ID
final taskByIdProvider = FutureProvider.family<Task?, int>((ref, id) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getById(id);
});

// ============================================
// TASK STATISTICS
// ============================================

/// Task statistics provider
final taskStatsProvider = FutureProvider<TaskStats>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return repo.getStats();
});

// ============================================
// TASK SEARCH
// ============================================

/// Task search query state
final taskSearchQueryProvider = StateProvider<String>((ref) => '');

/// Task search results
final taskSearchResultsProvider = FutureProvider<List<Task>>((ref) {
  final query = ref.watch(taskSearchQueryProvider);
  if (query.isEmpty) return Future.value([]);

  final repo = ref.watch(taskRepositoryProvider);
  return repo.search(query);
});

// ============================================
// TASK ACTIONS (NOTIFIER)
// ============================================

/// Task actions notifier for mutations
class TaskActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final TaskRepository _repo;
  final Ref _ref;

  TaskActionsNotifier(this._repo, this._ref)
    : super(const AsyncValue.data(null));

  /// Create a new task
  Future<Task?> createTask({
    required String title,
    String? description,
    int priority = 4,
    DateTime? dueDate,
    int? dueTimeMinutes,
    int? projectId,
    int? sectionId,
    int? parentTaskId,
    List<int>? tagIds,
  }) async {
    state = const AsyncValue.loading();
    try {
      final task = Task.create(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
        dueTimeMinutes: dueTimeMinutes,
        projectId: projectId,
        sectionId: sectionId,
        parentTaskId: parentTaskId,
        tagIds: tagIds,
      );

      final created = await _repo.create(task);
      state = const AsyncValue.data(null);
      _invalidateProviders();
      return created;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update a task with individual parameters
  Future<Task?> updateTask(
    int taskId, {
    String? title,
    String? description,
    int? priority,
    DateTime? dueDate,
    int? dueTimeMinutes,
    int? projectId,
    int? sectionId,
    String? recurrenceRule,
    List<int>? tagIds,
  }) async {
    state = const AsyncValue.loading();
    try {
      final task = await _repo.getById(taskId);
      if (task == null) {
        state = const AsyncValue.data(null);
        return null;
      }

      final updated = await _repo.update(
        task.copyWith(
          title: title ?? task.title,
          description: description,
          priority: priority ?? task.priority,
          dueDate: dueDate,
          dueTimeMinutes: dueTimeMinutes,
          projectId: projectId ?? task.projectId,
          sectionId: sectionId,
          recurrenceRule: recurrenceRule,
          tagIds: tagIds?.join(','),
        ),
      );
      state = const AsyncValue.data(null);
      _invalidateProviders();
      return updated;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Update a task with a Task object
  Future<Task?> updateTaskModel(Task task) async {
    state = const AsyncValue.loading();
    try {
      final updated = await _repo.update(task);
      state = const AsyncValue.data(null);
      _invalidateProviders();
      return updated;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Complete a task
  Future<void> completeTask(int taskId) async {
    state = const AsyncValue.loading();
    try {
      final task = await _repo.getById(taskId);
      if (task != null) {
        await _repo.update(task.complete());
      }
      state = const AsyncValue.data(null);
      _invalidateProviders();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Uncomplete a task
  Future<void> uncompleteTask(int taskId) async {
    state = const AsyncValue.loading();
    try {
      final task = await _repo.getById(taskId);
      if (task != null) {
        await _repo.update(task.uncomplete());
      }
      state = const AsyncValue.data(null);
      _invalidateProviders();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Toggle task completion
  Future<void> toggleComplete(int taskId) async {
    final task = await _repo.getById(taskId);
    if (task != null) {
      if (task.isCompleted) {
        await uncompleteTask(taskId);
      } else {
        await completeTask(taskId);
      }
    }
  }

  /// Delete a task (soft)
  Future<void> deleteTask(int taskId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.softDelete(taskId);
      state = const AsyncValue.data(null);
      _invalidateProviders();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Move tasks to project
  Future<void> moveToProject(List<int> taskIds, int? projectId) async {
    state = const AsyncValue.loading();
    try {
      await _repo.moveToProject(taskIds, projectId);
      state = const AsyncValue.data(null);
      _invalidateProviders();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reorder tasks
  Future<void> reorderTasks(List<int> orderedIds) async {
    state = const AsyncValue.loading();
    try {
      await _repo.reorder(orderedIds);
      state = const AsyncValue.data(null);
      _invalidateProviders();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Complete multiple tasks
  Future<void> completeMany(List<int> taskIds) async {
    state = const AsyncValue.loading();
    try {
      await _repo.completeMany(taskIds);
      state = const AsyncValue.data(null);
      _invalidateProviders();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _invalidateProviders() {
    _ref.invalidate(taskStatsProvider);
  }
}

/// Task actions provider
final taskActionsProvider =
    StateNotifierProvider<TaskActionsNotifier, AsyncValue<void>>((ref) {
      final repo = ref.watch(taskRepositoryProvider);
      return TaskActionsNotifier(repo, ref);
    });

// ============================================
// TASK FILTER STATE
// ============================================

/// Task filter options
enum TaskFilter { all, today, upcoming, overdue, completed, highPriority }

/// Current task filter
final taskFilterProvider = StateProvider<TaskFilter>((ref) => TaskFilter.all);

/// Filtered tasks based on current filter
final filteredTasksProvider = FutureProvider<List<Task>>((ref) async {
  final filter = ref.watch(taskFilterProvider);
  final repo = ref.watch(taskRepositoryProvider);

  return switch (filter) {
    TaskFilter.all => repo.getAll(),
    TaskFilter.today => repo.getDueToday(),
    TaskFilter.upcoming => repo.getUpcoming(),
    TaskFilter.overdue => repo.getOverdue(),
    TaskFilter.completed => repo.getCompleted(),
    TaskFilter.highPriority => repo.getHighPriority(),
  };
});

// ============================================
// SELECTED TASK STATE
// ============================================

/// Currently selected task ID (for detail view)
final selectedTaskIdProvider = StateProvider<int?>((ref) => null);

/// Currently selected task
final selectedTaskProvider = FutureProvider<Task?>((ref) {
  final taskId = ref.watch(selectedTaskIdProvider);
  if (taskId == null) return Future.value(null);

  final repo = ref.watch(taskRepositoryProvider);
  return repo.getById(taskId);
});
