import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:locora/features/driver/providers/live_delivery_controller.dart';

class DeliveryDetailScreen extends ConsumerWidget {
  const DeliveryDetailScreen({super.key, required this.deliveryId});

  final String deliveryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final delivery = ref.watch(
      FutureProvider.autoDispose(
        (ref) => ref.watch(driverApiProvider).deliveryDetail(deliveryId),
      ),
    );

    final tracking = ref.watch(liveDeliveryControllerProvider(deliveryId));

    return Scaffold(
      appBar: AppBar(title: Text('Delivery $deliveryId')),
      body: delivery.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load delivery: $error')),
        data: (item) {
          final hasCustomerLocation =
              item.customerLat != null && item.customerLng != null;

          if (!hasCustomerLocation) {
            return const Center(
              child: Text('Customer location is not available yet.'),
            );
          }

          final customer = LatLng(item.customerLat!, item.customerLng!);

          return Column(
            children: [
              Expanded(
                child: MapWidget(
                  viewport: CameraViewportState(
                    center: Point(
                      coordinates: Position(
                        customer.longitude,
                        customer.latitude,
                      ),
                    ),
                    zoom: 15,
                  ),
                  onMapCreated: (map) async {
                    final manager = await map.annotations
                        .createCircleAnnotationManager();
                    await manager.create(
                      CircleAnnotationOptions(
                        geometry: Point(
                          coordinates: Position(
                            customer.longitude,
                            customer.latitude,
                          ),
                        ),
                        circleColor: 0xff1976d2,
                        circleRadius: 10,
                        circleStrokeColor: 0xffffffff,
                        circleStrokeWidth: 3,
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: tracking.isSharing
                            ? null
                            : () => ref
                                  .read(
                                    liveDeliveryControllerProvider(deliveryId)
                                        .notifier,
                                  )
                                  .start(),
                        child: Text(
                          tracking.isSharing
                              ? 'Sharing location'
                              : 'Start delivery',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: tracking.isSharing
                            ? () => ref
                                  .read(
                                    liveDeliveryControllerProvider(deliveryId)
                                        .notifier,
                                  )
                                  .stop()
                            : null,
                        child: const Text('Mark delivered'),
                      ),
                    ),
                  ],
                ),
              ),

              if (tracking.error != null)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Text(
                    tracking.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
