// lib/features/notes/presentation/screens/note_editor_screen.dart
// Markdown note editor with toolbar

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme.dart';
import '../../data/models/note_model.dart';
import '../providers/note_providers.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final int? noteId;
  final int? folderId;

  const NoteEditorScreen({super.key, this.noteId, this.folderId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;

  Timer? _autoSaveTimer;
  bool _isLoading = false;
  bool _hasUnsavedChanges = false;
  Note? _note;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    // Load existing note or create new
    if (widget.noteId != null) {
      _loadNote();
    } else {
      // Auto-focus title for new notes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }

    // Setup auto-save
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    setState(() => _isLoading = true);

    try {
      final note = await ref.read(noteByIdProvider(widget.noteId!).future);
      if (note != null && mounted) {
        setState(() {
          _note = note;
          _titleController.text = note.title;
          _contentController.text = note.content;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load note'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onTextChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }

    // Debounce auto-save
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(
      const Duration(milliseconds: AppConstants.autoSaveDebounceMs),
      _autoSave,
    );
  }

  Future<void> _autoSave() async {
    if (!_hasUnsavedChanges) return;

    final title = _titleController.text.trim();
    final content = _contentController.text;

    // Don't save empty notes
    if (title.isEmpty && content.isEmpty) return;

    try {
      if (_note == null) {
        // Create new note
        final newNote = await ref
            .read(noteActionsProvider.notifier)
            .createNote(
              title: title.isEmpty ? 'Untitled' : title,
              content: content,
              folderId: widget.folderId,
            );
        if (mounted) {
          setState(() {
            _note = newNote;
            _hasUnsavedChanges = false;
          });
        }
      } else {
        // Update existing note
        final updatedNote = _note!.copyWith(
          title: title.isEmpty ? 'Untitled' : title,
          content: content,
        );
        await ref.read(noteActionsProvider.notifier).updateNote(updatedNote);
        if (mounted) {
          setState(() => _hasUnsavedChanges = false);
        }
      }
    } catch (e) {
      // Silent fail for auto-save, will retry
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasUnsavedChanges) {
      await _autoSave();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
        appBar: _EditorAppBar(
          note: _note,
          hasUnsavedChanges: _hasUnsavedChanges,
          onSave: _autoSave,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // Title field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      0,
                    ),
                    child: TextField(
                      controller: _titleController,
                      focusNode: _titleFocusNode,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: AppTextStyles.headlineMedium.copyWith(
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onSubmitted: (_) => _contentFocusNode.requestFocus(),
                    ),
                  ),

                  // Content field
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: TextField(
                        controller: _contentController,
                        focusNode: _contentFocusNode,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          height: 1.6,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Start writing...',
                          hintStyle: AppTextStyles.bodyLarge.copyWith(
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.only(
                            top: AppSpacing.sm,
                            bottom: AppSpacing.xl,
                          ),
                        ),
                        maxLines: null,
                        expands: true,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),

                  // Formatting toolbar
                  _FormattingToolbar(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                  ),
                ],
              ),
      ),
    );
  }
}

/// Editor app bar
class _EditorAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final Note? note;
  final bool hasUnsavedChanges;
  final VoidCallback onSave;

  const _EditorAppBar({
    this.note,
    required this.hasUnsavedChanges,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      title: hasUnsavedChanges
          ? Text(
              'Unsaved changes',
              style: AppTextStyles.labelMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            )
          : null,
      actions: [
        // Pin toggle
        if (note != null)
          IconButton(
            onPressed: () {
              ref.read(noteActionsProvider.notifier).togglePin(note!.id);
            },
            icon: Icon(
              note!.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: note!.isPinned
                  ? AppColors.primary
                  : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight),
            ),
            tooltip: note!.isPinned ? 'Unpin' : 'Pin',
          ),

        // More options
        IconButton(
          onPressed: () {
            // TODO: Show note options
          },
          icon: Icon(
            Icons.more_vert,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

/// Formatting toolbar
class _FormattingToolbar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;

  const _FormattingToolbar({required this.controller, required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    if (bottomPadding == 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              _ToolbarButton(
                icon: Icons.format_bold,
                tooltip: 'Bold',
                onTap: () => _wrapSelection('**', '**'),
              ),
              _ToolbarButton(
                icon: Icons.format_italic,
                tooltip: 'Italic',
                onTap: () => _wrapSelection('*', '*'),
              ),
              _ToolbarButton(
                icon: Icons.format_strikethrough,
                tooltip: 'Strikethrough',
                onTap: () => _wrapSelection('~~', '~~'),
              ),
              _ToolbarDivider(),
              _ToolbarButton(
                icon: Icons.title,
                tooltip: 'Heading',
                onTap: () => _insertAtLineStart('## '),
              ),
              _ToolbarButton(
                icon: Icons.format_list_bulleted,
                tooltip: 'Bullet list',
                onTap: () => _insertAtLineStart('- '),
              ),
              _ToolbarButton(
                icon: Icons.format_list_numbered,
                tooltip: 'Numbered list',
                onTap: () => _insertAtLineStart('1. '),
              ),
              _ToolbarButton(
                icon: Icons.check_box_outlined,
                tooltip: 'Checkbox',
                onTap: () => _insertAtLineStart('- [ ] '),
              ),
              _ToolbarDivider(),
              _ToolbarButton(
                icon: Icons.link,
                tooltip: 'Link',
                onTap: () => _wrapSelection('[', '](url)'),
              ),
              _ToolbarButton(
                icon: Icons.code,
                tooltip: 'Code',
                onTap: () => _wrapSelection('`', '`'),
              ),
              _ToolbarButton(
                icon: Icons.format_quote,
                tooltip: 'Quote',
                onTap: () => _insertAtLineStart('> '),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _wrapSelection(String before, String after) {
    final selection = controller.selection;
    final text = controller.text;

    if (selection.isCollapsed) {
      // No selection, just insert
      final newText =
          text.substring(0, selection.start) +
          before +
          after +
          text.substring(selection.end);
      controller.text = newText;
      controller.selection = TextSelection.collapsed(
        offset: selection.start + before.length,
      );
    } else {
      // Wrap selection
      final selectedText = text.substring(selection.start, selection.end);
      final newText =
          text.substring(0, selection.start) +
          before +
          selectedText +
          after +
          text.substring(selection.end);
      controller.text = newText;
      controller.selection = TextSelection(
        baseOffset: selection.start + before.length,
        extentOffset: selection.start + before.length + selectedText.length,
      );
    }

    focusNode.requestFocus();
    HapticFeedback.lightImpact();
  }

  void _insertAtLineStart(String prefix) {
    final selection = controller.selection;
    final text = controller.text;

    // Find start of current line
    int lineStart = selection.start;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    // Insert prefix at line start
    final newText =
        text.substring(0, lineStart) + prefix + text.substring(lineStart);
    controller.text = newText;
    controller.selection = TextSelection.collapsed(
      offset: selection.start + prefix.length,
    );

    focusNode.requestFocus();
    HapticFeedback.lightImpact();
  }
}

/// Toolbar button
class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedSm,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(
              icon,
              size: 20,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

/// Toolbar divider
class _ToolbarDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    );
  }
}
