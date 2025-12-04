// lib/features/tasks/data/models/section_model.dart
// Section entity for grouping tasks within projects

import 'package:isar/isar.dart';

part 'section_model.g.dart';

@collection
class Section {
  Id id = Isar.autoIncrement;

  /// Unique identifier for sync
  @Index(unique: true)
  late String uid;

  /// Section name
  @Index(type: IndexType.value, caseSensitive: false)
  late String name;

  /// Parent project ID
  @Index()
  late int projectId;

  /// Sort order within project
  int sortOrder = 0;

  /// Is section collapsed in UI?
  bool isCollapsed = false;

  /// Creation timestamp
  late DateTime createdAt;

  /// Last update timestamp
  late DateTime updatedAt;

  /// Soft delete flag
  @Index()
  bool isDeleted = false;

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  /// Create a new section
  static Section create({
    required String name,
    required int projectId,
    int sortOrder = 0,
  }) {
    final now = DateTime.now();
    return Section()
      ..uid = _generateUid()
      ..name = name
      ..projectId = projectId
      ..sortOrder = sortOrder
      ..createdAt = now
      ..updatedAt = now;
  }

  /// Create from JSON
  static Section fromJson(Map<String, dynamic> json) {
    return Section()
      ..uid = json['uid'] as String
      ..name = json['name'] as String
      ..projectId = json['projectId'] as int
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..isCollapsed = json['isCollapsed'] as bool? ?? false
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String)
      ..isDeleted = json['isDeleted'] as bool? ?? false;
  }

  // ============================================
  // METHODS
  // ============================================

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'projectId': projectId,
      'sortOrder': sortOrder,
      'isCollapsed': isCollapsed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Create a copy with updates
  Section copyWith({String? name, int? sortOrder, bool? isCollapsed}) {
    return Section()
      ..id = id
      ..uid = uid
      ..name = name ?? this.name
      ..projectId = projectId
      ..sortOrder = sortOrder ?? this.sortOrder
      ..isCollapsed = isCollapsed ?? this.isCollapsed
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..isDeleted = isDeleted;
  }

  /// Toggle collapsed state
  Section toggleCollapsed() => copyWith(isCollapsed: !isCollapsed);

  /// Soft delete
  Section softDelete() {
    return this
      ..isDeleted = true
      ..updatedAt = DateTime.now();
  }

  @override
  String toString() => 'Section(id: $id, name: $name, projectId: $projectId)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Section && other.id == id && other.uid == uid;
  }

  @override
  int get hashCode => id.hashCode ^ uid.hashCode;
}

String _generateUid() {
  final now = DateTime.now();
  final random = now.microsecondsSinceEpoch.toRadixString(36);
  return 'sect_$random';
}
