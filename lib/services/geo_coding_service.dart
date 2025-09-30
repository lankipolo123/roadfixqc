import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:roadfix/models/address_config.dart';

class KalmanFilter {
  double _lat = 0.0;
  double _lng = 0.0;
  double _latVariance = 1000.0;
  double _lngVariance = 1000.0;
  bool _initialized = false;

  void update(double lat, double lng, double accuracy) {
    if (!_initialized) {
      _lat = lat;
      _lng = lng;
      _latVariance = accuracy * accuracy;
      _lngVariance = accuracy * accuracy;
      _initialized = true;
      return;
    }

    // Process noise (GPS tends to drift)
    const processNoise = 0.1;
    _latVariance += processNoise;
    _lngVariance += processNoise;

    // Measurement noise from GPS accuracy
    final measurementVariance = accuracy * accuracy;

    // Kalman gain
    final latGain = _latVariance / (_latVariance + measurementVariance);
    final lngGain = _lngVariance / (_lngVariance + measurementVariance);

    // Update estimates
    _lat = _lat + latGain * (lat - _lat);
    _lng = _lng + lngGain * (lng - _lng);

    // Update variances
    _latVariance = (1 - latGain) * _latVariance;
    _lngVariance = (1 - lngGain) * _lngVariance;
  }

  double get latitude => _lat;
  double get longitude => _lng;
  bool get isInitialized => _initialized;
}

class MapMatchedCoordinate {
  final double latitude;
  final double longitude;
  final String roadName;
  final double confidence;

  MapMatchedCoordinate({
    required this.latitude,
    required this.longitude,
    required this.roadName,
    required this.confidence,
  });
}

class GeocodingService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String _valhallaBaseUrl = 'https://valhalla1.openstreetmap.de';

  static final KalmanFilter _kalmanFilter = KalmanFilter();

  // Enhanced method with map matching
  static Future<AddressComponents> getAddressComponentsAccurate(
    double latitude,
    double longitude,
    double accuracy,
  ) async {
    try {
      // Step 1: Apply Kalman filter for GPS smoothing
      _kalmanFilter.update(latitude, longitude, accuracy);
      final smoothedLat = _kalmanFilter.latitude;
      final smoothedLng = _kalmanFilter.longitude;

      // Debug logging removed for production

      // Step 2: Apply map matching to snap to nearest road
      final mapMatched = await _performMapMatching(smoothedLat, smoothedLng);

      if (mapMatched != null && mapMatched.confidence > 0.7) {
        // Use map-matched coordinates for reverse geocoding
        return await _reverseGeocode(mapMatched.latitude, mapMatched.longitude);
      } else {
        // Fallback to smoothed coordinates if map matching fails
        return await _reverseGeocode(smoothedLat, smoothedLng);
      }
    } catch (e) {
      // Error handling without logging for production
      // Ultimate fallback to original coordinates
      return await _reverseGeocode(latitude, longitude);
    }
  }

  // Valhalla map matching API call
  static Future<MapMatchedCoordinate?> _performMapMatching(
    double latitude,
    double longitude,
  ) async {
    try {
      // Create a simple route with single point (you can extend this for multiple points)
      final requestBody = {
        "shape": [
          {"lat": latitude, "lon": longitude},
        ],
        "costing": "auto", // or "pedestrian" for walking
        "shape_match": "map_snap",
        "filters": {
          "attributes": ["edge.way_id", "edge.names"],
        },
      };

      final url = Uri.parse('$_valhallaBaseUrl/trace_attributes');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'RoadFix Mobile App',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['shape'] != null && data['shape'].isNotEmpty) {
          final matchedPoint = data['shape'][0];
          final edgeInfo = data['edges']?[0];

          return MapMatchedCoordinate(
            latitude: matchedPoint['lat']?.toDouble() ?? latitude,
            longitude: matchedPoint['lon']?.toDouble() ?? longitude,
            roadName: edgeInfo?['names']?[0] ?? 'Unknown Road',
            confidence:
                0.9, // Valhalla doesn't return confidence, assume high if successful
          );
        }
      }
    } catch (e) {
      // Map matching error - continue to fallback
    }

    // Fallback: try OSRM map matching
    return await _performOSRMMapMatching(latitude, longitude);
  }

  // OSRM map matching as fallback
  static Future<MapMatchedCoordinate?> _performOSRMMapMatching(
    double latitude,
    double longitude,
  ) async {
    try {
      // OSRM match service
      final url = Uri.parse(
        'https://router.project-osrm.org/match/v1/driving/$longitude,$latitude?geometries=geojson&overview=full',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'RoadFix Mobile App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['matchings'] != null && data['matchings'].isNotEmpty) {
          final matching = data['matchings'][0];
          final geometry = matching['geometry'];

          if (geometry['coordinates'] != null &&
              geometry['coordinates'].isNotEmpty) {
            final coord = geometry['coordinates'][0];

            return MapMatchedCoordinate(
              latitude: coord[1]?.toDouble() ?? latitude,
              longitude: coord[0]?.toDouble() ?? longitude,
              roadName: 'Matched Road',
              confidence: matching['confidence']?.toDouble() ?? 0.8,
            );
          }
        }
      }
    } catch (e) {
      // OSRM map matching error - return null
    }

    return null;
  }

  // Enhanced reverse geocoding with higher precision
  static Future<AddressComponents> _reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      '$_nominatimBaseUrl/reverse?'
      'format=json&'
      'lat=$latitude&'
      'lon=$longitude&'
      'zoom=21&' // Maximum zoom for building level
      'addressdetails=1&'
      'extratags=1&'
      'namedetails=1&'
      'accept-language=en',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'RoadFix Mobile App'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to get address from coordinates. Status: ${response.statusCode}',
      );
    }

    final data = json.decode(response.body);

    if (data['error'] != null) {
      throw Exception('Geocoding error: ${data['error']}');
    }

    return AddressComponents.fromJson(data['address'] ?? {});
  }

  // Keep your original method for compatibility
  static Future<AddressComponents> getAddressComponents(
    double latitude,
    double longitude,
  ) async {
    return await _reverseGeocode(latitude, longitude);
  }
}
