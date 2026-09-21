class DeliveryLocation {
  const DeliveryLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
    );
  }
}

class DeliveryModel {
  const DeliveryModel({
    required this.id,
    required this.orderId,
    required this.status,
    required this.businessName,
    required this.customerLocation,
    required this.driverLocation,
    required this.assignment,
    this.updatedAt,
  });

  final String id;
  final String orderId;
  final String status;
  final String businessName;
  final DeliveryLocation? customerLocation;
  final DeliveryLocation? driverLocation;
  final String assignment;
  final DateTime? updatedAt;

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    final customerLat = json['customer_lat'];
    final customerLng = json['customer_lng'];
    final driver = json['driver'];

    return DeliveryModel(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      status: json['status'].toString(),
      businessName: json['business_name']?.toString() ?? 'Your delivery',
      customerLocation: customerLat is num && customerLng is num
          ? DeliveryLocation(
              latitude: customerLat.toDouble(),
              longitude: customerLng.toDouble(),
            )
          : null,
      driverLocation:
          driver is Map<String, dynamic> &&
              driver['lat'] is num &&
              driver['lng'] is num
          ? DeliveryLocation.fromJson(driver)
          : null,
      assignment: json['assignment']?.toString() ?? 'still_to_be_assigned',
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}
