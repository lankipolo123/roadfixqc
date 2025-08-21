import 'package:geolocator/geolocator.dart';
import 'package:roadfix/models/location_models.dart';
import 'package:roadfix/services/geo_coding_service.dart';
import 'package:roadfix/utils/address_fortmatter.dart';
import 'package:roadfix/utils/location_permission_manager.dart';

class GeolocationService {
  // Cache variables
  static LocationData? _cachedLocation;
  static DateTime? _lastLocationTime;
  static const Duration _cacheExpiry = Duration(minutes: 10);

  Future<Position> getCurrentPosition() async {
    if (!await LocationPermissionManager.checkLocationService()) {
      throw Exception(
        'Location services are disabled. Please enable location services in your device settings.',
      );
    }

    if (!await LocationPermissionManager.checkLocationPermission()) {
      throw Exception(
        'Location permissions are denied. Please grant location access to use this feature.',
      );
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );
  }

  Future<LocationData> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final components = await GeocodingService.getAddressComponents(
        latitude,
        longitude,
      );

      return LocationData(
        latitude: latitude,
        longitude: longitude,
        formattedAddress: AddressFormatter.createDetailedAddress(components),
        shortAddress: AddressFormatter.createShortAddress(components),
        fullAddress: AddressFormatter.createFullAddress(components),
        city: components.locality,
        province: components.adminArea,
        country: components.country,
      );
    } catch (e) {
      throw Exception('Failed to get address: $e');
    }
  }

  Future<LocationData> getCurrentLocation() async {
    try {
      // Check cache first
      if (_cachedLocation != null && _lastLocationTime != null) {
        final timeSinceLastUpdate = DateTime.now().difference(
          _lastLocationTime!,
        );
        if (timeSinceLastUpdate < _cacheExpiry) {
          return _cachedLocation!;
        }
      }

      Position position = await getCurrentPosition();
      LocationData locationData = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Update cache
      _cachedLocation = locationData;
      _lastLocationTime = DateTime.now();

      return locationData;
    } catch (e) {
      // Fallback to cached data if available
      if (_cachedLocation != null) {
        return _cachedLocation!;
      }
      throw Exception('Failed to get current location: $e');
    }
  }

  Future<LocationData> getCurrentLocationForced() async {
    try {
      Position position = await getCurrentPosition();
      LocationData locationData = await getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Update cache
      _cachedLocation = locationData;
      _lastLocationTime = DateTime.now();

      return locationData;
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  void clearLocationCache() {
    _cachedLocation = null;
    _lastLocationTime = null;
  }

  Future<bool> hasLocationPermission() async {
    return await LocationPermissionManager.hasLocationPermission();
  }

  Future<bool> isLocationServiceEnabled() async {
    return await LocationPermissionManager.checkLocationService();
  }
}
