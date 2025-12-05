// lib/features/onboarding/presentation/screens/onboarding_screen.dart
// Multi-page onboarding flow

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/buttons/app_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  final _pages = const [
    _OnboardingPageData(
      icon: Icons.hub,
      title: 'Welcome to Nexus',
      subtitle: 'Your tasks and notes,\nconnected in one place',
      color: Color(0xFF6366F1),
    ),
    _OnboardingPageData(
      icon: Icons.check_circle_outline,
      title: 'Powerful Task Management',
      subtitle: 'Organize tasks with projects,\npriorities, and due dates',
      color: Color(0xFF22C55E),
    ),
    _OnboardingPageData(
      icon: Icons.note_alt_outlined,
      title: 'Connected Notes',
      subtitle: 'Build your second brain with\nbidirectional linking',
      color: Color(0xFFF59E0B),
    ),
    _OnboardingPageData(
      icon: Icons.devices,
      title: 'Always Available',
      subtitle: 'Local-first design means\nyour data is always accessible',
      color: Color(0xFFEC4899),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animStandard,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipToEnd() {
    HapticFeedback.lightImpact();
    _pageController.animateToPage(
      _pages.length - 1,
      duration: AppConstants.animStandard,
      curve: Curves.easeInOut,
    );
  }

  Future<void> _completeOnboarding() async {
    await StorageService.completeOnboarding();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skipToEnd,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(data: _pages[index]);
                },
              ),
            ),

            // Page indicators
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: AppConstants.animFast,
                    margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    width: isActive ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive
                          ? _pages[_currentPage].color
                          : (isDark
                                ? AppColors.surfaceVariantDark
                                : AppColors.surfaceVariantLight),
                      borderRadius: AppRadius.roundedFull,
                    ),
                  );
                }),
              ),
            ),

            // Action button
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: AppButton(
                label: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Continue',
                isFullWidth: true,
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Onboarding page data
class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}

/// Individual onboarding page
class _OnboardingPage extends StatelessWidget {
  final _OnboardingPageData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with background
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 64, color: data.color),
          ),

          SizedBox(height: AppSpacing.xl),

          // Title
          Text(
            data.title,
            style: AppTextStyles.headlineMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: AppSpacing.md),

          // Subtitle
          Text(
            data.subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Quick setup screen (shown after onboarding)
class QuickSetupScreen extends ConsumerStatefulWidget {
  const QuickSetupScreen({super.key});

  @override
  ConsumerState<QuickSetupScreen> createState() => _QuickSetupScreenState();
}

class _QuickSetupScreenState extends ConsumerState<QuickSetupScreen> {
  String? _selectedUseCase;
  final _useCases = [
    ('work', 'Work', Icons.work_outline, 'Manage projects and deadlines'),
    (
      'personal',
      'Personal',
      Icons.person_outline,
      'Track personal tasks and goals',
    ),
    ('study', 'Study', Icons.school_outlined, 'Organize courses and research'),
    (
      'creative',
      'Creative',
      Icons.palette_outlined,
      'Capture ideas and inspiration',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How will you use Nexus?',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: AppSpacing.sm),

              Text(
                'We\'ll customize your experience based on your needs.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),

              SizedBox(height: AppSpacing.xl),

              // Use case options
              ...(_useCases.map(
                (useCase) => _UseCaseOption(
                  id: useCase.$1,
                  title: useCase.$2,
                  icon: useCase.$3,
                  description: useCase.$4,
                  isSelected: _selectedUseCase == useCase.$1,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedUseCase = useCase.$1);
                  },
                ),
              )),

              const Spacer(),

              // Continue button
              AppButton(
                label: 'Continue',
                isFullWidth: true,
                onPressed: _selectedUseCase != null
                    ? () {
                        // TODO: Save preference and navigate
                        context.go('/');
                      }
                    : null,
              ),

              SizedBox(height: AppSpacing.sm),

              // Skip button
              Center(
                child: TextButton(
                  onPressed: () {
                    context.go('/');
                  },
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Use case option
class _UseCaseOption extends StatelessWidget {
  final String id;
  final String title;
  final IconData icon;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const _UseCaseOption({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.08)
            : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
        borderRadius: AppRadius.roundedMd,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedMd,
          child: Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.roundedMd,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : (isDark
                              ? AppColors.surfaceVariantDark
                              : AppColors.surfaceVariantLight),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        description,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
