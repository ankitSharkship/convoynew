import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/locale_notifier.dart';
import '../../l10n/generated/app_localizations.dart';

/// Top-right translate button shown on every screen. Tapping it opens a
/// small popup with the three supported languages; selecting one switches
/// the whole app's locale immediately (persisted via [LocaleNotifier]).
class LanguageSwitcherButton extends ConsumerWidget {
  /// When true, renders as the 40x40 white rounded "card" icon button used
  /// on light-background screens. When false, renders as a bare icon button
  /// (for dark/gradient headers), tinted with [iconColor].
  final bool card;
  final Color? iconColor;

  const LanguageSwitcherButton({super.key, this.card = true, this.iconColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    final options = <(Locale, String)>[
      (const Locale('en'), l10n.languageEnglish),
      (const Locale('hi'), l10n.languageHindi),
      (const Locale('mr'), l10n.languageMarathi),
    ];

    final button = PopupMenuButton<Locale>(
      icon: Icon(
        Icons.translate,
        size: card ? 20 : 22,
        color: iconColor ?? AppColors.textPrimary,
      ),
      tooltip: l10n.languageSelectTitle,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (locale) =>
          ref.read(localeNotifierProvider.notifier).setLocale(locale),
      itemBuilder: (context) => options.map((option) {
        final (locale, label) = option;
        final selected = locale.languageCode == current.languageCode;
        return PopupMenuItem(
          value: locale,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? AppColors.primaryBlue
                      : AppColors.textPrimary,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 10),
                const Icon(Icons.check, size: 18, color: AppColors.primaryBlue),
              ],
            ],
          ),
        );
      }).toList(),
    );

    if (!card) return button;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: button,
    );
  }
}
