import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../kyc/presentation/navigation/post_truck_gate.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../widgets/trending_reels_section.dart';

const _carouselAutoAdvanceInterval = Duration(seconds: 4);
const _carouselImages = [
  'assets/images/corouselImages/I111.png',
  'assets/images/corouselImages/I2.png',
  'assets/images/corouselImages/I3.png',
  'assets/images/corouselImages/I4.png',
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final displayName = profileAsync.valueOrNull?.name ?? 'Pilot';
    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: _HomeContent(userName: displayName),
    );
  }
}

class _HomeContent extends ConsumerStatefulWidget {
  final String userName;

  const _HomeContent({required this.userName});

  @override
  ConsumerState<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<_HomeContent> {
  @override
  Widget build(BuildContext context) {
    final firstName = widget.userName.split(' ').first;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header — the hero carousel is the only section that
                  // deliberately bleeds edge to edge, so every other
                  // section carries its own 20px horizontal inset instead
                  // of one padding wrapping the whole column.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.homeHello,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                firstName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const LanguageSwitcherButton(),
                        // const SizedBox(width: 10),
                        // const _IconButton(
                        //   icon: Icons.notifications_none_rounded,
                        //   showBadge: true,
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _HeroCarousel(
                    onPostTap: () => navigateToPostTruck(context, ref),
                  ),
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      l10n.homeQuickActions,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.add,
                            iconColor: AppColors.primaryBlue,
                            iconBackground: AppColors.primaryBlueLight,
                            title: l10n.homePostNewTruck,
                            subtitle: l10n.homePostNewTruckSubtitle,
                            onTap: () => navigateToPostTruck(context, ref),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            icon: Icons.search,
                            iconColor: AppColors.primaryDark,
                            iconBackground: AppColors.primaryDark.withValues(
                              alpha: 0.1,
                            ),
                            title: l10n.homeSearchTrucks,
                            subtitle: l10n.homeSearchTrucksSubtitle,
                            onTap: () => context.go('/search'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const TrendingReelsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero carousel ──────────────────────────────────────────────────────────

/// Auto-advancing, swipeable 4-slide carousel that replaces the old single
/// static hero banner — same "post a truck" call to action, just cycling
/// through a few different pitches instead of showing only one.
class _HeroCarousel extends StatefulWidget {
  final VoidCallback onPostTap;

  const _HeroCarousel({required this.onPostTap});

  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

// Slightly less than 1 so the current card sits just shy of the true
// screen edges (leaving room for its own margin below) while still
// keeping the sliver of the next/previous card small enough that it
// doesn't read as "another card is visible" at rest. The point of this,
// combined with the per-card margin, is motion: because a hair of the
// incoming card is technically already on screen before a swipe starts,
// its real edge is what crosses into view — not 20px of empty margin
// that has to clear the screen boundary first.
const _carouselViewportFraction = 0.97;
const _carouselCardMargin = 10.0;

class _HeroCarouselState extends State<_HeroCarousel> {
  final _pageController = PageController(
    viewportFraction: _carouselViewportFraction,
  );
  Timer? _autoAdvanceTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    _autoAdvanceTimer?.cancel();
    _autoAdvanceTimer = Timer.periodic(_carouselAutoAdvanceInterval, (_) {
      final next = (_currentPage + 1) % _carouselImages.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoAdvanceTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = [
      _CarouselSlideData(
        image: _carouselImages[0],
        title: l10n.homeHeroTitle,
        subtitle: l10n.homeHeroSubtitle,
      ),
      _CarouselSlideData(
        image: _carouselImages[1],
        title: l10n.homeCarousel2Title,
        subtitle: l10n.homeCarousel2Subtitle,
      ),
      _CarouselSlideData(
        image: _carouselImages[2],
        title: l10n.homeCarousel3Title,
        subtitle: l10n.homeCarousel3Subtitle,
      ),
      _CarouselSlideData(
        image: _carouselImages[3],
        title: l10n.homeCarousel4Title,
        subtitle: l10n.homeCarousel4Subtitle,
      ),
    ];

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // The card's real rendered width is its page slot
            // (viewportFraction of the full width) minus its own
            // margin — not the full outer width. Basing the aspect
            // ratio on the wrong width is exactly what made cards look
            // too tall the last time this was tried.
            final cardWidth =
                constraints.maxWidth * _carouselViewportFraction -
                _carouselCardMargin * 2;
            // Width is ~10% larger now (see the viewport fraction/margin
            // constants above); dividing by 1.1 here keeps the absolute
            // height pinned to half of what it was pre-widening, rather
            // than half of the new (larger) width.
            final cardHeight = cardWidth * 5 / 8 / 1.1;
            return SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) => _CarouselSlide(
                  data: slides[i],
                  buttonLabel: l10n.homeHeroButton,
                  onPostTap: () {
                    _startAutoAdvance();
                    widget.onPostTap();
                  },
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            slides.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentPage ? 18 : 6,
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
      ],
    );
  }
}

class _CarouselSlideData {
  final String image;
  final String title;
  final String subtitle;

  const _CarouselSlideData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

/// Splits [text] into sentences (on `.`/`?`/`...`) and highlights the last
/// one — a translation-agnostic stand-in for the reference design's manual
/// per-word color split, which can't be hard-coded once the same slide has
/// to work in four different languages with different word orders.
List<TextSpan> _highlightLastSentence(String text, TextStyle base) {
  final matches = RegExp(r'[^.?]+[.?]+|[^.?]+$')
      .allMatches(text.trim())
      .map((m) => m.group(0)!.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (matches.length < 2) return [TextSpan(text: text, style: base)];

  final highlighted = matches.removeLast();
  return [
    TextSpan(text: '${matches.join(' ')} ', style: base),
    TextSpan(
      text: highlighted,
      style: base.copyWith(color: AppColors.primaryBlue),
    ),
  ];
}

class _CarouselSlide extends StatelessWidget {
  final _CarouselSlideData data;
  final String buttonLabel;
  final VoidCallback onPostTap;

  const _CarouselSlide({
    required this.data,
    required this.buttonLabel,
    required this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(
      color: AppColors.white,
      fontSize: 16,
      fontWeight: FontWeight.w800,
      height: 1.25,
    );

    return Container(
      // A small viewport peek (see _carouselViewportFraction) means the
      // next/previous card's real edge — not empty margin — is what's
      // technically already at the screen boundary, so it's the card
      // itself that appears to emerge from the side during a swipe.
      margin: const EdgeInsets.symmetric(horizontal: _carouselCardMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              data.image,
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
              errorBuilder: (context, error, stackTrace) =>
                  const ColoredBox(color: AppColors.primaryDark),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: _highlightLastSentence(
                            data.title,
                            titleStyle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Constrained to half the card's content width so the
                      // subtitle wraps to a second line on its own instead
                      // of stretching across the card toward the image.
                      FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.5,
                        child: Text(
                          data.subtitle,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // ~65% of the card's content width (a 30-40% reduction
                  // from full width). The label stays untranslated-length
                  // agnostic — FittedBox scales the row down rather than
                  // overflowing if a locale's label runs long.
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.45,
                    child: ElevatedButton(
                      onPressed: onPostTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              buttonLabel,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick action card ──────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
