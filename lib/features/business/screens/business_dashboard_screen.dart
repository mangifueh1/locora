import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/features/business/providers/business_providers.dart';
import 'package:locora/features/business/widgets/business_dashboard_content.dart';

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
    final businessId = businessIdFromApiKey(apiKey);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: dashboard.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Could not load dashboard: $error'),
          ),
        ),
        data: (data) => BusinessDashboardContent(
          data: data,
          businessId: businessId,
          apiKey: apiKey,
          onRefresh: () async {
            ref.invalidate(businessDashboardProvider);
            await ref.read(businessDashboardProvider.future);
          },
        ),
      ),
    );
  }
}
