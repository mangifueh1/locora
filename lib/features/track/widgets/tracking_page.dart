import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/track/widgets/delivery_details_card.dart';
import 'package:locora/features/track/widgets/driver_tracking_actions.dart';
import 'package:locora/features/track/widgets/tracker_map.dart';
import 'package:locora/features/track/providers/track_route_provider.dart';

class TrackingPage extends ConsumerStatefulWidget {
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
  ConsumerState<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends ConsumerState<TrackingPage> {
  @override
  void initState() {
    super.initState();
    _scheduleRouteUpdate();
  }

  @override
  void didUpdateWidget(covariant TrackingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deliveryId != widget.deliveryId ||
        oldWidget.customerLocation != widget.customerLocation ||
        oldWidget.driverLocation != widget.driverLocation) {
      _scheduleRouteUpdate();
    }
  }

  void _scheduleRouteUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(trackRouteProvider(widget.deliveryId).notifier)
          .updateLocations(
            driverLocation: widget.driverLocation,
            customerLocation: widget.customerLocation,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeState = ref.watch(trackRouteProvider(widget.deliveryId));
    final center = widget.customerLocation ?? widget.driverLocation;
    final details = DeliveryDetailsCard(
      deliveryId: widget.deliveryId,
      orderId: widget.orderId,
      status: widget.status,
      businessName: widget.businessName,
      assignment: widget.assignment,
      updatedAt: widget.updatedAt,
      isDriver: widget.isDriver,
    );
    final actions = widget.isDriver
        ? DriverTrackingActions(
            status: widget.status,
            isSharing: widget.isSharing,
            isLoading: widget.isActionLoading,
            error: widget.actionError,
            onStart: widget.onStart,
            onResume: widget.onResume,
            onComplete: widget.onComplete,
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
            customerLocation: widget.customerLocation,
            driverLocation: widget.driverLocation,
            routeGeometry: routeState.geometry,
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details,
                    const SizedBox(height: 8),
                    const TrackingMapKey(),
                  ],
                ),
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

class TrackingMapKey extends StatelessWidget {
  const TrackingMapKey({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Map key',
      child: Material(
        elevation: 4,
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Wrap(
            spacing: 18,
            runSpacing: 10,
            children: [
              _TrackingMapKeyItem(
                label: 'Driver',
                semanticLabel: 'Driver, red marker',
                markerColor: Color(0xFFF4511E),
              ),
              _TrackingMapKeyItem(
                label: 'Customer',
                semanticLabel: 'Customer, blue marker',
                markerColor: Color(0xFF1976D2),
              ),
              _TrackingMapKeyItem(
                label: 'Route',
                semanticLabel: 'Route, teal line',
                markerColor: Color(0xFF00BFA5),
                isRoute: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrackingMapKeyItem extends StatelessWidget {
  const _TrackingMapKeyItem({
    required this.label,
    required this.semanticLabel,
    required this.markerColor,
    this.isRoute = false,
  });

  final String label;
  final String semanticLabel;
  final Color markerColor;
  final bool isRoute;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isRoute)
              SizedBox(
                width: 20,
                height: 14,
                child: Center(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: markerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              )
            else
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: markerColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
