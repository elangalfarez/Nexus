// lib/features/tasks/data/models/task_model.dart
// Core task entity with Isar schema for local persistence

import 'package:isar/isar.dart';

part 'task_model.g.dart';

@collection
class Task {
  Id id = Isar.autoIncrement;

  /// Unique identifier for sync and linking
  @Index(unique: true)
  late String uid;

  /// Task title (required)
  @Index(type: IndexType.value, caseSensitive: false)
  late String title;

  /// Optional description/notes
  String? description;

  /// Priority level: 1 (urgent) to 4 (low), 5 (none)
  @Index()
  int priority = 4;

  /// Due date (nullable)
  @Index()
  DateTime? dueDate;

  /// Due time (nullable, stored as minutes from midnight)
  int? dueTimeMinutes;

  /// Completion status
  @Index()
  bool isCompleted = false;

  /// Completion timestamp
  DateTime? completedAt;

  /// Creation timestamp
  @Index()
  late DateTime createdAt;

  /// Last update timestamp
  @Index()
  late DateTime updatedAt;

  /// Soft delete flag
  @Index()
  bool isDeleted = false;

  /// Deletion timestamp
  DateTime? deletedAt;

  /// Sort order within project/section
  int sortOrder = 0;

  /// Project reference (nullable - null means Inbox)
  @Index()
  int? projectId;

  /// Section reference (nullable)
  int? sectionId;

  /// Parent task ID for subtasks (nullable)
  @Index()
  int? parentTaskId;

  /// Recurring task configuration (JSON string)
  String? recurrenceRule;

  /// Tags (stored as comma-separated tag IDs)
  String tagIds = '';

  /// Linked note IDs (comma-separated)
  String linkedNoteIds = '';

  // ============================================
  // COMPUTED PROPERTIES
  // ============================================

