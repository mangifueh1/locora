import 'package:flutter/material.dart';

import 'package:locora/features/business/models/business_dashboard_data.dart';
import 'package:locora/features/business/widgets/business_api_key_panel.dart';
import 'package:locora/features/business/widgets/business_dashboard_header.dart';
import 'package:locora/features/business/widgets/dashboard_metric_card.dart';
import 'package:locora/features/business/widgets/dispatch_queue_panel.dart';
import 'package:locora/features/business/widgets/driver_roster_panel.dart';

class BusinessDashboardContent extends StatelessWidget {
  const BusinessDashboardContent({
    super.key,
    required this.data,
    required this.businessId,
    required this.apiKey,
    required this.onRefresh,
  });

  final BusinessDashboardData data;
  final String? businessId;
  final String? apiKey;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          final horizontalPadding = constraints.maxWidth >= 1000 ? 32.0 : 20.0;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              28,
              horizontalPadding,
              36,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BusinessDashboardHeader(onRefresh: onRefresh),
                    const SizedBox(height: 26),
                    BusinessApiKeyPanel(businessId: businessId, apiKey: apiKey),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final metrics = [
                          DashboardMetricCard(
                            label: 'Registered drivers',
                            value: '${data.drivers.length}',
                            detail: 'Drivers on your roster',
                            icon: Icons.badge_outlined,
                            accent: Theme.of(context).colorScheme.primary,
                          ),
                          DashboardMetricCard(
                            label: 'Pending deliveries',
                            value: '${data.pendingDeliveries.length}',
                            detail: 'Waiting in the dispatch queue',
                            icon: Icons.pending_actions_rounded,
                            accent: Theme.of(context).colorScheme.secondary,
                          ),
                        ];

                        if (constraints.maxWidth < 560) {
                          return Column(
                            children: [
                              metrics[0],
                              const SizedBox(height: 12),
                              metrics[1],
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: metrics[0]),
                            const SizedBox(width: 14),
                            Expanded(child: metrics[1]),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DriverRosterPanel(drivers: data.drivers),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: DispatchQueuePanel(
                              deliveries: data.pendingDeliveries,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      DriverRosterPanel(drivers: data.drivers),
                      const SizedBox(height: 18),
                      DispatchQueuePanel(deliveries: data.pendingDeliveries),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
