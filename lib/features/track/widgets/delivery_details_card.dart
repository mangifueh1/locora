import 'package:flutter/material.dart';

class DeliveryDetailsCard extends StatefulWidget {
  const DeliveryDetailsCard({
    super.key,
    required this.deliveryId,
    required this.orderId,
    required this.status,
    required this.businessName,
    required this.assignment,
    required this.updatedAt,
    required this.isDriver,
  });

  final String deliveryId;
  final String orderId;
  final String status;
  final String businessName;
  final String assignment;
  final DateTime? updatedAt;
  final bool isDriver;

  @override
  State<DeliveryDetailsCard> createState() => _DeliveryDetailsCardState();
}

class _DeliveryDetailsCardState extends State<DeliveryDetailsCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              button: true,
              expanded: _isExpanded,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          widget.businessName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusChip(label: widget.status.replaceAll('_', ' ')),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              child: _isExpanded
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        _DetailRow(label: 'Order', value: widget.orderId),
                        _DetailRow(label: 'Delivery', value: widget.deliveryId),
                        if (!widget.isDriver)
                          _DetailRow(label: 'Driver', value: widget.assignment),
                        if (widget.updatedAt != null)
                          _DetailRow(
                            label: 'Last updated',
                            value: widget.updatedAt!.toLocal().toString(),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          !widget.isDriver &&
                                  widget.assignment == 'still_to_be_assigned'
                              ? 'Waiting for a driver to be assigned.'
                              : 'The map shows the delivery location and latest driver position.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Text(value, overflow: TextOverflow.ellipsis)),
      ],
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      visualDensity: VisualDensity.compact,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      side: BorderSide.none,
    );
  }
}
