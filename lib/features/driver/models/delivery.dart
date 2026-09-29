class Delivery {
  const Delivery({
    required this.id,
    required this.orderId,
    required this.status,
    this.businessName,
    this.customerLat,
    this.customerLng,
    this.driverLat,
    this.driverLng,
  });

  final String id;
  final String orderId;
  final String status;
  final String? businessName;
  final double? customerLat;
  final double? customerLng;
  final double? driverLat;
  final double? driverLng;

  factory Delivery.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final driverLat =
        json['driver_lat'] ??
        (driver is Map<String, dynamic> ? driver['lat'] : null);
    final driverLng =
        json['driver_lng'] ??
        (driver is Map<String, dynamic> ? driver['lng'] : null);

    return Delivery(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      status: json['status'].toString(),
      businessName: json['business_name']?.toString(),
      customerLat: (json['customer_lat'] as num?)?.toDouble(),
      customerLng: (json['customer_lng'] as num?)?.toDouble(),
      driverLat: (driverLat as num?)?.toDouble(),
      driverLng: (driverLng as num?)?.toDouble(),
    );
  }
}
