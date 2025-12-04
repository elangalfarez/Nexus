// lib/features/notes/data/models/note_model.dart
// Core note entity with markdown support and wiki-style linking

import 'package:isar/isar.dart';

part 'note_model.g.dart';

@collection
class Note {
  Id id = Isar.autoIncrement;

  /// Unique identifier for sync and linking
  @Index(unique: true)
  late String uid;

  /// Note title
  @Index(type: IndexType.value, caseSensitive: false)
  late String title;

  /// Markdown content (full-text indexed)
  @Index(type: IndexType.value, caseSensitive: false)
  String content = '';

  /// Plain text content for search (stripped markdown)
  String plainTextContent = '';

  /// Parent folder ID (nullable - null means root)
  @Index()
  int? folderId;

  /// Is note pinned?
  @Index()
  bool isPinned = false;

  /// Is note favorited?
  @Index()
  bool isFavorite = false;

  /// Sort order within folder
  int sortOrder = 0;

  /// Creation timestamp
  @Index()
  late DateTime createdAt;

  /// Last update timestamp
  @Index()
  late DateTime updatedAt;

  /// Last viewed timestamp
  DateTime? lastViewedAt;

  /// Soft delete flag
  @Index()
  bool isDeleted = false;

  /// Deletion timestamp
  DateTime? deletedAt;

  /// Tags (stored as comma-separated tag IDs)
  String tagIds = '';

  /// Linked task IDs (comma-separated)
  String linkedTaskIds = '';

  /// Outgoing note links - notes this note links TO (comma-separated IDs)
  String outgoingLinks = '';

  /// Word count (cached for display)
  int wordCount = 0;

  /// Character count (cached)
  int characterCount = 0;

  /// Template ID this note was created from (nullable)
  int? templateId;

  /// Is this note a template?
  @Index()
  bool isTemplate = false;

  // ============================================
  // COMPUTED PROPERTIES
  // ============================================

  /// Get tag IDs as list
  @ignore
  List<int> get tagIdList {
    if (tagIds.isEmpty) return [];
    return tagIds.split(',').map((e) => int.parse(e.trim())).toList();
  }

  /// Get linked task IDs as list
  @ignore
  List<int> get linkedTaskIdList {
    if (linkedTaskIds.isEmpty) return [];
    return linkedTaskIds.split(',').map((e) => int.parse(e.trim())).toList();
  }

  /// Get outgoing link IDs as list
  @ignore
  List<int> get outgoingLinkList {
    if (outgoingLinks.isEmpty) return [];
    return outgoingLinks.split(',').map((e) => int.parse(e.trim())).toList();
  }

  /// Check if note is in root (no folder)
  @ignore
  bool get isInRoot => folderId == null;

  /// Check if note is empty
  @ignore
  bool get isEmpty => title.isEmpty && content.isEmpty;

  /// Get preview text (first 200 chars of plain content)
  @ignore
  String get preview {
    if (plainTextContent.isEmpty) return '';
    if (plainTextContent.length <= 200) return plainTextContent;
    return '${plainTextContent.substring(0, 200)}...';
  }

  /// Extract wiki links from content [[note title]]
  @ignore
  List<String> get extractedWikiLinks {
    final regex = RegExp(r'\[\[([^\]]+)\]\]');
    final matches = regex.allMatches(content);
    return matches.map((m) => m.group(1)!).toList();
  }

  /// Extract task links from content {{task title}}
  @ignore
  List<String> get extractedTaskLinks {
    final regex = RegExp(r'\{\{([^\}]+)\}\}');
    final matches = regex.allMatches(content);
    return matches.map((m) => m.group(1)!).toList();
  }

  /// Extract hashtags from content
  @ignore
  List<String> get extractedHashtags {
    final regex = RegExp(r'#(\w+)');
    final matches = regex.allMatches(content);
    return matches.map((m) => m.group(1)!).toList();
  }

