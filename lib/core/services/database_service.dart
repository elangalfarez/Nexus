// lib/core/services/database_service.dart
// Isar database initialization and management

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/tasks/data/models/task_model.dart';
import '../../features/tasks/data/models/project_model.dart';
import '../../features/tasks/data/models/section_model.dart';
import '../../features/notes/data/models/note_model.dart';
import '../../features/notes/data/models/folder_model.dart';
import '../../features/organization/data/models/tag_model.dart';
import '../../features/organization/data/models/link_model.dart';
import '../constants/app_constants.dart';

/// Database service for Isar initialization and access
class DatabaseService {
  static Isar? _instance;
  static bool _isInitialized = false;

  /// Private constructor
  DatabaseService._();

  /// Get the Isar instance
  static Isar get instance {
    if (_instance == null) {
      throw StateError(
        'Database not initialized. Call DatabaseService.initialize() first.',
      );
    }
    return _instance!;
  }

  /// Check if database is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize the database
  static Future<Isar> initialize() async {
    if (_isInitialized && _instance != null) {
      return _instance!;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();

      _instance = await Isar.open(
        [
          TaskSchema,
          ProjectSchema,
          SectionSchema,
          NoteSchema,
          FolderSchema,
          TagSchema,
          LinkSchema,
        ],
        directory: dir.path,
        name: AppConstants.databaseName,
        inspector: kDebugMode, // Enable inspector in debug mode
      );

      _isInitialized = true;

      // Ensure default Inbox project exists
      await _ensureInboxExists();

      if (kDebugMode) {
        debugPrint('Database initialized at: ${dir.path}');
        debugPrint(
          'Collections: ${_instance!.schemas.map((s) => s.name).join(', ')}',
        );
      }

      return _instance!;
    } catch (e, stack) {
      debugPrint('Failed to initialize database: $e');
      debugPrint('Stack trace: $stack');
      rethrow;
    }
  }

  /// Ensure the default Inbox project exists
  static Future<void> _ensureInboxExists() async {
    final db = _instance!;

    final existingInbox = await db.projects
        .filter()
        .isInboxEqualTo(true)
        .findFirst();

    if (existingInbox == null) {
      final inbox = Project.createInbox();
      await db.writeTxn(() async {
        await db.projects.put(inbox);
      });
      if (kDebugMode) {
        debugPrint('Created default Inbox project');
      }
    }
  }

  /// Close the database
  static Future<void> close() async {
    if (_instance != null && _instance!.isOpen) {
      await _instance!.close();
      _instance = null;
      _isInitialized = false;
      if (kDebugMode) {
        debugPrint('Database closed');
      }
    }
  }

  /// Clear all data (for testing or reset)
  static Future<void> clearAll() async {
    final db = _instance;
    if (db == null) return;

    await db.writeTxn(() async {
      await db.clear();
    });

    // Recreate inbox
    await _ensureInboxExists();

    if (kDebugMode) {
      debugPrint('Database cleared');
    }
  }

  /// Export all data to JSON
  static Future<Map<String, dynamic>> exportAll() async {
    final db = _instance!;

    final tasks = await db.tasks.where().findAll();
    final projects = await db.projects.where().findAll();
    final sections = await db.sections.where().findAll();
    final notes = await db.notes.where().findAll();
    final folders = await db.folders.where().findAll();
    final tags = await db.tags.where().findAll();
    final links = await db.links.where().findAll();

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'version': AppConstants.databaseVersion,
      'tasks': tasks.map((t) => t.toJson()).toList(),
      'projects': projects.map((p) => p.toJson()).toList(),
      'sections': sections.map((s) => s.toJson()).toList(),
      'notes': notes.map((n) => n.toJson()).toList(),
      'folders': folders.map((f) => f.toJson()).toList(),
      'tags': tags.map((t) => t.toJson()).toList(),
      'links': links.map((l) => l.toJson()).toList(),
    };
  }

  /// Import data from JSON
  static Future<void> importAll(Map<String, dynamic> data) async {
    final db = _instance!;

    await db.writeTxn(() async {
      // Import tags first (referenced by tasks and notes)
      if (data['tags'] != null) {
        for (final json in data['tags'] as List) {
          final tag = Tag.fromJson(json as Map<String, dynamic>);
          await db.tags.put(tag);
        }
      }

      // Import folders
      if (data['folders'] != null) {
        for (final json in data['folders'] as List) {
          final folder = Folder.fromJson(json as Map<String, dynamic>);
          await db.folders.put(folder);
        }
      }

      // Import projects
      if (data['projects'] != null) {
        for (final json in data['projects'] as List) {
          final project = Project.fromJson(json as Map<String, dynamic>);
          await db.projects.put(project);
        }
      }

      // Import sections
      if (data['sections'] != null) {
        for (final json in data['sections'] as List) {
          final section = Section.fromJson(json as Map<String, dynamic>);
          await db.sections.put(section);
        }
      }

      // Import tasks
      if (data['tasks'] != null) {
        for (final json in data['tasks'] as List) {
          final task = Task.fromJson(json as Map<String, dynamic>);
          await db.tasks.put(task);
        }
      }

      // Import notes
      if (data['notes'] != null) {
        for (final json in data['notes'] as List) {
          final note = Note.fromJson(json as Map<String, dynamic>);
          await db.notes.put(note);
        }
      }

      // Import links last
      if (data['links'] != null) {
        for (final json in data['links'] as List) {
          final link = Link.fromJson(json as Map<String, dynamic>);
          await db.links.put(link);
        }
      }
    });

    if (kDebugMode) {
      debugPrint('Data imported successfully');
    }
  }

  /// Get database statistics
  static Future<Map<String, int>> getStats() async {
    final db = _instance!;

    return {
      'tasks': await db.tasks.count(),
      'projects': await db.projects.count(),
      'sections': await db.sections.count(),
      'notes': await db.notes.count(),
      'folders': await db.folders.count(),
      'tags': await db.tags.count(),
      'links': await db.links.count(),
    };
  }
}

/// Extension on Isar for convenience methods
extension IsarExtensions on Isar {
  /// Get the Inbox project
  Future<Project> getInbox() async {
    final inbox = await projects.filter().isInboxEqualTo(true).findFirst();
    if (inbox == null) {
      throw StateError('Inbox project not found');
    }
    return inbox;
  }

  /// Get inbox project ID
  Future<int> getInboxId() async {
    final inbox = await getInbox();
    return inbox.id;
  }
}
