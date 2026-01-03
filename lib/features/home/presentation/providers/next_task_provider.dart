// lib/features/home/presentation/providers/next_task_provider.dart
// "Do This Next" feature - Smart task selection algorithm for ADHD-friendly focus
//
// Algorithm Priority:
// 1. Overdue tasks (oldest first by due date)
// 2. Urgent priority (P1) tasks due today
// 3. High priority (P2) tasks due today
// 4. Medium priority (P3) tasks due today
// 5. Remaining tasks due today
//
// Features:
// - Skip: Rotates task to end of queue (persists during session)
// - Done: Marks complete, transitions to next
// - Later: Moves task to tomorrow

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/data/repositories/task_repository.dart';
import '../../../tasks/presentation/providers/task_providers.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STATE CLASS - Manages the "Do This Next" queue
// ═══════════════════════════════════════════════════════════════════════════════

/// State for the "Do This Next" feature
class DoThisNextState {
  /// IDs of tasks that have been skipped (moved to end of queue)
  final List<int> skippedTaskIds;

  /// The date this state was created (to reset on day change)
  final DateTime stateDate;

  /// Whether the feature is currently transitioning (for animations)
  final bool isTransitioning;

  /// Action that triggered the last transition
  final DoThisNextAction? lastAction;

  /// Whether all available tasks have been skipped (queue exhausted)
  final bool allTasksSkipped;

  const DoThisNextState({
    this.skippedTaskIds = const [],
    required this.stateDate,
    this.isTransitioning = false,
    this.lastAction,
    this.allTasksSkipped = false,
  });

  DoThisNextState copyWith({
    List<int>? skippedTaskIds,
    DateTime? stateDate,
    bool? isTransitioning,
    DoThisNextAction? lastAction,
    bool? allTasksSkipped,
  }) {
    return DoThisNextState(
      skippedTaskIds: skippedTaskIds ?? this.skippedTaskIds,
      stateDate: stateDate ?? this.stateDate,
      isTransitioning: isTransitioning ?? this.isTransitioning,
      lastAction: lastAction,
      allTasksSkipped: allTasksSkipped ?? this.allTasksSkipped,
    );
  }

  /// Check if the state needs to be reset (day changed)
  bool get needsReset {
    final now = DateTime.now();
    return stateDate.year != now.year ||
        stateDate.month != now.month ||
        stateDate.day != now.day;
  }
}

/// Actions that can be performed on the "next" task
enum DoThisNextAction {
  done, // Task completed
  skip, // Move to end of queue
  later, // Postpone to tomorrow
}

// ═══════════════════════════════════════════════════════════════════════════════
// STATE NOTIFIER - Business logic for task queue management
// ═══════════════════════════════════════════════════════════════════════════════

class DoThisNextNotifier extends StateNotifier<DoThisNextState> {
  final TaskRepository _repo;
  final Ref _ref;
  bool _isProcessing = false;

  DoThisNextNotifier(this._repo, this._ref)
      : super(DoThisNextState(stateDate: DateTime.now()));

  /// Skip the current task - moves it to end of queue
  /// Returns a SkipResult indicating the outcome
  SkipResult skipTask(int taskId) {
    // Prevent concurrent operations
    if (_isProcessing || state.isTransitioning) {
      return SkipResult.busy;
    }

    // Check if day changed and reset if needed
    if (state.needsReset) {
      state = DoThisNextState(stateDate: DateTime.now());
    }

    // If task is already skipped, signal that all tasks have been cycled
    if (state.skippedTaskIds.contains(taskId)) {
      state = state.copyWith(allTasksSkipped: true);
      return SkipResult.allSkipped;
    }

    _isProcessing = true;

    // Add to skipped list
    state = state.copyWith(
      skippedTaskIds: [...state.skippedTaskIds, taskId],
      isTransitioning: true,
      lastAction: DoThisNextAction.skip,
      allTasksSkipped: false,
    );

    // Reset transitioning state after animation
    _resetTransitioningState();

    return SkipResult.success;
  }

