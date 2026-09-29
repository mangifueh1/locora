import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/track/models/delivery_model.dart';
import 'package:locora/features/track/providers/track_provider.dart';
import 'package:locora/features/track/widgets/delivery_tracking_view.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      ref.invalidate(trackingProvider(widget.token));
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = ref.watch(trackingProvider(widget.token));

    return Scaffold(
      body: tracking.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _TrackingError(error: error),
        data: (delivery) => _TrackingBody(delivery: delivery),
      ),
    );
  }
}

class _TrackingBody extends StatelessWidget {
  const _TrackingBody({required this.delivery});

  final DeliveryModel delivery;

  @override
  Widget build(BuildContext context) {
    final customer = delivery.customerLocation;
    final driver = delivery.driverLocation;

    return DeliveryTrackingView(
      businessName: delivery.businessName,
      orderId: delivery.orderId,
      status: delivery.status,
      customerLocation: customer == null
          ? null
          : LatLng(customer.latitude, customer.longitude),
      driverLocation: driver == null
          ? null
          : LatLng(driver.latitude, driver.longitude),
    );
  }
}

class _TrackingError extends StatelessWidget {
  const _TrackingError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.link_off, size: 48),
            const SizedBox(height: 12),
            Text(
              'This tracking link is unavailable.',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
