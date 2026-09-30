import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/track/widgets/delivery_details_card.dart';
import 'package:locora/features/track/widgets/driver_tracking_actions.dart';
import 'package:locora/features/track/widgets/tracker_map.dart';

class TrackingPage extends StatelessWidget {
  const TrackingPage({
    super.key,
    required this.deliveryId,
    required this.orderId,
    required this.status,
    required this.businessName,
    required this.assignment,
    required this.updatedAt,
    required this.customerLocation,
    required this.driverLocation,
    this.isDriver = false,
    this.isSharing = false,
    this.isActionLoading = false,
    this.actionError,
    this.onStart,
    this.onResume,
    this.onComplete,
  });

  final String deliveryId;
  final String orderId;
  final String status;
  final String businessName;
  final String assignment;
  final DateTime? updatedAt;
  final LatLng? customerLocation;
  final LatLng? driverLocation;
  final bool isDriver;
  final bool isSharing;
  final bool isActionLoading;
  final String? actionError;
  final VoidCallback? onStart;
  final VoidCallback? onResume;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final center = customerLocation ?? driverLocation;
    final details = DeliveryDetailsCard(
      deliveryId: deliveryId,
      orderId: orderId,
      status: status,
      businessName: businessName,
      assignment: assignment,
      updatedAt: updatedAt,
      isDriver: isDriver,
    );
    final actions = isDriver
        ? DriverTrackingActions(
            status: status,
            isSharing: isSharing,
            isLoading: isActionLoading,
            error: actionError,
            onStart: onStart,
            onResume: onResume,
            onComplete: onComplete,
          )
        : null;

    if (center == null) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details,
                    const SizedBox(height: 12),
                    const Text('Customer location is not available yet.'),
                    if (actions != null) ...[
                      const SizedBox(height: 12),
                      actions,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Positioned.fill(
          child: TrackerMap(
            center: center,
            customerLocation: customerLocation,
            driverLocation: driverLocation,
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: details,
              ),
            ),
          ),
        ),
        if (actions != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: actions,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
