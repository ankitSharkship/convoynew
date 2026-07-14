import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../shared/widgets/loader.dart';
import '../../../auth/presentation/state/auth_notifier.dart';
import '../../../post/presentation/state/vehicle_notifier.dart';
import '../state/profile_notifier.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final vehicleCount =
        ref.watch(vehicleNotifierProvider).valueOrNull?.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.white,
      ),
      body: profileAsync.when(
        loading: () => const FullPageLoader(),
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
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.invalidate(profileNotifierProvider),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (profile) => _ProfileContent(
          name: profile.name,
          phone: profile.phone,
          memberSince: profile.memberSince,
          rating: profile.rating,
          totalPosts: profile.totalPosts,
          callsMade: profile.callsMade,
          responseRate: profile.responseRate,
          kycStatus: profile.kycStatus,
          accountStatus: profile.accountStatus,
          photoPath: profile.photoPath,
          profilePhotoUrl: profile.profilePhotoUrl,
          vehicleCount: vehicleCount,
          onPhotoTap: () async {
            final picker = ImagePicker();
            final picked = await picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 512,
              maxHeight: 512,
            );
            if (picked != null) {
              await ref
                  .read(profileNotifierProvider.notifier)
                  .updatePhoto(picked.path);
            }
          },
          onLogout: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Logout'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: AppColors.red),
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
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final String name;
  final String phone;
  final String memberSince;
  final double rating;
  final int totalPosts;
  final int callsMade;
  final int responseRate;
  final String kycStatus;
  final String accountStatus;
  final String? photoPath;
  final String? profilePhotoUrl;
  final int vehicleCount;
  final VoidCallback onPhotoTap;
  final VoidCallback onLogout;

  const _ProfileContent({
    required this.name,
    required this.phone,
    required this.memberSince,
    required this.rating,
    required this.totalPosts,
    required this.callsMade,
    required this.responseRate,
    required this.kycStatus,
    required this.accountStatus,
    this.photoPath,
    this.profilePhotoUrl,
    required this.vehicleCount,
    required this.onPhotoTap,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    GestureDetector(
                      onTap: onPhotoTap,
                      child: Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryBlue.withOpacity(0.12),
                          border: Border.all(
                            color: AppColors.primaryBlue.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: ClipOval(
                          child: SizedBox(
                            width: 84,
                            height: 84,
                            child: _AvatarImage(
                              photoPath: photoPath,
                              profilePhotoUrl: profilePhotoUrl,
                              initials: initials,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      size: 18,
                      color: AppColors.primaryBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (memberSince.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Member since $memberSince',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
                if (accountStatus != 'active') ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
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
                          size: 16,
                          color: AppColors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Account ${_accountStatusLabel(accountStatus)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlueLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _Stat(label: 'Rating', value: rating.toString()),
                      _VertDivider(),
                      _Stat(label: 'Total Posts', value: '$totalPosts'),
                      _VertDivider(),
                      _Stat(label: 'Calls Made', value: '$callsMade'),
                      _VertDivider(),
                      _Stat(label: 'Response\nRate', value: '$responseRate%'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: AppColors.white,
            child: Column(
              children: [
                _ProfileItem(
                  icon: Icons.verified_user_outlined,
                  label: 'KYC',

                  badge: _kycBadgeLabel(kycStatus),
                  badgeColor: _kycBadgeColor(kycStatus),
                ),
                _Divider(),
                _ProfileItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'My Vehicles',
                  sublabel: vehicleCount == 1
                      ? '1 vehicle added'
                      : '$vehicleCount vehicles added',
                ),
                _Divider(),
                _ProfileItem(
                  icon: Icons.description_outlined,
                  label: 'Terms & Conditions',
                ),
                _Divider(),
                _ProfileItem(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy & Policy',
                ),
                _Divider(),
                _ProfileItem(
                  icon: Icons.headset_mic_outlined,
                  label: 'Help & Support',
                  sublabel: 'Chat, call or email us',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            color: AppColors.white,
            child: _ProfileItem(
              icon: Icons.logout,
              label: 'Logout',
              iconColor: AppColors.red,
              labelColor: AppColors.red,
              onTap: onLogout,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

String _kycBadgeLabel(String kycStatus) {
  switch (kycStatus) {
    case 'approved':
    case 'verified':
      return 'Verified';
    case 'in_review':
      return 'In Review';
    case 'rejected':
      return 'Rejected';
    default:
      return 'Pending';
  }
}

String _accountStatusLabel(String accountStatus) {
  switch (accountStatus) {
    case 'suspended':
      return 'suspended';
    case 'blocked':
      return 'blocked';
    case 'inactive':
      return 'inactive';
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
      color: AppColors.primaryBlue.withValues(alpha: 0.12),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 28,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 32,
    color: AppColors.primaryBlue.withOpacity(0.2),
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 56, color: AppColors.divider);
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? sublabel;
  final String? badge;
  final Color? badgeColor;
  final Color? iconColor;
  final Color? labelColor;
  final VoidCallback? onTap;

  const _ProfileItem({
    required this.icon,
    required this.label,
    this.sublabel,
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
                  if (sublabel != null)
                    Text(
                      sublabel!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (badgeColor ?? AppColors.green).withOpacity(0.1),
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
