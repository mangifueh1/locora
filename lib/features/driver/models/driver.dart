
class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    this.load,
    this.status,
    this.isOnline,
    this.activeDeliveryCount,
    this.joinedAt,
  });

  final String id;
  final String name;
  final String phone;
  final int? load;
  final String? status;
  final bool? isOnline;
  final int? activeDeliveryCount;
  final DateTime? joinedAt;

  factory Driver.fromJson(Map<String, dynamic> json) {
    final rawOnline = json['is_online'] ?? json['online'];
    final status = json['status']?.toString() ??
        json['availability']?.toString();

    return Driver(
      id: json['id'].toString(),
      name: json['name'].toString(),
      phone: json['phone'].toString(),
      load: (json['load'] as num?)?.toInt(),
      status: status,
      isOnline: switch (rawOnline) {
        bool value => value,
        String value when value.toLowerCase() == 'true' ||
            value.toLowerCase() == 'online' ||
            value.toLowerCase() == 'available' =>
          true,
        String value when value.toLowerCase() == 'false' ||
            value.toLowerCase() == 'offline' =>
          false,
        _ => null,
      },
      activeDeliveryCount:
          (json['active_delivery_count'] as num?)?.toInt(),
      joinedAt: DateTime.tryParse(json['joined_at']?.toString() ?? ''),
    );
  }
}
