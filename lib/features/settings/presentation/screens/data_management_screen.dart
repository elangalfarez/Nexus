// lib/features/settings/presentation/screens/data_management_screen.dart
// Export and import functionality

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../providers/settings_providers.dart';

class DataManagementScreen extends ConsumerStatefulWidget {
  const DataManagementScreen({super.key});

  @override
  ConsumerState<DataManagementScreen> createState() =>
      _DataManagementScreenState();
}

class _DataManagementScreenState extends ConsumerState<DataManagementScreen> {
  bool _isExporting = false;
  bool _isImporting = false;
  String? _lastExport;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statsAsync = ref.watch(appStatsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Data Management',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          // Data statistics
          _SectionHeader(title: 'Your Data'),
          statsAsync.when(
            data: (stats) => _StatsCard(stats: stats),
            loading: () => _LoadingCard(),
            error: (e, _) => _ErrorCard(message: e.toString()),
          ),

          SizedBox(height: AppSpacing.lg),

          // Export section
          _SectionHeader(title: 'Export'),
          _DataCard(
            icon: Icons.cloud_download_outlined,
            title: 'Export all data',
            description:
                'Download a JSON backup of all your tasks, notes, projects, and settings.',
            trailing: _isExporting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(Icons.download, color: AppColors.primary),
            onTap: _isExporting ? null : _exportData,
          ),

          if (_lastExport != null) ...[
            SizedBox(height: AppSpacing.sm),
            _DataCard(
              icon: Icons.check_circle,
              title: 'Last export ready',
              description: 'Tap to copy export data to clipboard',
              iconColor: AppColors.success,
              onTap: () => _copyToClipboard(_lastExport!),
            ),
          ],

          SizedBox(height: AppSpacing.lg),

          // Import section
          _SectionHeader(title: 'Import'),
          _DataCard(
            icon: Icons.cloud_upload_outlined,
            title: 'Import from backup',
            description:
                'Restore data from a previously exported JSON backup. This will merge with existing data.',
            trailing: _isImporting
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(Icons.upload, color: AppColors.primary),
            onTap: _isImporting ? null : _importData,
          ),

          SizedBox(height: AppSpacing.lg),

          // Cloud sync section
          _SectionHeader(title: 'Cloud Sync'),
          _DataCard(
            icon: Icons.cloud_sync_outlined,
            title: 'Enable cloud backup',
            description:
                'Automatically sync your data across devices. Coming soon in Pro.',
            trailing: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha:0.15),
                borderRadius: AppRadius.roundedFull,
              ),
              child: Text(
                'Pro',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            onTap: () => _showProDialog(),
          ),

          SizedBox(height: AppSpacing.lg),

          // Danger zone
          _SectionHeader(title: 'Danger Zone'),
          _DataCard(
            icon: Icons.delete_forever,
            title: 'Delete all data',
            description:
                'Permanently delete all your tasks, notes, and settings. This cannot be undone.',
            iconColor: AppColors.error,
            onTap: _confirmDeleteAll,
          ),

          SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }

  Future<void> _exportData() async {
    setState(() => _isExporting = true);

    try {
      final data = await ref.read(dataManagementProvider.notifier).exportData();

      if (data != null) {
        final json = jsonEncode(data);
        setState(() {
          _lastExport = json;
          _isExporting = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Export complete! Tap to copy.'),
              action: SnackBarAction(
                label: 'Copy',
                onPressed: () => _copyToClipboard(json),
              ),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isExporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
  }

  Future<void> _importData() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Paste your JSON backup data below:',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '{"tasks": [...], "notes": [...]}',
                border: OutlineInputBorder(borderRadius: AppRadius.roundedSm),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    setState(() => _isImporting = true);

    try {
      final data = jsonDecode(result) as Map<String, dynamic>;
      final success = await ref
          .read(dataManagementProvider.notifier)
          .importData(data);

      setState(() => _isImporting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Import complete!' : 'Import failed'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    } catch (e) {
      setState(() => _isImporting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid JSON format'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showProDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Pro'),
        content: Text(
          'Cloud sync, unlimited projects, and more advanced features are coming soon in Nexus Pro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all data?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete:',
              style: AppTextStyles.bodyMedium,
            ),
            SizedBox(height: AppSpacing.sm),
            _BulletPoint('All tasks and subtasks'),
            _BulletPoint('All notes and folders'),
            _BulletPoint('All projects and sections'),
            _BulletPoint('All tags and links'),
            _BulletPoint('All settings'),
            SizedBox(height: AppSpacing.sm),
            Text(
              'This action cannot be undone.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(dataManagementProvider.notifier)
                  .clearAllData();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'All data deleted' : 'Failed to delete data',
                    ),
                    backgroundColor: success
                        ? AppColors.error
                        : AppColors.error,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
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

class _DataCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const _DataCard({
    required this.icon,
    required this.title,
    required this.description,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: AppRadius.roundedMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha:0.12),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: Icon(icon, color: iconColor ?? AppColors.primary),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: AppSpacing.sm),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final AppStats stats;

  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _StatItem(
                label: 'Tasks',
                value: stats.totalTasks.toString(),
                icon: Icons.check_circle_outline,
              ),
              _StatItem(
                label: 'Notes',
                value: stats.totalNotes.toString(),
                icon: Icons.note_outlined,
              ),
              _StatItem(
                label: 'Projects',
                value: stats.totalProjects.toString(),
                icon: Icons.folder_outlined,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _StatItem(
                label: 'Tags',
                value: stats.totalTags.toString(),
                icon: Icons.label_outline,
              ),
              _StatItem(
                label: 'Words',
                value: _formatNumber(stats.totalWords),
                icon: Icons.text_fields,
              ),
              _StatItem(
                label: 'Completed',
                value: '${(stats.taskCompletionRate * 100).toInt()}%',
                icon: Icons.trending_up,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedMd,
      ),
      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha:0.1),
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.error.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  final String text;

  const _BulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: AppSpacing.sm, bottom: AppSpacing.xxs),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
