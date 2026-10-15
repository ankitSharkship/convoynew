import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/utils/truck_type_i18n.dart';
import '../../../../shared/widgets/location_permission_dialog.dart';
import '../../../search/domain/entities/truck_search_result_entity.dart';
import '../state/truck_map_notifier.dart';
import '../widgets/truck_details_sheet.dart';
import '../widgets/truck_marker.dart';

const _defaultCenter = LatLng(20.5937, 78.9629); // India, used until located
const _focusedZoom = 11.0;

const _sheetMinSize = 0.15;
const _sheetInitialSize = 0.32;
const _sheetMaxSize = 0.75;

Future<void> _callNumber(BuildContext context, String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  final launched = await canLaunchUrl(uri) && await launchUrl(uri);
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.resultsCallDialerError),
      ),
    );
  }
}

class TruckMapScreen extends ConsumerStatefulWidget {
  const TruckMapScreen({super.key});

  @override
  ConsumerState<TruckMapScreen> createState() => _TruckMapScreenState();
}

class _TruckMapScreenState extends ConsumerState<TruckMapScreen> {
  final _mapController = MapController();
  final _sheetController = DraggableScrollableController();

  bool _sheetVisible = true;
  double _sheetExtent = _sheetInitialSize;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetExtentChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetExtentChanged);
    _sheetController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onSheetExtentChanged() {
    if (!_sheetController.isAttached) return;
    setState(() => _sheetExtent = _sheetController.size);
  }

  Future<void> _load() async {
    try {
      await ref.read(truckMapNotifierProvider.notifier).loadNearbyTrucks();
      final userLocation = ref.read(truckMapNotifierProvider).userLocation;
      if (userLocation != null) _recenter(userLocation);
    } on LocationServiceException catch (e) {
      if (mounted) await showLocationPermissionDialog(context, e);
    }
  }

  void _recenter(CurrentLocation location) {
    _mapController.move(LatLng(location.lat, location.lng), _focusedZoom);
  }

  void _hideSheet() => setState(() => _sheetVisible = false);

  void _showSheet() => setState(() {
    _sheetVisible = true;
    _sheetExtent = _sheetInitialSize;
  });

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(truckMapNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primaryBlueLight,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 5,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.sharkship.bonut',
              ),
              MarkerLayer(
                markers: [
                  if (state.userLocation != null)
                    Marker(
                      point: LatLng(
                        state.userLocation!.lat,
                        state.userLocation!.lng,
                      ),
                      width: 22,
                      height: 22,
                      child: const UserLocationMarker(),
                    ),
                  ...state.trucks.map(
                    (truck) => Marker(
                      point: LatLng(
                        truck.currentLocation.lat,
                        truck.currentLocation.lng,
                      ),
                      width: 40,
                      height: 40,
                      child: TruckMarker(
                        onTap: () => TruckDetailsSheet.show(context, truck),
                      ),
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    '© OpenStreetMap contributors',
                    onTap: () => launchUrl(
                      Uri.parse('https://www.openstreetmap.org/copyright'),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 0, 0),
              child: _BackButton(onTap: () => context.pop()),
            ),
          ),
          if (state.loading && state.trucks.isEmpty && !_sheetVisible)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          if (state.userLocation != null)
            Positioned(
              right: 20,
              bottom: _sheetVisible ? screenHeight * _sheetExtent + 16 : 24,
              child: FloatingActionButton(
                heroTag: 'truck_map_recenter',
                backgroundColor: AppColors.white,
                onPressed: () => _recenter(state.userLocation!),
                child: const Icon(
                  Icons.my_location,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          if (!_sheetVisible)
            Positioned(
              left: 20,
              bottom: 24,
              child: _ViewListPill(
                count: state.trucks.length,
                onTap: _showSheet,
              ),
            ),
          if (_sheetVisible)
            DraggableScrollableSheet(
              controller: _sheetController,
              initialChildSize: _sheetInitialSize,
              minChildSize: _sheetMinSize,
              maxChildSize: _sheetMaxSize,
              snap: true,
              snapSizes: const [
                _sheetMinSize,
                _sheetInitialSize,
                _sheetMaxSize,
              ],
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.truckMapAppBarTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  state.loading
                                      ? l10n.truckMapLoading
                                      : l10n.truckMapCountFound(
                                          state.trucks.length,
                                        ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: _hideSheet,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.chipBackground,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0xFFF0F4F8)),
                      const SizedBox(height: 4),
                      if (state.loading && state.trucks.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        )
                      else if (state.error != null)
                        _SheetMessage(
                          message: state.error!,
                          actionLabel: l10n.truckMapRetry,
                          onAction: _load,
                        )
                      else if (state.trucks.isEmpty)
                        _SheetMessage(message: l10n.truckMapNoTrucksNearby)
                      else
                        ...state.trucks.map(
                          (truck) => _TruckListTile(result: truck),
                        ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back,
          size: 18,
          color: AppColors.primaryBlue,
        ),
      ),
    );
  }
}

class _ViewListPill extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _ViewListPill({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.keyboard_arrow_up,
              size: 18,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 4),
            Text(
              l10n.truckMapViewList(count),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetMessage extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SheetMessage({required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TruckListTile extends StatelessWidget {
  final TruckSearchResultEntity result;

  const _TruckListTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = result.displayContactName;
    final initials = displayName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return InkWell(
      onTap: () => TruckDetailsSheet.show(context, result),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.origin,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.capacity > 0
                        ? '${truckTypeLabel(context, result.truckType)} • ${l10n.capacityTon(result.capacity)}'
                        : truckTypeLabel(context, result.truckType),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _callNumber(context, result.displayContactNumber),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.phone,
                  size: 16,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
