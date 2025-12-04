// lib/core/utils/app_transitions.dart
// Custom page transitions for navigation

import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Custom page transitions
class AppTransitions {
  /// Fade transition
  static Widget fadeTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    );
  }

  /// Slide up transition (for modals)
  static Widget slideUpTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// Slide from right transition (for detail pages)
  static Widget slideRightTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final offsetAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.5),
        ),
        child: child,
      ),
    );
  }

  /// Scale transition (for dialogs)
  static Widget scaleTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(opacity: animation, child: child),
    );
  }

  /// Shared axis transition (for tab switches)
  static Widget sharedAxisTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    bool forward,
  ) {
    final offsetAnimation = Tween<Offset>(
      begin: Offset(forward ? 0.05 : -0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

    return SlideTransition(
      position: offsetAnimation,
      child: FadeTransition(opacity: animation, child: child),
    );
  }
}

/// Custom page route with fade transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: AppTransitions.fadeTransition,
        transitionDuration: AppConstants.animStandard,
        reverseTransitionDuration: AppConstants.animFast,
      );
}

/// Custom page route with slide up transition
class SlideUpPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideUpPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: AppTransitions.slideUpTransition,
        transitionDuration: AppConstants.animStandard,
        reverseTransitionDuration: AppConstants.animFast,
      );
}

/// Custom page route with slide from right
class SlideRightPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SlideRightPageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: AppTransitions.slideRightTransition,
        transitionDuration: AppConstants.animStandard,
        reverseTransitionDuration: AppConstants.animFast,
      );
}

/// Hero dialog route for modal presentations
class HeroDialogRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  HeroDialogRoute({
    required this.builder,
    super.settings,
    super.fullscreenDialog = true,
  });

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => AppConstants.animStandard;

  @override
  bool get maintainState => true;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => 'Dismiss';

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppTransitions.scaleTransition(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }
}

/// Staggered animation controller helper
class StaggeredAnimationController {
  final AnimationController controller;
  final int itemCount;
  final Duration staggerDelay;

  StaggeredAnimationController({
    required this.controller,
    required this.itemCount,
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  /// Get animation for item at index
  Animation<double> getAnimation(int index) {
    final startTime =
        index *
        staggerDelay.inMilliseconds /
        (controller.duration?.inMilliseconds ?? 1000);
    final endTime = startTime + 0.4;

    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          startTime.clamp(0, 1),
          endTime.clamp(0, 1),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  /// Get offset animation for item at index
  Animation<Offset> getOffsetAnimation(
    int index, {
    Offset begin = const Offset(0, 0.1),
  }) {
    return Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(parent: getAnimation(index), curve: Curves.easeOutCubic),
    );
  }
}
