import 'package:locora/features/driver/models/delivery.dart';
import 'package:locora/features/driver/models/driver.dart';

class BusinessDashboardData {
  const BusinessDashboardData({
    required this.drivers,
    required this.pendingDeliveries,
  });

  final List<Driver> drivers;
  final List<Delivery> pendingDeliveries;
}
