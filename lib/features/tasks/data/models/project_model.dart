// lib/features/tasks/data/models/project_model.dart
// Project entity for organizing tasks into projects

import 'package:isar/isar.dart';

part 'project_model.g.dart';

@collection
class Project {
  Id id = Isar.autoIncrement;

  /// Unique identifier for sync
  @Index(unique: true)
  late String uid;

  /// Project name
  @Index(type: IndexType.value, caseSensitive: false)
  late String name;

  /// Optional description
  String? description;

  /// Color index (0-11 for predefined colors)
  int colorIndex = 0;

  /// Icon name (for icon selection)
  String iconName = 'folder';

  /// Is this the Inbox project?
  @Index()
  bool isInbox = false;

  /// Is project favorited?
  @Index()
  bool isFavorite = false;

  /// Is project archived?
  @Index()
  bool isArchived = false;

  /// Sort order
  int sortOrder = 0;

  /// Creation timestamp
  late DateTime createdAt;

  /// Last update timestamp
  late DateTime updatedAt;

  /// Soft delete flag
  @Index()
  bool isDeleted = false;

  /// Deletion timestamp
  DateTime? deletedAt;

  // ============================================
  // COMPUTED PROPERTIES
  // ============================================

  /// Check if project is active (not archived, not deleted)
  @ignore
  bool get isActive => !isArchived && !isDeleted;

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  /// Create a new project
  static Project create({
    required String name,
    String? description,
    int colorIndex = 0,
    String iconName = 'folder',
    bool isFavorite = false,
    int sortOrder = 0,
  }) {
    final now = DateTime.now();
    return Project()
      ..uid = _generateUid()
      ..name = name
      ..description = description
      ..colorIndex = colorIndex
      ..iconName = iconName
      ..isFavorite = isFavorite
      ..sortOrder = sortOrder
      ..createdAt = now
      ..updatedAt = now;
  }

  /// Create the special Inbox project
  static Project createInbox() {
    final now = DateTime.now();
    return Project()
      ..uid = 'inbox'
      ..name = 'Inbox'
      ..description = 'Default inbox for new tasks'
      ..colorIndex = 0
      ..iconName = 'inbox'
      ..isInbox = true
      ..isFavorite = false
      ..sortOrder = -1
      ..createdAt = now
      ..updatedAt = now;
  }

  /// Create from JSON
  static Project fromJson(Map<String, dynamic> json) {
    return Project()
      ..uid = json['uid'] as String
      ..name = json['name'] as String
      ..description = json['description'] as String?
      ..colorIndex = json['colorIndex'] as int? ?? 0
      ..iconName = json['iconName'] as String? ?? 'folder'
      ..isInbox = json['isInbox'] as bool? ?? false
      ..isFavorite = json['isFavorite'] as bool? ?? false
      ..isArchived = json['isArchived'] as bool? ?? false
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String)
      ..isDeleted = json['isDeleted'] as bool? ?? false
      ..deletedAt = json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null;
  }

  // ============================================
  // METHODS
  // ============================================

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'description': description,
      'colorIndex': colorIndex,
      'iconName': iconName,
      'isInbox': isInbox,
      'isFavorite': isFavorite,
      'isArchived': isArchived,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDeleted': isDeleted,
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  /// Create a copy with updates
  Project copyWith({
    String? name,
    String? description,
    int? colorIndex,
    String? iconName,
    bool? isFavorite,
    bool? isArchived,
    int? sortOrder,
  }) {
    return Project()
      ..id = id
      ..uid = uid
      ..name = name ?? this.name
      ..description = description ?? this.description
      ..colorIndex = colorIndex ?? this.colorIndex
      ..iconName = iconName ?? this.iconName
      ..isInbox = isInbox
      ..isFavorite = isFavorite ?? this.isFavorite
      ..isArchived = isArchived ?? this.isArchived
      ..sortOrder = sortOrder ?? this.sortOrder
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..isDeleted = isDeleted
      ..deletedAt = deletedAt;
  }

  /// Toggle favorite status
  Project toggleFavorite() {
    return copyWith(isFavorite: !isFavorite);
  }

  /// Archive project
  Project archive() {
    return copyWith(isArchived: true);
  }

  /// Unarchive project
  Project unarchive() {
    return copyWith(isArchived: false);
  }

  /// Soft delete
  Project softDelete() {
    final now = DateTime.now();
    return Project()
      ..id = id
      ..uid = uid
      ..name = name
      ..description = description
      ..colorIndex = colorIndex
      ..iconName = iconName
      ..isInbox = isInbox
      ..isFavorite = isFavorite
      ..isArchived = isArchived
      ..sortOrder = sortOrder
      ..createdAt = createdAt
      ..updatedAt = now
      ..isDeleted = true
      ..deletedAt = now;
  }

  /// Restore from soft delete
  Project restore() {
    return Project()
      ..id = id
      ..uid = uid
      ..name = name
      ..description = description
      ..colorIndex = colorIndex
      ..iconName = iconName
      ..isInbox = isInbox
      ..isFavorite = isFavorite
      ..isArchived = isArchived
      ..sortOrder = sortOrder
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..isDeleted = false
      ..deletedAt = null;
  }

  // ============================================
  // PRIVATE HELPERS
  // ============================================

  /// Generate a unique identifier
  static String _generateUid() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }
}
