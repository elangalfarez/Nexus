// lib/features/tasks/presentation/widgets/recurrence_picker_sheet.dart
// Recurrence/repeat configuration bottom sheet

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/buttons/app_button.dart';

/// Recurrence type
enum RecurrenceType {
  none,
  daily,
  weekdays,
  weekly,
  biweekly,
  monthly,
  yearly,
  custom,
}

/// Recurrence picker bottom sheet
class RecurrencePickerSheet extends StatefulWidget {
  final String? initialRecurrence;
  final ValueChanged<String?> onRecurrenceSelected;

  const RecurrencePickerSheet({
    super.key,
    this.initialRecurrence,
    required this.onRecurrenceSelected,
  });

  /// Show the recurrence picker sheet
  static Future<void> show(
    BuildContext context, {
    String? initialRecurrence,
    required ValueChanged<String?> onRecurrenceSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RecurrencePickerSheet(
        initialRecurrence: initialRecurrence,
        onRecurrenceSelected: onRecurrenceSelected,
      ),
    );
  }

  @override
  State<RecurrencePickerSheet> createState() => _RecurrencePickerSheetState();
}

class _RecurrencePickerSheetState extends State<RecurrencePickerSheet> {
  late RecurrenceType _selectedType;
  final int _interval = 1;
  Set<int> _selectedWeekdays = {};

  @override
  void initState() {
    super.initState();
    _selectedType = _parseRecurrence(widget.initialRecurrence);
  }

  RecurrenceType _parseRecurrence(String? rule) {
    if (rule == null || rule.isEmpty) return RecurrenceType.none;

    // Simple parsing - in production would use proper RRULE parsing
    if (rule.contains('DAILY')) return RecurrenceType.daily;
    if (rule.contains('WEEKLY') && rule.contains('MO,TU,WE,TH,FR')) {
      return RecurrenceType.weekdays;
    }
    if (rule.contains('WEEKLY')) return RecurrenceType.weekly;
    if (rule.contains('MONTHLY')) return RecurrenceType.monthly;
    if (rule.contains('YEARLY')) return RecurrenceType.yearly;

    return RecurrenceType.custom;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                  'Repeat',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                if (_selectedType != RecurrenceType.none)
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedType = RecurrenceType.none);
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ),

          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                _RecurrenceOption(
                  icon: Icons.block,
                  label: 'No repeat',
                  isSelected: _selectedType == RecurrenceType.none,
                  onTap: () => _selectType(RecurrenceType.none),
                ),
                _RecurrenceOption(
                  icon: Icons.today,
                  label: 'Daily',
                  description: 'Every day',
                  isSelected: _selectedType == RecurrenceType.daily,
                  onTap: () => _selectType(RecurrenceType.daily),
                ),
                _RecurrenceOption(
                  icon: Icons.work_outline,
                  label: 'Weekdays',
                  description: 'Mon-Fri',
                  isSelected: _selectedType == RecurrenceType.weekdays,
                  onTap: () => _selectType(RecurrenceType.weekdays),
                ),
                _RecurrenceOption(
                  icon: Icons.view_week,
                  label: 'Weekly',
                  description: 'Every week',
                  isSelected: _selectedType == RecurrenceType.weekly,
                  onTap: () => _selectType(RecurrenceType.weekly),
                ),
                _RecurrenceOption(
                  icon: Icons.date_range,
                  label: 'Biweekly',
                  description: 'Every 2 weeks',
                  isSelected: _selectedType == RecurrenceType.biweekly,
                  onTap: () => _selectType(RecurrenceType.biweekly),
                ),
                _RecurrenceOption(
                  icon: Icons.calendar_month,
                  label: 'Monthly',
                  description: 'Every month',
                  isSelected: _selectedType == RecurrenceType.monthly,
                  onTap: () => _selectType(RecurrenceType.monthly),
                ),
                _RecurrenceOption(
                  icon: Icons.cake_outlined,
                  label: 'Yearly',
                  description: 'Every year',
                  isSelected: _selectedType == RecurrenceType.yearly,
                  onTap: () => _selectType(RecurrenceType.yearly),
                ),
              ],
            ),
          ),

          // Custom options (if applicable)
          if (_selectedType == RecurrenceType.weekly) ...[
            Divider(
              height: AppSpacing.lg,
              color: isDark ? AppColors.outlineDark : AppColors.outline,
            ),
            _WeekdayPicker(
              selectedDays: _selectedWeekdays,
              onChanged: (days) => setState(() => _selectedWeekdays = days),
            ),
          ],

          // Confirm button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: 'Done',
              isFullWidth: true,
              onPressed: () {
                final rule = _buildRecurrenceRule();
                widget.onRecurrenceSelected(rule);
                Navigator.of(context).pop();
              },
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _selectType(RecurrenceType type) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedType = type;
      if (type == RecurrenceType.weekly) {
        // Default to current day
        _selectedWeekdays = {DateTime.now().weekday};
      }
    });
  }

  String? _buildRecurrenceRule() {
    return switch (_selectedType) {
      RecurrenceType.none => null,
      RecurrenceType.daily => 'RRULE:FREQ=DAILY',
      RecurrenceType.weekdays => 'RRULE:FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR',
      RecurrenceType.weekly => _buildWeeklyRule(),
      RecurrenceType.biweekly => 'RRULE:FREQ=WEEKLY;INTERVAL=2',
      RecurrenceType.monthly => 'RRULE:FREQ=MONTHLY',
      RecurrenceType.yearly => 'RRULE:FREQ=YEARLY',
      RecurrenceType.custom => 'RRULE:FREQ=DAILY;INTERVAL=$_interval',
    };
  }

  String _buildWeeklyRule() {
    if (_selectedWeekdays.isEmpty) {
      return 'RRULE:FREQ=WEEKLY';
    }

    final days = _selectedWeekdays
        .map(
          (d) => switch (d) {
            1 => 'MO',
            2 => 'TU',
            3 => 'WE',
            4 => 'TH',
            5 => 'FR',
            6 => 'SA',
            7 => 'SU',
            _ => 'MO',
          },
        )
        .join(',');

    return 'RRULE:FREQ=WEEKLY;BYDAY=$days';
  }
}

/// Recurrence option row
class _RecurrenceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? description;
  final bool isSelected;
  final VoidCallback onTap;

  const _RecurrenceOption({
    required this.icon,
    required this.label,
    this.description,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (description != null)
                      Text(
                        description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.onSurfaceVariantDark
                              : AppColors.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check, size: 20, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

/// Weekday picker
class _WeekdayPicker extends StatelessWidget {
  final Set<int> selectedDays;
  final ValueChanged<Set<int>> onChanged;

  const _WeekdayPicker({required this.selectedDays, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Repeat on',
            style: AppTextStyles.labelMedium.copyWith(
              color: isDark
                  ? AppColors.onSurfaceVariantDark
                  : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final dayIndex = index + 1;
              final isSelected = selectedDays.contains(dayIndex);

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  final newDays = Set<int>.from(selectedDays);
                  if (isSelected) {
                    newDays.remove(dayIndex);
                  } else {
                    newDays.add(dayIndex);
                  }
                  onChanged(newDays);
                },
                child: AnimatedContainer(
                  duration: AppConstants.animMicro,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.outlineDark
                                : AppColors.outline),
                    ),
                    borderRadius: AppRadius.allFull,
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                  ? AppColors.onSurfaceDark
                                  : AppColors.onSurface),
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
