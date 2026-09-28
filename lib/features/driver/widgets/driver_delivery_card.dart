import 'package:flutter/material.dart';

import 'package:locora/features/driver/models/delivery.dart';

enum DriverDeliveryCardKind { available, assigned }

class DriverDeliveryCard extends StatelessWidget {
  const DriverDeliveryCard({
    super.key,
    required this.delivery,
    required this.kind,
    this.isBusy = false,
    this.canClaim = false,
    this.isTracking = false,
    this.onClaim,
    this.onStart,
    this.onResume,
    this.onComplete,
    this.onOpen,
  });

  final Delivery delivery;
  final DriverDeliveryCardKind kind;
  final bool isBusy;
  final bool canClaim;
  final bool isTracking;
  final VoidCallback? onClaim;
  final VoidCallback? onStart;
  final VoidCallback? onResume;
  final VoidCallback? onComplete;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final normalizedStatus = delivery.status.replaceAll('_', ' ');
    final statusColor = switch (delivery.status.toLowerCase()) {
      'pending' => colors.tertiary,
      'assigned' => colors.primary,
      'in_progress' => colors.secondary,
      'delivered' => colors.onSurfaceVariant,
      _ => colors.outline,
    };

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.surfaceContainer, width: 0.8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: colors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.orderId,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      delivery.businessName ?? 'Business delivery',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _DeliveryStatus(label: normalizedStatus, color: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: _actions(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    if (kind == DriverDeliveryCardKind.available) {
      return [
        FilledButton.icon(
          onPressed: canClaim && !isBusy ? onClaim : null,
          icon: isBusy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.add_rounded, size: 18),
          label: Text(canClaim ? 'Claim delivery' : 'No slots available'),
        ),
      ];
    }

    final actions = <Widget>[];
    if (onStart != null) {
      actions.add(
        FilledButton.icon(
          onPressed: isBusy ? null : onStart,
          icon: isBusy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text('Start delivery'),
        ),
      );
    }
    if (onResume != null) {
      actions.add(
        FilledButton.icon(
          onPressed: isBusy ? null : onResume,
          icon: isBusy
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded, size: 18),
          label: const Text('Resume tracking'),
        ),
      );
    }
    if (onComplete != null) {
      actions.add(
        OutlinedButton.icon(
          onPressed: isBusy ? null : onComplete,
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Mark delivered'),
        ),
      );
    }
    if (onOpen != null) {
      actions.add(
        TextButton.icon(
          onPressed: onOpen,
          icon: const Icon(Icons.map_outlined, size: 18),
          label: const Text('Details'),
        ),
      );
    }
    return actions;
  }
}

class _DeliveryStatus extends StatelessWidget {
  const _DeliveryStatus({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(maxWidth: 120),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: color, fontWeight: FontWeight.w700),
    ),
  );
}