  /// Mark task as done
  Future<void> completeTask(int taskId) async {
    // Prevent concurrent operations
    if (_isProcessing || state.isTransitioning) {
      debugPrint('DoThisNext: completeTask blocked - already processing');
      return;
    }

    _isProcessing = true;

    try {
      state = state.copyWith(
        isTransitioning: true,
        lastAction: DoThisNextAction.done,
        allTasksSkipped: false,
      );

      // Use the task actions provider to complete
      await _ref.read(taskActionsProvider.notifier).completeTask(taskId);

      // Remove from skipped list if it was there (only if still mounted)
      if (mounted && state.skippedTaskIds.contains(taskId)) {
        state = state.copyWith(
          skippedTaskIds: state.skippedTaskIds.where((id) => id != taskId).toList(),
        );
      }
    } catch (e) {
      debugPrint('DoThisNext: Error completing task: $e');
    } finally {
      // Reset transitioning state after animation
      _resetTransitioningState();
    }
  }

  /// Move task to tomorrow (Later action)
  Future<void> postponeTask(int taskId) async {
    // Prevent concurrent operations
    if (_isProcessing || state.isTransitioning) {
      debugPrint('DoThisNext: postponeTask blocked - already processing');
      return;
    }

    _isProcessing = true;

    try {
      state = state.copyWith(
        isTransitioning: true,
        lastAction: DoThisNextAction.later,
        allTasksSkipped: false,
      );

      // Get the task and update its due date to tomorrow
      final task = await _repo.getById(taskId);
      if (task != null && mounted) {
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        final normalizedTomorrow = DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
        );

        await _repo.update(task.copyWith(dueDate: normalizedTomorrow));

        // Invalidate task stats only if still mounted
        if (mounted) {
          _ref.invalidate(taskStatsProvider);
        }
      }

      // Remove from skipped list if it was there
      if (mounted && state.skippedTaskIds.contains(taskId)) {
        state = state.copyWith(
          skippedTaskIds: state.skippedTaskIds.where((id) => id != taskId).toList(),
        );
      }
    } catch (e) {
      debugPrint('DoThisNext: Error postponing task: $e');
    } finally {
      // Reset transitioning state after animation
      _resetTransitioningState();
    }
  }

  /// Reset skip state (e.g., when user wants fresh queue)
  void resetSkipState() {
    _isProcessing = false;
    state = DoThisNextState(stateDate: DateTime.now());
  }

  /// Remove a specific task from skipped list (e.g., if it was edited)
  void unskipTask(int taskId) {
    if (state.skippedTaskIds.contains(taskId)) {
      state = state.copyWith(
        skippedTaskIds: state.skippedTaskIds.where((id) => id != taskId).toList(),
        allTasksSkipped: false,
      );
    }
  }

  /// Clear the "all tasks skipped" flag without resetting state
  void clearAllSkippedFlag() {
    if (state.allTasksSkipped) {
      state = state.copyWith(allTasksSkipped: false);
    }
  }

  void _resetTransitioningState() {
    Future.delayed(const Duration(milliseconds: 400), () {
      _isProcessing = false;
      if (mounted) {
        state = state.copyWith(isTransitioning: false);
      }
    });
  }
}

/// Result of a skip operation
enum SkipResult {
  success, // Task was skipped successfully
  allSkipped, // All tasks have been skipped - show message
  busy, // Operation in progress, try again later
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════════════

/// Provider for the Do This Next state notifier
final doThisNextStateProvider =
    StateNotifierProvider<DoThisNextNotifier, DoThisNextState>((ref) {
  final repo = ref.watch(taskRepositoryProvider);
  return DoThisNextNotifier(repo, ref);
});

/// Provider that computes the "next" task based on the algorithm
/// Returns null if no tasks available or all tasks skipped
///
/// Uses existing Riverpod stream providers for reactive updates.
/// No polling required - automatically updates when database changes.
final nextTaskStreamProvider = Provider<AsyncValue<Task?>>((ref) {
  final doThisNextState = ref.watch(doThisNextStateProvider);

  // If transitioning, return loading to prevent UI jank
  if (doThisNextState.isTransitioning) {
    return const AsyncValue.loading();
  }

  // Watch existing stream providers (Riverpod handles subscriptions)
  final overdueAsync = ref.watch(overdueTasksProvider);
  final todayAsync = ref.watch(todayTasksProvider);

  // Combine the async values with error protection
  try {
    return overdueAsync.when(
      data: (overdueTasks) => todayAsync.when(
        data: (todayTasks) {
          final queue = _buildTaskQueue(
            overdueTasks,
            todayTasks,
            doThisNextState.skippedTaskIds,
          );
          return AsyncValue.data(queue.isNotEmpty ? queue.first : null);
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) {
          debugPrint('DoThisNext: todayTasks error: $e');
          return AsyncValue.error(e, st);
        },
      ),
      loading: () => const AsyncValue.loading(),
      error: (e, st) {
        debugPrint('DoThisNext: overdueTasks error: $e');
        return AsyncValue.error(e, st);
      },
    );
  } catch (e, st) {
    debugPrint('DoThisNext: Unexpected error in nextTaskStreamProvider: $e');
    return AsyncValue.error(e, st);
  }
});

/// Builds the priority queue for "next" task selection
///
/// Priority order:
/// 1. Overdue tasks (oldest due date first)
/// 2. Today's tasks by priority (P1 → P2 → P3 → P4)
///
/// Skipped tasks are moved to the end of their respective sections
List<Task> _buildTaskQueue(
  List<Task> overdueTasks,
  List<Task> todayTasks,
  List<int> skippedIds,
) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final tomorrowStart = todayStart.add(const Duration(days: 1));

