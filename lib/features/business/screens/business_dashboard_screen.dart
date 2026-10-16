import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/features/business/providers/business_providers.dart';
import 'package:locora/features/business/widgets/business_dashboard_content.dart';

class BusinessDashboardScreen extends ConsumerWidget {
  const BusinessDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(businessDashboardProvider);
    final profile = ref.watch(businessProfileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: BusinessDashboardContent(
        dashboard: dashboard,
        profile: profile.asData?.value,
        isProfileLoading: profile.isLoading,
        profileError: profile.hasError ? profile.error : null,
        onRegenerateApiKey: () =>
            ref.read(businessApiProvider).regenerateApiKey(),
        onRefresh: () async {
          ref.invalidate(businessDashboardProvider);
          ref.invalidate(businessProfileProvider);
          await ref.read(businessDashboardProvider.future);
        },
      ),
    );
  }
}
