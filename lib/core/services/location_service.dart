import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

@riverpod
LocationService locationService(LocationServiceRef ref) => LocationService();

class LocationServiceException implements Exception {
  final String message;
  const LocationServiceException(this.message);

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
      throw const LocationServiceException('Location services are disabled.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationServiceException('Location permission denied.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Location permission permanently denied. Enable it from Settings.',
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
    final state =
        place.administrativeArea?.isNotEmpty == true ? place.administrativeArea : null;
    final pincode = place.postalCode?.isNotEmpty == true ? place.postalCode : null;

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
