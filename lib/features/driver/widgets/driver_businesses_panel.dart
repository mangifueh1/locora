import 'package:flutter/material.dart';

import 'package:locora/features/driver/models/driver_business.dart';
import 'package:locora/features/driver/widgets/driver_dashboard_section.dart';

class DriverBusinessesPanel extends StatelessWidget {
  const DriverBusinessesPanel({super.key, required this.businesses});

  final List<DriverBusiness> businesses;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DriverDashboardSection(
      title: 'My businesses',
      count: '${businesses.length}',
      child: businesses.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'You are not linked to any businesses yet.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            )
          : Column(
              children: [
                for (final business in businesses)
                  Container(
                    constraints: const BoxConstraints(minHeight: 62),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colors.surfaceContainer,
                          width: 0.8,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: colors.secondaryContainer.withValues(
                            alpha: 0.45,
                          ),
                          child: Icon(
                            Icons.storefront_outlined,
                            size: 18,
                            color: colors.secondary,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                business.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                business.id,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
