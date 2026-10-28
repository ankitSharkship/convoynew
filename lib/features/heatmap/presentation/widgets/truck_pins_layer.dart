import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../truck_map/presentation/widgets/truck_marker.dart';
import '../../domain/entities/truck_pin_entity.dart';
import '../rendering/map_zoom_levels.dart';

const _pinSize = 38.0;

/// Real truck pins over a [FlutterMap] (place it after the tile layer).
///
/// Zoomed out within pin mode, trucks that sit close together are grouped into
/// a numbered bubble; tapping one zooms in on it ([onClusterTap]). From zoom 15
/// up only pins that would overlap on screen are grouped, and from 17.5 every
/// truck is drawn on its own. Tapping a pin calls [onPinTap].
class TruckPinsLayer extends StatelessWidget {
  final List<TruckPinEntity> pins;

  /// The pin to highlight (the one whose details are open / loading).
  final String? selectedId;

  final ValueChanged<TruckPinEntity> onPinTap;

  /// A group was tapped: its centre and how many trucks it holds.
  final void Function(LatLng center, int count) onClusterTap;

  const TruckPinsLayer({
    super.key,
    required this.pins,
    required this.selectedId,
    required this.onPinTap,
    required this.onClusterTap,
  });

  @override
  Widget build(BuildContext context) {
    final camera = MapCamera.of(context);
    final cellPx = pinGroupingCellPx(camera.zoom);

    // Only pins on (or just off) screen are turned into widgets.
    final visible = camera.visibleBounds;
    final inView = <TruckPinEntity>[
      for (final pin in pins)
        if (_nearView(visible, pin)) pin,
    ];

    final markers = <Marker>[];
    if (cellPx == null) {
      for (final pin in inView) {
        markers.add(_pinMarker(pin));
      }
    } else {
      final points = [
        for (final pin in inView)
          () {
            final world = camera.projectAtZoom(LatLng(pin.lat, pin.lng));
            return (world.dx, world.dy);
          }(),
      ];
      for (final group in groupByGrid(points, cellPx)) {
        if (group.length == 1) {
          markers.add(_pinMarker(inView[group.first]));
        } else {
          markers.add(_clusterMarker([for (final i in group) inView[i]]));
        }
      }
    }

    // Draw the selected pin last so it sits on top.
    markers.sort((a, b) {
      final aSelected = a.key == ValueKey('pin-$selectedId');
      final bSelected = b.key == ValueKey('pin-$selectedId');
      return aSelected == bSelected ? 0 : (aSelected ? 1 : -1);
    });

    return MarkerLayer(markers: markers);
  }

  bool _nearView(LatLngBounds bounds, TruckPinEntity pin) {
    final padLat = (bounds.north - bounds.south) * 0.1;
    final padLng = (bounds.east - bounds.west) * 0.1;
    return pin.lat >= bounds.south - padLat &&
        pin.lat <= bounds.north + padLat &&
        pin.lng >= bounds.west - padLng &&
        pin.lng <= bounds.east + padLng;
  }

  Marker _pinMarker(TruckPinEntity pin) {
    final selected = pin.id == selectedId;
    final size = selected ? _pinSize + 8 : _pinSize;
    return Marker(
      key: ValueKey('pin-${pin.id}'),
      point: LatLng(pin.lat, pin.lng),
      width: size,
      height: size,
      child: TruckMarker(size: size, onTap: () => onPinTap(pin)),
    );
  }

  Marker _clusterMarker(List<TruckPinEntity> members) {
    var lat = 0.0;
    var lng = 0.0;
    for (final pin in members) {
      lat += pin.lat;
      lng += pin.lng;
    }
    final center = LatLng(lat / members.length, lng / members.length);
    final count = members.length;
    final size = count < 10 ? 42.0 : (count < 100 ? 50.0 : 58.0);
    return Marker(
      key: ValueKey('cluster-${center.latitude}-${center.longitude}-$count'),
      point: center,
      width: size,
      height: size,
      child: _ClusterBubble(
        count: count,
        size: size,
        onTap: () => onClusterTap(center, count),
      ),
    );
  }
}

class _ClusterBubble extends StatelessWidget {
  final int count;
  final double size;
  final VoidCallback onTap;

  const _ClusterBubble({
    required this.count,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primaryBlue,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$count',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
