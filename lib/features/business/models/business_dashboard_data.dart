import 'package:locora/features/driver/models/delivery.dart';
import 'package:locora/features/driver/models/driver.dart';

class BusinessDashboardData {
  const BusinessDashboardData({
    required this.drivers,
    required this.pendingDeliveries,
    this.deliveries = const [],
  });

  final List<Driver> drivers;
  final List<Delivery> pendingDeliveries;
  final List<Delivery> deliveries;

  List<Delivery> get allDeliveries =>
      deliveries.isEmpty && pendingDeliveries.isNotEmpty
      ? pendingDeliveries
      : deliveries;
}
