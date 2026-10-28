// Zoom levels of the Trucks heatmap. Zoomed out it is a heat layer (the H3
// resolution steps live in heat_field.dart); once a whole city fits on screen it
// switches to real truck pins, so you can tap an individual truck.
//
//   zoom  < 12            heat (resolution 4..7)
//   zoom >= 12            real pins
//     12 .. <15           nearby pins grouped into numbered bubbles
//     15 .. <17.5         only pins that visually overlap are grouped
//     >= 17.5             every pin on its own
//
// Reels have no pin level: they stay a heatmap at every zoom, and the map cannot be
// zoomed in past [reelsMaxZoom] (a city) on that tab — tapping a hotspot opens that
// area's reels instead of going closer.

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Box around India (Andaman & Nicobar, Lakshadweep and Ladakh included). The
/// heatmap's camera is held inside it, so no other country is ever the focus of
/// the map. Neighbouring land that falls inside the box is still drawn by the tiles.
final indiaBounds = LatLngBounds(const LatLng(6.5, 68.0), const LatLng(37.2, 97.5));

/// Furthest the map zooms in on the Reels tab: a whole city still fits on screen.
/// Kept under [truckPinsEnterZoom] so Reels never reach the resolutions (8 and 9)
/// where the server hides small cells, and tapping a hotspot is the way "closer".
const double reelsMaxZoom = 11.5;

/// Furthest the map zooms in on the Trucks tab (street level, for the pins).
const double trucksMaxZoom = 18.0;

/// At this zoom a city (~13 km across) fits on a phone screen: switch heat -> pins.
const double truckPinsEnterZoom = 12.0;

/// Switch back pins -> heat only below this, so the layer can't flicker back and
/// forth when the zoom hovers at the boundary.
const double truckPinsExitZoom = 11.8;

/// Below this zoom nearby pins are grouped into count bubbles.
const double pinClusterBelowZoom = 15.0;

/// From [pinClusterBelowZoom] up to this, only pins that would overlap on screen
/// are grouped; above it every pin is drawn on its own.
const double pinOverlapGroupBelowZoom = 17.5;

/// Grid cell (screen pixels) used to group pins in each zoom band.
const double pinClusterCellPx = 70;
const double pinOverlapCellPx = 30;

/// Whether the Trucks tab is in real-pin mode at [zoom], given whether it already
/// was ([currentlyPins]) — the gap between enter and exit zoom is the hysteresis.
bool truckPinsModeFor(double zoom, {required bool currentlyPins}) =>
    currentlyPins ? zoom >= truckPinsExitZoom : zoom >= truckPinsEnterZoom;

/// Grid cell size in pixels to group pins at [zoom], or null to draw each alone.
double? pinGroupingCellPx(double zoom) {
  if (zoom < pinClusterBelowZoom) return pinClusterCellPx;
  if (zoom < pinOverlapGroupBelowZoom) return pinOverlapCellPx;
  return null;
}

/// Groups points that fall in the same `cellPx` x `cellPx` square of a pixel
/// grid. Returns the indices of each group (every point lands in exactly one),
/// in first-seen order. Pure, so the grouping can be tested without a map.
List<List<int>> groupByGrid(List<(double, double)> points, double cellPx) {
  final groups = <(int, int), List<int>>{};
  for (var i = 0; i < points.length; i++) {
    final key = ((points[i].$1 / cellPx).floor(), (points[i].$2 / cellPx).floor());
    (groups[key] ??= <int>[]).add(i);
  }
  return groups.values.toList();
}
