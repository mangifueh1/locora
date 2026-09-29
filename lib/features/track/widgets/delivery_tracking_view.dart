import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/track/widgets/tracker_map.dart';

class DeliveryTrackingView extends StatelessWidget {
  const DeliveryTrackingView({
    super.key,
    required this.orderId,
    required this.status,
    required this.businessName,
    this.customerLocation,
    this.driverLocation,
    this.bottomContent,
  });

  final String orderId;
  final String status;
  final String businessName;
  final LatLng? customerLocation;
  final LatLng? driverLocation;
  final Widget? bottomContent;

  @override
  Widget build(BuildContext context) {
    final center =
        customerLocation ?? driverLocation ?? const LatLng(4.1560, 9.2632);

    return Stack(
      children: [
        Positioned.fill(
          child: customerLocation == null && driverLocation == null
              ? const ColoredBox(
                  color: Color(0xffe8edf0),
                  child: Center(
                    child: Icon(
                      Icons.location_off_outlined,
                      size: 48,
                      color: Color(0xff687780),
                    ),
                  ),
                )
              : TrackerMap(
                  center: center,
                  customerLocation: customerLocation,
                  driverLocation: driverLocation,
                ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: _DeliverySummary(
                      orderId: orderId,
                      status: status,
                      businessName: businessName,
                      hasCustomerLocation: customerLocation != null,
                      hasDriverLocation: driverLocation != null,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              if (bottomContent != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: bottomContent!,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliverySummary extends StatelessWidget {
  const _DeliverySummary({
    required this.orderId,
    required this.status,
    required this.businessName,
    required this.hasCustomerLocation,
    required this.hasDriverLocation,
  });

  final String orderId;
  final String status;
  final String businessName;
  final bool hasCustomerLocation;
  final bool hasDriverLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    businessName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusLabel(label: status.replaceAll('_', ' ')),
              ],
            ),
            const SizedBox(height: 6),
            Text('Order $orderId'),
            const SizedBox(height: 14),
            _LocationStatus(
              color: const Color(0xff1976d2),
              label: hasCustomerLocation
                  ? 'Customer location'
                  : 'Customer location unavailable',
              available: hasCustomerLocation,
            ),
            const SizedBox(height: 8),
            _LocationStatus(
              color: const Color(0xfff4511e),
              label: hasDriverLocation
                  ? 'Driver location is live'
                  : 'Waiting for a driver location',
              available: hasDriverLocation,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLabel extends StatelessWidget {
  const _StatusLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(maxWidth: 140),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _LocationStatus extends StatelessWidget {
  const _LocationStatus({
    required this.color,
    required this.label,
    required this.available,
  });

  final Color color;
  final String label;
  final bool available;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: available ? color : Theme.of(context).disabledColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
