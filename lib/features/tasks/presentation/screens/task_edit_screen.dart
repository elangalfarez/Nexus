// lib/features/tasks/presentation/screens/task_edit_screen.dart
// Full task create/edit form

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/buttons/app_button.dart';
import '../../data/models/task_model.dart';
import '../providers/task_providers.dart';
import '../providers/project_providers.dart';
import '../widgets/date_picker_sheet.dart';
import '../widgets/priority_picker_sheet.dart';
import '../widgets/project_picker_sheet.dart';
import '../widgets/recurrence_picker_sheet.dart';

class TaskEditScreen extends ConsumerStatefulWidget {
  final int? taskId;
  final int? initialProjectId;

  const TaskEditScreen({super.key, this.taskId, this.initialProjectId});

  @override
  ConsumerState<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends ConsumerState<TaskEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _titleFocusNode;

  bool _isLoading = false;
  bool _isNew = true;

  // Task properties
  int _projectId = 0;
  DateTime? _dueDate;
  int _priority = 4;
  String? _recurrenceRule;
  List<int> _tagIds = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _titleFocusNode = FocusNode();

    _isNew = widget.taskId == null;

    if (!_isNew) {
      _loadTask();
    } else {
      _projectId = widget.initialProjectId ?? 0;
      // Auto-focus title for new tasks
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);

