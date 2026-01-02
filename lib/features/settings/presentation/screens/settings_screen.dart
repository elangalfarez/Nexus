// lib/features/settings/presentation/screens/settings_screen.dart
// Main settings page with all app preferences

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/theme.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Settings',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Appearance section
          const _SectionHeader(title: 'Appearance'),
          _SettingsCard(
            children: [
              _ThemeSelector(),
              _SettingsDivider(),
              _AccentColorSelector(),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Tasks section
          const _SectionHeader(title: 'Tasks'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.calendar_today,
                title: 'Show overdue in Today',
                subtitle: 'Include overdue tasks in Today view',
                provider: showOverdueInTodayProvider,
              ),
              _SettingsDivider(),
              _SwitchTile(
                icon: Icons.priority_high,
                title: 'Default priority',
                subtitle: 'New tasks start with medium priority',
                provider: defaultHighPriorityProvider,
              ),
              _SettingsDivider(),
              _DefaultProjectTile(),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Notes section
          const _SectionHeader(title: 'Notes'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.spellcheck,
                title: 'Spell check',
                subtitle: 'Check spelling while typing',
                provider: spellCheckEnabledProvider,
              ),
              _SettingsDivider(),
              _SwitchTile(
                icon: Icons.format_list_numbered,
                title: 'Auto-continue lists',
                subtitle: 'Automatically continue bullet and numbered lists',
                provider: autoContinueListsProvider,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Notifications section
          const _SectionHeader(title: 'Notifications'),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Reminders',
                subtitle: 'Get notified about due tasks',
                provider: remindersEnabledProvider,
              ),
              _SettingsDivider(),
              _ReminderTimeTile(),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Data section
          const _SectionHeader(title: 'Data'),
          _SettingsCard(
            children: [
              _NavigationTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Backup & Sync',
                subtitle: 'Manage cloud backup',
                onTap: () {
                  // TODO: Navigate to backup settings
                },
              ),
              _SettingsDivider(),
              _NavigationTile(
                icon: Icons.download_outlined,
                title: 'Export data',
                subtitle: 'Export tasks and notes',
                onTap: () => _showExportDialog(context, ref),
              ),
              _SettingsDivider(),
              _NavigationTile(
                icon: Icons.upload_outlined,
                title: 'Import data',
                subtitle: 'Import from backup',
                onTap: () => _showImportDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // About section
          const _SectionHeader(title: 'About'),
          _SettingsCard(
            children: [
              _NavigationTile(
                icon: Icons.info_outline,
                title: 'About Nexus',
                subtitle: 'Version, licenses, credits',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
              _SettingsDivider(),
              _NavigationTile(
                icon: Icons.help_outline,
                title: 'Help & Feedback',
                subtitle: 'Get help or send feedback',
                onTap: () {
                  // TODO: Open help
                },
              ),
              _SettingsDivider(),
              _NavigationTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Danger zone
          const _SectionHeader(title: 'Danger Zone'),
          _SettingsCard(
            children: [
              _NavigationTile(
                icon: Icons.delete_forever,
                title: 'Delete all data',
                subtitle: 'Permanently delete all tasks and notes',
                destructive: true,
                onTap: () => _showDeleteAllDialog(context, ref),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export data'),
        content: const Text(
          'Export all your tasks and notes to a JSON file that you can use as a backup.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export started...')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import data'),
        content: const Text(
          'Import tasks and notes from a previously exported backup file. This will merge with existing data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement import
            },
            child: const Text('Choose file'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data?'),
        content: const Text(
          'This will permanently delete all your tasks, notes, projects, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete all
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data deleted'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
  }
}

/// Section header
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.labelLarge.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
    );
  }
}

/// Settings card container
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

/// Settings divider
class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Divider(
      height: 1,
      thickness: 0.5,
      indent: AppSpacing.md + 24 + AppSpacing.sm,
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}

/// Theme selector tile
class _ThemeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

    return ListTile(
      leading: Icon(
        Icons.palette_outlined,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
      title: Text(
        'Theme',
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        _getThemeLabel(themeMode),
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark
            ? AppColors.textDisabledDark
            : AppColors.textDisabledLight,
      ),
      onTap: () => _showThemePicker(context, ref, themeMode),
    );
  }

  String _getThemeLabel(AppThemeMode mode) => switch (mode) {
    AppThemeMode.system => 'System default',
    AppThemeMode.light => 'Light',
    AppThemeMode.dark => 'Dark',
  };

  void _showThemePicker(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode current,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ThemePickerSheet(
        currentMode: current,
        onModeSelected: (mode) {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Theme picker bottom sheet
class _ThemePickerSheet extends StatelessWidget {
  final AppThemeMode currentMode;
  final ValueChanged<AppThemeMode> onModeSelected;

  const _ThemePickerSheet({
    required this.currentMode,
    required this.onModeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.bottomSheet,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.textDisabledDark
                    : AppColors.textDisabledLight,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Theme',
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),

          _ThemeOption(
            icon: Icons.brightness_auto,
            label: 'System default',
            isSelected: currentMode == AppThemeMode.system,
            onTap: () => onModeSelected(AppThemeMode.system),
          ),
          _ThemeOption(
            icon: Icons.light_mode,
            label: 'Light',
            isSelected: currentMode == AppThemeMode.light,
            onTap: () => onModeSelected(AppThemeMode.light),
          ),
          _ThemeOption(
            icon: Icons.dark_mode,
            label: 'Dark',
            isSelected: currentMode == AppThemeMode.dark,
            onTap: () => onModeSelected(AppThemeMode.dark),
          ),

          const SizedBox(height: AppSpacing.md),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// Theme option
class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppColors.primary
            : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
      ),
      title: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }
}

/// Accent color selector
class _AccentColorSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentIndex = ref.watch(accentColorIndexProvider);

    return ListTile(
      leading: Icon(
        Icons.color_lens_outlined,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
      title: Text(
        'Accent color',
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.getProjectColor(accentIndex),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            Icons.chevron_right,
            color: isDark
                ? AppColors.textDisabledDark
                : AppColors.textDisabledLight,
          ),
        ],
      ),
      onTap: () => _showColorPicker(context, ref, accentIndex),
    );
  }

  void _showColorPicker(BuildContext context, WidgetRef ref, int current) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: AppRadius.bottomSheet,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Accent color',
                style: AppTextStyles.titleLarge.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: List.generate(12, (index) {
                  final color = AppColors.getProjectColor(index);
                  final isSelected = index == current;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(accentColorIndexProvider.notifier).state = index;
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }
}

/// Switch setting tile
class _SwitchTile extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final StateProvider<bool> provider;

  const _SwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.provider,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final value = ref.watch(provider);

    return ListTile(
      leading: Icon(
        icon,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: Switch(
        value: value,
        onChanged: (newValue) {
          HapticFeedback.lightImpact();
          ref.read(provider.notifier).state = newValue;
        },
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}

/// Navigation tile
class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool destructive;

  const _NavigationTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: destructive
            ? AppColors.error
            : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: destructive
              ? AppColors.error
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: isDark
            ? AppColors.textDisabledDark
            : AppColors.textDisabledLight,
      ),
      onTap: onTap,
    );
  }
}

/// Default project tile
class _DefaultProjectTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        Icons.folder_outlined,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
      title: Text(
        'Default project',
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        'Inbox',
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark
            ? AppColors.textDisabledDark
            : AppColors.textDisabledLight,
      ),
      onTap: () {
        // TODO: Show project picker
      },
    );
  }
}

/// Reminder time tile
class _ReminderTimeTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final time = ref.watch(defaultReminderTimeProvider);

    return ListTile(
      leading: Icon(
        Icons.access_time,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
      title: Text(
        'Default reminder time',
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        time.format(context),
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark
            ? AppColors.textDisabledDark
            : AppColors.textDisabledLight,
      ),
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          ref.read(defaultReminderTimeProvider.notifier).state = picked;
        }
      },
    );
  }
}

/// About screen
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'About',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // App icon and name
          Center(
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.roundedLg,
                  ),
                  child: const Icon(Icons.hub, size: 48, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Nexus',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tasks & Second Brain',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Version 1.0.0 (Build 1)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textDisabledDark
                        : AppColors.textDisabledLight,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),

          // Links
          _SettingsCard(
            children: [
              _NavigationTile(
                icon: Icons.article_outlined,
                title: 'Terms of Service',
                onTap: () {
                  // TODO: Open terms
                },
              ),
              _SettingsDivider(),
              _NavigationTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  // TODO: Open privacy
                },
              ),
              _SettingsDivider(),
              _NavigationTile(
                icon: Icons.description_outlined,
                title: 'Open Source Licenses',
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'Nexus',
                    applicationVersion: '1.0.0',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        child: const Icon(Icons.hub, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Credits
          Center(
            child: Text(
              'Made with ❤️ by Elang',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
