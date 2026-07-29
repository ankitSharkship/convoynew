import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Truck pin used on both the mini preview map and the full live map —
/// same visual for a dummy or a real truck, only [onTap] differs.
class TruckMarker extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const TruckMarker({super.key, this.size = 40, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.16),
        decoration: BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primaryBlue, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset('assets/images/truck.png', fit: BoxFit.contain),
      ),
    );
  }
}

/// Marks the user's own current position on the full live map.
class UserLocationMarker extends StatelessWidget {
  final double size;

  const UserLocationMarker({super.key, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryBlue,
        border: Border.all(color: AppColors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
