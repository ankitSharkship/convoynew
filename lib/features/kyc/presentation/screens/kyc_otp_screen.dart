import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/borderless_input_decoration.dart';
import '../state/kyc_notifier.dart';
import '../widgets/kyc_hero_banner.dart';
import '../widgets/kyc_success_dialog.dart';

const _otpLength = 6;

class KycOtpScreen extends ConsumerStatefulWidget {
  const KycOtpScreen({super.key});

  @override
  ConsumerState<KycOtpScreen> createState() => _KycOtpScreenState();
}

class _KycOtpScreenState extends ConsumerState<KycOtpScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _focusNode.requestFocus(),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text;
    if (otp.length != _otpLength) return;

    final success = await ref.read(kycNotifierProvider.notifier).verifyOtp(otp);
    if (success && mounted) {
      await showKycSuccessDialog(
        context,
        onDismiss: () => context.go('/post'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kycNotifierProvider);
    final otpStr = _otpController.text;
    final canVerify = otpStr.length == _otpLength && !state.verifyingOtp;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KycHeroBanner(onBack: () => context.pop()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify Aadhar Card',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _focusNode.requestFocus(),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(_otpLength, (i) {
                            final filled = i < otpStr.length;
                            final isCursor =
                                i == otpStr.length && _focusNode.hasFocus;
                            return Container(
                              width: 44,
                              height: 52,
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
                                  fontSize: 20,
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
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(_otpLength),
                              ],
                              decoration: borderlessInputDecoration(
                                counterText: '',
                              ),
                              onChanged: (_) {
                                if (state.error != null) {
                                  ref
                                      .read(kycNotifierProvider.notifier)
                                      .clearError();
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'OTP has been sent to your Aadhaar-linked mobile number. '
                    'Please enter it to verify.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      state.error!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.red,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: canVerify ? _verify : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor:
                            AppColors.primaryBlue.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: state.verifyingOtp
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Verify OTP',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
