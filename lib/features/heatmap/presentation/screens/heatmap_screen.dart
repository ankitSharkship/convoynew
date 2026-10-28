import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/location_permission_dialog.dart';
import '../../../reels/presentation/state/reels_notifier.dart';
import '../../../truck_map/presentation/widgets/truck_details_sheet.dart';
import '../../../truck_map/presentation/widgets/truck_marker.dart';
import '../../domain/entities/geo_box.dart';
import '../../domain/entities/heatmap_entity.dart';
import '../../domain/entities/truck_pin_entity.dart';
import '../../domain/failures/truck_post_unavailable_exception.dart';
import '../rendering/heat_field.dart';
import '../rendering/map_zoom_levels.dart';
import '../state/heatmap_notifier.dart';
import '../state/truck_pins_notifier.dart';
import '../widgets/heat_layer.dart';
import '../widgets/heatmap_kind_toggle.dart';
import '../widgets/heatmap_legend.dart';
import '../widgets/truck_pins_layer.dart';

const _initialZoom = 5.0;
const _myLocationZoom = 9.0;

/// Wait this long after the zoom stops crossing resolution steps before
/// fetching, so a fast pinch doesn't fire a request per step.
const _resolutionDebounce = Duration(milliseconds: 180);

/// Same idea for pins: wait for the map to settle before fetching the new view.
const _pinsDebounce = Duration(milliseconds: 250);

/// OSM tiles pulled towards a pale, low-contrast look (like the web POC's
/// light terrain style) so the heat colours stay the loudest thing on screen.
const _softTileFilter = ColorFilter.matrix(<double>[
  0.50, 0.38, 0.12, 0, 56, //
  0.14, 0.74, 0.12, 0, 56, //
  0.14, 0.38, 0.48, 0, 56, //
  0, 0, 0, 1, 0, //
]);

class HeatmapScreen extends ConsumerStatefulWidget {
  const HeatmapScreen({super.key});

  @override
  ConsumerState<HeatmapScreen> createState() => _HeatmapScreenState();
}

class _HeatmapScreenState extends ConsumerState<HeatmapScreen> {
  final _mapController = MapController();

  HeatmapKind _kind = HeatmapKind.trucks;
  double _zoom = _initialZoom;
  Timer? _resolutionTimer;
  HeatCellEntity? _selected;
  CurrentLocation? _userLocation;
  bool _locating = false;

  /// True when the data on screen has cells (or pins) but none inside the
  /// current view (e.g. zoomed into an area with too little activity).
  bool _nothingInView = false;

  /// Trucks tab zoomed in on a city: real pins instead of heat. See
  /// map_zoom_levels.dart for the zoom levels.
  bool _pinMode = false;
  Timer? _pinsTimer;
  TruckPinEntity? _selectedPin;
  String? _loadingPinId;

