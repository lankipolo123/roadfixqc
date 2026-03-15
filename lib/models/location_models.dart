class LocationData {
  final double latitude;
  final double longitude;
  final String formattedAddress;
  final String shortAddress;
  final String badgeAddress;
  final String fullAddress;
  final String city;
  final String province;
  final String country;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
    required this.shortAddress,
    this.badgeAddress = '',
    required this.fullAddress,
    required this.city,
    required this.province,
    required this.country,
  });

  @override
  String toString() => shortAddress;
}
