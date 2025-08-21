class AddressComponents {
  final String houseNumber;
  final String road;
  final String suburb;
  final String village;
  final String town;
  final String city;
  final String municipality;
  final String county;
  final String state;
  final String province;
  final String region;
  final String country;
  final String postcode;
  final String subdivision;

  AddressComponents({
    required this.houseNumber,
    required this.road,
    required this.suburb,
    required this.village,
    required this.town,
    required this.city,
    required this.municipality,
    required this.county,
    required this.state,
    required this.province,
    required this.region,
    required this.country,
    required this.postcode,
    required this.subdivision,
  });

  factory AddressComponents.fromJson(Map<String, dynamic> address) {
    return AddressComponents(
      houseNumber: address['house_number'] ?? '',
      road: address['road'] ?? '',
      suburb: address['suburb'] ?? '',
      village: address['village'] ?? '',
      town: address['town'] ?? '',
      city: address['city'] ?? '',
      municipality: address['municipality'] ?? '',
      county: address['county'] ?? '',
      state: address['state'] ?? '',
      province: address['province'] ?? '',
      region: address['region'] ?? '',
      country: address['country'] ?? '',
      postcode: address['postcode'] ?? '',
      subdivision: address['residential'] ?? address['neighbourhood'] ?? '',
    );
  }

  String get street {
    if (houseNumber.isNotEmpty && road.isNotEmpty) {
      return '$houseNumber $road';
    } else if (road.isNotEmpty) {
      return road;
    }
    return '';
  }

  String get locality {
    return city.isNotEmpty
        ? city
        : town.isNotEmpty
        ? town
        : municipality.isNotEmpty
        ? municipality
        : village.isNotEmpty
        ? village
        : suburb.isNotEmpty
        ? suburb
        : '';
  }

  String get adminArea {
    return province.isNotEmpty
        ? province
        : state.isNotEmpty
        ? state
        : region.isNotEmpty
        ? region
        : county.isNotEmpty
        ? county
        : '';
  }
}
