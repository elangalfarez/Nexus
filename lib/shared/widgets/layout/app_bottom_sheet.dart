// lib/shared/widgets/layout/app_bottom_sheet.dart
// Bottom sheet components

import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

/// Show a modal bottom sheet with consistent styling
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  bool isScrollControlled = false,
  double? initialChildSize,
  double? minChildSize,
  double? maxChildSize,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    builder: (context) {
      if (isScrollControlled) {
        return DraggableScrollableSheet(
          initialChildSize: initialChildSize ?? 0.5,
          minChildSize: minChildSize ?? 0.25,
          maxChildSize: maxChildSize ?? 0.9,
          builder: (context, scrollController) {
            return _BottomSheetContainer(
              scrollController: scrollController,
              child: child,
            );
          },
        );
      }
      return _BottomSheetContainer(child: child);
    },
  );
}

/// Bottom sheet container with handle
class _BottomSheetContainer extends StatelessWidget {
  final Widget child;
  final ScrollController? scrollController;

  const _BottomSheetContainer({required this.child, this.scrollController});

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
          _DragHandle(),

          // Content
          Flexible(child: child),
        ],
      ),
    );
  }
}

/// Drag handle widget
class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
    );
  }
}

/// Bottom sheet header with title and close button
class BottomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  final Widget? trailing;

  const BottomSheetHeader({
    super.key,
    required this.title,
    this.onClose,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: Icon(
                Icons.close,
                color: isDark
                    ? AppColors.onSurfaceVariantDark
                    : AppColors.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Action sheet option item
class ActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final bool destructive;

  const ActionSheetItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveColor =
        color ??
        (destructive
            ? AppColors.error
            : (isDark ? AppColors.onSurfaceDark : AppColors.onSurface));

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: effectiveColor),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(color: effectiveColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show action sheet with options
Future<T?> showActionSheet<T>({
  required BuildContext context,
  String? title,
  required List<ActionSheetItem> actions,
  bool showCancel = true,
}) {
  return showAppBottomSheet<T>(
    context: context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          BottomSheetHeader(title: title),
          Divider(height: 1),
        ],
        ...actions,
        if (showCancel) ...[
          Divider(height: 1),
          ActionSheetItem(
            icon: Icons.close,
            label: 'Cancel',
            onTap: () => Navigator.of(context).pop(),
          ),
        ],
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    ),
  );
}
