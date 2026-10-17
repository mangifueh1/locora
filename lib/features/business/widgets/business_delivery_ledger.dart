import 'package:flutter/material.dart';

import 'package:locora/features/driver/models/delivery.dart';

class BusinessDeliveryLedger extends StatefulWidget {
  const BusinessDeliveryLedger({super.key, required this.deliveries});

  final List<Delivery> deliveries;

  @override
  State<BusinessDeliveryLedger> createState() => _BusinessDeliveryLedgerState();
}

class _BusinessDeliveryLedgerState extends State<BusinessDeliveryLedger> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final query = _searchController.text.trim().toLowerCase();
    final deliveries = widget.deliveries.where((delivery) {
      final status = delivery.status.toLowerCase();
      final matchesFilter = switch (_selectedFilter) {
        'Active' =>
          status == 'pending' || status == 'accepted' || status == 'in_transit',
        'Completed' => status == 'completed',
        'Cancelled' => status == 'cancelled',
        'Failed' => status == 'failed',
        _ => true,
      };
      final matchesSearch =
          query.isEmpty ||
          delivery.orderId.toLowerCase().contains(query) ||
          delivery.id.toLowerCase().contains(query) ||
          (delivery.businessName?.toLowerCase().contains(query) ?? false);
      return matchesFilter && matchesSearch;
    }).toList();
    final wide = MediaQuery.sizeOf(context).width >= 740;
    final filters = [
      ('All', widget.deliveries.length),
      (
        'Active',
        widget.deliveries.where((delivery) {
          final status = delivery.status.toLowerCase();
          return status == 'pending' ||
              status == 'accepted' ||
              status == 'in_transit';
        }).length,
      ),
      (
        'Completed',
        widget.deliveries
            .where((delivery) => delivery.status.toLowerCase() == 'completed')
            .length,
      ),
      (
        'Cancelled',
        widget.deliveries
            .where((delivery) => delivery.status.toLowerCase() == 'cancelled')
            .length,
      ),
      (
        'Failed',
        widget.deliveries
            .where((delivery) => delivery.status.toLowerCase() == 'failed')
            .length,
      ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 17, 18, 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 18,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 340,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Ledger & History',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Review and track your dispatched deliveries.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: wide ? 360 : double.infinity,
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search deliveries by order ID...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 19),
                    isDense: true,
                    filled: true,
                    fillColor: colors.surfaceContainerLow,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final filter in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: _LedgerFilter(
                      label: filter.$1,
                      count: filter.$2,
                      selected: _selectedFilter == filter.$1,
                      onTap: () => setState(() => _selectedFilter = filter.$1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: colors.surfaceContainer),
          if (deliveries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                widget.deliveries.isEmpty
                    ? 'No deliveries to show yet.'
                    : 'No deliveries match your search and filter.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 740) {
                  return Column(
                    children: [
                      for (final delivery in deliveries)
                        _CompactDeliveryRow(delivery: delivery),
                    ],
                  );
                }

                return DataTable(
                  headingRowHeight: 40,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 60,
                  horizontalMargin: 8,
                  columnSpacing: 24,
                  headingTextStyle: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                  columns: const [
                    DataColumn(
                      columnWidth: FlexColumnWidth(1.2),
                      label: Text('ORDER ID'),
                    ),
                    DataColumn(
                      columnWidth: FlexColumnWidth(1.4),
                      label: Text('BUSINESS'),
                    ),
                    DataColumn(
                      columnWidth: FlexColumnWidth(1),
                      label: Text('STATUS'),
                    ),
                    DataColumn(
                      columnWidth: FlexColumnWidth(1.4),
                      label: Text('LAST UPDATED'),
                    ),
                  ],
                  rows: [
                    for (final delivery in deliveries)
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              delivery.orderId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              delivery.businessName ?? '—',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(_DeliveryStatus(status: delivery.status)),
                          DataCell(
                            Text(
                              _formatTimestamp(delivery.updatedAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          const SizedBox(height: 10),
          Text(
            'Showing ${deliveries.length} of ${widget.deliveries.length} deliveries',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _LedgerFilter extends StatelessWidget {
  const _LedgerFilter({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primary : colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Text(
            '$label ($count)',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: selected ? colors.onPrimary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactDeliveryRow extends StatelessWidget {
  const _CompactDeliveryRow({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.surfaceContainer)),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined, size: 19, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.orderId,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  delivery.businessName ?? _formatTimestamp(delivery.updatedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _DeliveryStatus(status: delivery.status),
        ],
      ),
    );
  }
}

class _DeliveryStatus extends StatelessWidget {
  const _DeliveryStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final normalized = status.toLowerCase();
    final isComplete = normalized == 'completed';
    final isFailed = normalized == 'failed' || normalized == 'cancelled';
    final foreground = isComplete
        ? colors.secondary
        : isFailed
        ? colors.error
        : colors.primary;
    final background = isComplete
        ? colors.secondaryContainer.withValues(alpha: 0.55)
        : isFailed
        ? colors.errorContainer.withValues(alpha: 0.65)
        : colors.primary.withValues(alpha: 0.1);
    final label = switch (normalized) {
      'in_transit' => 'In transit',
      'pending' => 'Pending',
      'accepted' => 'Accepted',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      'failed' => 'Failed',
      _ => status.replaceAll('_', ' '),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _formatTimestamp(DateTime? timestamp) {
  if (timestamp == null) return '—';
  final local = timestamp.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return 'Today, $hour:$minute $period';
}
