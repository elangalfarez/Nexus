// lib/features/home/presentation/screens/home_shell.dart
// Main navigation shell with bottom nav and centered FAB

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../widgets/quick_capture_sheet.dart';
import 'today_screen.dart';
import 'inbox_screen.dart';
import 'projects_screen.dart';
import 'notes_screen.dart';

/// Current tab index
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

/// Home shell with bottom navigation
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: ref.read(homeTabIndexProvider),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    // Listen for tab changes to animate page
    ref.listen<int>(homeTabIndexProvider, (previous, next) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: AppConstants.animStandard,
          curve: Curves.easeInOut,
        );
      }
    });

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          TodayScreen(),
          InboxScreen(),
          ProjectsScreen(),
          NotesScreen(),
        ],
      ),
      // Use extendBody to let content flow behind the nav bar
      extendBody: true,
      bottomNavigationBar: _BottomNavBarWithFab(
        currentIndex: currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          ref.read(homeTabIndexProvider.notifier).state = index;
        },
      ),
    );
  }
}

/// Bottom navigation bar with centered FAB - Premium ADHD-friendly design
/// The FAB pops out above the nav bar for maximum visibility and easy access
class _BottomNavBarWithFab extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBarWithFab({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;

    // FAB size and offset calculations
    const fabSize = 58.0;
    const fabOffset = 28.0; // How much the FAB pops out above nav

    return SizedBox(
      height: 72 + bottomPadding + fabOffset,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 72 + bottomPadding,
              decoration: BoxDecoration(
                color: bgColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  // Use mdl (20px) to align with screen content padding
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.mdl),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Left side: Today, Inbox
                      _NavItem(
                        icon: Icons.wb_sunny_outlined,
                        activeIcon: Icons.wb_sunny_rounded,
                        label: 'Today',
                        isSelected: currentIndex == 0,
                        onTap: () => onTap(0),
                      ),
                      _NavItem(
                        icon: Icons.inbox_outlined,
                        activeIcon: Icons.inbox_rounded,
                        label: 'Inbox',
                        isSelected: currentIndex == 1,
                        onTap: () => onTap(1),
                      ),

                      // Center spacer for FAB
                      const SizedBox(width: fabSize + 16),

                      // Right side: Projects, Notes
                      _NavItem(
                        icon: Icons.folder_copy_outlined,
                        activeIcon: Icons.folder_copy_rounded,
                        label: 'Projects',
                        isSelected: currentIndex == 2,
                        onTap: () => onTap(2),
                      ),
                      _NavItem(
                        icon: Icons.sticky_note_2_outlined,
                        activeIcon: Icons.sticky_note_2_rounded,
                        label: 'Notes',
                        isSelected: currentIndex == 3,
                        onTap: () => onTap(3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Centered FAB - pops out above nav bar
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomPadding + (72 - fabSize) / 2 + fabOffset,
            child: Center(
              child: _CenterFab(currentTab: currentIndex),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered floating action button with premium design
/// - Elevated above nav bar for ADHD visibility
/// - Haptic feedback for sensory confirmation
/// - Context-aware (auto-sets date on Today screen)
class _CenterFab extends ConsumerWidget {
  final int currentTab;

  const _CenterFab({required this.currentTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine default capture type based on current tab
    final defaultType = currentTab == 3 ? CaptureType.note : CaptureType.task;

    // Auto-set today's date when on Today screen (tab 0)
    // This reduces friction for ADHD users - one less decision to make
    final defaultDate = currentTab == 0 ? DateTime.now() : null;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        QuickCaptureSheet.show(
          context,
          initialType: defaultType,
          defaultDate: defaultDate,
        );
      },
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          // Gradient for premium feel
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            // Primary shadow for depth
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: 0,
            ),
            // Subtle ambient shadow
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
}

/// Navigation item with pill background - optimized for ADHD
/// - Clear visual distinction between active/inactive states
/// - Smooth animations for satisfying feedback
/// - Large touch targets (Fitts's Law)
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const selectedColor = AppColors.primary;
    final unselectedColor = isDark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiaryLight;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with animated pill background
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16 : 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? selectedColor.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    size: 22,
                    color: isSelected ? selectedColor : unselectedColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 11,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
