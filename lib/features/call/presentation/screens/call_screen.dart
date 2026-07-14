import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class CallScreen extends StatefulWidget {
  final String driverName;
  final String phone;
  final String initials;

  const CallScreen({
    super.key,
    required this.driverName,
    required this.phone,
    required this.initials,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _duration {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Opens your phone dialer',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                widget.initials,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.driverName,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.phone,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _seconds < 3 ? 'Calling…' : 'Connected · $_duration',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Convoy has no in-app calling. Tapping Call\nopens your phone dialer and logs it for your records.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white.withOpacity(0.45),
                fontSize: 11,
                height: 1.5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call_end,
                    color: AppColors.white, size: 32),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
