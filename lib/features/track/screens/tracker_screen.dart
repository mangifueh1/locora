import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/core/network/connectivity_provider.dart';
import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:locora/features/driver/providers/live_delivery_controller.dart';
import 'package:locora/features/track/models/delivery_model.dart';
import 'package:locora/features/track/providers/track_provider.dart';
import 'package:locora/features/track/widgets/tracking_error.dart';
import 'package:locora/features/track/widgets/tracking_page.dart';

class TrackerScreen extends ConsumerStatefulWidget {
  const TrackerScreen({super.key, this.token, this.deliveryId});

  final String? token;
  final String? deliveryId;

  @override
  ConsumerState<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends ConsumerState<TrackerScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _startRefreshTimer();
  }

  @override
  void didUpdateWidget(covariant TrackerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.token != widget.token ||
        oldWidget.deliveryId != widget.deliveryId) {
      _refreshTimer?.cancel();
      _startRefreshTimer();
    }
  }

  void _startRefreshTimer() {
    if (widget.token == null && widget.deliveryId == null) return;
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      final token = widget.token;
      final deliveryId = widget.deliveryId;
      if (token != null) {
        ref.invalidate(trackingProvider(token));
      } else if (deliveryId != null) {
        ref.invalidate(driverDeliveryDetailProvider(deliveryId));
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = ref.watch(deviceConnectivityProvider);
    final isOffline = connectivity.when(
      data: (isConnected) => !isConnected,
      error: (_, _) => false,
      loading: () => false,
    );
    final token = widget.token;
    final deliveryId = widget.deliveryId;
    if ((token == null) == (deliveryId == null) ||
        token?.isEmpty == true ||
        deliveryId?.isEmpty == true) {
      return const Scaffold(
        body: Center(
          child: Text('A tracking token or delivery ID is required.'),
        ),
      );
    }

    if (token != null) {
      final tracking = ref.watch(trackingProvider(token));
      return Scaffold(
        body: _trackingBody(
          isOffline: isOffline,
          content: tracking.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => TrackingError(error: error),
            data: (delivery) => TrackingPage(
              deliveryId: delivery.id,
              orderId: delivery.orderId,
              status: delivery.status,
              businessName: delivery.businessName,
              assignment: delivery.assignment,
              driverName: delivery.driverName,
              driverPhone: delivery.driverPhone,
              updatedAt: delivery.updatedAt,
              customerLocation: _toLatLng(delivery.customerLocation),
              driverLocation: _toLatLng(delivery.driverLocation),
            ),
          ),
        ),
      );
    }

    final delivery = ref.watch(driverDeliveryDetailProvider(deliveryId!));
    final tracking = ref.watch(liveDeliveryControllerProvider(deliveryId));
    return Scaffold(
      body: _trackingBody(
        isOffline: isOffline,
        content: delivery.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => TrackingError(error: error),
          data: (item) => TrackingPage(
            deliveryId: item.id,
            orderId: item.orderId,
            status: item.status,
            businessName: item.businessName ?? 'Delivery details',
            assignment: 'Assigned to you',
            updatedAt: item.updatedAt,
            customerLocation: _toLatLng(
              item.customerLat == null || item.customerLng == null
                  ? null
                  : DeliveryLocation(
                      latitude: item.customerLat!,
                      longitude: item.customerLng!,
                    ),
            ),
            driverLocation: _toLatLng(
              item.driverLat == null || item.driverLng == null
                  ? null
                  : DeliveryLocation(
                      latitude: item.driverLat!,
                      longitude: item.driverLng!,
                    ),
            ),
            isDriver: true,
            isSharing: tracking.isSharing,
            isActionLoading: tracking.isLoading,
            actionError: tracking.error,
            onStart: () => _runDriverAction(resume: false),
            onResume: () => _runDriverAction(resume: true),
            onComplete: _completeDelivery,
          ),
        ),
      ),
    );
  }

  Widget _trackingBody({required bool isOffline, required Widget content}) =>
      SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isOffline) const _OfflineTrackingBanner(),
            Expanded(child: content),
          ],
        ),
      );

  Future<void> _runDriverAction({required bool resume}) async {
    final deliveryId = widget.deliveryId;
    if (deliveryId == null) return;
    final controller = ref.read(
      liveDeliveryControllerProvider(deliveryId).notifier,
    );
    if (resume) {
      await controller.resume();
    } else {
      await controller.start();
    }
    if (mounted) ref.invalidate(driverDeliveryDetailProvider(deliveryId));
  }

  Future<void> _completeDelivery() async {
    final deliveryId = widget.deliveryId;
    if (deliveryId == null) return;
    await ref.read(liveDeliveryControllerProvider(deliveryId).notifier).stop();
    if (mounted) ref.invalidate(driverDeliveryDetailProvider(deliveryId));
  }
}

class _OfflineTrackingBanner extends StatelessWidget {
  const _OfflineTrackingBanner();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      liveRegion: true,
      child: Material(
        color: colors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: colors.onErrorContainer),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No active connection. Connect to Wi-Fi or mobile data to keep tracking.',
                  style: TextStyle(
                    color: colors.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

LatLng? _toLatLng(DeliveryLocation? location) =>
    location == null ? null : LatLng(location.latitude, location.longitude);
