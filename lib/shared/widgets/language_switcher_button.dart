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
  /// (for dark/gradient headers), tinted with [iconColor]. Ignored when
  /// [trigger] is provided.
  final bool card;
  final Color? iconColor;

  /// A custom widget to use as the popup's trigger instead of the default
  /// translate icon (e.g. a "Change language" text link).
  final Widget? trigger;

  const LanguageSwitcherButton({
    super.key,
    this.card = true,
    this.iconColor,
    this.trigger,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    final options = <(Locale, String)>[
      (const Locale('en'), l10n.languageEnglish),
      (const Locale('hi'), l10n.languageHindi),
      (const Locale('mr'), l10n.languageMarathi),
      (const Locale('kn'), l10n.languageKannada),
    ];

    List<PopupMenuEntry<Locale>> itemBuilder(BuildContext context) {
      return options.map((option) {
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
      }).toList();
    }

    void onSelected(Locale locale) =>
        ref.read(localeNotifierProvider.notifier).setLocale(locale);

    if (trigger != null) {
      // PopupMenuButton anchors its menu using the button's own bounding
      // box: if that box is (close to) as wide as the screen — as it is
      // for a full-width settings row like the "Language" item on the
      // Profile screen — the box's left and right edges end up roughly
      // equidistant from the screen edges, and Flutter's positioning
      // logic falls back to opening the menu flush with the *left* edge.
      // To always open the menu against the right end regardless of how
      // wide the visible trigger is, the real PopupMenuButton is shrunk
      // to a 1x1 anchor pinned to the trigger's right edge (via a
      // GlobalKey so it can still be opened programmatically), while the
      // full-size trigger stays visible and tappable underneath.
      final menuKey = GlobalKey<PopupMenuButtonState<Locale>>();
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => menuKey.currentState?.showButtonMenu(),
        child: Stack(
          children: [
            trigger!,
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: PopupMenuButton<Locale>(
                    key: menuKey,
                    tooltip: l10n.languageSelectTitle,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    onSelected: onSelected,
                    itemBuilder: itemBuilder,
                    child: const SizedBox(width: 1, height: 1),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final button = PopupMenuButton<Locale>(
      icon: Icon(
        Icons.g_translate,
        size: card ? 20 : 22,
        color: iconColor ?? AppColors.textPrimary,
      ),
      tooltip: l10n.languageSelectTitle,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: onSelected,
      itemBuilder: itemBuilder,
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
