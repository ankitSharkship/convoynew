import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/location_entity.dart';
import '../state/search_notifier.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _originController = TextEditingController();
  final _destinationController = TextEditingController();

  static const _truckTypes = [
    'Open Body',
    'Closed Body',
    'Container 20ft',
    'Container 32ft',
    'Tipper',
    'Sidewall Trailer',
    'Flat Bed Trailer',
    'Bulker',
    'Tanker',
  ];

  static final _capacities = List.generate(30, (i) => '${i + 6} Ton');

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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Search Trucks',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Find the right truck for your load',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SortButton(onTap: () {}),
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
                    const _FieldLabel('Origin'),
                    const SizedBox(height: 8),
                    _LocationField(
                      controller: _originController,
                      hintText: 'Select Origin',
                      markerColor: AppColors.green,
                      markerIsRing: true,
                      loading: state.originLocating,
                      onChanged: notifier.onOriginQueryChanged,
                      onLocate: () => _useCurrentLocation(isOrigin: true),
                    ),
                    _SuggestionsList(
                      suggestions: state.originSuggestions,
                      loading: state.originSuggestionsLoading,
                      onSelect: notifier.selectOriginSuggestion,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Container(
                        width: 2,
                        height: 18,
                        color: AppColors.textTertiary.withValues(alpha: 0.4),
                      ),
                    ),
                    const _FieldLabel('Destination'),
                    const SizedBox(height: 8),
                    _LocationField(
                      controller: _destinationController,
                      hintText: 'Select Destination',
                      markerColor: AppColors.red,
                      markerIsRing: false,
                      loading: state.destinationLocating,
                      onChanged: notifier.onDestinationQueryChanged,
                      onLocate: () => _useCurrentLocation(isOrigin: false),
                    ),
                    _SuggestionsList(
                      suggestions: state.destinationSuggestions,
                      loading: state.destinationSuggestionsLoading,
                      onSelect: notifier.selectDestinationSuggestion,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Truck Type'),
                              const SizedBox(height: 8),
                              _DropdownField(
                                hintText: 'Select Truck',
                                value: state.selectedTruckType,
                                items: _truckTypes,
                                onChanged: notifier.selectTruckType,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FieldLabel('Capacity'),
                              const SizedBox(height: 8),
                              _DropdownField(
                                hintText: 'Select',
                                value: state.selectedCapacity,
                                items: _capacities,
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
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Find Trucks',
                                    style: TextStyle(
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

// ─── Sort button ─────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SortButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.sort_by_alpha,
          size: 20,
          color: AppColors.primaryBlue,
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

  const _LocationField({
    required this.controller,
    required this.hintText,
    required this.markerColor,
    required this.markerIsRing,
    required this.loading,
    required this.onChanged,
    required this.onLocate,
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
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.normal,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textTertiary,
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
      margin: const EdgeInsets.only(left: 26, top: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
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

// ─── Dropdown field (truck type) ────────────────────────────────────────────

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
