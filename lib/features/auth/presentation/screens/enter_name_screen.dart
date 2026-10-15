import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/borderless_input_decoration.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../profile/presentation/state/profile_notifier.dart';
import '../state/auth_notifier.dart';

class EnterNameScreen extends ConsumerStatefulWidget {
  const EnterNameScreen({super.key});

  @override
  ConsumerState<EnterNameScreen> createState() => _EnterNameScreenState();
}

class _EnterNameScreenState extends ConsumerState<EnterNameScreen> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
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
    if (mounted) context.go('/auth/phone');
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref.read(profileNotifierProvider.notifier).updateName(name);
      if (mounted) context.go('/home');
    } catch (_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _isSubmitting = false;
        _error = l10n.enterNameError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameEntered = _controller.text.trim().isNotEmpty;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.primaryDark,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 24, 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: AppColors.white,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      onSelected: (value) {
                        if (value == 'logout') _logout();
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.logout,
                                size: 18,
                                color: AppColors.red,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                l10n.profileLogoutTitle,
                                style: const TextStyle(color: AppColors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const LanguageSwitcherButton(
                      card: false,
                      iconColor: AppColors.white,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.enterNameTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.enterNameSubtitle,
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
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            decoration: borderlessInputDecoration(
                              hintText: l10n.enterNameHint,
                              hintStyle: const TextStyle(
                                color: AppColors.textTertiary,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: ElevatedButton(
                          onPressed: (_isSubmitting || !nameEntered)
                              ? null
                              : _submit,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: AppColors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.enterNameButton),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
