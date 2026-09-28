import 'package:locora/features/driver/models/delivery.dart';

class AvailableDeliveries {
  const AvailableDeliveries({
    required this.activeDeliveryCount,
    required this.availableSlots,
    required this.deliveries,
  });

  final int activeDeliveryCount;
  final int availableSlots;
  final List<Delivery> deliveries;

  factory AvailableDeliveries.fromJson(Map<String, dynamic> json) {
    final items = json['deliveries'] as List<dynamic>? ?? [];

    return AvailableDeliveries(
      activeDeliveryCount:
          (json['active_delivery_count'] as num?)?.toInt() ?? 0,
      availableSlots: (json['available_slots'] as num?)?.toInt() ?? 0,
      deliveries: items
          .whereType<Map<String, dynamic>>()
          .map(Delivery.fromJson)
          .toList(),
    );
  }
}
