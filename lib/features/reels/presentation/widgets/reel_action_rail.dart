import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/reel_entity.dart';
import 'reel_formatters.dart';

/// Right-hand vertical stack of like / comment / share buttons with counts.
class ReelActionRail extends StatelessWidget {
  final ReelEntity reel;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  const ReelActionRail({
    super.key,
    required this.reel,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RailButton(
          icon: reel.likedByMe ? Icons.favorite : Icons.favorite_border,
          color: reel.likedByMe ? AppColors.red : Colors.white,
          count: reel.likeCount,
          onTap: onLike,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.mode_comment_outlined,
          count: reel.commentCount,
          onTap: onComment,
        ),
        const SizedBox(height: 18),
        _RailButton(
          icon: Icons.share_outlined,
          count: reel.shareCount,
          onTap: onShare,
        ),
      ],
    );
  }
}

class _RailButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final VoidCallback onTap;

  const _RailButton({
    required this.icon,
    this.color = Colors.white,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
            shadows: const [Shadow(blurRadius: 8, color: Colors.black54)],
          ),
          const SizedBox(height: 2),
          Text(
            formatCount(count),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(blurRadius: 8, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }
}
