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
    this.updatedAt,
  });

  final String id;
  final String orderId;
  final String status;
  final String? businessName;
  final double? customerLat;
  final double? customerLng;
  final double? driverLat;
  final double? driverLng;
  final DateTime? updatedAt;

  factory Delivery.fromJson(Map<String, dynamic> json) {
    return Delivery(
      id: json['id'].toString(),
      orderId: json['order_id'].toString(),
      status: json['status'].toString(),
      businessName: json['business_name']?.toString(),
      customerLat: (json['customer_lat'] as num?)?.toDouble(),
      customerLng: (json['customer_lng'] as num?)?.toDouble(),
      driverLat: (json['driver_lat'] as num?)?.toDouble(),
      driverLng: (json['driver_lng'] as num?)?.toDouble(),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
    );
  }
}
