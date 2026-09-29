import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:locora/features/driver/providers/live_delivery_controller.dart';
import 'package:locora/features/track/widgets/delivery_tracking_view.dart';

class DeliveryDetailScreen extends ConsumerWidget {
  const DeliveryDetailScreen({super.key, required this.deliveryId});

  final String deliveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delivery = ref.watch(driverDeliveryDetailProvider(deliveryId));

    final tracking = ref.watch(liveDeliveryControllerProvider(deliveryId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery $deliveryId', overflow: TextOverflow.ellipsis),
      ),
      body: delivery.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load delivery: $error')),
        data: (item) => DeliveryTrackingView(
          orderId: item.orderId,
          status: item.status,
          businessName: item.businessName ?? 'Your delivery',
          customerLocation: item.customerLat == null || item.customerLng == null
              ? null
              : LatLng(item.customerLat!, item.customerLng!),
          driverLocation:
              tracking.driverLatitude != null &&
                  tracking.driverLongitude != null
              ? LatLng(tracking.driverLatitude!, tracking.driverLongitude!)
              : item.driverLat != null && item.driverLng != null
              ? LatLng(item.driverLat!, item.driverLng!)
              : null,
          bottomContent: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (tracking.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    tracking.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              _DeliveryActionButtons(
                onStart: tracking.isSharing || tracking.isLoading
                    ? null
                    : () => ref
                          .read(
                            liveDeliveryControllerProvider(deliveryId).notifier,
                          )
                          .start(),
                onDelivered: tracking.isSharing && !tracking.isLoading
                    ? () => ref
                          .read(
                            liveDeliveryControllerProvider(deliveryId).notifier,
                          )
                          .stop()
                    : null,
                isSharing: tracking.isSharing,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeliveryActionButtons extends StatelessWidget {
  const _DeliveryActionButtons({
    required this.onStart,
    required this.onDelivered,
    required this.isSharing,
  });

  final VoidCallback? onStart;
  final VoidCallback? onDelivered;
  final bool isSharing;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: onStart,
          child: Text(isSharing ? 'Sharing location' : 'Start delivery'),
        ),
      ),
      const SizedBox(height: 8),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onDelivered,
          child: const Text('Mark delivered'),
        ),
      ),
    ],
  );
}
