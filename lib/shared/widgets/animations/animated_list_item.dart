// lib/shared/widgets/animations/animated_list_item.dart
// List item with staggered animation support

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Animated list item that fades and slides in
class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final Duration staggerDelay;
  final Curve curve;
  final Offset slideOffset;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.curve = Curves.easeOutCubic,
    this.slideOffset = const Offset(0, 20),
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _slideAnimation = Tween<Offset>(
      begin: widget.slideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    // Stagger the animation based on index
    Future.delayed(widget.staggerDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Animated sliver list with staggered children
class AnimatedSliverList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDuration;
  final Duration staggerDelay;

  const AnimatedSliverList({
    super.key,
    required this.children,
    this.itemDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return AnimatedListItem(
          index: index,
          duration: itemDuration,
          staggerDelay: staggerDelay,
          child: children[index],
        );
      }, childCount: children.length),
    );
  }
}

/// Reorderable list with animations
class AnimatedReorderableList<T> extends StatefulWidget {
  final List<T> items;
  final Widget Function(T item, int index, Animation<double> animation)
  itemBuilder;
  final void Function(int oldIndex, int newIndex) onReorder;
  final EdgeInsets? padding;
  final ScrollController? controller;

  const AnimatedReorderableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onReorder,
    this.padding,
    this.controller,
  });

  @override
  State<AnimatedReorderableList<T>> createState() =>
      _AnimatedReorderableListState<T>();
}

class _AnimatedReorderableListState<T>
    extends State<AnimatedReorderableList<T>> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: widget.padding,
      scrollController: widget.controller,
      itemCount: widget.items.length,
      onReorder: widget.onReorder,
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            final elevation = Tween<double>(
              begin: 0,
              end: 8,
            ).animate(animation);
            return Material(
              elevation: elevation.value,
              borderRadius: AppRadius.allMd,
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        return KeyedSubtree(
          key: ValueKey(widget.items[index]),
          child: widget.itemBuilder(
            widget.items[index],
            index,
            const AlwaysStoppedAnimation(1),
          ),
        );
      },
    );
  }
}

/// Hero-animated card for seamless transitions
class HeroCard extends StatelessWidget {
  final String tag;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const HeroCard({
    super.key,
    required this.tag,
    required this.child,
    this.onTap,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Hero(
      tag: tag,
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: borderRadius ?? AppRadius.allMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? AppRadius.allMd,
          child: Padding(
            padding: padding ?? EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Page transition wrapper for hero animations
class HeroPageWrapper extends StatelessWidget {
  final String tag;
  final Widget child;

  const HeroPageWrapper({super.key, required this.tag, required this.child});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

/// Dismissible list item with animation
class AnimatedDismissible extends StatelessWidget {
  final Widget child;
  final VoidCallback onDismissed;
  final DismissDirection direction;
  final Widget? background;
  final Widget? secondaryBackground;
  final Duration duration;

  const AnimatedDismissible({
    super.key,
    required this.child,
    required this.onDismissed,
    this.direction = DismissDirection.horizontal,
    this.background,
    this.secondaryBackground,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: direction,
      onDismissed: (_) => onDismissed(),
      movementDuration: duration,
      background:
          background ??
          _buildBackground(
            context,
            alignment: Alignment.centerLeft,
            color: AppColors.success,
            icon: Icons.check,
          ),
      secondaryBackground:
          secondaryBackground ??
          _buildBackground(
            context,
            alignment: Alignment.centerRight,
            color: AppColors.error,
            icon: Icons.delete,
          ),
      child: child,
    );
  }

  Widget _buildBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      color: color,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Icon(icon, color: Colors.white),
    );
  }
}

/// Expandable/collapsible section with animation
class AnimatedExpandable extends StatefulWidget {
  final Widget header;
  final Widget child;
  final bool initiallyExpanded;
  final Duration duration;
  final ValueChanged<bool>? onExpansionChanged;

  const AnimatedExpandable({
    super.key,
    required this.header,
    required this.child,
    this.initiallyExpanded = false,
    this.duration = const Duration(milliseconds: 200),
    this.onExpansionChanged,
  });

  @override
  State<AnimatedExpandable> createState() => _AnimatedExpandableState();
}

class _AnimatedExpandableState extends State<AnimatedExpandable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _rotationAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(duration: widget.duration, vsync: this);

    if (_isExpanded) {
      _controller.value = 1.0;
    }

    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      widget.onExpansionChanged?.call(_isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Expanded(child: widget.header),
              RotationTransition(
                turns: _rotationAnimation,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizeTransition(sizeFactor: _heightAnimation, child: widget.child),
      ],
    );
  }
}

/// Animated tab indicator
class AnimatedTabIndicator extends StatelessWidget {
  final int selectedIndex;
  final int tabCount;
  final Color? color;
  final double height;
  final Duration duration;

  const AnimatedTabIndicator({
    super.key,
    required this.selectedIndex,
    required this.tabCount,
    this.color,
    this.height = 3,
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tabWidth = constraints.maxWidth / tabCount;
        return AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOut,
          margin: EdgeInsets.only(left: selectedIndex * tabWidth),
          width: tabWidth,
          height: height,
          decoration: BoxDecoration(
            color: color ?? AppColors.primary,
            borderRadius: AppRadius.allFull,
          ),
        );
      },
    );
  }
}
