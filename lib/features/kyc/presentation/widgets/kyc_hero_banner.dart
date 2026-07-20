import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/language_switcher_button.dart';

class KycHeroBanner extends StatelessWidget {
  final VoidCallback onBack;

  const KycHeroBanner({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.heroGradientStart,
            AppColors.heroGradientMid,
            AppColors.heroGradientEnd,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                  const Spacer(),
                  const LanguageSwitcherButton(
                    card: false,
                    iconColor: AppColors.white,
                  ),
                ],
              ),
            ),
            // Fills the rest of the hero banner edge-to-edge — the gradient
            // above only remains as a fallback backdrop if the image is
            // ever slow to load, not a visible border around it.
            SizedBox(
              width: double.infinity,
              height: 300,
              child: Image.asset(
                'assets/images/kyc_page_image.webp',
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
