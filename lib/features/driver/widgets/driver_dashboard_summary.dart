import 'package:flutter/material.dart';

class DriverDashboardSummary extends StatelessWidget {
  const DriverDashboardSummary({
    super.key,
    required this.activeDeliveryCount,
    required this.availableSlots,
  });

  final int? activeDeliveryCount;
  final int? availableSlots;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final cards = [
      _SummaryCard(
        label: 'Active deliveries',
        value: activeDeliveryCount?.toString() ?? '—',
        detail: 'Your current workload',
        icon: Icons.route_outlined,
        accent: colors.primary,
      ),
      _SummaryCard(
        label: 'Available slots',
        value: availableSlots?.toString() ?? '—',
        detail: 'Maximum 2 active deliveries',
        icon: Icons.add_task_rounded,
        accent: colors.secondary,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [cards[0], const SizedBox(height: 12), cards[1]],
          );
        }
        return Row(
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 14),
            Expanded(child: cards[1]),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(icon, color: accent, size: 23),
        ],
      ),
    );
  }
}
