// lib/features/home/presentation/screens/today_screen.dart
// Today view - Premium ADHD-friendly design with world-class UI/UX
// Dynamic animations, extended date navigation, smart sorting

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/feedback/empty_state.dart';
import '../../../../shared/widgets/inputs/app_checkbox.dart';
import '../../../../shared/widgets/inputs/app_chip.dart';
import '../../../tasks/data/models/project_model.dart';
import '../../../tasks/data/models/task_model.dart';
import '../../../tasks/presentation/providers/project_providers.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../providers/next_task_provider.dart';
import '../widgets/do_this_next_card.dart';
import '../widgets/quick_capture_sheet.dart';
import '../widgets/task_detail_sheet.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// STATE PROVIDERS - Today screen state management
// ═══════════════════════════════════════════════════════════════════════════════

/// Task filter for Today screen
enum TodayFilter { all, pending, completed }

/// Sort option for today tasks
enum TodaySortOption {
  dateNewest('Date Created', 'Newest First', Icons.arrow_downward_rounded),
  dateOldest('Date Created', 'Oldest First', Icons.arrow_upward_rounded),
  priorityHighToLow('Priority', 'Urgent → Low', Icons.keyboard_arrow_down_rounded),
  priorityLowToHigh('Priority', 'Low → Urgent', Icons.keyboard_arrow_up_rounded),
  projectAZ('Project', 'A → Z', Icons.sort_by_alpha_rounded),
  projectZA('Project', 'Z → A', Icons.sort_by_alpha_rounded);

  final String label;
  final String subtitle;
  final IconData icon;
  const TodaySortOption(this.label, this.subtitle, this.icon);
}

/// Current filter state
final todayFilterProvider = StateProvider<TodayFilter>((ref) => TodayFilter.all);

/// Selected date for calendar
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// Week offset for navigation (0 = current week, -1 = previous week, etc.)
final weekOffsetProvider = StateProvider<int>((ref) => 0);

/// Controls whether completed tasks section is expanded
final todayCompletedExpandedProvider = StateProvider<bool>((ref) => true);

/// Sort option (null = no sorting, default order)
final todaySortOptionProvider = StateProvider<TodaySortOption?>((ref) => null);

// ═══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════════

/// Check if two dates are the same day
bool _isSameDayGlobal(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  /// Consistent horizontal padding - aligns with bottom navigation
  static const double _horizontalPadding = AppSpacing.mdl; // 20px

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _dateChangeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _dateChangeController = AnimationController(
      vsync: this,
      duration: AppConstants.animMedium,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dateChangeController, curve: Curves.easeOutCubic),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _dateChangeController, curve: Curves.easeOutCubic),
    );
    _dateChangeController.forward();
  }

  @override
  void dispose() {
    _dateChangeController.dispose();
    super.dispose();
  }

  void _animateDateChange() {
    _dateChangeController.reset();
    _dateChangeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);
    final sortOption = ref.watch(todaySortOptionProvider);

    // Listen for date changes to trigger animation
    ref.listen<DateTime>(selectedDateProvider, (previous, next) {
      if (previous != next) {
        _animateDateChange();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Premium App Bar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 64,
            titleSpacing: 0,
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: TodayScreen._horizontalPadding),
              child: Row(
                children: [
                  // Sun icon with premium glassmorphic effect
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.warning.withValues(alpha: 0.18),
                          AppColors.warning.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: AppRadius.roundedMd,
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      size: 22,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.smd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppTextStyles.headlineMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: AppConstants.animFast,
                          child: Text(
                            _formatDate(selectedDate),
                            key: ValueKey(selectedDate),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? AppColors.textTertiaryDark
                                  : AppColors.textTertiaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Sort button with active indicator
              _ActionButton(
                icon: Icons.swap_vert_rounded,
                tooltip: 'Sort',
                isActive: sortOption != null,
                onPressed: () => _showSortSheet(context, ref),
              ),
              // More options
              _ActionButton(
                icon: Icons.more_horiz_rounded,
                tooltip: 'More options',
                onPressed: () => _showMoreOptionsSheet(context, ref),
              ),
              const SizedBox(width: TodayScreen._horizontalPadding - AppSpacing.sm),
            ],
          ),

          // Content with animation
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xs),

                    // Week Calendar Strip with Navigation
                    _WeekCalendarStrip(onDateChanged: _animateDateChange),

                    const SizedBox(height: AppSpacing.md),

                    // Progress Card
                    const _TodayProgressCard(),

                    const SizedBox(height: AppSpacing.md),

                    // "Do This Next" Card - Only show when viewing today
                    if (_isSameDayGlobal(selectedDate, DateTime.now()))
                      const _DoThisNextSection(),

                    // Filter Tabs
                    const _FilterTabs(),

                    const SizedBox(height: AppSpacing.sm),

                    // Task Sections
                    const _TaskSections(),

                    // Bottom padding
                    const SizedBox(height: AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatDate(DateTime date) {
    final dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${dayNames[date.weekday - 1]}, ${monthNames[date.month - 1]} ${date.day}';
  }

  /// Show sort options bottom sheet
  void _showSortSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _SortOptionsSheet(ref: ref),
    );
  }

  /// Show more options bottom sheet
  void _showMoreOptionsSheet(BuildContext context, WidgetRef ref) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MoreOptionsSheet(ref: ref),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ACTION BUTTON - Premium app bar action
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.xs),
      child: Material(
        color: isActive
            ? AppColors.warning.withValues(alpha: 0.15)
            : Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 22,
              color: isActive
                  ? AppColors.warning
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight),
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// WEEK CALENDAR STRIP - Premium horizontal week view with navigation
// ═══════════════════════════════════════════════════════════════════════════════

