import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../state/onboarding_notifier.dart';

const _pageImages = [
  'assets/images/corouselImages/I5.png',
  'assets/images/corouselImages/I11.png',
  'assets/images/corouselImages/I7.png',
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

/// Splits a title on `~...~` markers and colors the wrapped span orange —
/// the marker's position is chosen per-language in the ARB source (see
/// app_en/hi/kn/mr.arb), since the emphasized phrase doesn't always land
/// in the same spot once word order changes (e.g. "every day" sits on
/// line 1 in Hindi/Kannada/Marathi but line 2 in English). Splitting on an
/// explicit marker sidesteps guessing that from sentence punctuation alone.
List<TextSpan> _highlightMarked(String text, TextStyle base) {
  final parts = text.split('~');
  return [
    for (var i = 0; i < parts.length; i++)
      if (parts[i].isNotEmpty)
        TextSpan(
          text: parts[i],
          style: i.isOdd ? base.copyWith(color: AppColors.primaryBlue) : base,
        ),
  ];
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
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      // The onboarding images are full-screen portrait photos (light sky at
      // top, dark road at the bottom) — the whole screen is one Stack now
      // instead of an image-on-top/controls-below Column, so the photo can
      // paint edge to edge (including behind the status bar) while the
      // title, skip pill, and bottom controls float above it.
      body: Stack(
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(bottom: bottomInset),
              // Elliptical radii that each span exactly half the screen
              // width meet with no flat segment between them, so the two
              // "corners" read as one continuous arch across the whole top
              // edge instead of a rounded rectangle.
              decoration: BoxDecoration(
                color: AppColors.primaryDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.elliptical(screenWidth / 2, 48),
                  topRight: Radius.elliptical(screenWidth / 2, 48),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 44),
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
                                : AppColors.white.withValues(alpha: 0.4),
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
                          Icon(
                            Icons.language,
                            size: 16,
                            color: AppColors.white.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.onboardingChangeLanguage,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
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
    // Clears the top-right skip pill (status bar inset + pill height + gap)
    // so the title never runs under it.
    final topInset = MediaQuery.of(context).padding.top;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Shifted up so the photo's subject (truck/handshake) isn't hidden
        // behind the now-taller navy card — the resulting gap at the very
        // bottom is covered by that same card, which is opaque.
        // Transform.translate(
        //   offset: const Offset(0, -60),
        //   child: Image.asset(image, fit: BoxFit.cover),
        // ),
        Image.asset(image, fit: BoxFit.cover),
        // Frosted, cloudy backdrop behind the title/subtitle so the photo
        // underneath softens into a haze instead of competing with the
        // text for contrast. The ShaderMask fades the blurred layer's own
        // opacity out over its bottom half — a flat BackdropFilter clip
        // has a uniform blur that just stops dead at its edge, which reads
        // as a hard square; masking it lets the haze dissolve smoothly
        // back into the sharp photo instead of cutting off.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topInset + 260,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.white, Colors.transparent],
              stops: [0.0, 0.5, 1.0],
            ).createShader(rect),
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                child: Container(color: Colors.white.withValues(alpha: 0.22)),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24, topInset + 76, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: _highlightMarked(
                    title,
                    const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  // color: AppColors.textSecondary,
                  color: Colors.black,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
