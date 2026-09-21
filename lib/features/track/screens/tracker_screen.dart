import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/track/models/delivery_model.dart';
import 'package:locora/features/track/providers/track_provider.dart';
import 'package:locora/features/track/widgets/tracker_map.dart';

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
    final center = customer != null
        ? LatLng(customer.latitude, customer.longitude)
        : driver != null
        ? LatLng(driver.latitude, driver.longitude)
        : const LatLng(4.1560, 9.2632);

    return Stack(
      children: [
        TrackerMap(
          center: center,
          customerLocation: customer == null
              ? null
              : LatLng(customer.latitude, customer.longitude),
          driverLocation: driver == null
              ? null
              : LatLng(driver.latitude, driver.longitude),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _DeliveryCard(delivery: delivery),
          ),
        ),
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.delivery});

  final DeliveryModel delivery;

  @override
  Widget build(BuildContext context) {
    final hasDriver = delivery.driverLocation != null;
    final status = delivery.status.replaceAll('_', ' ');

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    delivery.businessName,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                _StatusChip(label: status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Order ${delivery.orderId}'),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  hasDriver ? Icons.local_shipping : Icons.hourglass_top,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  hasDriver
                      ? 'Your driver is on the map'
                      : 'Waiting for a driver to be assigned',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasDriver
                  ? 'The map shows your delivery location and the latest driver position.'
                  : 'Your delivery location is saved. We will show the driver here once assigned.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      side: BorderSide.none,
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
