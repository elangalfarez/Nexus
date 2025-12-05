// lib/features/home/presentation/widgets/quick_capture_sheet.dart
// Quick capture bottom sheet for adding tasks/notes with full functionality

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/theme.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/widgets/project_picker_sheet.dart';
import '../../../organization/presentation/widgets/tag_picker_sheet.dart';
import '../../../organization/presentation/providers/tag_providers.dart';
import '../../../notes/presentation/providers/note_providers.dart';

/// Capture type
enum CaptureType { task, note }

/// Task priority with visual properties
enum TaskPriorityLevel {
  urgent(1, 'Urgent', Colors.red, Icons.flag),
  high(2, 'High', Colors.orange, Icons.flag),
  medium(3, 'Medium', Colors.blue, Icons.flag_outlined),
  low(4, 'Low', Colors.grey, Icons.flag_outlined);

  final int value;
  final String label;
  final Color color;
  final IconData icon;

  const TaskPriorityLevel(this.value, this.label, this.color, this.icon);

  static TaskPriorityLevel fromValue(int value) {
    return TaskPriorityLevel.values.firstWhere(
      (p) => p.value == value,
      orElse: () => TaskPriorityLevel.low,
    );
  }
}

/// Quick capture sheet
class QuickCaptureSheet extends ConsumerStatefulWidget {
  final CaptureType initialType;
  final int? defaultProjectId;
  final int? defaultFolderId;
  final DateTime? defaultDate;

  const QuickCaptureSheet({
    super.key,
    this.initialType = CaptureType.task,
    this.defaultProjectId,
    this.defaultFolderId,
    this.defaultDate,
  });

