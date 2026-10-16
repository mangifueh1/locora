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
    this.customerPhone,
    this.customerLandmark,
    this.driverName,
    this.driverPhone,
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
  final String? customerPhone;
  final String? customerLandmark;
  final String? driverName;
  final String? driverPhone;

  factory Delivery.fromJson(Map<String, dynamic> json) {
    final driver = json['driver'];
    final nestedDriver = driver is Map<String, dynamic> ? driver : null;
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
      customerPhone: json['customer_phone']?.toString(),
      customerLandmark:
          json['customer_landmark']?.toString() ??
          json['address_description']?.toString() ??
          json['landmark']?.toString(),
      driverName:
          _nonEmptyString(json['driver_name']) ??
          _nonEmptyString(nestedDriver?['name']),
      driverPhone:
          _nonEmptyString(json['driver_phone']) ??
          _nonEmptyString(nestedDriver?['phone']),
    );
  }
}

String? _nonEmptyString(dynamic value) {
  final string = value?.toString().trim();
  return string == null || string.isEmpty ? null : string;
}
