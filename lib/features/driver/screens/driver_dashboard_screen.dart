import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:locora/features/driver/providers/live_delivery_controller.dart';
import 'package:locora/features/driver/widgets/driver_businesses_panel.dart';
import 'package:locora/features/driver/widgets/driver_dashboard_header.dart';
import 'package:locora/features/driver/widgets/driver_dashboard_section.dart';
import 'package:locora/features/driver/widgets/driver_dashboard_summary.dart';
import 'package:locora/features/driver/widgets/driver_delivery_card.dart';

class DriverDashboardScreen extends ConsumerStatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  ConsumerState<DriverDashboardScreen> createState() =>
      _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends ConsumerState<DriverDashboardScreen> {
  final Set<String> _busyDeliveryIds = {};

  Future<void> _refresh() async {
    ref.invalidate(driverAvailableDeliveriesProvider);
    ref.invalidate(driverDeliveriesProvider);
    ref.invalidate(driverBusinessesProvider);

    try {
      await Future.wait<Object?>([
        ref.read(driverAvailableDeliveriesProvider.future),
        ref.read(driverDeliveriesProvider.future),
        ref.read(driverBusinessesProvider.future),
      ]);
    } catch (_) {
      // Each section displays its own error and retry action.
    }
  }

  void _invalidateDeliveryLists() {
    ref.invalidate(driverAvailableDeliveriesProvider);
    ref.invalidate(driverDeliveriesProvider);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _claimDelivery(String deliveryId) async {
    setState(() => _busyDeliveryIds.add(deliveryId));
    try {
      final position = await ref
          .read(driverLocationServiceProvider)
          .getCurrentPosition();
      if (!mounted) return;
      if (position == null) {
        _showMessage('Enable location access to claim a delivery.');
        return;
      }

      await ref
          .read(driverApiProvider)
          .claimDelivery(
            deliveryId,
            latitude: position.latitude,
            longitude: position.longitude,
          );
      _invalidateDeliveryLists();
      _showMessage('Delivery claimed.');
    } catch (error) {
      if (mounted) _showMessage('Could not claim delivery: $error');
    } finally {
      if (mounted) setState(() => _busyDeliveryIds.remove(deliveryId));
    }
  }

  Future<void> _runDeliveryAction(
    String deliveryId,
    Future<void> Function() action, {
    bool checkTrackingError = false,
  }) async {
    setState(() => _busyDeliveryIds.add(deliveryId));
    try {
      await action();
      if (checkTrackingError) {
        final error = ref
            .read(liveDeliveryControllerProvider(deliveryId))
            .error;
        if (error != null) throw StateError(error);
      }
      _invalidateDeliveryLists();
    } catch (error) {
      if (mounted) _showMessage('Could not update delivery: $error');
    } finally {
      if (mounted) setState(() => _busyDeliveryIds.remove(deliveryId));
    }
  }

  Widget _loadingSection(String title) => DriverDashboardSection(
    title: title,
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(child: CircularProgressIndicator()),
    ),
  );

  Widget _errorSection(String title, Object error, VoidCallback onRetry) =>
      DriverDashboardSection(
        title: title,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Could not load this section: $error',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              IconButton(
                tooltip: 'Retry $title',
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final available = ref.watch(driverAvailableDeliveriesProvider);
    final assigned = ref.watch(driverDeliveriesProvider);
    final businesses = ref.watch(driverBusinessesProvider);
    final availabilityData = available.asData?.value;
    final isWide = MediaQuery.sizeOf(context).width >= 1000;

    final availableSection = available.when(
      data: (data) => DriverDashboardSection(
        title: 'Available deliveries',
        count: '${data.deliveries.length}',
        child: data.deliveries.isEmpty
            ? const _EmptyMessage(
                message: 'No deliveries are available right now.',
              )
            : Column(
                children: [
                  for (final delivery in data.deliveries)
                    DriverDeliveryCard(
                      delivery: delivery,
                      kind: DriverDeliveryCardKind.available,
                      isBusy: _busyDeliveryIds.contains(delivery.id),
                      canClaim: data.availableSlots > 0,
                      onClaim: () => _claimDelivery(delivery.id),
                    ),
                ],
              ),
      ),
      loading: () => _loadingSection('Available deliveries'),
      error: (error, _) => _errorSection(
        'Available deliveries',
        error,
        () => ref.invalidate(driverAvailableDeliveriesProvider),
      ),
    );

    final assignedSection = assigned.when(
      data: (deliveries) => DriverDashboardSection(
        title: 'My deliveries',
        count: '${deliveries.length}',
        child: deliveries.isEmpty
            ? const _EmptyMessage(message: 'You have no assigned deliveries.')
            : Column(
                children: [
                  for (final delivery in deliveries)
                    Builder(
                      builder: (context) {
                        final tracking = ref.watch(
                          liveDeliveryControllerProvider(delivery.id),
                        );
                        final status = delivery.status.toLowerCase();
                        final isInProgress = status == 'in_progress';

                        return DriverDeliveryCard(
                          delivery: delivery,
                          kind: DriverDeliveryCardKind.assigned,
                          isBusy:
                              _busyDeliveryIds.contains(delivery.id) ||
                              tracking.isLoading,
                          isTracking: tracking.isSharing,
                          onOpen: () => context.push(
                            Uri(
                              path: '/track',
                              queryParameters: {'deliveryId': delivery.id},
                            ).toString(),
                          ),
                          onStart: status == 'assigned'
                              ? () => _runDeliveryAction(
                                  delivery.id,
                                  () => ref
                                      .read(
                                        liveDeliveryControllerProvider(
                                          delivery.id,
                                        ).notifier,
                                      )
                                      .start(),
                                  checkTrackingError: true,
                                )
                              : null,
                          onResume: isInProgress && !tracking.isSharing
                              ? () => _runDeliveryAction(
                                  delivery.id,
                                  () => ref
                                      .read(
                                        liveDeliveryControllerProvider(
                                          delivery.id,
                                        ).notifier,
                                      )
                                      .resume(),
                                  checkTrackingError: true,
                                )
                              : null,
                          onComplete: isInProgress
                              ? () => _runDeliveryAction(delivery.id, () async {
                                  if (tracking.isSharing) {
                                    await ref
                                        .read(
                                          liveDeliveryControllerProvider(
                                            delivery.id,
                                          ).notifier,
                                        )
                                        .stop();
                                  } else {
                                    await ref
                                        .read(driverApiProvider)
                                        .completeDelivery(delivery.id);
                                  }
                                }, checkTrackingError: tracking.isSharing)
                              : null,
                        );
                      },
                    ),
                ],
              ),
      ),
      loading: () => _loadingSection('My deliveries'),
      error: (error, _) => _errorSection(
        'My deliveries',
        error,
        () => ref.invalidate(driverDeliveriesProvider),
      ),
    );

    final businessesPanel = businesses.when(
      data: (items) => DriverBusinessesPanel(businesses: items),
      loading: () => _loadingSection('My businesses'),
      error: (error, _) => _errorSection(
        'My businesses',
        error,
        () => ref.invalidate(driverBusinessesProvider),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 1000
                ? 32.0
                : 18.0;
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                24,
                horizontalPadding,
                36,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DriverDashboardHeader(onRefresh: _refresh),
                        const SizedBox(height: 20),
                        DriverDashboardSummary(
                          activeDeliveryCount:
                              availabilityData?.activeDeliveryCount,
                          availableSlots: availabilityData?.availableSlots,
                        ),
                        const SizedBox(height: 18),

                        if (isWide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: assignedSection),
                              const SizedBox(width: 18),
                              Expanded(child: businessesPanel),
                            ],
                          )
                        else ...[
                          assignedSection,
                          const SizedBox(height: 18),
                          businessesPanel,
                        ],

                        const SizedBox(height: 18),
                        availableSection,
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    ),
  );
}