  // ============================================
  // FACTORY CONSTRUCTORS
  // ============================================

  /// Create a new note
  static Note create({
    required String title,
    String content = '',
    int? folderId,
    bool isPinned = false,
    List<int>? tagIds,
    bool isTemplate = false,
  }) {
    final now = DateTime.now();
    final note = Note()
      ..uid = _generateUid()
      ..title = title
      ..content = content
      ..folderId = folderId
      ..isPinned = isPinned
      ..tagIds = tagIds?.join(',') ?? ''
      ..isTemplate = isTemplate
      ..createdAt = now
      ..updatedAt = now;

    // Update computed fields
    note._updateComputedFields();
    return note;
  }

  /// Create from JSON
  static Note fromJson(Map<String, dynamic> json) {
    final note = Note()
      ..uid = json['uid'] as String
      ..title = json['title'] as String
      ..content = json['content'] as String? ?? ''
      ..plainTextContent = json['plainTextContent'] as String? ?? ''
      ..folderId = json['folderId'] as int?
      ..isPinned = json['isPinned'] as bool? ?? false
      ..isFavorite = json['isFavorite'] as bool? ?? false
      ..sortOrder = json['sortOrder'] as int? ?? 0
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..updatedAt = DateTime.parse(json['updatedAt'] as String)
      ..lastViewedAt = json['lastViewedAt'] != null
          ? DateTime.parse(json['lastViewedAt'] as String)
          : null
      ..isDeleted = json['isDeleted'] as bool? ?? false
      ..tagIds = json['tagIds'] as String? ?? ''
      ..linkedTaskIds = json['linkedTaskIds'] as String? ?? ''
      ..outgoingLinks = json['outgoingLinks'] as String? ?? ''
      ..wordCount = json['wordCount'] as int? ?? 0
      ..characterCount = json['characterCount'] as int? ?? 0
      ..templateId = json['templateId'] as int?
      ..isTemplate = json['isTemplate'] as bool? ?? false;

    return note;
  }

