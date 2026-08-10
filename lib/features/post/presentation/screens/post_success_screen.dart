import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../kyc/presentation/navigation/post_truck_gate.dart';

class PostSuccessScreen extends ConsumerWidget {
  final String truckType;
  final int capacity;
  final String origin;

  const PostSuccessScreen({
    super.key,
    required this.truckType,
    required this.capacity,
    required this.origin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.topRight,
                child: LanguageSwitcherButton(),
              ),
              const Spacer(),
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.greenLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.postSuccessTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.postSuccessSubtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _DetailRow(
                      label: l10n.postSuccessTruckTypeLabel,
                      value: truckTypeLabel(context, truckType),
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: l10n.postCapacityLabel,
                      value: capacity > 0 ? l10n.capacityTon(capacity) : '—',
                    ),
                    const SizedBox(height: 10),
                    _DetailRow(
                      label: l10n.postSuccessPickupLabel,
                      value: origin,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.search, size: 18),
                label: Text(l10n.postSuccessGoToDashboard),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
