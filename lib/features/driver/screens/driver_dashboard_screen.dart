
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/features/driver/providers/driver_providers.dart';

class DriverDashboardScreen extends ConsumerWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveries = ref.watch(driverDeliveriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My deliveries')),
      body: deliveries.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Could not load deliveries: $error'),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('No deliveries assigned yet.'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(driverDeliveriesProvider);
              await ref.read(driverDeliveriesProvider.future);
            },
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final delivery = items[index];

                return ListTile(
                  title: Text(
                    '${delivery.businessName ?? 'Business'} — '
                    'Order ${delivery.orderId}',
                  ),
                  subtitle: Text('Status: ${delivery.status}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.pushNamed(
                      '/driver/deliveries/${delivery.id}',
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

