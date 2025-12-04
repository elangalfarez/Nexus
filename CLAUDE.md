# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Nexus is a Flutter productivity app (Tasks & Second Brain) targeting iOS, Android, and Web platforms. It's a local-first application using Isar for storage with sync infrastructure prepared for future implementation.

## Build & Development Commands

```bash
# Code generation (required after modifying Isar models or Riverpod providers)
flutter pub run build_runner build

# Run the app
flutter run

# Analyze/lint
flutter analyze

# Run tests
flutter test

# Build releases
flutter build apk    # Android
flutter build ios    # iOS
flutter build web    # Web
```

## Architecture

### State Management: Riverpod
- `Provider` for immutable dependencies (repositories)
- `StreamProvider` for real-time Isar data streams
- `FutureProvider.family` for parameterized async lookups
- `StateProvider` for simple UI state
- Use `ref.watch()` for reactive updates, `ref.read()` for one-time access

### Database: Isar
- All entities use `@collection` decorators with generated `.g.dart` files
- Soft delete pattern: `isDeleted` flag with `deletedAt` timestamp
- `uid` field on models for future sync support
- Always wrap writes in `writeTxn()` for atomicity

### Navigation: GoRouter
- Routes defined in `lib/core/router/app_router.dart`
- `AppRoutes` class for route names, `AppPaths` for path strings
- Type-safe navigation via extensions

### Feature Module Structure
```
lib/features/{feature}/
├── data/
│   ├── models/        # Isar @collection schemas
│   └── repositories/  # CRUD operations
└── presentation/
    ├── providers/     # Riverpod providers
    ├── screens/       # Full-page UI
    └── widgets/       # Feature-specific widgets
```

### Theme System
Design tokens in `lib/core/theme/`:
- `app_colors.dart` - Light/dark color schemes
- `app_text_styles.dart` - Typography
- `app_spacing.dart` - Spacing scale
- `app_radius.dart` - Border radius values
- `app_shadows.dart` - Elevation shadows

## Key Patterns

- **Data Flow**: Repository → Riverpod Provider → UI Widget → back to Repository
- **Repositories**: Each entity has its own repository with CRUD + query methods
- **DatabaseService**: Singleton accessed via `DatabaseService.instance.isar`
- **Enums**: Used for TaskPriority, ViewMode, SortOption, AppThemeMode

## Active Features

| Feature | Description |
|---------|-------------|
| Tasks | CRUD, subtasks, priorities, due dates, project/section organization |
| Projects | Task containers, Inbox as default |
| Notes | Markdown content, folder organization |
| Organization | Tags and links between notes/tasks |
| Settings | Theme, view modes, sort preferences |
