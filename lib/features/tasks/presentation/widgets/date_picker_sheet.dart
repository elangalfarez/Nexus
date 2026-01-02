// lib/features/tasks/presentation/widgets/date_picker_sheet.dart
// Date and time picker bottom sheet

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/buttons/app_button.dart';

/// Date picker bottom sheet
class DatePickerSheet extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onDateSelected;
  final bool showTime;

  const DatePickerSheet({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    this.showTime = false,
  });

  /// Show the date picker sheet
  static Future<void> show(
    BuildContext context, {
    DateTime? initialDate,
    required ValueChanged<DateTime?> onDateSelected,
    bool showTime = false,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DatePickerSheet(
        initialDate: initialDate,
        onDateSelected: onDateSelected,
        showTime: showTime,
      ),
    );
  }

  @override
  State<DatePickerSheet> createState() => _DatePickerSheetState();
}

class _DatePickerSheetState extends State<DatePickerSheet> {
  late DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    if (widget.initialDate != null && widget.showTime) {
      _selectedTime = TimeOfDay.fromDateTime(widget.initialDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final nextWeek = today.add(const Duration(days: 7));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.bottomSheetRadius,
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
                    ? AppColors.onSurfaceDisabledDark
                    : AppColors.onSurfaceDisabled,
                borderRadius: AppRadius.allFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  'Due date',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                if (_selectedDate != null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                        _selectedTime = null;
                      });
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),

          // Quick options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                _QuickDateOption(
                  icon: Icons.today,
                  label: 'Today',
                  sublabel: _formatDay(today),
                  isSelected: _isSameDay(_selectedDate, today),
                  onTap: () => _selectDate(today),
                ),
                _QuickDateOption(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Tomorrow',
                  sublabel: _formatDay(tomorrow),
                  isSelected: _isSameDay(_selectedDate, tomorrow),
                  onTap: () => _selectDate(tomorrow),
                ),
                _QuickDateOption(
                  icon: Icons.next_week_outlined,
                  label: 'Next week',
                  sublabel: _formatDay(nextWeek),
                  isSelected: _isSameDay(_selectedDate, nextWeek),
                  onTap: () => _selectDate(nextWeek),
                ),
                _QuickDateOption(
                  icon: Icons.calendar_month,
                  label: 'Pick a date',
                  sublabel:
                      _selectedDate != null &&
                          !_isSameDay(_selectedDate, today) &&
                          !_isSameDay(_selectedDate, tomorrow) &&
                          !_isSameDay(_selectedDate, nextWeek)
                      ? _formatDate(_selectedDate!)
                      : null,
                  isSelected:
                      _selectedDate != null &&
                      !_isSameDay(_selectedDate, today) &&
                      !_isSameDay(_selectedDate, tomorrow) &&
                      !_isSameDay(_selectedDate, nextWeek),
                  onTap: () => _showCalendar(),
                ),
              ],
            ),
          ),

          // Time picker (if enabled)
          if (widget.showTime) ...[
            Divider(
              height: AppSpacing.lg,
              color: isDark ? AppColors.outlineDark : AppColors.outline,
            ),
            _TimePickerRow(
              selectedTime: _selectedTime,
              onTimeSelected: (time) {
                setState(() => _selectedTime = time);
              },
            ),
          ],

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: 'Done',
              isFullWidth: true,
              onPressed: () {
                DateTime? result = _selectedDate;
                if (result != null && _selectedTime != null) {
                  result = DateTime(
                    result.year,
                    result.month,
                    result.day,
                    _selectedTime!.hour,
                    _selectedTime!.minute,
                  );
                }
                widget.onDateSelected(result);
                Navigator.of(context).pop();
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _selectDate(DateTime date) {
    HapticFeedback.lightImpact();
    setState(() => _selectedDate = date);
  }

  Future<void> _showCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectDate(picked);
    }
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDay(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _formatDate(DateTime date) {
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
}

/// Quick date option row
class _QuickDateOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateOption({
    required this.icon,
    required this.label,
    this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isSelected
          ? AppColors.primary.withOpacity(0.08)
          : Colors.transparent,
      borderRadius: AppRadius.allSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allSm,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              const Spacer(),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant),
                  ),
                ),
              if (isSelected) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.check, size: 20, color: AppColors.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Time picker row
class _TimePickerRow extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final ValueChanged<TimeOfDay?> onTimeSelected;

  const _TimePickerRow({this.selectedTime, required this.onTimeSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Icon(
            Icons.access_time,
            size: 20,
            color: isDark
                ? AppColors.onSurfaceVariantDark
                : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            'Time',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: selectedTime ?? TimeOfDay.now(),
              );
              if (picked != null) {
                onTimeSelected(picked);
              }
            },
            child: Text(
              selectedTime != null ? selectedTime!.format(context) : 'Add time',
              style: TextStyle(
                color: selectedTime != null
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariant),
              ),
            ),
          ),
          if (selectedTime != null)
            IconButton(
              onPressed: () => onTimeSelected(null),
              icon: Icon(
                Icons.close,
                size: 18,
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
