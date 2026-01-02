// lib/features/notes/presentation/widgets/note_card.dart
// Note card widget for list and grid views

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/inputs/app_chip.dart';
import '../../data/models/note_model.dart';

/// Note card for list view
class NoteListCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final String? folderName;
  final List<String>? tagNames;
  final bool selected;

  const NoteListCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.folderName,
    this.tagNames,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = selected
        ? AppColors.primary.withValues(alpha: 0.08)
        : Colors.transparent;

    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress?.call();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pin indicator
              if (note.isPinned) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.push_pin,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
              ],

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: titleColor,
                        fontStyle: note.title.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Preview
                    if (note.preview.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        note.preview,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: subtitleColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Metadata
                    const SizedBox(height: AppSpacing.sm),
                    _buildMetadataRow(context, isDark, subtitleColor),
                  ],
                ),
              ),

              // Link indicator
              if (note.outgoingLinks.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.link, size: 16, color: subtitleColor),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataRow(
    BuildContext context,
    bool isDark,
    Color subtitleColor,
  ) {
    final items = <Widget>[];

    // Updated time
    items.add(
      Text(
        _formatDate(note.updatedAt),
        style: AppTextStyles.labelSmall.copyWith(color: subtitleColor),
      ),
    );

    // Word count
    if (note.wordCount > 0) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notes, size: 12, color: subtitleColor),
            const SizedBox(width: 2),
            Text(
              '${note.wordCount} words',
              style: AppTextStyles.labelSmall.copyWith(color: subtitleColor),
            ),
          ],
        ),
      );
    }

    // Folder
    if (folderName != null) {
      items.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_outlined, size: 12, color: subtitleColor),
            const SizedBox(width: 2),
            Text(
              folderName!,
              style: AppTextStyles.labelSmall.copyWith(color: subtitleColor),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.xs,
      children: items,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Note card for grid view
class NoteGridCard extends StatelessWidget {
  final Note note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final List<String>? tagNames;
  final bool selected;

  const NoteGridCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.tagNames,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final subtitleColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final borderColor = selected
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.borderLight);

    return Material(
      color: bgColor,
      borderRadius: AppRadius.card,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          onLongPress?.call();
        },
        borderRadius: AppRadius.card,
        child: Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: borderColor, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  if (note.isPinned) ...[
                    const Icon(Icons.push_pin, size: 14, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: titleColor,
                        fontStyle: note.title.isEmpty
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (note.isFavorite)
                    const Icon(Icons.star, size: 14, color: AppColors.tertiary),
                ],
              ),

              // Preview
              if (note.preview.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: Text(
                    note.preview,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: subtitleColor,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ] else
                const Spacer(),

              // Footer
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Text(
                    _formatDate(note.updatedAt),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: subtitleColor,
                    ),
                  ),
                  const Spacer(),
                  if (note.outgoingLinks.isNotEmpty)
                    Icon(Icons.link, size: 14, color: subtitleColor),
                ],
              ),

              // Tags
              if (tagNames != null && tagNames!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: tagNames!
                      .take(3)
                      .map((tag) => TagChip(tagName: tag))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';

    return '${date.month}/${date.day}';
  }
}

/// Note card skeleton for loading state
class NoteCardSkeleton extends StatelessWidget {
  final bool isGrid;

  const NoteCardSkeleton({super.key, this.isGrid = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final shimmerBase = isDark
        ? AppColors.surfaceVariantDark
        : AppColors.surfaceVariantLight;

    if (isGrid) {
      return Container(
        padding: AppSpacing.cardPadding,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerBase,
                borderRadius: AppRadius.roundedXs,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: shimmerBase,
                borderRadius: AppRadius.roundedXs,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Container(
              height: 12,
              width: 100,
              decoration: BoxDecoration(
                color: shimmerBase,
                borderRadius: AppRadius.roundedXs,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: shimmerBase,
              borderRadius: AppRadius.roundedXs,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: shimmerBase,
              borderRadius: AppRadius.roundedXs,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            height: 12,
            width: 150,
            decoration: BoxDecoration(
              color: shimmerBase,
              borderRadius: AppRadius.roundedXs,
            ),
          ),
        ],
      ),
    );
  }
}
