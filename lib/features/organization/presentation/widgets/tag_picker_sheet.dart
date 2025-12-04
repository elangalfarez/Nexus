// lib/features/organization/presentation/widgets/tag_picker_sheet.dart
// Tag selection and creation bottom sheet

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/inputs/app_chip.dart';
import '../../data/models/tag_model.dart';
import '../providers/tag_providers.dart';

/// Tag picker bottom sheet
class TagPickerSheet extends ConsumerStatefulWidget {
  final List<int> selectedTagIds;
  final ValueChanged<List<int>> onTagsSelected;
  final bool allowCreate;

  const TagPickerSheet({
    super.key,
    required this.selectedTagIds,
    required this.onTagsSelected,
    this.allowCreate = true,
  });

  /// Show the tag picker sheet
  static Future<void> show(
    BuildContext context, {
    required List<int> selectedTagIds,
    required ValueChanged<List<int>> onTagsSelected,
    bool allowCreate = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => TagPickerSheet(
          selectedTagIds: selectedTagIds,
          onTagsSelected: onTagsSelected,
          allowCreate: allowCreate,
        ),
      ),
    );
  }

  @override
  ConsumerState<TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<TagPickerSheet> {
  final _searchController = TextEditingController();
  late Set<int> _selectedIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedTagIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tagsAsync = ref.watch(allTagsProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: AppRadius.bottomSheetRadius,
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
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
          ),

          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  'Tags',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    widget.onTagsSelected(_selectedIds.toList());
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search/create field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase().trim());
              },
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: 'Search or create tag...',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceDisabledDark
                      : AppColors.onSurfaceDisabled,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.surfaceVariantDark
                    : AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.allFull,
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  _createAndSelectTag(value.trim());
                }
              },
            ),
          ),

          SizedBox(height: AppSpacing.sm),

          // Selected tags
          if (_selectedIds.isNotEmpty) ...[
            _SelectedTagsRow(
              tagIds: _selectedIds.toList(),
              onRemove: (id) {
                setState(() => _selectedIds.remove(id));
              },
            ),
            SizedBox(height: AppSpacing.sm),
          ],

          // Tag list
          Expanded(
            child: tagsAsync.when(
              data: (tags) {
                // Filter tags
                final filteredTags = _searchQuery.isEmpty
                    ? tags
                    : tags
                          .where(
                            (t) => t.name.toLowerCase().contains(_searchQuery),
                          )
                          .toList();

                // Check if search matches any existing tag exactly
                final exactMatch = tags.any(
                  (t) => t.name.toLowerCase() == _searchQuery,
                );

                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  children: [
                    // Create new tag option
                    if (_searchQuery.isNotEmpty &&
                        !exactMatch &&
                        widget.allowCreate) ...[
                      _CreateTagOption(
                        tagName: _searchQuery,
                        onTap: () => _createAndSelectTag(_searchQuery),
                      ),
                      SizedBox(height: AppSpacing.sm),
                    ],

                    // Existing tags
                    ...filteredTags.map(
                      (tag) => _TagOption(
                        tag: tag,
                        isSelected: _selectedIds.contains(tag.id),
                        onTap: () => _toggleTag(tag.id),
                      ),
                    ),

                    if (filteredTags.isEmpty && _searchQuery.isEmpty)
                      Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.label_outline,
                                size: 48,
                                color: isDark
                                    ? AppColors.onSurfaceVariantDark
                                    : AppColors.onSurfaceVariant,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              Text(
                                'No tags yet',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.onSurfaceVariantDark
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Type to create one',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isDark
                                      ? AppColors.onSurfaceDisabledDark
                                      : AppColors.onSurfaceDisabled,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SizedBox(height: AppSpacing.md),
                  ],
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Error loading tags',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleTag(int tagId) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_selectedIds.contains(tagId)) {
        _selectedIds.remove(tagId);
      } else {
        _selectedIds.add(tagId);
      }
    });
  }

  Future<void> _createAndSelectTag(String name) async {
    HapticFeedback.lightImpact();

    try {
      final tag = await ref
          .read(tagActionsProvider.notifier)
          .getOrCreateTag(name);

      if (mounted) {
        setState(() {
          _selectedIds.add(tag.id);
          _searchController.clear();
          _searchQuery = '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create tag'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Selected tags row
class _SelectedTagsRow extends ConsumerWidget {
  final List<int> tagIds;
  final ValueChanged<int> onRemove;

  const _SelectedTagsRow({required this.tagIds, required this.onRemove});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: tagIds.map((id) {
          final tagAsync = ref.watch(tagByIdProvider(id));
          final tag = tagAsync.valueOrNull;

          if (tag == null) return const SizedBox.shrink();

          return Padding(
            padding: EdgeInsets.only(right: AppSpacing.xs),
            child: TagChip(
              tagName: tag.name,
              colorIndex: tag.colorIndex,
              onDelete: () => onRemove(id),
              selected: true,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Create tag option
class _CreateTagOption extends StatelessWidget {
  final String tagName;
  final VoidCallback onTap;

  const _CreateTagOption({required this.tagName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: AppRadius.allSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allSm,
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Icon(Icons.add, size: 20, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Create ',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              TagChip(tagName: tagName),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tag option row
class _TagOption extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagOption({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tagColor = AppColors.getProjectColor(tag.colorIndex);

    return Material(
      color: isSelected ? tagColor.withOpacity(0.12) : Colors.transparent,
      borderRadius: AppRadius.allSm,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.allSm,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              // Tag chip
              TagChip(tagName: tag.name, colorIndex: tag.colorIndex),

              const Spacer(),

              // Usage count
              Text(
                '${tag.usageCount}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: isDark
                      ? AppColors.onSurfaceVariantDark
                      : AppColors.onSurfaceVariant,
                ),
              ),

              SizedBox(width: AppSpacing.sm),

              // Selected indicator
              if (isSelected) Icon(Icons.check, size: 20, color: tagColor),
            ],
          ),
        ),
      ),
    );
  }
}
