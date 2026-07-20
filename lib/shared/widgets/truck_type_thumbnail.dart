import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../utils/truck_type_image.dart';

/// Small illustrated thumbnail for a truck type, falling back to a generic
/// shipping icon for types without a dedicated asset yet.
class TruckTypeThumbnail extends StatelessWidget {
  final String type;
  final double size;
  final double borderRadius;

  const TruckTypeThumbnail({
    super.key,
    required this.type,
    required this.size,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = truckTypeImagePath(type);
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imagePath != null
          ? Image.asset(imagePath, width: size, height: size, fit: BoxFit.cover)
          : Container(
              width: size,
              height: size,
              color: AppColors.chipBackground,
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.textTertiary,
              ),
            ),
    );
  }
}
