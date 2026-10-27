import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import 'reel_formatters.dart';

/// Circular profile photo with an initial-letter fallback.
class ReelAvatar extends StatelessWidget {
  final String? photo;
  final String? name;
  final double size;

  const ReelAvatar({super.key, this.photo, this.name, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final trimmed = name?.trim();
    final initial = (trimmed != null && trimmed.isNotEmpty)
        ? trimmed[0].toUpperCase()
        : '?';
    final fallback = Center(
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryBlue,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: photo != null
          ? Image.network(
              resolveApiUrl(photo!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback,
            )
          : fallback,
    );
  }
}