  // Filter out completed, subtasks, AND validate dates to prevent stale data
  // A task is overdue if its due date is before today
  final filteredOverdue = overdueTasks.where((t) {
    if (t.isCompleted || t.isSubtask) return false;
    if (t.dueDate == null) return false;
    // Must actually be overdue (due date before today)
    return t.dueDate!.isBefore(todayStart);
  }).toList();

  // A task is "today" if its due date is today (not tomorrow or later)
  final filteredToday = todayTasks.where((t) {
    if (t.isCompleted || t.isSubtask) return false;
    if (t.dueDate == null) return true; // No due date = show in today
    // Must be due today (>= today start AND < tomorrow start)
    return !t.dueDate!.isBefore(todayStart) && t.dueDate!.isBefore(tomorrowStart);
  }).toList();

  // Sort overdue by due date (oldest first), then move skipped to end
  filteredOverdue.sort((a, b) {
    final aSkipped = skippedIds.contains(a.id);
    final bSkipped = skippedIds.contains(b.id);

    // Skipped tasks go to end
    if (aSkipped && !bSkipped) return 1;
    if (!aSkipped && bSkipped) return -1;

    // Otherwise sort by due date (oldest first)
    if (a.dueDate != null && b.dueDate != null) {
      return a.dueDate!.compareTo(b.dueDate!);
    }
    return 0;
  });

  // Sort today by priority (1 = urgent first), then move skipped to end
  filteredToday.sort((a, b) {
    final aSkipped = skippedIds.contains(a.id);
    final bSkipped = skippedIds.contains(b.id);

    // Skipped tasks go to end
    if (aSkipped && !bSkipped) return 1;
    if (!aSkipped && bSkipped) return -1;

    // Otherwise sort by priority (lower number = higher priority)
    final priorityCompare = a.priority.compareTo(b.priority);
    if (priorityCompare != 0) return priorityCompare;

    // Same priority: sort by creation date (older first for consistency)
    return a.createdAt.compareTo(b.createdAt);
  });

  // Combine: overdue first, then today
  return [...filteredOverdue, ...filteredToday];
}

/// Provider for the full task queue (for debugging/display purposes)
final taskQueueProvider = FutureProvider<List<Task>>((ref) async {
  final repo = ref.watch(taskRepositoryProvider);
  final doThisNextState = ref.watch(doThisNextStateProvider);

  final overdueTasks = await repo.getOverdue();
  final todayTasks = await repo.getDueToday();

  return _buildTaskQueue(
    overdueTasks,
    todayTasks,
    doThisNextState.skippedTaskIds,
  );
});

/// Provider that indicates whether there are tasks available for "Do This Next"
final hasNextTaskProvider = Provider<bool>((ref) {
  final doThisNextState = ref.watch(doThisNextStateProvider);

  // Don't show card while transitioning
  if (doThisNextState.isTransitioning) {
    return true; // Keep showing during transitions to prevent flickering
  }

  final nextTask = ref.watch(nextTaskStreamProvider);
  return nextTask.when(
    data: (task) => task != null,
    loading: () => true, // Assume true during loading to prevent flickering
    error: (_, __) => false,
  );
});

/// Provider that indicates if all tasks have been skipped
final allTasksSkippedProvider = Provider<bool>((ref) {
  final doThisNextState = ref.watch(doThisNextStateProvider);
  return doThisNextState.allTasksSkipped;
});

/// Provider for the count of remaining tasks in queue
final remainingTaskCountProvider = FutureProvider<int>((ref) async {
  try {
    final queue = await ref.watch(taskQueueProvider.future);
    return queue.length;
  } catch (e) {
    debugPrint('DoThisNext: Error getting remaining task count: $e');
    return 0;
  }
});
