import 'package:flutter/material.dart';

import 'package:locora/features/business/widgets/dashboard_list_panel.dart';
import 'package:locora/features/driver/models/delivery.dart';

class DispatchQueuePanel extends StatelessWidget {
  const DispatchQueuePanel({super.key, required this.deliveries});

  final List<Delivery> deliveries;

  @override
  Widget build(BuildContext context) {
    return DashboardListPanel(
      title: 'Dispatch queue',
      count: '${deliveries.length}',
      emptyMessage: 'Your dispatch queue is clear.',
      items: [
        for (final delivery in deliveries)
          DashboardInfoRow(
            leading: Icon(
              Icons.local_shipping_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: delivery.orderId,
            detail: 'Pending dispatch',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
      ],
    );
  }
}
