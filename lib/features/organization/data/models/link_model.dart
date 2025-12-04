// lib/features/organization/data/models/link_model.dart
// Bidirectional link entity for note-to-note and task-to-note linking

import 'package:isar/isar.dart';

part 'link_model.g.dart';

/// Link types for polymorphic linking
enum LinkType {
  noteToNote, // [[wiki link]] between notes
  noteToTask, // Link from note to task
  taskToNote, // Link from task to note
}

@collection
class Link {
  Id id = Isar.autoIncrement;

  /// Unique identifier for sync
  @Index(unique: true)
  late String uid;

  /// Link type
  @Enumerated(EnumType.ordinal)
  late LinkType linkType;

  /// Source entity type ('note' or 'task')
  @Index()
  late String sourceType;

  /// Source entity ID
  @Index()
  late int sourceId;

  /// Target entity type ('note' or 'task')
  @Index()
  late String targetType;

  /// Target entity ID
  @Index()
  late int targetId;

  /// Link text (the display text, e.g., "[[My Note]]" -> "My Note")
  String? linkText;

  /// Position in source content (character offset, for highlighting)
  int? positionStart;
  int? positionEnd;

  /// Is this link manually created or auto-detected?
  bool isManual = false;

  /// Creation timestamp
  late DateTime createdAt;

  // ============================================
  // COMPUTED PROPERTIES
  // ============================================

  /// Check if this is a note-to-note link
  @ignore
  bool get isNoteToNote => linkType == LinkType.noteToNote;

  /// Check if source is a note
  @ignore
  bool get sourceIsNote => sourceType == 'note';

  /// Check if source is a task
  @ignore
  bool get sourceIsTask => sourceType == 'task';

  /// Check if target is a note
  @ignore
  bool get targetIsNote => targetType == 'note';

  /// Check if target is a task
  @ignore
  bool get targetIsTask => targetType == 'task';

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  /// Create a note-to-note link (wiki link)
  static Link createNoteToNote({
    required int sourceNoteId,
    required int targetNoteId,
    String? linkText,
    int? positionStart,
    int? positionEnd,
    bool isManual = false,
  }) {
    return Link()
      ..uid = _generateUid()
      ..linkType = LinkType.noteToNote
      ..sourceType = 'note'
      ..sourceId = sourceNoteId
      ..targetType = 'note'
      ..targetId = targetNoteId
      ..linkText = linkText
      ..positionStart = positionStart
      ..positionEnd = positionEnd
      ..isManual = isManual
      ..createdAt = DateTime.now();
  }

  /// Create a note-to-task link
  static Link createNoteToTask({
    required int sourceNoteId,
    required int targetTaskId,
    String? linkText,
    int? positionStart,
    int? positionEnd,
    bool isManual = false,
  }) {
    return Link()
      ..uid = _generateUid()
      ..linkType = LinkType.noteToTask
      ..sourceType = 'note'
      ..sourceId = sourceNoteId
      ..targetType = 'task'
      ..targetId = targetTaskId
      ..linkText = linkText
      ..positionStart = positionStart
      ..positionEnd = positionEnd
      ..isManual = isManual
      ..createdAt = DateTime.now();
  }

  /// Create a task-to-note link
  static Link createTaskToNote({
    required int sourceTaskId,
    required int targetNoteId,
    bool isManual = true,
  }) {
    return Link()
      ..uid = _generateUid()
      ..linkType = LinkType.taskToNote
      ..sourceType = 'task'
      ..sourceId = sourceTaskId
      ..targetType = 'note'
      ..targetId = targetNoteId
      ..isManual = isManual
      ..createdAt = DateTime.now();
  }

  /// Create from JSON
  static Link fromJson(Map<String, dynamic> json) {
    return Link()
      ..uid = json['uid'] as String
      ..linkType = LinkType.values[json['linkType'] as int]
      ..sourceType = json['sourceType'] as String
      ..sourceId = json['sourceId'] as int
      ..targetType = json['targetType'] as String
      ..targetId = json['targetId'] as int
      ..linkText = json['linkText'] as String?
      ..positionStart = json['positionStart'] as int?
      ..positionEnd = json['positionEnd'] as int?
      ..isManual = json['isManual'] as bool? ?? false
      ..createdAt = DateTime.parse(json['createdAt'] as String);
  }

  // ============================================
  // METHODS
  // ============================================

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'linkType': linkType.index,
      'sourceType': sourceType,
      'sourceId': sourceId,
      'targetType': targetType,
      'targetId': targetId,
      'linkText': linkText,
      'positionStart': positionStart,
      'positionEnd': positionEnd,
      'isManual': isManual,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Update position in content
  Link updatePosition(int start, int end) {
    return this
      ..positionStart = start
      ..positionEnd = end;
  }

  @override
  String toString() =>
      'Link($sourceType#$sourceId -> $targetType#$targetId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Link &&
        other.sourceType == sourceType &&
        other.sourceId == sourceId &&
        other.targetType == targetType &&
        other.targetId == targetId;
  }

  @override
  int get hashCode =>
      sourceType.hashCode ^
      sourceId.hashCode ^
      targetType.hashCode ^
      targetId.hashCode;
}

String _generateUid() {
  final now = DateTime.now();
  final random = now.microsecondsSinceEpoch.toRadixString(36);
  return 'link_$random';
}
