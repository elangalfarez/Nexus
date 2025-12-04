// lib/main.dart
// App entry point with initialization

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/services/database_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only for mobile)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await _initializeServices();

  // Run app with Riverpod
  runApp(const ProviderScope(child: NexusApp()));
}

/// Initialize all services before app starts
Future<void> _initializeServices() async {
  // Initialize storage (SharedPreferences)
  await StorageService.initialize();

  // Initialize database (Isar)
  await DatabaseService.initialize();
}

/// Main app widget
class NexusApp extends ConsumerWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode
    final themeMode = ref.watch(flutterThemeModeProvider);

    // Get router
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      // App info
      title: 'Nexus',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Router configuration
      routerConfig: router,

      // Builder for global overlays
      builder: (context, child) {
        // Apply system UI overlay style based on theme
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          isDark ? AppTheme.darkSystemUI : AppTheme.lightSystemUI,
        );

        return child ?? const SizedBox.shrink();
      },
    );
  }
}
