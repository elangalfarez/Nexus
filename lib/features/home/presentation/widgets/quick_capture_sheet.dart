// lib/features/home/presentation/widgets/quick_capture_sheet.dart
// Quick capture bottom sheet for adding tasks/notes

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../../../shared/widgets/inputs/app_chip.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../notes/presentation/providers/note_providers.dart';

/// Capture type
enum CaptureType { task, note }

/// Quick capture sheet
class QuickCaptureSheet extends ConsumerStatefulWidget {
  final CaptureType initialType;
  final int? defaultProjectId;
  final int? defaultFolderId;

  const QuickCaptureSheet({
    super.key,
    this.initialType = CaptureType.task,
    this.defaultProjectId,
    this.defaultFolderId,
  });

  /// Show the quick capture sheet
  static Future<void> show(
    BuildContext context, {
    CaptureType initialType = CaptureType.task,
    int? defaultProjectId,
    int? defaultFolderId,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickCaptureSheet(
        initialType: initialType,
        defaultProjectId: defaultProjectId,
        defaultFolderId: defaultFolderId,
      ),
    );
  }

  @override
  ConsumerState<QuickCaptureSheet> createState() => _QuickCaptureSheetState();
}

class _QuickCaptureSheetState extends ConsumerState<QuickCaptureSheet> {
  late CaptureType _type;
  final _titleController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    // Auto-focus after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.onSurfaceDisabledDark
                    : AppColors.onSurfaceDisabled,
                borderRadius: AppRadius.allFull,
              ),
            ),
          ),

          // Type selector
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _TypeChip(
                  label: 'Task',
                  icon: Icons.check_circle_outline,
                  isSelected: _type == CaptureType.task,
                  onTap: () => setState(() => _type = CaptureType.task),
                ),
                SizedBox(width: AppSpacing.sm),
                _TypeChip(
                  label: 'Note',
                  icon: Icons.note_outlined,
                  isSelected: _type == CaptureType.note,
                  onTap: () => setState(() => _type = CaptureType.note),
                ),
              ],
            ),
          ),

          SizedBox(height: AppSpacing.md),

          // Input field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: _type == CaptureType.task
                          ? 'What needs to be done?'
                          : 'Note title...',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceDisabledDark
                            : AppColors.onSurfaceDisabled,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (_) => _handleSave(),
                  ),
                ),

                SizedBox(width: AppSpacing.sm),

                // Save button
                _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : IconButton(
                        onPressed: _titleController.text.isEmpty
                            ? null
                            : _handleSave,
                        icon: Icon(
                          Icons.send,
                          color: _titleController.text.isEmpty
                              ? (isDark
                                    ? AppColors.onSurfaceDisabledDark
                                    : AppColors.onSurfaceDisabled)
                              : AppColors.primary,
                        ),
                      ),
              ],
            ),
          ),

          // Quick actions row
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                if (_type == CaptureType.task) ...[
                  _QuickActionButton(
                    icon: Icons.calendar_today,
                    tooltip: 'Due date',
                    onTap: () {
                      // TODO: Show date picker
                      HapticFeedback.lightImpact();
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _QuickActionButton(
                    icon: Icons.flag_outlined,
                    tooltip: 'Priority',
                    onTap: () {
                      // TODO: Show priority picker
                      HapticFeedback.lightImpact();
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _QuickActionButton(
                    icon: Icons.folder_outlined,
                    tooltip: 'Project',
                    onTap: () {
                      // TODO: Show project picker
                      HapticFeedback.lightImpact();
                    },
                  ),
                ] else ...[
                  _QuickActionButton(
                    icon: Icons.folder_outlined,
                    tooltip: 'Folder',
                    onTap: () {
                      // TODO: Show folder picker
                      HapticFeedback.lightImpact();
                    },
                  ),
                  SizedBox(width: AppSpacing.sm),
                  _QuickActionButton(
                    icon: Icons.push_pin_outlined,
                    tooltip: 'Pin',
                    onTap: () {
                      // TODO: Toggle pin
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],

                SizedBox(width: AppSpacing.sm),
                _QuickActionButton(
                  icon: Icons.label_outline,
                  tooltip: 'Tags',
                  onTap: () {
                    // TODO: Show tag picker
                    HapticFeedback.lightImpact();
                  },
                ),

                const Spacer(),

                // Expand button
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to full editor
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.open_in_full, size: 18),
                  label: Text('Expand'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      if (_type == CaptureType.task) {
        await ref
            .read(taskActionsProvider.notifier)
            .createTask(title: title, projectId: widget.defaultProjectId);
      } else {
        await ref
            .read(noteActionsProvider.notifier)
            .createNote(title: title, folderId: widget.defaultFolderId);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _type == CaptureType.task ? 'Task created' : 'Note created',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create ${_type.name}'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Type selector chip
class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? AppColors.primary.withOpacity(0.12)
          : Colors.transparent,
      borderRadius: AppRadius.allFull,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: AppRadius.allFull,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.allFull,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.outlineDark : AppColors.outline),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant),
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick action button
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;

  const _QuickActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive
            ? AppColors.primary.withOpacity(0.12)
            : Colors.transparent,
        borderRadius: AppRadius.allSm,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.allSm,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}