class _WeekCalendarStrip extends ConsumerWidget {
  final VoidCallback? onDateChanged;

  const _WeekCalendarStrip({this.onDateChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);
    final weekOffset = ref.watch(weekOffsetProvider);
    final now = DateTime.now();

    // Calculate week start based on offset
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final displayWeekStart = currentWeekStart.add(Duration(days: weekOffset * 7));
    final weekDays = List.generate(7, (i) => displayWeekStart.add(Duration(days: i)));

    // Check if viewing current week
    final isCurrentWeek = weekOffset == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TodayScreen._horizontalPadding),
      child: Column(
        children: [
          // Week navigation header
          Row(
            children: [
              // Previous week button
              _WeekNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(weekOffsetProvider.notifier).state = weekOffset - 1;
                },
              ),
              const SizedBox(width: AppSpacing.sm),

              // Week label / Date picker button
              Expanded(
                child: GestureDetector(
                  onTap: () => _showDatePicker(context, ref),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: AppRadius.roundedMd,
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _getWeekLabel(displayWeekStart, now),
                          style: AppTextStyles.labelLarge.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.unfold_more_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Next week button
              _WeekNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(weekOffsetProvider.notifier).state = weekOffset + 1;
                },
              ),

              // Jump to today button (only show if not on current week)
              if (!isCurrentWeek) ...[
                const SizedBox(width: AppSpacing.sm),
                _TodayJumpButton(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref.read(weekOffsetProvider.notifier).state = 0;
                    ref.read(selectedDateProvider.notifier).state = now;
                    onDateChanged?.call();
                  },
                ),
              ],
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Week days strip
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: AppRadius.roundedLg,
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: weekDays.map((date) {
                final isToday = _isSameDay(date, now);
                final isSelected = _isSameDay(date, selectedDate);
                final isPast = date.isBefore(DateTime(now.year, now.month, now.day));

                return _DayItem(
                  date: date,
                  isToday: isToday,
                  isSelected: isSelected,
                  isPast: isPast && !isToday,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    ref.read(selectedDateProvider.notifier).state = date;
                    onDateChanged?.call();
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String _getWeekLabel(DateTime weekStart, DateTime now) {
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));

    if (_isSameDay(weekStart, currentWeekStart)) {
      return 'This Week';
    } else if (weekStart.isBefore(currentWeekStart)) {
      final weeksAgo = ((currentWeekStart.difference(weekStart).inDays) / 7).ceil();
      if (weeksAgo == 1) return 'Last Week';
      return '$weeksAgo Weeks Ago';
    } else {
      final weeksAhead = ((weekStart.difference(currentWeekStart).inDays) / 7).ceil();
      if (weeksAhead == 1) return 'Next Week';
      return 'In $weeksAhead Weeks';
    }
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();
    final selectedDate = ref.read(selectedDateProvider);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.warning,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticFeedback.selectionClick();
      // Calculate week offset for picked date
      final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
      final pickedWeekStart = picked.subtract(Duration(days: picked.weekday - 1));
      final weekDiff = pickedWeekStart.difference(currentWeekStart).inDays ~/ 7;

      ref.read(weekOffsetProvider.notifier).state = weekDiff;
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Week navigation button
class _WeekNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _WeekNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      borderRadius: AppRadius.roundedMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }
}

/// Today jump button
class _TodayJumpButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TodayJumpButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.warning,
      borderRadius: AppRadius.roundedMd,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.smd,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.today_rounded, size: 16, color: Colors.white),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Today',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual day item with premium styling
class _DayItem extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final bool isSelected;
  final bool isPast;
  final VoidCallback onTap;