  @override
  void dispose() {
    _resolutionTimer?.cancel();
    _pinsTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  int get _wantedResolution => heatResolutionForZoom(_zoom);

  void _load({bool force = false}) {
    if (_pinMode) {
      _loadPins(force: force);
      return;
    }
    ref
        .read(heatmapNotifierProvider(_kind).notifier)
        .ensureResolution(_wantedResolution, force: force);
  }

  GeoBox _viewportBox() {
    final bounds = _mapController.camera.visibleBounds;
    return GeoBox(
      minLat: bounds.south,
      minLng: bounds.west,
      maxLat: bounds.north,
      maxLng: bounds.east,
    );
  }

  void _loadPins({bool force = false}) {
    ref
        .read(truckPinsNotifierProvider.notifier)
        .ensureCovering(_viewportBox(), force: force);
  }

  void _updateNothingInView(MapCamera camera) {
    final bounds = camera.visibleBounds;
    final bool nothing;
    if (_pinMode) {
      final pins = ref.read(truckPinsNotifierProvider);
      nothing =
          pins.hasLoaded &&
          !pins.pins.any((pin) => bounds.contains(LatLng(pin.lat, pin.lng)));
    } else {
      final cells = ref.read(heatmapNotifierProvider(_kind)).cells;
      nothing =
          cells.isNotEmpty &&
          !cells.any((cell) => bounds.contains(LatLng(cell.lat, cell.lng)));
    }
    if (nothing != _nothingInView && mounted) {
      setState(() => _nothingInView = nothing);
    }
  }

  /// Switches between heat and real pins when the zoom crosses the pin level
  /// (Trucks tab only). Returns true if the mode changed.
  bool _syncMode() {
    final wantPins =
        _kind == HeatmapKind.trucks &&
        truckPinsModeFor(_zoom, currentlyPins: _pinMode);
    if (wantPins == _pinMode) return false;
    setState(() {
      _pinMode = wantPins;
      _selected = null;
      _selectedPin = null;
      _nothingInView = false;
    });
    _resolutionTimer?.cancel();
    _pinsTimer?.cancel();
    _load();
    return true;
  }

  void _onPositionChanged(MapCamera camera, bool hasGesture) {
    _zoom = camera.zoom;
    if (_syncMode()) return;
    _updateNothingInView(camera);
    if (_pinMode) {
      _pinsTimer?.cancel();
      _pinsTimer = Timer(_pinsDebounce, () {
        if (mounted) _loadPins();
      });
      return;
    }
    final shown = ref.read(heatmapNotifierProvider(_kind)).resolution;
    if (shown == _wantedResolution) {
      _resolutionTimer?.cancel();
      return;
    }
    _resolutionTimer?.cancel();
    _resolutionTimer = Timer(_resolutionDebounce, () {
      if (mounted) _load();
    });
  }

  void _onKindChanged(HeatmapKind kind) {
    if (kind == _kind) return;
    if (kind == HeatmapKind.reels && _zoom > reelsMaxZoom) {
      // Coming from a closer Trucks view: pull back to the city view, same spot.
      _zoom = reelsMaxZoom;
      _mapController.move(_mapController.camera.center, reelsMaxZoom);
    }
    setState(() {
      _kind = kind;
      _selected = null;
      _selectedPin = null;
      _nothingInView = false;
      _pinMode =
          kind == HeatmapKind.trucks &&
          truckPinsModeFor(_zoom, currentlyPins: false);
    });
    _resolutionTimer?.cancel();
    _pinsTimer?.cancel();
    _load();
  }

  void _onMapTap(LatLng point) {
    if (_pinMode) {
      // A tap on bare map just deselects.
      if (_selectedPin != null && _loadingPinId == null) {
        setState(() => _selectedPin = null);
      }
      return;
    }
    final layer = ref.read(heatmapNotifierProvider(_kind));
    final resolution = layer.resolution;
    if (resolution == null) return;
    final cell = findHeatCellAt(
      camera: _mapController.camera,
      cells: layer.cells,
      resolution: resolution,
      tap: point,
    );
    if (_kind == HeatmapKind.reels) {
      // A Reels hotspot has no count card: it opens that area's reels.
      if (cell != null) _openAreaReels(cell);
      return;
    }
    setState(() => _selected = cell);
  }

  /// Sends the user to the Reels tab narrowed to the tapped hotspot — exactly the
  /// reels that made that cell glow, most popular first.
  void _openAreaReels(HeatCellEntity cell) {
    // The category chip would silently narrow the area further; start from "All".
    ref.read(selectedReelCategoryProvider.notifier).select(null);
    ref.read(selectedReelAreaProvider.notifier).select(cell.h3Cell);
    context.go('/reels');
  }

  Future<void> _onPinTap(TruckPinEntity pin) async {
    if (_loadingPinId != null) return;
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _selectedPin = pin;
      _loadingPinId = pin.id;
    });
    try {
      final detail = await ref
          .read(truckPinsNotifierProvider.notifier)
          .fetchDetail(pin.id);
      if (!mounted) return;
      setState(() => _loadingPinId = null);
      await TruckDetailsSheet.show(context, detail);
    } on TruckPostUnavailableException {
      // Expired since the pin was drawn: say so, and refresh so it disappears.
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.heatmapPinUnavailable)),
      );
      if (mounted) _loadPins(force: true);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.heatmapPinDetailError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingPinId = null;
          _selectedPin = null;
        });
      }
    }
  }

  void _onClusterTap(LatLng center, int count) {
    // Zoom in on the group: just past the grouping level so it splits into pins
    // (or, once only overlaps are grouped, a step closer).
    final target = _zoom < pinClusterBelowZoom
        ? math.min(_zoom + 2, pinClusterBelowZoom + 0.5)
        : math.min(_zoom + 1.5, 18.0);
    _mapController.move(center, target);
  }

  Future<void> _goToMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final location = await ref
          .read(locationServiceProvider)
          .getCurrentLocation();
      if (!mounted) return;
      setState(() => _userLocation = location);
      _mapController.move(LatLng(location.lat, location.lng), _myLocationZoom);
    } on LocationServiceException catch (e) {
      if (mounted) await showLocationPermissionDialog(context, e);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final layer = ref.watch(heatmapNotifierProvider(_kind));
    final pinsState = ref.watch(truckPinsNotifierProvider);
    final loading = _pinMode ? pinsState.loading : layer.loading;
    final hasLoaded = _pinMode ? pinsState.hasLoaded : layer.hasLoaded;
    final hasError = _pinMode ? pinsState.hasError : layer.hasError;
    final isConnectivityIssue = _pinMode
        ? pinsState.isConnectivityIssue
        : layer.isConnectivityIssue;
    ref.listen(truckPinsNotifierProvider, (previous, next) {
      if (!identical(previous?.pins, next.pins)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _pinMode) _updateNothingInView(_mapController.camera);
        });
      }
    });
    ref.listen(heatmapNotifierProvider(_kind), (previous, next) {
      // A selected cell belongs to the resolution it was tapped at; once other
      // cells are on screen it no longer exists, so its card must go too.
      if (previous?.resolution != next.resolution ||
          !identical(previous?.cells, next.cells)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          if (_selected != null) setState(() => _selected = null);
          _updateNothingInView(_mapController.camera);
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(selected: _kind, onChanged: _onKindChanged),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCameraFit: CameraFit.insideBounds(bounds: indiaBounds),
                    // The map never shows anything outside India: the camera's
                    // edges stay inside its box, which also sets how far out the
                    // zoom can go (the whole box fills the screen).
                    cameraConstraint: CameraConstraint.contain(
                      bounds: indiaBounds,
                    ),
                    minZoom: 3,
                    // Reels can't be zoomed in past a city: tapping a hotspot opens
                    // its reels instead.
                    maxZoom: _kind == HeatmapKind.reels
                        ? reelsMaxZoom
                        : trucksMaxZoom,
                    // North-up only: the heat image is anchored to a
                    // screen-aligned rectangle of the map.
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onMapReady: () {
                      _zoom = _mapController.camera.zoom;
                      _load();
                    },
                    onPositionChanged: _onPositionChanged,
                    onTap: (_, point) => _onMapTap(point),
                  ),
                  children: [
                    ColorFiltered(
                      colorFilter: _softTileFilter,
                      child: TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.sharkship.bonut',
                      ),
                    ),
                    if (!_pinMode && layer.hasLoaded)
                      HeatLayer(
                        cells: layer.cells,
                        resolution: layer.resolution!,
                      ),
                    if (_pinMode)
                      TruckPinsLayer(
                        pins: pinsState.pins,
                        selectedId: _selectedPin?.id,
                        onPinTap: _onPinTap,
                        onClusterTap: _onClusterTap,
                      ),
                    MarkerLayer(
                      markers: [
                        if (_userLocation != null)
                          Marker(
                            point: LatLng(_userLocation!.lat, _userLocation!.lng),
                            width: 22,
                            height: 22,
                            child: const UserLocationMarker(),
                          ),
                        if (_selected != null)
                          Marker(
                            point: LatLng(_selected!.lat, _selected!.lng),
                            width: 26,
                            height: 26,
                            child: const _SelectedCellRing(),
                          ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution(
                          '© OpenStreetMap contributors',
                          onTap: () => launchUrl(
                            Uri.parse(
                              'https://www.openstreetmap.org/copyright',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (loading)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      minHeight: 3,
                      color: AppColors.primaryBlue,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                if (loading && !hasLoaded && !hasError)
                  Center(child: _StatusPill(text: l10n.heatmapLoading)),
                if (_loadingPinId != null)
                  Center(child: _StatusPill(text: l10n.heatmapPinLoading)),
                if (hasError)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _MessageCard(
                      icon: isConnectivityIssue
                          ? Icons.wifi_off_rounded
                          : Icons.error_outline_rounded,
                      message: isConnectivityIssue
                          ? l10n.networkOfflineBanner
                          : l10n.heatmapErrorGeneric,
                      actionLabel: l10n.tryAgain,
                      onAction: () => _load(force: true),
                    ),
                  )
                else if (_nothingInView && !loading)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _MessageCard(
                      icon: _pinMode
                          ? Icons.local_shipping_outlined
                          : Icons.zoom_out_map_rounded,
                      message: _pinMode
                          ? l10n.heatmapNoTrucksInView
                          : l10n.heatmapZoomOutHint,
                    ),
                  )
                else if (_pinMode && pinsState.truncated)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _MessageCard(
                      icon: Icons.zoom_in_map_rounded,
                      message: l10n.heatmapPinsTruncated,
                    ),
                  )
                else if (!_pinMode && layer.isEmpty && !layer.loading)
                  Positioned(
                    top: 12,
                    left: 16,
                    right: 16,
                    child: _MessageCard(
                      icon: Icons.local_fire_department_outlined,
                      message:
                          layer.minCellActivity > 1 &&
                              (layer.resolution ?? 0) >= 8
                          ? l10n.heatmapZoomOutHint
                          : _kind == HeatmapKind.trucks
                          ? l10n.heatmapEmptyTrucks
                          : l10n.heatmapEmptyReels,
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 44,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!_pinMode && _selected != null)
                        _SelectedCellCard(kind: _kind, count: _selected!.count),
                      if (!_pinMode && _selected != null)
                        const SizedBox(height: 10),
                      if (_pinMode)
                        _ModeHint(text: l10n.heatmapPinsModeHint)
                      else
                        const HeatmapLegend(),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 44,
                  child: FloatingActionButton.small(
                    heroTag: 'heatmap_my_location',
                    tooltip: l10n.heatmapMyLocation,
                    backgroundColor: AppColors.white,
                    onPressed: _goToMyLocation,
                    child: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primaryBlue,
                            ),
                          )
                        : const Icon(
                            Icons.my_location,
                            color: AppColors.primaryBlue,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final HeatmapKind selected;
  final ValueChanged<HeatmapKind> onChanged;

  const _Header({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.heatmapTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              HeatmapKindToggle(selected: selected, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;

  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MessageCard({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (actionLabel != null)
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
        ),
      ),
    );
  }
}

class _SelectedCellCard extends StatelessWidget {
  final HeatmapKind kind;
  final int count;

  const _SelectedCellCard({required this.kind, required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isTrucks = kind == HeatmapKind.trucks;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isTrucks ? Icons.local_shipping_outlined : Icons.play_circle_outline,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                isTrucks
                    ? l10n.heatmapCellTrucks(count)
                    : l10n.heatmapCellReels(count),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedCellRing extends StatelessWidget {
  const _SelectedCellRing();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
        border: Border.all(color: AppColors.primaryDark, width: 2.5),
      ),
    );
  }
}

/// Small label shown in pin mode in place of the heat legend.
class _ModeHint extends StatelessWidget {
  final String text;

  const _ModeHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.local_shipping_outlined,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