    try {
      final task = await ref.read(taskByIdProvider(widget.taskId!).future);
      if (task != null && mounted) {
        setState(() {
          _titleController.text = task.title;
          _descriptionController.text = task.description ?? '';
          _projectId = task.projectId;
          _dueDate = task.dueDate;
          _priority = task.priority;
          _recurrenceRule = task.recurrenceRule;
          _tagIds = task.tagIdList;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load task'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
          ),
        ),
        title: Text(
          _isNew ? 'New task' : 'Edit task',
          style: AppTextStyles.titleLarge.copyWith(
            color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _titleController.text.trim().isEmpty ? null : _saveTask,
            child: Text(
              'Save',
              style: TextStyle(
                color: _titleController.text.trim().isEmpty
                    ? (isDark
                          ? AppColors.onSurfaceDisabledDark
                          : AppColors.onSurfaceDisabled)
                    : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    onChanged: (_) => setState(() {}),
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Task title',
                      hintStyle: AppTextStyles.headlineSmall.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceDisabledDark
                            : AppColors.onSurfaceDisabled,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                  ),

                  SizedBox(height: AppSpacing.md),

                  // Description
                  TextField(
                    controller: _descriptionController,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurface,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add description...',
                      hintStyle: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceDisabledDark
                            : AppColors.onSurfaceDisabled,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLines: null,
                    minLines: 3,
                  ),

                  SizedBox(height: AppSpacing.lg),
                  Divider(
                    color: isDark ? AppColors.outlineDark : AppColors.outline,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Project
                  _PropertyRow(
                    icon: Icons.folder_outlined,
                    label: 'Project',
                    value: _buildProjectValue(),
                    onTap: _showProjectPicker,
                  ),

                  // Due date
                  _PropertyRow(
                    icon: Icons.calendar_today,
                    label: 'Due date',
                    value: _buildDateValue(),
                    valueColor: _dueDate != null && _isOverdue()
                        ? AppColors.error
                        : null,
                    onTap: _showDatePicker,
                  ),

                  // Priority
                  _PropertyRow(
                    icon: Icons.flag_outlined,
                    label: 'Priority',
                    value: _buildPriorityValue(),
                    valueColor: AppColors.getPriorityColor(_priority),
                    trailing: PriorityBadge(priority: _priority, compact: true),
                    onTap: _showPriorityPicker,
                  ),

                  // Repeat
                  _PropertyRow(
                    icon: Icons.repeat,
                    label: 'Repeat',
                    value: _buildRecurrenceValue(),
                    onTap: _showRecurrencePicker,
                  ),

                  SizedBox(height: AppSpacing.md),
                  Divider(
                    color: isDark ? AppColors.outlineDark : AppColors.outline,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Tags
                  _TagsSection(
                    tagIds: _tagIds,
                    onTagsChanged: (tags) => setState(() => _tagIds = tags),
                  ),

                  SizedBox(height: AppSpacing.huge),
                ],
              ),
            ),
    );
  }

  Widget _buildProjectValue() {
    final projectAsync = ref.watch(projectByIdProvider(_projectId));
    return Text(
      projectAsync.valueOrNull?.name ?? 'Inbox',
      style: AppTextStyles.bodyMedium,
    );
  }

  String _buildDateValue() {
    if (_dueDate == null) return 'No date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final date = DateTime(_dueDate!.year, _dueDate!.month, _dueDate!.day);

    if (date == today) return 'Today';
    if (date == tomorrow) return 'Tomorrow';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _buildPriorityValue() => switch (_priority) {
    1 => 'Urgent',
    2 => 'High',
    3 => 'Medium',
    4 => 'Low',
    _ => 'None',
  };

  String _buildRecurrenceValue() {
    if (_recurrenceRule == null) return 'No repeat';
    if (_recurrenceRule!.contains('DAILY')) return 'Daily';
    if (_recurrenceRule!.contains('MO,TU,WE,TH,FR')) return 'Weekdays';
    if (_recurrenceRule!.contains('WEEKLY')) return 'Weekly';
    if (_recurrenceRule!.contains('MONTHLY')) return 'Monthly';
    if (_recurrenceRule!.contains('YEARLY')) return 'Yearly';
    return 'Custom';
  }

  bool _isOverdue() {
    if (_dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _dueDate!.isBefore(today);
  }

  void _showProjectPicker() {
    ProjectPickerSheet.show(
      context,
      selectedProjectId: _projectId,
      onProjectSelected: (id) {
        setState(() => _projectId = id);
      },
    );
  }

  void _showDatePicker() {
    DatePickerSheet.show(
      context,
      initialDate: _dueDate,
      onDateSelected: (date) {
        setState(() => _dueDate = date);
      },
    );
  }

  void _showPriorityPicker() {
    PriorityPickerSheet.show(
      context,
      selectedPriority: _priority,
      onPrioritySelected: (priority) {
        setState(() => _priority = priority);
      },
    );
  }

  void _showRecurrencePicker() {
    RecurrencePickerSheet.show(
      context,
      initialRecurrence: _recurrenceRule,
      onRecurrenceSelected: (rule) {
        setState(() => _recurrenceRule = rule);
      },
    );
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      if (_isNew) {
        await ref
            .read(taskActionsProvider.notifier)
            .createTask(
              title: title,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              projectId: _projectId > 0 ? _projectId : null,
              dueDate: _dueDate,
              priority: _priority,
              recurrenceRule: _recurrenceRule,
            );
      } else {
        await ref
            .read(taskActionsProvider.notifier)
            .updateTask(
              widget.taskId!,
              title: title,
              description: _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
              projectId: _projectId,
              dueDate: _dueDate,
              priority: _priority,
              recurrenceRule: _recurrenceRule,
            );
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isNew ? 'Task created' : 'Task updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save task'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Property row
class _PropertyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? value;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _PropertyRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.allSm,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                ),
              ),
            ),
            if (value != null)
              DefaultTextStyle(
                style: AppTextStyles.bodyMedium.copyWith(
                  color:
                      valueColor ??
                      (isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant),
                ),
                child: value!,
              ),
            if (trailing != null) ...[
              SizedBox(width: AppSpacing.sm),
              trailing!,
            ],
            SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: isDark
                  ? AppColors.onSurfaceDisabledDark
                  : AppColors.onSurfaceDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tags section
class _TagsSection extends StatelessWidget {
  final List<int> tagIds;
  final ValueChanged<List<int>> onTagsChanged;

  const _TagsSection({required this.tagIds, required this.onTagsChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.label_outline,
              size: 20,
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
            SizedBox(width: AppSpacing.sm),
            Text(
              'Tags',
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () {
            // TODO: Show tag picker
          },
          borderRadius: AppRadius.allSm,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark ? AppColors.outlineDark : AppColors.outline,
              ),
              borderRadius: AppRadius.allSm,
            ),
            child: Row(
              children: [
                Icon(Icons.add, size: 18, color: AppColors.primary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Add tags',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
