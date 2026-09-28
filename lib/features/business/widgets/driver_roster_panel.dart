import 'package:flutter/material.dart';

import 'package:locora/features/business/widgets/dashboard_list_panel.dart';
import 'package:locora/features/driver/models/driver.dart';

class DriverRosterPanel extends StatelessWidget {
  const DriverRosterPanel({super.key, required this.drivers});

  final List<Driver> drivers;

  @override
  Widget build(BuildContext context) {
    return DashboardListPanel(
      title: 'Your drivers',
      count: '${drivers.length}',
      emptyMessage: 'No drivers have been added yet.',
      items: [
        for (final driver in drivers)
          DashboardInfoRow(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              child: Text(
                _initials(driver.name),
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            title: driver.name,
            detail: driver.phone,
          ),
      ],
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
      .join();
}
