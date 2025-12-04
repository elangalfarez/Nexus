// lib/features/notes/data/models/folder_model.dart
// Folder entity for organizing notes with nesting support

import 'package:isar/isar.dart';

part 'folder_model.g.dart';

@collection
class Folder {
  Id id = Isar.autoIncrement;

  /// Unique identifier for sync
  @Index(unique: true)
  late String uid;

  /// Folder name
  @Index(type: IndexType.value, caseSensitive: false)
  late String name;

  /// Parent folder ID (null means root level)
  @Index()
  int? parentFolderId;

  /// Folder color index (from AppColors.projectColors)
  int colorIndex = 0;

  /// Folder icon name (from Lucide icons)
  String iconName = 'folder';

  /// Sort order at current level
  int sortOrder = 0;

  /// Is folder expanded in UI?
  bool isExpanded = true;

  /// Creation timestamp
  late DateTime createdAt;

  /// Last update timestamp
  late DateTime updatedAt;

  /// Soft delete flag
  @Index()
  bool isDeleted = false;

  // ============================================
  // COMPUTED PROPERTIES
  // ============================================

  /// Check if this is a root folder
  @ignore
  bool get isRoot => parentFolderId == null;

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  /// Create a new folder
  static Folder create({
    required String name,
    int? parentFolderId,
    int colorIndex = 0,
    String iconName = 'folder',
  }) {
    final now = DateTime.now();
    return Folder()
      ..uid = _generateUid()
      ..name = name
      ..parentFolderId = parentFolderId
      ..colorIndex = colorIndex
      ..iconName = iconName
      ..createdAt = now
      ..updatedAt = now;
  }

  /// Create from JSON
  static Folder fromJson(Map<String, dynamic> json) {
    return Folder()
      ..uid = json['uid'] as String
      ..name = json['name'] as String
      ..parentFolderId = json['parentFolderId'] as int?
      ..colorIndex = json['colorIndex'] as int? ?? 0
      ..iconName = json['iconName'] as String? ?? 'folder'
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..isExpanded = json['isExpanded'] as bool? ?? true
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
      'parentFolderId': parentFolderId,
      'colorIndex': colorIndex,
      'iconName': iconName,
      'sortOrder': sortOrder,
      'isExpanded': isExpanded,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  /// Create a copy with updates
  Folder copyWith({
    String? name,
    int? parentFolderId,
    int? colorIndex,
    String? iconName,
    int? sortOrder,
    bool? isExpanded,
    bool clearParent = false,
  }) {
    return Folder()
      ..id = id
      ..uid = uid
      ..name = name ?? this.name
      ..parentFolderId = clearParent
          ? null
          : (parentFolderId ?? this.parentFolderId)
      ..colorIndex = colorIndex ?? this.colorIndex
      ..iconName = iconName ?? this.iconName
      ..sortOrder = sortOrder ?? this.sortOrder
      ..isExpanded = isExpanded ?? this.isExpanded
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..isDeleted = isDeleted;
  }

  /// Toggle expanded state
  Folder toggleExpanded() => copyWith(isExpanded: !isExpanded);

  /// Soft delete
  Folder softDelete() {
    return this
      ..isDeleted = true
      ..updatedAt = DateTime.now();
  }

  @override
  String toString() => 'Folder(id: $id, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Folder && other.id == id && other.uid == uid;
  }

  @override
  int get hashCode => id.hashCode ^ uid.hashCode;
}

String _generateUid() {
  final now = DateTime.now();
  final random = now.microsecondsSinceEpoch.toRadixString(36);
  return 'fold_$random';
}
