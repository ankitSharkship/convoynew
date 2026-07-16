import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

@riverpod
LocationService locationService(LocationServiceRef ref) => LocationService();

enum LocationServiceExceptionType {
  /// The device's location service (GPS) is turned off.
  serviceDisabled,

  /// The app doesn't have location permission (denied or denied forever).
  permissionDenied,

  /// Permission and service are both fine, but resolving the position or
  /// address otherwise failed (e.g. no placemark found).
  other,
}

class LocationServiceException implements Exception {
  final String message;
  final LocationServiceExceptionType type;

  const LocationServiceException(
    this.message, {
    this.type = LocationServiceExceptionType.other,
  });

  @override
  String toString() => message;
}

class CurrentLocation {
  final double lat;
  final double lng;
  final String name;
  final String? city;
  final String? state;
  final String? pincode;

  const CurrentLocation({
    required this.lat,
    required this.lng,
    required this.name,
    this.city,
    this.state,
    this.pincode,
  });
}

class LocationService {
  Future<CurrentLocation> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceException(
        'Location services are disabled.',
        type: LocationServiceExceptionType.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException(
          'Location permission denied.',
          type: LocationServiceExceptionType.permissionDenied,
        );
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission permanently denied. Enable it from Settings.',
        type: LocationServiceExceptionType.permissionDenied,
      );
    }

    final position = await Geolocator.getCurrentPosition();
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    if (placemarks.isEmpty) {
      throw const LocationServiceException('Could not resolve your address.');
    }

    final place = placemarks.first;
    final city = place.locality?.isNotEmpty == true ? place.locality : null;
    final state = place.administrativeArea?.isNotEmpty == true
        ? place.administrativeArea
        : null;
    final pincode = place.postalCode?.isNotEmpty == true
        ? place.postalCode
        : null;

    final nameParts = [city, state].whereType<String>().toList();
    final name = nameParts.isNotEmpty
        ? nameParts.join(', ')
        : (place.name?.isNotEmpty == true ? place.name! : 'Unknown location');

    return CurrentLocation(
      lat: position.latitude,
      lng: position.longitude,
      name: name,
      city: city,
      state: state,
      pincode: pincode,
    );
  }
}
