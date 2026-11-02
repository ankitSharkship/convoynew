import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';

/// "Expires in 28:41", ticking once a second.
class CallRequestCountdown extends StatefulWidget {
  final DateTime expiresAt;

  const CallRequestCountdown({super.key, required this.expiresAt});

  @override
  State<CallRequestCountdown> createState() => _CountdownState();
}

class _CountdownState extends State<CallRequestCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final left = widget.expiresAt.difference(DateTime.now().toUtc());
    final safe = left.isNegative ? Duration.zero : left;
    final mm = safe.inMinutes.toString().padLeft(2, '0');
    final ss = (safe.inSeconds % 60).toString().padLeft(2, '0');
    return Text(
      AppLocalizations.of(context)!.oneToOneExpiresIn('$mm:$ss'),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryBlue,
      ),
    );
  }
}
