import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:roadfix/models/address_config.dart';

class GeocodingService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';

  static Future<AddressComponents> getAddressComponents(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      '$_nominatimBaseUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
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
}
