class DeliveryLocation {
  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
    this.addressDescription,
  });

  final double latitude;
  final double longitude;
  final String? addressDescription;

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    final latitude = json['lat'];
    final longitude = json['lng'];
    if (latitude is! num || longitude is! num) {
      throw const FormatException('Invalid saved location coordinates');
    }

    final description = json['address_description'];
    return DeliveryLocation(
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      addressDescription: description is String ? description : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': latitude,
      'lng': longitude,
      'address_description': addressDescription?.trim().isNotEmpty == true
          ? addressDescription!.trim()
          : null,
    };
  }
}
