import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../state/onboarding_notifier.dart';

const _pageImages = [
  'assets/images/truck2.webp',
  'assets/images/truck4.webp',
  'assets/images/truck3.webp',
];

String _titleFor(AppLocalizations l10n, int page) {
  switch (page) {
    case 0:
      return l10n.onboardingTitle;
    case 1:
      return l10n.onboardingPage2Title;
    default:
      return l10n.onboardingPage3Title;
  }
}

String _subtitleFor(AppLocalizations l10n, int page) {
  switch (page) {
    case 0:
      return l10n.onboardingSubtitle;
    case 1:
      return l10n.onboardingPage2Subtitle;
    default:
      return l10n.onboardingPage3Subtitle;
  }
}

/// The last page's button submits (handled by `_onGetStarted`'s own
/// page-index check) — only the label changes here to match: "Get
/// Started" on page 1, "Next" on page 2, "Start" on the final page.
String _buttonTextFor(AppLocalizations l10n, int page) {
  switch (page) {
    case 0:
      return l10n.onboardingGetStarted;
    case 1:
      return l10n.onboardingPage2Button;
    default:
      return l10n.onboardingPage3Button;
  }
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  Future<void> _onGetStarted() async {
    if (_currentPage < _pageImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await ref.read(onboardingNotifierProvider.notifier).markSeen();
      if (mounted) context.go('/auth/phone');
    }
  }

  Future<void> _onSkip() async {
    await ref.read(onboardingNotifierProvider.notifier).markSeen();
    if (mounted) context.go('/auth/phone');
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _pageImages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (context, index) => _OnboardingPage(
                    image: _pageImages[index],
                    title: _titleFor(l10n, index),
                    subtitle: _subtitleFor(l10n, index),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12,
                  right: 16,
                  child: GestureDetector(
                    onTap: _onSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        l10n.onboardingSkip,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pageImages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _currentPage ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? AppColors.primaryBlue
                        : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _onGetStarted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _buttonTextFor(l10n, _currentPage),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: LanguageSwitcherButton(
              trigger: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.language,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.onboardingChangeLanguage,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Image.asset(image, fit: BoxFit.cover, width: double.infinity),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
