import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roadfix/services/geolocation_services.dart';

class LocationPermissionManager {
  /// Returns the current location status without requesting permission.
  static Future<LocationStatus> getLocationStatus() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationStatus.serviceOff;
    }
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.deniedForever) {
      return LocationStatus.deniedForever;
    }
    if (perm == LocationPermission.denied) return LocationStatus.denied;
    return LocationStatus.loaded;
  }

  /// Requests location permission. If [openSettings] is true and permission is
  /// permanently denied, opens app settings. Set to false for background/init
  /// calls to avoid kicking the user out of the app.
  static Future<bool> checkLocationPermission({
    bool openSettings = true,
  }) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (openSettings) {
        await openAppSettings();
      }
      return false;
    }

    return true;
  }

  static Future<bool> checkLocationService() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }
}
