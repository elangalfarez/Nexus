// lib/features/organization/data/models/tag_model.dart
// Unified tag entity for both tasks and notes

import 'package:isar/isar.dart';

part 'tag_model.g.dart';

@collection
class Tag {
  Id id = Isar.autoIncrement;

  /// Unique identifier for sync
  @Index(unique: true)
  late String uid;

  /// Tag name (unique, case-insensitive)
  @Index(unique: true, type: IndexType.value, caseSensitive: false)
  late String name;

  /// Tag color index (from AppColors.projectColors)
  int colorIndex = 0;

  /// Sort order in tag list
  int sortOrder = 0;

  /// Usage count (cached for sorting by popularity)
  int usageCount = 0;

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

  /// Create a new tag
  static Tag create({required String name, int colorIndex = 0}) {
    final now = DateTime.now();
    return Tag()
      ..uid = _generateUid()
      ..name = name.toLowerCase().trim()
      ..colorIndex = colorIndex
      ..createdAt = now
      ..updatedAt = now;
  }

  /// Create from JSON
  static Tag fromJson(Map<String, dynamic> json) {
    return Tag()
      ..uid = json['uid'] as String
      ..name = json['name'] as String
      ..colorIndex = json['colorIndex'] as int? ?? 0
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..usageCount = json['usageCount'] as int? ?? 0
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
      'colorIndex': colorIndex,
      'sortOrder': sortOrder,
      'usageCount': usageCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Create a copy with updates
  Tag copyWith({
    String? name,
    int? colorIndex,
    int? sortOrder,
    int? usageCount,
  }) {
    return Tag()
      ..id = id
      ..uid = uid
      ..name = name?.toLowerCase().trim() ?? this.name
      ..colorIndex = colorIndex ?? this.colorIndex
      ..sortOrder = sortOrder ?? this.sortOrder
      ..usageCount = usageCount ?? this.usageCount
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..isDeleted = isDeleted;
  }

  /// Increment usage count
  Tag incrementUsage() => copyWith(usageCount: usageCount + 1);

  /// Decrement usage count
  Tag decrementUsage() =>
      copyWith(usageCount: (usageCount - 1).clamp(0, usageCount));

  /// Soft delete
  Tag softDelete() {
    return this
      ..isDeleted = true
      ..updatedAt = DateTime.now();
  }

  /// Get display name with # prefix
  String get displayName => '#$name';

  @override
  String toString() => 'Tag(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tag && other.id == id && other.uid == uid;
  }

  @override
  int get hashCode => id.hashCode ^ uid.hashCode;
}

String _generateUid() {
  final now = DateTime.now();
  final random = now.microsecondsSinceEpoch.toRadixString(36);
  return 'tag_$random';
}