  /// Check if task is overdue
  @ignore
  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.isBefore(today);
  }

  /// Check if task is due today
  @ignore
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Check if task is due this week
  @ignore
  bool get isDueThisWeek {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return dueDate!.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        dueDate!.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if this is a subtask
  @ignore
  bool get isSubtask => parentTaskId != null;

  /// Check if task is in Inbox (no project)
  @ignore
  bool get isInInbox => projectId == null;

  /// Get tag IDs as list
  @ignore
  List<int> get tagIdList {
    if (tagIds.isEmpty) return [];
    return tagIds.split(',').map((e) => int.parse(e.trim())).toList();
  }

  /// Get linked note IDs as list
  @ignore
  List<int> get linkedNoteIdList {
    if (linkedNoteIds.isEmpty) return [];
    return linkedNoteIds.split(',').map((e) => int.parse(e.trim())).toList();
  }

  /// Get due time as TimeOfDay equivalent
  @ignore
  ({int hour, int minute})? get dueTime {
    if (dueTimeMinutes == null) return null;
    return (hour: dueTimeMinutes! ~/ 60, minute: dueTimeMinutes! % 60);
  }

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  /// Create a new task with defaults
  static Task create({
    required String title,
    String? description,
    int priority = 4,
    DateTime? dueDate,
    int? dueTimeMinutes,
    int? projectId,
    int? sectionId,
    int? parentTaskId,
    List<int>? tagIds,
  }) {
    final now = DateTime.now();
    return Task()
      ..uid = _generateUid()
      ..title = title
      ..description = description
      ..priority = priority
      ..dueDate = dueDate
      ..dueTimeMinutes = dueTimeMinutes
      ..projectId = projectId
      ..sectionId = sectionId
      ..parentTaskId = parentTaskId
      ..tagIds = tagIds?.join(',') ?? ''
      ..createdAt = now
      ..updatedAt = now;
  }

  /// Create from JSON (for import/sync)
  static Task fromJson(Map<String, dynamic> json) {
    return Task()
      ..uid = json['uid'] as String
      ..title = json['title'] as String
      ..description = json['description'] as String?
      ..priority = json['priority'] as int? ?? 4
      ..dueDate = json['dueDate'] != null
          ? DateTime.parse(json['dueDate'] as String)
          : null
      ..dueTimeMinutes = json['dueTimeMinutes'] as int?
      ..isCompleted = json['isCompleted'] as bool? ?? false
      ..completedAt = json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String)
      ..isDeleted = json['isDeleted'] as bool? ?? false
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..projectId = json['projectId'] as int?
      ..sectionId = json['sectionId'] as int?
      ..parentTaskId = json['parentTaskId'] as int?
      ..recurrenceRule = json['recurrenceRule'] as String?
      ..tagIds = json['tagIds'] as String? ?? ''
      ..linkedNoteIds = json['linkedNoteIds'] as String? ?? '';
  }

  // ============================================
  // METHODS
  // ============================================

  /// Convert to JSON (for export/sync)
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'description': description,
      'priority': priority,
      'dueDate': dueDate?.toIso8601String(),
      'dueTimeMinutes': dueTimeMinutes,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'sortOrder': sortOrder,
      'projectId': projectId,
      'sectionId': sectionId,
      'parentTaskId': parentTaskId,
      'recurrenceRule': recurrenceRule,
      'tagIds': tagIds,
      'linkedNoteIds': linkedNoteIds,
    };
  }

  /// Create a copy with updates
  Task copyWith({
    String? title,
    String? description,
    int? priority,
    DateTime? dueDate,
    int? dueTimeMinutes,
    bool? isCompleted,
    int? projectId,
    int? sectionId,
    int? parentTaskId,
    String? recurrenceRule,
    String? tagIds,
    String? linkedNoteIds,
    bool clearDueDate = false,
    bool clearDueTime = false,
    bool clearDescription = false,
  }) {
    return Task()
      ..id = id
      ..uid = uid
      ..title = title ?? this.title
      ..description = clearDescription
          ? null
          : (description ?? this.description)
      ..priority = priority ?? this.priority
      ..dueDate = clearDueDate ? null : (dueDate ?? this.dueDate)
      ..dueTimeMinutes = clearDueTime
          ? null
          : (dueTimeMinutes ?? this.dueTimeMinutes)
      ..isCompleted = isCompleted ?? this.isCompleted
      ..completedAt = (isCompleted == true && this.isCompleted == false)
          ? DateTime.now()
          : completedAt
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..isDeleted = isDeleted
      ..sortOrder = sortOrder
      ..projectId = projectId ?? this.projectId
      ..sectionId = sectionId ?? this.sectionId
      ..parentTaskId = parentTaskId ?? this.parentTaskId
      ..recurrenceRule = recurrenceRule ?? this.recurrenceRule
      ..tagIds = tagIds ?? this.tagIds
      ..linkedNoteIds = linkedNoteIds ?? this.linkedNoteIds;
  }

  /// Mark as completed
  Task complete() {
    return copyWith(isCompleted: true)..completedAt = DateTime.now();
  }

  /// Mark as incomplete
  Task uncomplete() {
    return copyWith(isCompleted: false)..completedAt = null;
  }

  /// Soft delete
  Task softDelete() {
    return this
      ..isDeleted = true
      ..deletedAt = DateTime.now()
      ..updatedAt = DateTime.now();
  }

  /// Add tag
  Task addTag(int tagId) {
    final currentTags = tagIdList;
    if (currentTags.contains(tagId)) return this;
    currentTags.add(tagId);
    return copyWith(tagIds: currentTags.join(','));
  }

  /// Remove tag
  Task removeTag(int tagId) {
    final currentTags = tagIdList;
    currentTags.remove(tagId);
    return copyWith(tagIds: currentTags.join(','));
  }

  /// Link a note
  Task linkNote(int noteId) {
    final currentLinks = linkedNoteIdList;
    if (currentLinks.contains(noteId)) return this;
    currentLinks.add(noteId);
    return copyWith(linkedNoteIds: currentLinks.join(','));
  }

  /// Unlink a note
  Task unlinkNote(int noteId) {
    final currentLinks = linkedNoteIdList;
    currentLinks.remove(noteId);
    return copyWith(linkedNoteIds: currentLinks.join(','));
  }

  @override
  String toString() => 'Task(id: $id, title: $title, completed: $isCompleted)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id && other.uid == uid;
  }

  @override
  int get hashCode => id.hashCode ^ uid.hashCode;
}

/// Generate unique ID
String _generateUid() {
  final now = DateTime.now();
  final random = now.microsecondsSinceEpoch.toRadixString(36);
  return 'task_$random';
}