  const _DayItem({
    required this.date,
    required this.isToday,
    required this.isSelected,
    required this.isPast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dayLabel = dayNames[date.weekday - 1];

    // Background color logic
    final bgColor = isSelected
        ? AppColors.warning
        : (isToday ? AppColors.warning.withValues(alpha: 0.15) : Colors.transparent);

    // Text color logic
    final textColor = isSelected
        ? Colors.white
        : (isToday
            ? AppColors.warning
            : (isPast
                ? (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight)
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)));

    final labelColor = isSelected
        ? Colors.white.withValues(alpha: 0.8)
        : (isPast
            ? (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight)
            : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        curve: Curves.easeOutCubic,
        width: 42,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.roundedMd,
          border: isToday && !isSelected
              ? Border.all(color: AppColors.warning.withValues(alpha: 0.4), width: 1.5)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              '${date.day}',
              style: AppTextStyles.titleMedium.copyWith(
                color: textColor,
                fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            // Today indicator dot
            if (isToday && !isSelected) ...[
              const SizedBox(height: AppSpacing.xxs),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TODAY PROGRESS CARD - Premium visual progress with circular ring
// ═══════════════════════════════════════════════════════════════════════════════

class _TodayProgressCard extends ConsumerWidget {
  const _TodayProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final isViewingToday = _isSameDay(selectedDate, now);

    // Get tasks for selected date
    final tasksAsync = ref.watch(tasksByDateProvider(selectedDate));

    return tasksAsync.when(
      data: (dateTasks) {
        if (dateTasks.isEmpty) {
          return const SizedBox.shrink();
        }

        final completedCount = dateTasks.where((t) => t.isCompleted).length;
        final totalCount = dateTasks.length;
        final pendingCount = totalCount - completedCount;
        final progress = totalCount > 0 ? completedCount / totalCount : 0.0;
        final isAllComplete = pendingCount == 0 && totalCount > 0;

        return AnimatedContainer(
          duration: AppConstants.animMedium,
          margin: const EdgeInsets.symmetric(horizontal: TodayScreen._horizontalPadding),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isAllComplete
                  ? [
                      AppColors.success.withValues(alpha: 0.12),
                      AppColors.success.withValues(alpha: 0.06),
                    ]
                  : [
                      (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                      (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
                    ],
            ),
            borderRadius: AppRadius.roundedLg,
            border: Border.all(
              color: isAllComplete
                  ? AppColors.success.withValues(alpha: 0.3)
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Progress ring
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background ring
                    CircularProgressIndicator(
                      value: 1,
                      strokeWidth: 4,
                      backgroundColor: (isDark
                              ? AppColors.borderDark
                              : AppColors.borderLight)
                          .withValues(alpha: 0.5),
                      valueColor: AlwaysStoppedAnimation(
                        (isDark ? AppColors.borderDark : AppColors.borderLight)
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    // Progress ring with animation
                    TweenAnimationBuilder<double>(
                      key: ValueKey('progress_$selectedDate'),
                      tween: Tween(begin: 0, end: progress),
                      duration: AppConstants.animSlow,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return CircularProgressIndicator(
                          value: value,
                          strokeWidth: 4,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation(
                            isAllComplete ? AppColors.success : AppColors.warning,
                          ),
                        );
                      },
                    ),
                    // Percentage text
                    TweenAnimationBuilder<int>(
                      key: ValueKey('percent_$selectedDate'),
                      tween: IntTween(begin: 0, end: (progress * 100).round()),
                      duration: AppConstants.animSlow,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) {
                        return Text(
                          '$value%',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isAllComplete
                                ? AppColors.success
                                : (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight),
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Stats section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isViewingToday ? "Today's Progress" : 'Progress',
                      style: AppTextStyles.titleSmall.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        _AnimatedStatBadge(
                          key: ValueKey('pending_$selectedDate'),
                          value: pendingCount,
                          label: 'Pending',
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _AnimatedStatBadge(
                          key: ValueKey('done_$selectedDate'),
                          value: completedCount,
                          label: 'Done',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Celebration indicator when all complete
              AnimatedScale(
                scale: isAllComplete ? 1.0 : 0.0,
                duration: AppConstants.animMedium,
                curve: Curves.elasticOut,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    size: 20,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const _ProgressCardSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _AnimatedStatBadge extends StatelessWidget {
  final int value;
  final String label;
  final Color color;

  const _AnimatedStatBadge({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.smd,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: AppConstants.animMedium,
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              return Text(
                '$animValue',
                style: AppTextStyles.titleMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// DO THIS NEXT SECTION - ADHD-friendly focus feature
// ═══════════════════════════════════════════════════════════════════════════════

class _DoThisNextSection extends ConsumerWidget {
  const _DoThisNextSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasNextTask = ref.watch(hasNextTaskProvider);

    // Only show if there are tasks in the queue
    if (!hasNextTask) {
      return const SizedBox.shrink();
    }

    return const Column(
      children: [
        DoThisNextCard(),
        SizedBox(height: AppSpacing.md),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// FILTER TABS - Premium segmented control
// ═══════════════════════════════════════════════════════════════════════════════

class _FilterTabs extends ConsumerWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(todayFilterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TodayScreen._horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.roundedFull,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _FilterTab(
                label: 'All',
                icon: Icons.list_rounded,
                isSelected: currentFilter == TodayFilter.all,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(todayFilterProvider.notifier).state = TodayFilter.all;
                },
              ),
            ),
            Expanded(
              child: _FilterTab(
                label: 'Pending',
                icon: Icons.pending_actions_rounded,
                isSelected: currentFilter == TodayFilter.pending,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(todayFilterProvider.notifier).state = TodayFilter.pending;
                },
              ),
            ),
            Expanded(
              child: _FilterTab(
                label: 'Done',
                icon: Icons.check_circle_outline_rounded,
                isSelected: currentFilter == TodayFilter.completed,
                onTap: () {
                  HapticFeedback.lightImpact();
                  ref.read(todayFilterProvider.notifier).state = TodayFilter.completed;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.smd,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.warning : Colors.transparent,
          borderRadius: AppRadius.roundedFull,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.warning.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TASK SECTIONS - Premium task list display
// ═══════════════════════════════════════════════════════════════════════════════

class _TaskSections extends ConsumerWidget {
  const _TaskSections();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final now = DateTime.now();
    final isViewingToday = _isSameDay(selectedDate, now);
    final filter = ref.watch(todayFilterProvider);
    final completedExpanded = ref.watch(todayCompletedExpandedProvider);
    final sortOption = ref.watch(todaySortOptionProvider);

    // Get tasks for the selected date - use select to minimize rebuilds
    final tasksAsync = ref.watch(tasksByDateProvider(selectedDate));

    // Only show overdue when viewing today - skip the watch if not needed
    final overdueAsync = isViewingToday
        ? ref.watch(overdueTasksRelativeProvider(selectedDate))
        : const AsyncValue<List<Task>>.data([]);

    // Get projects ONCE here - pass down to children to avoid multiple watches
    final projectsAsync = ref.watch(activeProjectsProvider);
    final projectMap = _buildProjectMap(projectsAsync);
    final projectList = projectsAsync.valueOrNull ?? [];

    return tasksAsync.when(
      data: (dateTasks) {
        final overdueTasks = overdueAsync.valueOrNull ?? [];

        // Apply sorting
        final sortedDateTasks = _sortTasks(dateTasks, sortOption, projectMap);
        final sortedOverdue = _sortTasks(overdueTasks, sortOption, projectMap);

        // Apply filter
        final filteredDateTasks = _applyFilter(sortedDateTasks, filter);
        final filteredOverdue = _applyFilter(sortedOverdue, filter);

        // Separate completed and incomplete
        final incompleteDateTasks = filteredDateTasks.where((t) => !t.isCompleted).toList();
        final completedDateTasks = filteredDateTasks.where((t) => t.isCompleted).toList();

        // Check if completely empty
        final hasNoTasks = dateTasks.isEmpty && overdueTasks.isEmpty;
        final hasNoFilteredTasks = filteredDateTasks.isEmpty && filteredOverdue.isEmpty;

        if (hasNoTasks) {
          final emptyStateContent = _getDateAwareEmptyState(selectedDate, now);
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyState(
              type: EmptyStateType.today,
              title: emptyStateContent.title,
              subtitle: emptyStateContent.subtitle,
              actionLabel: 'Add task',
              onAction: () => QuickCaptureSheet.show(
                context,
                defaultDate: selectedDate,
              ),
            ),
          );
        }

        if (hasNoFilteredTasks) {
          return _FilteredEmptyState(filter: filter);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: TodayScreen._horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overdue section (only when viewing today)
              if (filteredOverdue.isNotEmpty && isViewingToday) ...[
                const SizedBox(height: AppSpacing.md),
                _SectionHeader(
                  title: 'Overdue',
                  count: filteredOverdue.length,
                  icon: Icons.warning_amber_rounded,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...filteredOverdue.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < filteredOverdue.length - 1 ? AppSpacing.xs : 0,
                    ),
                    child: _TaskCard(
                      task: task,
                      projects: projectList,
                      showDueDate: true,
                      accentColor: AppColors.error,
                      onTap: () => TaskDetailSheet.show(context, task),
                      onCompleteChanged: (completed) {
                        HapticFeedback.lightImpact();
                        ref.read(taskActionsProvider.notifier).toggleComplete(task.id);
                      },
                    ),
                  );
                }),
              ],

              // Active tasks section
              if (incompleteDateTasks.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _SectionHeader(
                  title: isViewingToday ? 'Today' : _formatSectionTitle(selectedDate),
                  count: incompleteDateTasks.length,
                  icon: Icons.wb_sunny_outlined,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...incompleteDateTasks.asMap().entries.map((entry) {
                  final index = entry.key;
                  final task = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < incompleteDateTasks.length - 1 ? AppSpacing.xs : 0,
                    ),
                    child: _TaskCard(
                      task: task,
                      projects: projectList,
                      onTap: () => TaskDetailSheet.show(context, task),
                      onCompleteChanged: (completed) {
                        HapticFeedback.lightImpact();
                        ref.read(taskActionsProvider.notifier).toggleComplete(task.id);
                      },
                    ),
                  );
                }),
              ],

              // Completed section with collapse/expand
              if (completedDateTasks.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _CompletedSectionHeader(
                  count: completedDateTasks.length,
                  isExpanded: completedExpanded,
                  onToggle: () {
                    HapticFeedback.selectionClick();
                    ref.read(todayCompletedExpandedProvider.notifier).state =
                        !completedExpanded;
                  },
                ),
                AnimatedCrossFade(
                  firstChild: Column(
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      ...completedDateTasks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final task = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                index < completedDateTasks.length - 1 ? AppSpacing.xs : 0,
                          ),
                          child: _TaskCard(
                            task: task,
                            projects: projectList,
                            isCompleted: true,
                            onTap: () => TaskDetailSheet.show(context, task),
                            onCompleteChanged: (completed) {
                              HapticFeedback.lightImpact();
                              ref
                                  .read(taskActionsProvider.notifier)
                                  .toggleComplete(task.id);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: completedExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: AppConstants.animStandard,
                  sizeCurve: Curves.easeOutCubic,
                ),
              ],

              // Show "All caught up" when active tasks are empty but overdue exists
              if (incompleteDateTasks.isEmpty &&
                  completedDateTasks.isEmpty &&
                  filteredOverdue.isNotEmpty &&
                  isViewingToday)
                const _AllCaughtUpBanner(),

              // Bottom padding for FAB clearance
              const SizedBox(height: 80),
            ],
          ),
        );
      },
      loading: () => const _LoadingSection(),
      error: (e, _) => _ErrorSection(message: e.toString()),
    );
  }

  Map<int, Project> _buildProjectMap(AsyncValue<List<Project>> projectsAsync) {
    return projectsAsync.when(
      data: (projects) => {for (var p in projects) p.id: p},
      loading: () => <int, Project>{},
      error: (_, __) => <int, Project>{},
    );
  }

  List<Task> _sortTasks(
    List<Task> tasks,
    TodaySortOption? sortOption,
    Map<int, Project> projectMap,
  ) {
    if (sortOption == null) return tasks;

    final sorted = List<Task>.from(tasks);

    switch (sortOption) {
      case TodaySortOption.dateNewest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case TodaySortOption.dateOldest:
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case TodaySortOption.priorityHighToLow:
        sorted.sort((a, b) => a.priority.compareTo(b.priority));
      case TodaySortOption.priorityLowToHigh:
        sorted.sort((a, b) => b.priority.compareTo(a.priority));
      case TodaySortOption.projectAZ:
        sorted.sort((a, b) {
          final aProject = a.projectId != null ? projectMap[a.projectId]?.name ?? '' : '';
          final bProject = b.projectId != null ? projectMap[b.projectId]?.name ?? '' : '';
          // Tasks with projects come first
          if (aProject.isEmpty && bProject.isNotEmpty) return 1;
          if (aProject.isNotEmpty && bProject.isEmpty) return -1;
          return aProject.toLowerCase().compareTo(bProject.toLowerCase());
        });
      case TodaySortOption.projectZA:
        sorted.sort((a, b) {
          final aProject = a.projectId != null ? projectMap[a.projectId]?.name ?? '' : '';
          final bProject = b.projectId != null ? projectMap[b.projectId]?.name ?? '' : '';
          // Tasks with projects come first
          if (aProject.isEmpty && bProject.isNotEmpty) return 1;
          if (aProject.isNotEmpty && bProject.isEmpty) return -1;
          return bProject.toLowerCase().compareTo(aProject.toLowerCase());
        });
    }

    return sorted;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatSectionTitle(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (_isSameDay(date, tomorrow)) return 'Tomorrow';
    if (_isSameDay(date, yesterday)) return 'Yesterday';

    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month - 1]} ${date.day}';
  }

  List<Task> _applyFilter(List<Task> tasks, TodayFilter filter) {
    return switch (filter) {
      TodayFilter.all => tasks,
      TodayFilter.pending => tasks.where((t) => !t.isCompleted).toList(),
      TodayFilter.completed => tasks.where((t) => t.isCompleted).toList(),
    };
  }

  _DateEmptyState _getDateAwareEmptyState(DateTime selectedDate, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final difference = selected.difference(today).inDays;

    if (difference == 0) {
      return const _DateEmptyState(
        title: 'All clear for today',
        subtitle: 'Your day is open. Add a task or enjoy the space.',
      );
    }

    if (difference == -1) {
      return const _DateEmptyState(
        title: 'Nothing was due',
        subtitle: 'Yesterday was clear. No worries here.',
      );
    }

    if (difference < -1) {
      return const _DateEmptyState(
        title: 'Nothing was scheduled',
        subtitle: 'This day was free. All good.',
      );
    }

    if (difference == 1) {
      return const _DateEmptyState(
        title: "Tomorrow's open",
        subtitle: 'Nothing planned yet. Add tasks or keep it flexible.',
      );
    }

    return const _DateEmptyState(
      title: 'Day is open',
      subtitle: "Schedule ahead when you're ready.",
    );
  }
}

class _DateEmptyState {
  final String title;
  final String subtitle;

  const _DateEmptyState({required this.title, required this.subtitle});
}

// ═══════════════════════════════════════════════════════════════════════════════
// SECTION HEADER - Premium section header with icon and count
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadius.roundedFull,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xs),
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.roundedFull,
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// COMPLETED SECTION HEADER - Collapsible
// ═══════════════════════════════════════════════════════════════════════════════

class _CompletedSectionHeader extends StatelessWidget {
  final int count;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _CompletedSectionHeader({
    required this.count,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onToggle,
      borderRadius: AppRadius.roundedMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: AppConstants.animFast,
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: AppColors.success,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Completed',
              style: AppTextStyles.labelLarge.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: AppRadius.roundedFull,
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Spacer(),
            AnimatedSwitcher(
              duration: AppConstants.animFast,
              child: Icon(
                isExpanded ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                key: ValueKey(isExpanded),
                size: 16,
                color: isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TASK CARD - Premium card-based task display
// ═══════════════════════════════════════════════════════════════════════════════

class _TaskCard extends StatelessWidget {
  final Task task;
  final List<Project> projects;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onCompleteChanged;
  final bool isCompleted;
  final bool showDueDate;
  final Color? accentColor;

  const _TaskCard({
    required this.task,
    required this.projects,
    this.onTap,
    this.onCompleteChanged,
    this.isCompleted = false,
    this.showDueDate = false,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completed = isCompleted || task.isCompleted;

    // Get project info from passed-in list (no provider watch!)
    final project = _getProject(projects, task.projectId);

    // Text colors
    final titleColor = completed
        ? (isDark ? AppColors.textDisabledDark : AppColors.textDisabledLight)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final subtitleColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return AnimatedContainer(
      duration: AppConstants.animFast,
      decoration: BoxDecoration(
        color: completed
            ? (isDark ? AppColors.surfaceDark : AppColors.surfaceLight)
                .withValues(alpha: 0.5)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: accentColor?.withValues(alpha: 0.3) ??
              (isDark ? AppColors.borderDark : AppColors.borderLight)
                  .withValues(alpha: completed ? 0.3 : 0.6),
          width: accentColor != null ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedMd,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.smd,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: TaskCheckbox(
                    isCompleted: completed,
                    priority: task.priority,
                    onChanged: onCompleteChanged,
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: titleColor,
                          decoration: completed ? TextDecoration.lineThrough : null,
                          decorationColor: titleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Description preview
                      if (task.description != null &&
                          task.description!.isNotEmpty &&
                          !completed) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          task.description!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: subtitleColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      // Metadata row
                      if (!completed && _hasMetadata(project)) ...[
                        const SizedBox(height: AppSpacing.sm),
                        _buildMetadataRow(context, project),
                      ],
                    ],
                  ),
                ),

                // Linked notes indicator
                if (task.linkedNoteIds.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Icon(Icons.link_rounded, size: 16, color: subtitleColor),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Project? _getProject(List<Project> projects, int? projectId) {
    if (projectId == null) return null;
    return projects.cast<Project?>().firstWhere(
      (p) => p?.id == projectId,
      orElse: () => null,
    );
  }

  bool _hasMetadata(Project? project) {
    return task.dueDate != null || task.priority < 4 || project != null;
  }

  Widget _buildMetadataRow(BuildContext context, Project? project) {
    final chips = <Widget>[];

    // Due date
    if (showDueDate && task.dueDate != null) {
      chips.add(DueDateChip(dueDate: task.dueDate, isOverdue: task.isOverdue));
    }

    // Priority (only show if high)
    if (task.priority < 3) {
      chips.add(PriorityChip(priority: task.priority, showLabel: false));
    }

    // Project indicator
    if (project != null) {
      chips.add(_ProjectChip(project: project));
    }

    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: chips,
    );
  }
}

class _ProjectChip extends StatelessWidget {
  final Project project;

  const _ProjectChip({required this.project});

  @override
  Widget build(BuildContext context) {
    final color = _getProjectColor(project.colorIndex);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.roundedSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            project.name,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProjectColor(int colorIndex) {
    const colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.tertiary,
      AppColors.success,
      AppColors.warning,
      AppColors.error,
    ];
    return colors[colorIndex % colors.length];
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// EMPTY & ERROR STATES
// ═══════════════════════════════════════════════════════════════════════════════

class _FilteredEmptyState extends StatelessWidget {
  final TodayFilter filter;

  const _FilteredEmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final message = switch (filter) {
      TodayFilter.all => 'No tasks for this day',
      TodayFilter.pending => 'No pending tasks',
      TodayFilter.completed => 'No completed tasks',
    };

    final icon = switch (filter) {
      TodayFilter.all => Icons.inbox_outlined,
      TodayFilter.pending => Icons.pending_actions_rounded,
      TodayFilter.completed => Icons.task_alt_rounded,
    };

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariantLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.titleSmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllCaughtUpBanner extends StatelessWidget {
  const _AllCaughtUpBanner();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              size: 20,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All caught up for today!',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'No tasks scheduled for today',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TodayScreen._horizontalPadding),
      child: Column(
        children: List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.xs),
            child: _TaskCardSkeleton(),
          ),
        ),
      ),
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String message;

  const _ErrorSection({required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 32,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Something went wrong',
              style: AppTextStyles.titleSmall.copyWith(color: AppColors.error),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SKELETON LOADERS
// ═══════════════════════════════════════════════════════════════════════════════

class _ProgressCardSkeleton extends StatelessWidget {
  const _ProgressCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: TodayScreen._horizontalPadding),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 120,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: AppRadius.roundedXs,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Container(
                      height: 28,
                      width: 70,
                      decoration: BoxDecoration(
                        color: shimmerBase.withValues(alpha: 0.6),
                        borderRadius: AppRadius.roundedSm,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      height: 28,
                      width: 60,
                      decoration: BoxDecoration(
                        color: shimmerBase.withValues(alpha: 0.6),
                        borderRadius: AppRadius.roundedSm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCardSkeleton extends StatelessWidget {
  const _TaskCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final shimmerBase = isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: shimmerBase,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.smd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: shimmerBase,
                    borderRadius: AppRadius.roundedXs,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  height: 10,
                  width: 100,
                  decoration: BoxDecoration(
                    color: shimmerBase.withValues(alpha: 0.6),
                    borderRadius: AppRadius.roundedXs,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// SORT OPTIONS SHEET - Premium sorting with categories
// ═══════════════════════════════════════════════════════════════════════════════

class _SortOptionsSheet extends ConsumerWidget {
  final WidgetRef ref;

  const _SortOptionsSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef cRef) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentSort = ref.watch(todaySortOptionProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.smd),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),
                Expanded(
                  child: Text(
                    'Sort Tasks',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Clear sort button
                if (currentSort != null)
                  TextButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      ref.read(todaySortOptionProvider.notifier).state = null;
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.smd,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Sort options grouped
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              children: TodaySortOption.values.map((option) {
                final isSelected = currentSort == option;
                return _SortOptionTile(
                  option: option,
                  isSelected: isSelected,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(todaySortOptionProvider.notifier).state = option;
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final TodaySortOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.warning.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: AppRadius.roundedSm,
        ),
        child: Icon(
          option.icon,
          size: 20,
          color: isSelected
              ? AppColors.warning
              : (isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight),
        ),
      ),
      title: Text(
        option.label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isSelected
              ? AppColors.warning
              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      subtitle: Text(
        option.subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: isSelected
              ? AppColors.warning.withValues(alpha: 0.7)
              : (isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_rounded, color: AppColors.warning, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MORE OPTIONS SHEET - Premium options with animated toggle
// ═══════════════════════════════════════════════════════════════════════════════

class _MoreOptionsSheet extends ConsumerWidget {
  final WidgetRef ref;

  const _MoreOptionsSheet({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef cRef) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedExpanded = ref.watch(todayCompletedExpandedProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final weekOffset = ref.watch(weekOffsetProvider);
    final sortOption = ref.watch(todaySortOptionProvider);
    final filter = ref.watch(todayFilterProvider);
    final now = DateTime.now();
    final isOnToday = _isSameDay(selectedDate, now) && weekOffset == 0;
    final hasActiveFilters = sortOption != null || filter != TodayFilter.all;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: AppSpacing.smd),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: const Icon(
                    Icons.more_horiz_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.smd),
                Text(
                  'More Options',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Show Completed Toggle - Premium animated toggle
          _AnimatedToggleTile(
            icon: Icons.check_circle_outline_rounded,
            title: 'Show Completed',
            subtitle: 'Display completed tasks in the list',
            value: completedExpanded,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              ref.read(todayCompletedExpandedProvider.notifier).state = value;
            },
          ),

          const Divider(height: 1, indent: 72, endIndent: 16),

          // Jump to today (only show if not already on today)
          if (!isOnToday)
            _OptionTile(
              icon: Icons.today_rounded,
              title: 'Jump to Today',
              subtitle: 'Go back to today\'s view',
              iconColor: AppColors.warning,
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(weekOffsetProvider.notifier).state = 0;
                ref.read(selectedDateProvider.notifier).state = now;
                Navigator.pop(context);
              },
            ),

          // Reset filters (only show if there are active filters)
          if (hasActiveFilters)
            _OptionTile(
              icon: Icons.filter_alt_off_rounded,
              title: 'Reset All Filters',
              subtitle: 'Clear sorting and filter settings',
              iconColor: AppColors.error,
              onTap: () {
                HapticFeedback.mediumImpact();
                ref.read(todayFilterProvider.notifier).state = TodayFilter.all;
                ref.read(todaySortOptionProvider.notifier).state = null;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Filters cleared'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isDark ? AppColors.surfaceDark : AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.md),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Premium animated toggle tile (like in Settings)
class _AnimatedToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _AnimatedToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: value
              ? AppColors.success.withValues(alpha: 0.12)
              : (isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight),
          borderRadius: AppRadius.roundedSm,
        ),
        child: AnimatedSwitcher(
          duration: AppConstants.animFast,
          child: Icon(
            value ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            key: ValueKey(value),
            size: 20,
            color: value
                ? AppColors.success
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
      ),
      trailing: _PremiumSwitch(
        value: value,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }
}

/// Premium animated switch
class _PremiumSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _PremiumSwitch({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        curve: Curves.easeOutCubic,
        width: 52,
        height: 28,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: value ? AppColors.success : AppColors.textDisabledLight,
          borderRadius: AppRadius.roundedFull,
          boxShadow: value
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: AppConstants.animFast,
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 14, color: AppColors.success)
                : null,
          ),
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = iconColor ??
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: AppRadius.roundedSm,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(
          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
        ),
      ),
      onTap: onTap,
    );
  }
}
