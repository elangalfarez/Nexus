// lib/shared/widgets/navigation/animated_nav_bar.dart
// Custom animated bottom navigation bar

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/theme.dart';

/// Animated bottom navigation bar with custom styling
class AnimatedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final double height;
  final bool showLabels;

  const AnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.height = 64,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      height: height + bottomPadding,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            (isDark ? AppColors.surfaceDark : AppColors.surface),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return _NavBarItemWidget(
              item: item,
              isSelected: isSelected,
              selectedColor: selectedColor ?? AppColors.primary,
              unselectedColor:
                  unselectedColor ??
                  (isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant),
              showLabel: showLabels,
              onTap: () {
                HapticFeedback.lightImpact();
                onTap(index);
              },
            );
          }),
        ),
      ),
    );
  }
}

/// Navigation bar item data
class NavBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badge;

  const NavBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// Individual navigation item widget
class _NavBarItemWidget extends StatelessWidget {
  final NavBarItem item;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final bool showLabel;
  final VoidCallback onTap;

  const _NavBarItemWidget({
    required this.item,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with optional badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: AppConstants.animFast,
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.all(isSelected ? 8 : 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? selectedColor.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: AppRadius.allFull,
                  ),
                  child: AnimatedSwitcher(
                    duration: AppConstants.animFast,
                    child: Icon(
                      isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                      key: ValueKey(isSelected),
                      color: isSelected ? selectedColor : unselectedColor,
                      size: 24,
                    ),
                  ),
                ),

                // Badge
                if (item.badge != null && item.badge! > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: item.badge! > 9 ? 4 : 6,
                        vertical: 2,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        borderRadius: AppRadius.allFull,
                      ),
                      child: Text(
                        item.badge! > 99 ? '99+' : item.badge.toString(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Label
            if (showLabel) ...[
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: AppConstants.animFast,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? selectedColor : unselectedColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Floating bottom navigation bar variant
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md + bottomPadding,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: AppRadius.allLg,
          boxShadow: AppShadows.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final isSelected = index == currentIndex;

            return _FloatingNavItem(
              item: item,
              isSelected: isSelected,
              selectedColor: selectedColor ?? AppColors.primary,
              unselectedColor:
                  unselectedColor ??
                  (isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant),
              onTap: () {
                HapticFeedback.lightImpact();
                onTap(index);
              },
            );
          }),
        ),
      ),
    );
  }
}

/// Floating navigation item
class _FloatingNavItem extends StatefulWidget {
  final NavBarItem item;
  final bool isSelected;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _FloatingNavItem({
    required this.item,
    required this.isSelected,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  });

  @override
  State<_FloatingNavItem> createState() => _FloatingNavItemState();
}

class _FloatingNavItemState extends State<_FloatingNavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.9,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AppConstants.animFast,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 16 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.selectedColor.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: AppRadius.allFull,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.isSelected
                    ? (widget.item.activeIcon ?? widget.item.icon)
                    : widget.item.icon,
                color: widget.isSelected
                    ? widget.selectedColor
                    : widget.unselectedColor,
                size: 24,
              ),
              AnimatedSize(
                duration: AppConstants.animFast,
                curve: Curves.easeOutCubic,
                child: widget.isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          widget.item.label,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: widget.selectedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Page indicator dots
class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final double size;
  final double spacing;

  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
    this.size = 8,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: AppConstants.animFast,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? size * 2.5 : size,
          height: size,
          decoration: BoxDecoration(
            color: isActive
                ? (activeColor ?? AppColors.primary)
                : (inactiveColor ??
                      (isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant)),
            borderRadius: AppRadius.allFull,
          ),
        );
      }),
    );
  }
}
