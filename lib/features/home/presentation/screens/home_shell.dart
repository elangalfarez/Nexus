// lib/features/home/presentation/screens/home_shell.dart
// Main navigation shell with bottom nav and FAB

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
      bottomNavigationBar: _BottomNavBar(
        currentIndex: currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          ref.read(homeTabIndexProvider.notifier).state = index;
        },
      ),
      floatingActionButton: _QuickCaptureFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Bottom navigation bar
class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.outlineDark : AppColors.outline;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor.withOpacity(0.5), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.today_outlined,
                activeIcon: Icons.today,
                label: 'Today',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.inbox_outlined,
                activeIcon: Icons.inbox,
                label: 'Inbox',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.folder_outlined,
                activeIcon: Icons.folder,
                label: 'Projects',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.note_outlined,
                activeIcon: Icons.note,
                label: 'Notes',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation item
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedColor = AppColors.primary;
    final unselectedColor = isDark
        ? AppColors.onSurfaceVariantDark
        : AppColors.onSurfaceVariant;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.allMd,
          child: AnimatedContainer(
            duration: AppConstants.animMicro,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicator
                AnimatedContainer(
                  duration: AppConstants.animMicro,
                  height: 3,
                  width: isSelected ? 24 : 0,
                  margin: EdgeInsets.only(bottom: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: AppRadius.allFull,
                  ),
                ),
                // Icon
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 24,
                  color: isSelected ? selectedColor : unselectedColor,
                ),
                SizedBox(height: AppSpacing.xxs),
                // Label
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isSelected ? selectedColor : unselectedColor,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Quick capture floating action button
class _QuickCaptureFab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(homeTabIndexProvider);

    // Determine default capture type based on current tab
    final defaultType = currentTab == 3 ? CaptureType.note : CaptureType.task;

    return FloatingActionButton(
      onPressed: () {
        HapticFeedback.mediumImpact();
        QuickCaptureSheet.show(context, initialType: defaultType);
      },
      elevation: AppShadows.elevationMd,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      child: const Icon(Icons.add),
    );
  }
}
