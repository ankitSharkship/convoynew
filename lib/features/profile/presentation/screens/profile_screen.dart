import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../../shared/widgets/loader.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../../kyc/presentation/navigation/post_truck_gate.dart';
import '../state/profile_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.profileTitle,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const LanguageSwitcherButton(),
                ],
              ),
            ),
            // TextButton(
            //   onPressed: () {
            //     context.push('/face_capture');
            //   },
            //   child: Text("Go to kcy"),
            // ),
            Expanded(
              child: profileAsync.when(
                loading: () => const AppLoader(),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          ApiException.messageFor(e),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () =>
                              ref.invalidate(profileNotifierProvider),
                          child: Text(l10n.tryAgain),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (profile) => _ProfileContent(
                  name: profile.name,
                  kycStatus: profile.kycStatus,
                  kycStep: profile.kycStep,
                  accountStatus: profile.accountStatus,
                  photoPath: profile.photoPath,
                  profilePhotoUrl: profile.profilePhotoUrl,
                  onTapVehicles: () => context.push('/profile/vehicles'),
                  onTapTrips: () => context.push('/profile/trips'),
                  onTapUploads: () => context.push('/profile/uploads'),
                  onTapKyc: () => navigateToKycVerification(
                    context,
                    ref,
                    onAlreadyVerified: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.profileKycAlreadyVerified)),
                      );
                    },
                  ),
                  onLogout: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.profileLogoutTitle),
                        content: Text(l10n.profileLogoutConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l10n.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              l10n.profileLogoutTitle,
                              style: const TextStyle(color: AppColors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    await ref.read(authNotifierProvider.notifier).logout();
                    if (context.mounted) context.go('/auth/phone');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final String name;
  final String kycStatus;
  final String? kycStep;
  final String accountStatus;
  final String? photoPath;
  final String? profilePhotoUrl;
  final VoidCallback onTapVehicles;
  final VoidCallback onTapTrips;
  final VoidCallback onTapUploads;
  final VoidCallback onTapKyc;
  final VoidCallback onLogout;

  const _ProfileContent({
    required this.name,
    required this.kycStatus,
    this.kycStep,
    required this.accountStatus,
    this.photoPath,
    this.profilePhotoUrl,
    required this.onTapVehicles,
    required this.onTapTrips,
    required this.onTapUploads,
    required this.onTapKyc,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
    final isVerifiedDriver = kycStatus == 'approved' || kycStatus == 'verified';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: _AvatarImage(
                        photoPath: photoPath,
                        profilePhotoUrl: profilePhotoUrl,
                        initials: initials,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isVerifiedDriver)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.profileVerifiedDriver,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      if (accountStatus != 'active') ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.redLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                size: 14,
                                color: AppColors.red,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.profileAccountStatusPrefix(
                                  _accountStatusLabel(l10n, accountStatus),
                                ),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.profileAccountSection,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ProfileItem(
                  icon: Icons.local_shipping_outlined,
                  label: l10n.profileMyVehicles,
                  onTap: onTapVehicles,
                ),
                _Divider(),
                _ProfileItem(
                  icon: Icons.map_outlined,
                  label: l10n.tripsTitle,
                  onTap: onTapTrips,
                ),
                _Divider(),
                _ProfileItem(
                  icon: Icons.video_library_outlined,
                  label: l10n.profileMyUploads,
                  onTap: onTapUploads,
                ),
                _Divider(),
                _ProfileItem(
                  icon: Icons.badge_outlined,
                  label: l10n.profileKycLabel,
                  badge: _kycBadgeLabel(l10n, kycStatus, kycStep),
                  badgeColor: _kycBadgeColor(kycStatus),
                  onTap: onTapKyc,
                ),
                _Divider(),
                LanguageSwitcherButton(
                  trigger: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.language,
                          size: 22,
                          color: AppColors.primaryDark,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            l10n.profileLanguage,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          _currentLanguageLabel(context, l10n),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _ProfileItem(
                  icon: Icons.headset_mic_outlined,
                  label: l10n.profileHelp,
                ),
                _Divider(),
                _ProfileItem(
                  icon: Icons.description_outlined,
                  label: l10n.profileTermsPrivacy,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: _ProfileItem(
              icon: Icons.logout,
              label: l10n.profileLogoutTitle,
              iconColor: AppColors.red,
              labelColor: AppColors.red,
              onTap: onLogout,
            ),
          ),
        ],
      ),
    );
  }
}

String _currentLanguageLabel(BuildContext context, AppLocalizations l10n) {
  switch (Localizations.localeOf(context).languageCode) {
    case 'hi':
      return l10n.languageHindi;
    case 'mr':
      return l10n.languageMarathi;
    case 'kn':
      return l10n.languageKannada;
    default:
      return l10n.languageEnglish;
  }
}

String _kycBadgeLabel(
  AppLocalizations l10n,
  String kycStatus,
  String? kycStep,
) {
  switch (kycStatus) {
    case 'approved':
    case 'verified':
      return l10n.profileKycVerified;
    case 'in_review':
      return l10n.profileKycInReview;
    case 'rejected':
      return l10n.profileKycRejected;
    default:
      // Aadhaar's done and only the photo step remains — distinguish this
      // from "hasn't started KYC at all" instead of lumping both under a
      // generic "Pending".
      return kycStep == 'photo'
          ? l10n.profileKycPhotoPending
          : l10n.profileKycPending;
  }
}

String _accountStatusLabel(AppLocalizations l10n, String accountStatus) {
  switch (accountStatus) {
    case 'suspended':
      return l10n.profileAccountSuspended;
    case 'blocked':
      return l10n.profileAccountBlocked;
    case 'inactive':
      return l10n.profileAccountInactive;
    default:
      return accountStatus;
  }
}

Color _kycBadgeColor(String kycStatus) {
  switch (kycStatus) {
    case 'approved':
    case 'verified':
      return AppColors.green;
    case 'rejected':
      return AppColors.red;
    default:
      return AppColors.red;
  }
}

class _AvatarImage extends StatelessWidget {
  final String? photoPath;
  final String? profilePhotoUrl;
  final String initials;

  const _AvatarImage({
    required this.photoPath,
    required this.profilePhotoUrl,
    required this.initials,
  });

  @override
  Widget build(BuildContext context) {
    if (photoPath != null) {
      return Image.file(File(photoPath!), fit: BoxFit.cover);
    }
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) {
      return Image.network(
        profilePhotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _InitialsAvatar(initials: initials),
      );
    }
    return _InitialsAvatar(initials: initials);
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      alignment: Alignment.center,
      child: initials.isNotEmpty
          ? Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            )
          : const Icon(Icons.person, color: AppColors.white, size: 30),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, color: AppColors.divider);
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badge;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.label,
    this.badge,
    this.badgeColor,
    this.iconColor,
    this.labelColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? AppColors.primaryDark),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.green).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badgeColor ?? AppColors.green,
                  ),
                ),
              ),
            if (badge == null && labelColor == null)
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
