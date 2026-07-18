import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../contacts/presentation/state/contacts_sync_notifier.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/widgets/borderless_input_decoration.dart';
import '../../../../shared/widgets/language_switcher_button.dart';
import '../../../../shared/widgets/location_permission_dialog.dart';
import '../../../../shared/utils/truck_type_image.dart';
import '../../../../shared/widgets/suggestions_overlay.dart';
import '../../domain/entities/location_entity.dart';
import '../state/search_notifier.dart';
import '../widgets/truck_type_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation({required bool isOrigin}) async {
    final notifier = ref.read(searchNotifierProvider.notifier);
    try {
      if (isOrigin) {
        await notifier.useCurrentOriginLocation();
      } else {
        await notifier.useCurrentDestinationLocation();
      }
    } on LocationServiceException catch (e) {
      if (mounted) await showLocationPermissionDialog(context, e);
    }
  }

  Future<void> _pickTruckType(String? current) async {
    final selected = await TruckTypeSheet.show(context, selected: current);
    if (selected != null && mounted) {
      ref.read(searchNotifierProvider.notifier).selectTruckType(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    ref.listen<SearchState>(searchNotifierProvider, (previous, next) {
      if (next.originLocation != null &&
          next.originLocation != previous?.originLocation) {
        _originController.text = next.originLocation!.name;
      }
      if (next.destinationLocation != null &&
          next.destinationLocation != previous?.destinationLocation) {
        _destinationController.text = next.destinationLocation!.name;
      }
    });

    final l10n = AppLocalizations.of(context)!;
    final capacities = List.generate(30, (i) => l10n.capacityTon(i + 6));

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.searchTitle,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.searchSubtitle,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const LanguageSwitcherButton(),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel(l10n.searchOriginLabel),
                    const SizedBox(height: 8),
                    SuggestionsOverlay(
                      visible: state.showOriginSuggestions,
                      onDismissTap: notifier.dismissOriginSuggestions,
                      overlayBuilder: (_) => _SuggestionsList(
                        suggestions: state.originSuggestions,
                        loading: state.originSuggestionsLoading,
                        onSelect: notifier.selectOriginSuggestion,
                      ),
                      field: _LocationField(
                        controller: _originController,
                        hintText: l10n.searchOriginHint,
                        markerColor: AppColors.green,
                        markerIsRing: true,
                        loading: state.originLocating,
                        onChanged: notifier.onOriginQueryChanged,
                        onLocate: () => _useCurrentLocation(isOrigin: true),
                        onClear: () {
                          _originController.clear();
                          notifier.clearOrigin();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        width: 2,
                        height: 18,
                        color: AppColors.textTertiary.withValues(alpha: 0.4),
                      ),
                    ),
                    _FieldLabel(l10n.searchDestinationLabel),
                    const SizedBox(height: 8),
                    SuggestionsOverlay(
                      visible: state.showDestinationSuggestions,
                      onDismissTap: notifier.dismissDestinationSuggestions,
                      overlayBuilder: (_) => _SuggestionsList(
                        suggestions: state.destinationSuggestions,
                        loading: state.destinationSuggestionsLoading,
                        onSelect: notifier.selectDestinationSuggestion,
                      ),
                      field: _LocationField(
                        controller: _destinationController,
                        hintText: l10n.searchDestinationHint,
                        markerColor: AppColors.red,
                        markerIsRing: false,
                        loading: state.destinationLocating,
                        onChanged: notifier.onDestinationQueryChanged,
                        onLocate: () => _useCurrentLocation(isOrigin: false),
                        onClear: () {
                          _destinationController.clear();
                          notifier.clearDestination();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(l10n.searchTruckTypeLabel),
                              const SizedBox(height: 8),
                              _TruckTypeField(
                                hintText: l10n.searchSelectTruckHint,
                                value: state.selectedTruckType,
                                label: state.selectedTruckType != null
                                    ? truckTypeLabel(
                                        context,
                                        state.selectedTruckType!,
                                      )
                                    : null,
                                onTap: () =>
                                    _pickTruckType(state.selectedTruckType),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _FieldLabel(l10n.searchCapacityLabel),
                              const SizedBox(height: 8),
                              _DropdownField(
                                hintText: l10n.searchSelectHint,
                                value: state.selectedCapacity,
                                items: capacities,
                                onChanged: notifier.selectCapacity,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state.canSearch
                            ? () {
                                notifier.findTrucks();
                                // Fire-and-forget: this is the natural
                                // moment to ask for contacts permission if
                                // it's still missing, since mutual
                                // connections only show up on search
                                // results. Doesn't block the search itself.
                                ref
                                    .read(contactsSyncNotifierProvider.notifier)
                                    .syncIfStale();
                                context.push('/search/results');
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.primaryBlue
                              .withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: state.searching
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.white,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    l10n.searchFindTrucksButton,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
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
      ),
    );
  }
}

// ─── Field label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
  );
}

// ─── Location field (origin / destination) ──────────────────────────────────

class _LocationField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Color markerColor;
  final bool markerIsRing;
  final bool loading;
  final ValueChanged<String> onChanged;
  final VoidCallback onLocate;
  final VoidCallback onClear;

  const _LocationField({
    required this.controller,
    required this.hintText,
    required this.markerColor,
    required this.markerIsRing,
    required this.loading,
    required this.onChanged,
    required this.onLocate,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        markerIsRing
            ? Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: markerColor, width: 2.5),
                ),
              )
            : Icon(Icons.location_on, size: 20, color: markerColor),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onChanged: onChanged,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    decoration: borderlessInputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.normal,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      suffixIcon: controller.text.isNotEmpty
                          ? GestureDetector(
                              onTap: onClear,
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: AppColors.textTertiary,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: loading ? null : onLocate,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryBlue,
                    ),
                  )
                : const Icon(
                    Icons.my_location,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
          ),
        ),
      ],
    );
  }
}

// ─── Location suggestions dropdown ───────────────────────────────────────────

class _SuggestionsList extends StatelessWidget {
  final List<LocationEntity> suggestions;
  final bool loading;
  final ValueChanged<LocationEntity> onSelect;

  const _SuggestionsList({
    required this.suggestions,
    required this.loading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (!loading && suggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      constraints: const BoxConstraints(maxHeight: 220),
      child: loading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: suggestions.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, indent: 12, endIndent: 12),
              itemBuilder: (_, i) {
                final loc = suggestions[i];
                return InkWell(
                  onTap: () => onSelect(loc),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            loc.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

// ─── Dropdown field (capacity) ──────────────────────────────────────────────

class _DropdownField extends StatelessWidget {
  final String hintText;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      items: items
          .map((i) => DropdownMenuItem(value: i, child: Text(i)))
          .toList(),
      onChanged: onChanged,
    );
  }
}

// ─── Truck type field (opens the illustrated bottom sheet) ─────────────────

class _TruckTypeField extends StatelessWidget {
  final String hintText;
  final String? value;
  final String? label;
  final VoidCallback onTap;

  const _TruckTypeField({
    required this.hintText,
    required this.value,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imagePath = value != null ? truckTypeImagePath(value!) : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            if (imagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  imagePath,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label ?? hintText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: label != null
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
