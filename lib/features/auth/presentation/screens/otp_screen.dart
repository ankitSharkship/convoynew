import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../state/auth_notifier.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  int _resendSeconds = 24;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _focusNode.addListener(_onFocusChanged);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  void _onFocusChanged() => setState(() {});

  void _startTimer() {
    _resendSeconds = 24;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _onOtpChanged(String value) {
    setState(() {});
    if (value.length == 4) _verify();
  }

  Future<void> _verify() async {
    await ref
        .read(authNotifierProvider.notifier)
        .verifyOtp(widget.phone, _otpController.text);
  }

  Future<void> _resend() async {
    if (_resendSeconds > 0) return;
    _otpController.clear();
    setState(() {});
    await ref.read(authNotifierProvider.notifier).sendOtp(widget.phone);
    ref.read(authNotifierProvider.notifier).reset();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (_, next) {
      if (next is AuthSuccess) {
        context.go('/home');
      } else if (next is AuthError) {
        _otpController.clear();
        _focusNode.requestFocus();
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;
    final otpStr = _otpController.text;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.white),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.local_shipping,
                    color: AppColors.primaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Convoy',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter the 4-digit code',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sent to +91 ${widget.phone}',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 28),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: () => _focusNode.requestFocus(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(4, (i) {
                                final filled = i < otpStr.length;
                                final isCursor =
                                    i == otpStr.length && _focusNode.hasFocus;
                                return Container(
                                  width: 46,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: filled || isCursor
                                          ? AppColors.primaryBlue
                                          : AppColors.border,
                                      width: filled || isCursor ? 2 : 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    color: filled
                                        ? AppColors.primaryBlueLight
                                        : AppColors.white,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    filled ? otpStr[i] : '',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0,
                                child: TextField(
                                  controller: _otpController,
                                  focusNode: _focusNode,
                                  autofocus: true,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                  onChanged: _onOtpChanged,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (authState is AuthError) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          authState.message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Didn\'t receive it? Check the number and try resending.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
                      child: ElevatedButton(
                        onPressed: (isLoading || otpStr.length < 4)
                            ? null
                            : _verify,
                        child: isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('OK'),
                      ),
                    ),
                    GestureDetector(
                      onTap: _resend,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          _resendSeconds > 0
                              ? "Didn't get it? Resend in 0:${_resendSeconds.toString().padLeft(2, '0')}"
                              : 'Resend code',
                          style: TextStyle(
                            fontSize: 13,
                            color: _resendSeconds > 0
                                ? AppColors.textSecondary
                                : AppColors.primaryBlue,
                            fontWeight: _resendSeconds > 0
                                ? FontWeight.w400
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