  /// Show the quick capture sheet
  static Future<void> show(
    BuildContext context, {
    CaptureType initialType = CaptureType.task,
    int? defaultProjectId,
    int? defaultFolderId,
    DateTime? defaultDate,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickCaptureSheet(
        initialType: initialType,
        defaultProjectId: defaultProjectId,
        defaultFolderId: defaultFolderId,
        defaultDate: defaultDate,
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

  // Task-specific state
  DateTime? _selectedDate;
  TaskPriorityLevel _selectedPriority = TaskPriorityLevel.low;
  int? _selectedProjectId;
  List<int> _selectedTagIds = [];

  // Note-specific state
  int? _selectedFolderId;
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _selectedDate = widget.defaultDate;
    _selectedProjectId = widget.defaultProjectId;
    _selectedFolderId = widget.defaultFolderId;

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
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.bottomSheet,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
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

          // Type selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                _TypeChip(
                  label: 'Task',
                  icon: Icons.check_circle_outline,
                  isSelected: _type == CaptureType.task,
                  onTap: () => setState(() => _type = CaptureType.task),
                ),
                const SizedBox(width: AppSpacing.sm),
                _TypeChip(
                  label: 'Note',
                  icon: Icons.note_outlined,
                  isSelected: _type == CaptureType.note,
                  onTap: () => setState(() => _type = CaptureType.note),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Input field with send button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariantLight,
                      borderRadius: AppRadius.roundedMd,
                      border: Border.all(
                        color: _focusNode.hasFocus
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.borderLight),
                        width: _focusNode.hasFocus ? 1.5 : 1,
                      ),
                    ),
                    child: TextField(
                      controller: _titleController,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.sentences,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: _type == CaptureType.task
                            ? 'What needs to be done?'
                            : 'Note title...',
                        hintStyle: AppTextStyles.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.textDisabledDark
                              : AppColors.textDisabledLight,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.smd,
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _handleSave(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Send button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: _isLoading
                      ? Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(12),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : Material(
                          color: _titleController.text.trim().isEmpty
                              ? (isDark
                                    ? AppColors.surfaceVariantDark
                                    : AppColors.surfaceVariantLight)
                              : AppColors.primary,
                          borderRadius: AppRadius.roundedMd,
                          child: InkWell(
                            onTap: _titleController.text.trim().isEmpty
                                ? null
                                : _handleSave,
                            borderRadius: AppRadius.roundedMd,
                            child: Container(
                              width: 48,
                              height: 48,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.arrow_upward_rounded,
                                color: _titleController.text.trim().isEmpty
                                    ? (isDark
                                          ? AppColors.textDisabledDark
                                          : AppColors.textDisabledLight)
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Selected items preview
          _SelectedItemsPreview(
            type: _type,
            selectedDate: _selectedDate,
            selectedPriority: _selectedPriority,
            selectedProjectId: _selectedProjectId,
            selectedTagIds: _selectedTagIds,
            selectedFolderId: _selectedFolderId,
            isPinned: _isPinned,
            onClearDate: () => setState(() => _selectedDate = null),
            onClearPriority: () =>
                setState(() => _selectedPriority = TaskPriorityLevel.low),
            onClearProject: () => setState(() => _selectedProjectId = null),
            onClearTags: () => setState(() => _selectedTagIds = []),
            onClearFolder: () => setState(() => _selectedFolderId = null),
            onTogglePin: () => setState(() => _isPinned = !_isPinned),
          ),

          // Quick actions row
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                if (_type == CaptureType.task) ...[
                  _QuickActionButton(
                    icon: Icons.calendar_today,
                    tooltip: 'Due date',
                    isActive: _selectedDate != null,
                    activeColor: AppColors.primary,
                    onTap: _showDatePicker,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionButton(
                    icon: _selectedPriority.icon,
                    tooltip: 'Priority',
                    isActive: _selectedPriority != TaskPriorityLevel.low,
                    activeColor: _selectedPriority.color,
                    onTap: _showPriorityPicker,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionButton(
                    icon: Icons.folder_outlined,
                    tooltip: 'Project',
                    isActive: _selectedProjectId != null,
                    activeColor: AppColors.tertiary,
                    onTap: _showProjectPicker,
                  ),
                ] else ...[
                  _QuickActionButton(
                    icon: Icons.folder_outlined,
                    tooltip: 'Folder',
                    isActive: _selectedFolderId != null,
                    activeColor: AppColors.tertiary,
                    onTap: _showFolderPicker,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _QuickActionButton(
                    icon: _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    tooltip: 'Pin',
                    isActive: _isPinned,
                    activeColor: AppColors.warning,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isPinned = !_isPinned);
                    },
                  ),
                ],
                const SizedBox(width: AppSpacing.sm),
                _QuickActionButton(
                  icon: Icons.label_outline,
                  tooltip: 'Tags',
                  isActive: _selectedTagIds.isNotEmpty,
                  activeColor: AppColors.secondary,
                  badge: _selectedTagIds.isNotEmpty
                      ? _selectedTagIds.length.toString()
                      : null,
                  onTap: _showTagPicker,
                ),
                const Spacer(),
                // Expand button
                TextButton.icon(
                  onPressed: _navigateToFullEditor,
                  icon: const Icon(Icons.open_in_full, size: 18),
                  label: const Text('Expand'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
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

  // ============================================
  // ACTION HANDLERS
  // ============================================

  Future<void> _showDatePicker() async {
    HapticFeedback.lightImpact();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final now = DateTime.now();
    final initialDate = _selectedDate ?? now;

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.surfaceDark,
                    onSurface: AppColors.textPrimaryDark,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    onPrimary: Colors.white,
                    surface: AppColors.surfaceLight,
                    onSurface: AppColors.textPrimaryLight,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showPriorityPicker() {
    HapticFeedback.lightImpact();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.bottomSheet,
        ),
        child: SafeArea(
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
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Priority',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Priority options
              ...TaskPriorityLevel.values.map(
                (priority) => _PriorityOption(
                  priority: priority,
                  isSelected: _selectedPriority == priority,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedPriority = priority);
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showProjectPicker() {
    HapticFeedback.lightImpact();
    ProjectPickerSheet.show(
      context,
      selectedProjectId: _selectedProjectId,
      onProjectSelected: (projectId) {
        setState(() => _selectedProjectId = projectId);
      },
    );
  }

  void _showFolderPicker() {
    HapticFeedback.lightImpact();
    // TODO: Implement folder picker for notes when folder model is ready
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Folder picker coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showTagPicker() {
    HapticFeedback.lightImpact();
    TagPickerSheet.show(
      context,
      selectedTagIds: _selectedTagIds,
      onTagsSelected: (tagIds) {
        setState(() => _selectedTagIds = tagIds);
      },
    );
  }

  void _navigateToFullEditor() {
    Navigator.of(context).pop();

    if (_type == CaptureType.task) {
      // Navigate to task edit screen with pre-filled data
      // TODO: Implement navigation to task edit screen
    } else {
      // Navigate to note edit screen
      // TODO: Implement navigation to note edit screen
    }
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      if (_type == CaptureType.task) {
        await ref.read(taskActionsProvider.notifier).createTask(
              title: title,
              priority: _selectedPriority.value,
              dueDate: _selectedDate,
              projectId: _selectedProjectId,
              tagIds: _selectedTagIds.isNotEmpty ? _selectedTagIds : null,
            );
      } else {
        await ref.read(noteActionsProvider.notifier).createNote(
              title: title,
              folderId: _selectedFolderId,
              isPinned: _isPinned,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();

        // Show success feedback
        final message = _type == CaptureType.task
            ? 'Task created'
            : 'Note created';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(message),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
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

// ============================================
// HELPER WIDGETS
// ============================================

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
          ? AppColors.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: AppRadius.roundedFull,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: AppRadius.roundedFull,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedFull,
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
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
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick action button with optional badge
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool isActive;
  final Color activeColor;
  final String? badge;

  const _QuickActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.isActive = false,
    this.activeColor = AppColors.primary,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final iconColor = isActive
        ? activeColor
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return Tooltip(
      message: tooltip,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: isActive
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: AppRadius.roundedSm,
            child: InkWell(
              onTap: onTap,
              borderRadius: AppRadius.roundedSm,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(icon, size: 22, color: iconColor),
              ),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: AppRadius.roundedFull,
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selected items preview row
class _SelectedItemsPreview extends ConsumerWidget {
  final CaptureType type;
  final DateTime? selectedDate;
  final TaskPriorityLevel selectedPriority;
  final int? selectedProjectId;
  final List<int> selectedTagIds;
  final int? selectedFolderId;
  final bool isPinned;
  final VoidCallback onClearDate;
  final VoidCallback onClearPriority;
  final VoidCallback onClearProject;
  final VoidCallback onClearTags;
  final VoidCallback onClearFolder;
  final VoidCallback onTogglePin;

  const _SelectedItemsPreview({
    required this.type,
    required this.selectedDate,
    required this.selectedPriority,
    required this.selectedProjectId,
    required this.selectedTagIds,
    required this.selectedFolderId,
    required this.isPinned,
    required this.onClearDate,
    required this.onClearPriority,
    required this.onClearProject,
    required this.onClearTags,
    required this.onClearFolder,
    required this.onTogglePin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSelection = type == CaptureType.task
        ? (selectedDate != null ||
            selectedPriority != TaskPriorityLevel.low ||
            selectedProjectId != null ||
            selectedTagIds.isNotEmpty)
        : (selectedFolderId != null || isPinned || selectedTagIds.isNotEmpty);

    if (!hasSelection) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          if (type == CaptureType.task) ...[
            // Date chip
            if (selectedDate != null)
              _PreviewChip(
                icon: Icons.calendar_today,
                label: _formatDate(selectedDate!),
                color: AppColors.primary,
                onRemove: onClearDate,
              ),

            // Priority chip
            if (selectedPriority != TaskPriorityLevel.low)
              _PreviewChip(
                icon: selectedPriority.icon,
                label: selectedPriority.label,
                color: selectedPriority.color,
                onRemove: onClearPriority,
              ),

            // Project chip
            if (selectedProjectId != null)
              _ProjectPreviewChip(
                projectId: selectedProjectId!,
                onRemove: onClearProject,
              ),
          ] else ...[
            // Pinned chip
            if (isPinned)
              _PreviewChip(
                icon: Icons.push_pin,
                label: 'Pinned',
                color: AppColors.warning,
                onRemove: onTogglePin,
              ),
          ],

          // Tags
          if (selectedTagIds.isNotEmpty)
            _TagsPreviewChip(
              tagIds: selectedTagIds,
              onRemove: onClearTags,
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == tomorrow) return 'Tomorrow';

    return DateFormat('MMM d').format(date);
  }
}

/// Preview chip for selected items
class _PreviewChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const _PreviewChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedFull,
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            top: AppSpacing.xxs,
            bottom: AppSpacing.xxs,
            right: AppSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(color: color),
              ),
              const SizedBox(width: AppSpacing.xxs),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 12, color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Project preview chip
class _ProjectPreviewChip extends ConsumerWidget {
  final int projectId;
  final VoidCallback onRemove;

  const _ProjectPreviewChip({
    required this.projectId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectByIdProvider(projectId));
    final project = projectAsync.valueOrNull;

    if (project == null) return const SizedBox.shrink();

    final color = AppColors.getProjectColor(project.colorIndex);

    return _PreviewChip(
      icon: Icons.folder,
      label: project.name,
      color: color,
      onRemove: onRemove,
    );
  }
}

/// Tags preview chip
class _TagsPreviewChip extends ConsumerWidget {
  final List<int> tagIds;
  final VoidCallback onRemove;

  const _TagsPreviewChip({
    required this.tagIds,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (tagIds.isEmpty) return const SizedBox.shrink();

    // Get first tag name for preview
    final firstTagAsync = ref.watch(tagByIdProvider(tagIds.first));
    final firstTag = firstTagAsync.valueOrNull;

    final label = tagIds.length == 1
        ? (firstTag?.name ?? 'Tag')
        : '${tagIds.length} tags';

    return _PreviewChip(
      icon: Icons.label_outline,
      label: label,
      color: AppColors.secondary,
      onRemove: onRemove,
    );
  }
}

/// Priority option in picker
class _PriorityOption extends StatelessWidget {
  final TaskPriorityLevel priority;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? priority.color.withValues(alpha: 0.12)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(priority.icon, color: priority.color, size: 22),
              const SizedBox(width: AppSpacing.smd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priority.label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    Text(
                      _getPriorityDescription(priority),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check, color: priority.color, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  String _getPriorityDescription(TaskPriorityLevel priority) {
    return switch (priority) {
      TaskPriorityLevel.urgent => 'Needs immediate attention',
      TaskPriorityLevel.high => 'Important, do soon',
      TaskPriorityLevel.medium => 'Normal priority',
      TaskPriorityLevel.low => 'Can wait',
    };
  }
}
