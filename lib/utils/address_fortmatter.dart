import 'package:roadfix/models/address_config.dart';

class AddressFormatter {
  static const Map<String, String> _cityAbbreviations = {
    'Quezon City': 'QC',
    'Marikina City': 'Marikina',
    'Marikina': 'Marikina',
    'Pasig City': 'Pasig',
    'Pasig': 'Pasig',
    'Mandaluyong City': 'Mandaluyong',
    'Mandaluyong': 'Mandaluyong',
    'San Juan City': 'San Juan',
    'San Juan': 'San Juan',
    'Manila City': 'Manila',
    'Manila': 'Manila',
    'Makati City': 'Makati',
    'Makati': 'Makati',
    'Taguig City': 'Taguig',
    'Taguig': 'Taguig',
    'Pasay City': 'Pasay',
    'Pasay': 'Pasay',
    'Parañaque City': 'Parañaque',
    'Parañaque': 'Parañaque',
    'Las Piñas City': 'Las Piñas',
    'Las Piñas': 'Las Piñas',
    'Muntinlupa City': 'Muntinlupa',
    'Muntinlupa': 'Muntinlupa',
    'Caloocan City': 'Caloocan',
    'Caloocan': 'Caloocan',
    'Malabon City': 'Malabon',
    'Malabon': 'Malabon',
    'Navotas City': 'Navotas',
    'Navotas': 'Navotas',
    'Valenzuela City': 'Valenzuela',
    'Valenzuela': 'Valenzuela',
    'Antipolo City': 'Antipolo',
    'Antipolo': 'Antipolo',
    'Taytay': 'Taytay',
    'Cainta': 'Cainta',
  };

  static const Map<String, String> _provinceAbbreviations = {
    'Metro Manila': 'MM',
    'National Capital Region': 'NCR',
    'Metropolitan Manila': 'MM',
    'Rizal': 'Rizal',
    'Bulacan': 'Bulacan',
    'Cavite': 'Cavite',
    'Laguna': 'Laguna',
    'Batangas': 'Batangas',
    'Pampanga': 'Pampanga',
  };

  static String createShortAddress(AddressComponents components) {
    final street = components.street;
    final suburb = components.suburb;
    final locality = components.locality;
    final adminArea = components.adminArea;

    // Prioritize city + province over street address for short display
    if (locality.isNotEmpty && adminArea.isNotEmpty && adminArea != locality) {
      String cityShort = _abbreviateCity(locality);
      String provinceShort = _abbreviateProvince(adminArea);
      return '$cityShort, $provinceShort';
    }

    if (locality.isNotEmpty) {
      return _abbreviateCity(locality);
    }

    if (street.isNotEmpty) {
      return street;
    }

    if (suburb.isNotEmpty) {
      return suburb;
    }

    return 'Unknown Location';
  }

  static String createDetailedAddress(AddressComponents components) {
    List<String> parts = [];

    // Street address with house number
    if (components.street.isNotEmpty) {
      parts.add(components.street);
    }

    // Subdivision/Neighborhood if available
    if (components.subdivision.isNotEmpty &&
        components.subdivision != components.locality) {
      parts.add(components.subdivision);
    }

    // Suburb/Barangay if different from subdivision and locality
    if (components.suburb.isNotEmpty &&
        components.suburb != components.locality &&
        components.suburb != components.subdivision) {
      parts.add(components.suburb);
    }

    // City/Municipality
    if (components.locality.isNotEmpty) {
      parts.add(components.locality);
    }

    // Postal code + Province format
    if (components.postcode.isNotEmpty &&
        components.adminArea.isNotEmpty &&
        components.adminArea != components.locality) {
      parts.add('${components.postcode} ${components.adminArea}');
    } else if (components.postcode.isNotEmpty) {
      parts.add(components.postcode);
    } else if (components.adminArea.isNotEmpty &&
        components.adminArea != components.locality) {
      parts.add(components.adminArea);
    }

    return parts.join(', ');
  }

  static String createFullAddress(AddressComponents components) {
    List<String> addressParts = [];

    if (components.street.isNotEmpty) addressParts.add(components.street);
    if (components.suburb.isNotEmpty &&
        components.suburb != components.locality) {
      addressParts.add(components.suburb);
    }
    if (components.locality.isNotEmpty) addressParts.add(components.locality);
    if (components.adminArea.isNotEmpty) addressParts.add(components.adminArea);
    if (components.country.isNotEmpty) addressParts.add(components.country);

    return addressParts.join(', ');
  }

  static String _abbreviateCity(String city) {
    return _cityAbbreviations[city] ?? city;
  }

  static String _abbreviateProvince(String province) {
    return _provinceAbbreviations[province] ?? province;
  }
}
