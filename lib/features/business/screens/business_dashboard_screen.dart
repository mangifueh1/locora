import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/features/business/providers/business_providers.dart';

class BusinessDashboardScreen extends ConsumerWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(businessDashboardProvider);
    final apiKey = ref
        .watch(businessApiKeyProvider)
        .when(
          data: (value) => value,
          loading: () => null,
          error: (error, stackTrace) => null,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Business dashboard')),
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Could not load dashboard: $error')),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(businessDashboardProvider);
            await ref.read(businessDashboardProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (apiKey != null) ...[
                const Text(
                  'Your API key',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SelectableText(apiKey),
                const SizedBox(height: 16),
              ],
              Text('Drivers: ${data.drivers.length}'),
              Text('Pending deliveries: ${data.pendingDeliveries.length}'),
            ],
          ),
        ),
      ),
    );
  }
}
