import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/scratch_card_entity.dart';
import '../widgets/scratch_card_reveal.dart';

/// Shown right after a successful truck post when the backend signals a new
/// scratch card was earned — sits between form submission and
/// [PostSuccessScreen], which is reached either by cancelling here or by
/// tapping Continue after a reveal. Already full-screen/centered, so unlike
/// the wallet grid's tiles this doesn't need the enlarge-to-center overlay
/// treatment — the same [ScratchCardReveal] card is just the main event.
class PostScratchCardScreen extends StatefulWidget {
  final String truckType;
  final int capacity;
  final String origin;
  final ScratchCardEntity scratchCard;

  const PostScratchCardScreen({
    super.key,
    required this.truckType,
    required this.capacity,
    required this.origin,
    required this.scratchCard,
  });

  @override
  State<PostScratchCardScreen> createState() => _PostScratchCardScreenState();
}

class _PostScratchCardScreenState extends State<PostScratchCardScreen> {
  ScratchResultEntity? _result;

  void _goToSuccess() {
    context.pushReplacement(
      '/post/success',
      extra: {
        'truckType': widget.truckType,
        'capacity': widget.capacity,
        'origin': widget.origin,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = _result;
    final hasReward = (result?.rewardPaise ?? -1) > 0;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  onPressed: _goToSuccess,
                  icon: const Icon(Icons.close, color: AppColors.white),
                ),
              ),
              const Spacer(),
              Text(
                result == null
                    ? l10n.postScratchCardTitle
                    : (hasReward
                          ? l10n.postScratchCardWonTitle
                          : l10n.postScratchCardNoRewardTitle),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                result == null
                    ? l10n.postScratchCardSubtitle
                    : (hasReward ? '' : l10n.postScratchCardNoRewardSubtitle),
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ScratchCardReveal(
                card: widget.scratchCard,
                onRevealResult: (result) => setState(() => _result = result),
              ),
              const Spacer(),
              if (_result != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _goToSuccess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primaryDark,
                    ),
                    child: Text(l10n.postScratchCardContinueButton),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
