import 'package:flutter/material.dart';

import 'package:locora/features/business/widgets/dashboard_metric_card.dart';

class BusinessDashboardMetrics extends StatelessWidget {
  const BusinessDashboardMetrics({
    super.key,
    required this.totalDeliveries,
    required this.activeDeliveries,
    required this.registeredDrivers,
    required this.completedDeliveries,
  });

  final int totalDeliveries;
  final int activeDeliveries;
  final int registeredDrivers;
  final int completedDeliveries;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final metrics = [
      DashboardMetricCard(
        label: 'Total deliveries',
        value: '$totalDeliveries',
        detail: 'All delivery records',
        icon: Icons.local_shipping_outlined,
        accent: colors.primary,
      ),
      DashboardMetricCard(
        label: 'Active deliveries',
        value: '$activeDeliveries',
        detail: 'Pending dispatch',
        icon: Icons.route_outlined,
        accent: colors.primaryContainer,
      ),
      DashboardMetricCard(
        label: 'Registered drivers',
        value: '$registeredDrivers',
        detail: 'On your roster',
        icon: Icons.badge_outlined,
        accent: colors.secondary,
      ),
      DashboardMetricCard(
        label: 'Completed deliveries',
        value: '$completedDeliveries',
        detail: 'Successfully fulfilled',
        icon: Icons.check_circle_outline_rounded,
        accent: colors.secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 900
            ? 4
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final gap = 12.0;
        final itemWidth =
            (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final metric in metrics)
              SizedBox(width: itemWidth, child: metric),
          ],
        );
      },
    );
  }
}
