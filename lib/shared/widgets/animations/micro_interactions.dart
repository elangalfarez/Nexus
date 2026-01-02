// lib/shared/widgets/animations/micro_interactions.dart
// Micro-interaction widgets for delightful UI

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';
import '../../../core/utils/haptics.dart';

/// Pressable widget with scale and opacity feedback
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleDown;
  final Duration duration;
  final bool hapticFeedback;

  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleDown = 0.97,
    this.duration = const Duration(milliseconds: 100),
    this.hapticFeedback = true,
  });

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleDown,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? _onTapDown : null,
      onTapUp: widget.onTap != null ? _onTapUp : null,
      onTapCancel: widget.onTap != null ? _onTapCancel : null,
      onTap: () {
        if (widget.hapticFeedback) Haptics.tap();
        widget.onTap?.call();
      },
      onLongPress: widget.onLongPress != null
          ? () {
              if (widget.hapticFeedback) Haptics.longPress();
              widget.onLongPress?.call();
            }
          : null,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Bouncy tap animation
class BouncyTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double bounceScale;

  const BouncyTap({
    super.key,
    required this.child,
    this.onTap,
    this.bounceScale = 1.1,
  });

  @override
  State<BouncyTap> createState() => _BouncyTapState();
}

class _BouncyTapState extends State<BouncyTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: widget.bounceScale),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.bounceScale, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Haptics.tap();
        _controller.forward(from: 0);
        widget.onTap?.call();
      },
      child: ScaleTransition(scale: _animation, child: widget.child),
    );
  }
}

/// Animated checkmark for completions
class AnimatedCheckmark extends StatefulWidget {
  final bool checked;
  final Color? color;
  final double size;
  final Duration duration;

  const AnimatedCheckmark({
    super.key,
    required this.checked,
    this.color,
    this.size = 24,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<AnimatedCheckmark> createState() => _AnimatedCheckmarkState();
}

class _AnimatedCheckmarkState extends State<AnimatedCheckmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    if (widget.checked) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCheckmark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checked != oldWidget.checked) {
      if (widget.checked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.success;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CheckmarkPainter(progress: _controller.value, color: color),
        );
      },
    );
  }
}

class _CheckmarkPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckmarkPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Start point (left)
    final startX = size.width * 0.2;
    final startY = size.height * 0.5;

    // Middle point (bottom)
    final midX = size.width * 0.4;
    final midY = size.height * 0.7;

    // End point (top right)
    final endX = size.width * 0.8;
    final endY = size.height * 0.3;

    path.moveTo(startX, startY);

    if (progress <= 0.5) {
      // First segment
      final segmentProgress = progress * 2;
      path.lineTo(
        startX + (midX - startX) * segmentProgress,
        startY + (midY - startY) * segmentProgress,
      );
    } else {
      // Complete first segment, animate second
      path.lineTo(midX, midY);
      final segmentProgress = (progress - 0.5) * 2;
      path.lineTo(
        midX + (endX - midX) * segmentProgress,
        midY + (endY - midY) * segmentProgress,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CheckmarkPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// Ripple effect on tap
class RippleEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? rippleColor;
  final BorderRadius? borderRadius;

  const RippleEffect({
    super.key,
    required this.child,
    this.onTap,
    this.rippleColor,
    this.borderRadius,
  });

  @override
  State<RippleEffect> createState() => _RippleEffectState();
}

class _RippleEffectState extends State<RippleEffect> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Haptics.tap();
          widget.onTap?.call();
        },
        borderRadius: widget.borderRadius ?? AppRadius.allSm,
        splashColor:
            widget.rippleColor ??
            (isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05)),
        highlightColor:
            widget.rippleColor?.withOpacity(0.05) ??
            (isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.02)),
        child: widget.child,
      ),
    );
  }
}

/// Animated progress ring
class AnimatedProgressRing extends StatelessWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;
  final Widget? child;
  final Duration duration;

  const AnimatedProgressRing({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.size = 48,
    this.strokeWidth = 4,
    this.child,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              CircularProgressIndicator(
                value: 1,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation(
                  backgroundColor ??
                      (isDark
                          ? AppColors.surfaceVariantDark
                          : AppColors.surfaceVariant),
                ),
              ),
              // Progress ring
              CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                valueColor: AlwaysStoppedAnimation(color ?? AppColors.primary),
              ),
              // Center content
              if (child != null) child,
            ],
          ),
        );
      },
      child: child,
    );
  }
}

/// Floating action button with animation
class AnimatedFab extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget icon;
  final String? tooltip;
  final bool extended;
  final String? label;

  const AnimatedFab({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.extended = false,
    this.label,
  });

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Animate in
    Future.delayed(const Duration(milliseconds: 100), () {
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.extended && widget.label != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Haptics.tap();
                widget.onPressed();
              },
              icon: widget.icon,
              label: Text(widget.label!),
              tooltip: widget.tooltip,
            )
          : FloatingActionButton(
              onPressed: () {
                Haptics.tap();
                widget.onPressed();
              },
              tooltip: widget.tooltip,
              child: widget.icon,
            ),
    );
  }
}

/// Swipe to delete/complete wrapper
class SwipeAction extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final Widget? leftBackground;
  final Widget? rightBackground;
  final double threshold;

  const SwipeAction({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.leftBackground,
    this.rightBackground,
    this.threshold = 0.3,
  });

  @override
  State<SwipeAction> createState() => _SwipeActionState();
}

class _SwipeActionState extends State<SwipeAction> {
  double _dragExtent = 0;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: (details) {
        setState(() => _isDragging = true);
      },
      onHorizontalDragUpdate: (details) {
        setState(() {
          _dragExtent += details.primaryDelta ?? 0;
        });
      },
      onHorizontalDragEnd: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final threshold = screenWidth * widget.threshold;

        if (_dragExtent.abs() > threshold) {
          if (_dragExtent > 0 && widget.onSwipeRight != null) {
            Haptics.success();
            widget.onSwipeRight!();
          } else if (_dragExtent < 0 && widget.onSwipeLeft != null) {
            Haptics.delete();
            widget.onSwipeLeft!();
          }
        }

        setState(() {
          _dragExtent = 0;
          _isDragging = false;
        });
      },
      child: Stack(
        children: [
          // Background
          if (_dragExtent > 0 && widget.rightBackground != null)
            Positioned.fill(child: widget.rightBackground!),
          if (_dragExtent < 0 && widget.leftBackground != null)
            Positioned.fill(child: widget.leftBackground!),

          // Foreground
          AnimatedContainer(
            duration: _isDragging
                ? Duration.zero
                : const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(_dragExtent, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

/// Toast notification widget
class ToastNotification extends StatelessWidget {
  final String message;
  final IconData? icon;
  final Color? backgroundColor;
  final Duration duration;

  const ToastNotification({
    super.key,
    required this.message,
    this.icon,
    this.backgroundColor,
    this.duration = const Duration(seconds: 2),
  });

  static void show(
    BuildContext context, {
    required String message,
    IconData? icon,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 24,
        right: 24,
        child: ToastNotification(
          message: message,
          icon: icon,
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () => entry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (isDark ? AppColors.surfaceDark : AppColors.onSurface),
          borderRadius: AppRadius.allMd,
          boxShadow: AppShadows.lg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
            ],
            Flexible(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