  // ============================================
  // METHODS
  // ============================================

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'title': title,
      'content': content,
      'plainTextContent': plainTextContent,
      'folderId': folderId,
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'sortOrder': sortOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastViewedAt': lastViewedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'tagIds': tagIds,
      'linkedTaskIds': linkedTaskIds,
      'outgoingLinks': outgoingLinks,
      'wordCount': wordCount,
      'characterCount': characterCount,
      'templateId': templateId,
      'isTemplate': isTemplate,
    };
  }

  /// Create a copy with updates
  Note copyWith({
    String? title,
    String? content,
    int? folderId,
    bool? isPinned,
    bool? isFavorite,
    int? sortOrder,
    String? tagIds,
    String? linkedTaskIds,
    String? outgoingLinks,
    bool clearFolder = false,
  }) {
    final note = Note()
      ..id = id
      ..uid = uid
      ..title = title ?? this.title
      ..content = content ?? this.content
      ..folderId = clearFolder ? null : (folderId ?? this.folderId)
      ..isPinned = isPinned ?? this.isPinned
      ..isFavorite = isFavorite ?? this.isFavorite
      ..sortOrder = sortOrder ?? this.sortOrder
      ..createdAt = createdAt
      ..updatedAt = DateTime.now()
      ..lastViewedAt = lastViewedAt
      ..isDeleted = isDeleted
      ..tagIds = tagIds ?? this.tagIds
      ..linkedTaskIds = linkedTaskIds ?? this.linkedTaskIds
      ..outgoingLinks = outgoingLinks ?? this.outgoingLinks
      ..templateId = templateId
      ..isTemplate = isTemplate;

    // Update computed fields if content changed
    if (content != null) {
      note._updateComputedFields();
    } else {
      note.plainTextContent = plainTextContent;
      note.wordCount = wordCount;
      note.characterCount = characterCount;
    }

    return note;
  }

  /// Update computed fields (word count, plain text, etc.)
  void _updateComputedFields() {
    // Strip markdown for plain text
    plainTextContent = _stripMarkdown(content);

    // Count words
    wordCount = plainTextContent.isEmpty
        ? 0
        : plainTextContent.split(RegExp(r'\s+')).length;

    // Count characters
    characterCount = content.length;
  }

  /// Strip markdown formatting
  static String _stripMarkdown(String markdown) {
    return markdown
        // Remove headers
        .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
        // Remove bold/italic
        .replaceAll(RegExp(r'\*{1,3}([^*]+)\*{1,3}'), r'$1')
        .replaceAll(RegExp(r'_{1,3}([^_]+)_{1,3}'), r'$1')
        // Remove links
        .replaceAll(RegExp(r'\[([^\]]+)\]\([^)]+\)'), r'$1')
        // Remove wiki links
        .replaceAll(RegExp(r'\[\[([^\]]+)\]\]'), r'$1')
        // Remove task links
        .replaceAll(RegExp(r'\{\{([^}]+)\}\}'), r'$1')
        // Remove inline code
        .replaceAll(RegExp(r'`([^`]+)`'), r'$1')
        // Remove code blocks
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')
        // Remove blockquotes
        .replaceAll(RegExp(r'^>\s*', multiLine: true), '')
        // Remove horizontal rules
        .replaceAll(RegExp(r'^-{3,}$', multiLine: true), '')
        // Remove list markers
        .replaceAll(RegExp(r'^[\s]*[-*+]\s+', multiLine: true), '')
        .replaceAll(RegExp(r'^[\s]*\d+\.\s+', multiLine: true), '')
        // Clean up whitespace
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  /// Toggle pinned status
  Note togglePinned() => copyWith(isPinned: !isPinned);

  /// Toggle favorite status
  Note toggleFavorite() => copyWith(isFavorite: !isFavorite);

  /// Mark as viewed
  Note markViewed() {
    return this..lastViewedAt = DateTime.now();
  }

  /// Soft delete
  Note softDelete() {
    return this
      ..isDeleted = true
      ..deletedAt = DateTime.now()
      ..updatedAt = DateTime.now();
  }

  /// Add tag
  Note addTag(int tagId) {
    final currentTags = tagIdList;
    if (currentTags.contains(tagId)) return this;
    currentTags.add(tagId);
    return copyWith(tagIds: currentTags.join(','));
  }

  /// Remove tag
  Note removeTag(int tagId) {
    final currentTags = tagIdList;
    currentTags.remove(tagId);
    return copyWith(tagIds: currentTags.join(','));
  }

  /// Link a task
  Note linkTask(int taskId) {
    final currentLinks = linkedTaskIdList;
    if (currentLinks.contains(taskId)) return this;
    currentLinks.add(taskId);
    return copyWith(linkedTaskIds: currentLinks.join(','));
  }

  /// Unlink a task
  Note unlinkTask(int taskId) {
    final currentLinks = linkedTaskIdList;
    currentLinks.remove(taskId);
    return copyWith(linkedTaskIds: currentLinks.join(','));
  }

  /// Add outgoing note link
  Note addOutgoingLink(int noteId) {
    final currentLinks = outgoingLinkList;
    if (currentLinks.contains(noteId)) return this;
    currentLinks.add(noteId);
    return copyWith(outgoingLinks: currentLinks.join(','));
  }

  /// Remove outgoing note link
  Note removeOutgoingLink(int noteId) {
    final currentLinks = outgoingLinkList;
    currentLinks.remove(noteId);
    return copyWith(outgoingLinks: currentLinks.join(','));
  }

  @override
  String toString() => 'Note(id: $id, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id && other.uid == uid;
  }

  @override
  int get hashCode => id.hashCode ^ uid.hashCode;
}

String _generateUid() {
  final now = DateTime.now();
  final random = now.microsecondsSinceEpoch.toRadixString(36);
  return 'note_$random';
}
