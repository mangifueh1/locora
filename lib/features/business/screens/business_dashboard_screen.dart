import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/features/business/providers/business_providers.dart';
import 'package:locora/features/business/widgets/business_dashboard_content.dart';

class BusinessDashboardScreen extends ConsumerWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(businessDashboardProvider);
    final businessId = ref
        .watch(businessIdProvider)
        .when(
          data: (value) => value,
          loading: () => null,
          error: (error, stackTrace) => null,
        );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BusinessDashboardContent(
        dashboard: dashboard,
        businessId: businessId,
        onRegenerateApiKey: () =>
            ref.read(businessApiProvider).regenerateApiKey(),
        onRefresh: () async {
          ref.invalidate(businessDashboardProvider);
          ref.invalidate(businessIdProvider);
          await ref.read(businessDashboardProvider.future);
        },
      ),
    );
  }
}
