import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:locora/features/business/widgets/dashboard_metric_card.dart';
import 'package:locora/features/driver/models/delivery.dart';

class BusinessDeliveriesContent extends StatefulWidget {
  const BusinessDeliveriesContent({
    super.key,
    required this.deliveries,
    this.onMenuTap,
    this.isLoading = false,
    this.error,
  });

  final List<Delivery> deliveries;
  final VoidCallback? onMenuTap;
  final bool isLoading;
  final Object? error;

  @override
  State<BusinessDeliveriesContent> createState() =>
      _BusinessDeliveriesContentState();
}

class _BusinessDeliveriesContentState extends State<BusinessDeliveriesContent> {
  static const _pageSize = 6;
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  String? _selectedDeliveryId;
  int _page = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final deliveries = [...widget.deliveries]
      ..sort((first, second) {
        final firstDate = first.updatedAt;
        final secondDate = second.updatedAt;
        if (firstDate == null || secondDate == null) {
          if (firstDate == null && secondDate == null) return 0;
          return firstDate == null ? 1 : -1;
        }
        return secondDate.compareTo(firstDate);
      });
    final active = deliveries.where(_isActive).length;
    final completed = deliveries
        .where((delivery) => _normalizedStatus(delivery) == 'delivered')
        .length;
    final query = _searchController.text.trim().toLowerCase();
    final matching = deliveries.where((delivery) {
      final matchesFilter = switch (_selectedFilter) {
        'Active' => _isActive(delivery),
        'Completed' => _normalizedStatus(delivery) == 'delivered',
        _ => true,
      };
      final matchesQuery =
          query.isEmpty ||
          delivery.orderId.toLowerCase().contains(query) ||
          delivery.id.toLowerCase().contains(query) ||
          (delivery.businessName?.toLowerCase().contains(query) ?? false) ||
          (delivery.customerPhone?.toLowerCase().contains(query) ?? false) ||
          (delivery.driverName?.toLowerCase().contains(query) ?? false);
      return matchesFilter && matchesQuery;
    }).toList();
    final pageCount = matching.isEmpty
        ? 1
        : (matching.length / _pageSize).ceil();
    final page = _page.clamp(0, pageCount - 1);
    final start = page * _pageSize;
    final pageDeliveries = matching.skip(start).take(_pageSize).toList();
    final selected = matching.where(
      (delivery) => delivery.id == _selectedDeliveryId,
    );
    final selectedDelivery = selected.isNotEmpty
        ? selected.first
        : pageDeliveries.firstOrNull;
    final wide = MediaQuery.sizeOf(context).width >= 1080;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.onMenuTap != null) ...[
              IconButton(
                tooltip: 'Open navigation sidebar',
                onPressed: widget.onMenuTap,
                icon: const Icon(Icons.menu_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colors.surfaceContainerLowest,
                  foregroundColor: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                      children: [
                        const TextSpan(text: 'OPERATIONS  ›  '),
                        TextSpan(
                          text: 'DELIVERIES',
                          style: TextStyle(color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Deliveries Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Search, inspect, and filter your dispatched deliveries.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Text(
              'Could not load delivery data: ${widget.error}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.error),
            ),
          )
        else ...[
          _DeliveryMetrics(
            total: deliveries.length,
            active: active,
            completed: completed,
          ),
          const SizedBox(height: 16),
          _DeliveryFilters(
            controller: _searchController,
            filter: _selectedFilter,
            allCount: deliveries.length,
            activeCount: active,
            completedCount: completed,
            onSearchChanged: () => setState(() => _page = 0),
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
                _page = 0;
              });
            },
          ),
          const SizedBox(height: 14),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: _DeliveryRecords(
                    deliveries: pageDeliveries,
                    selectedId: selectedDelivery?.id,
                    totalCount: deliveries.length,
                    matchingCount: matching.length,
                    startIndex: start,
                    currentPage: page,
                    pageCount: pageCount,
                    onSelect: (delivery) {
                      setState(() => _selectedDeliveryId = delivery.id);
                    },
                    onPageChanged: (nextPage) {
                      setState(() {
                        _page = nextPage;
                        if (nextPage != page) _selectedDeliveryId = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 5,
                  child: selectedDelivery == null
                      ? const _NoDeliverySelected()
                      : _DeliveryDetailPanel(delivery: selectedDelivery),
                ),
              ],
            )
          else ...[
            _DeliveryRecords(
              deliveries: pageDeliveries,
              selectedId: selectedDelivery?.id,
              totalCount: deliveries.length,
              matchingCount: matching.length,
              startIndex: start,
              currentPage: page,
              pageCount: pageCount,
              onSelect: (delivery) {
                setState(() => _selectedDeliveryId = delivery.id);
              },
              onPageChanged: (nextPage) {
                setState(() {
                  _page = nextPage;
                  if (nextPage != page) _selectedDeliveryId = null;
                });
              },
            ),
            const SizedBox(height: 14),
            if (selectedDelivery == null)
              const _NoDeliverySelected()
            else
              _DeliveryDetailPanel(delivery: selectedDelivery),
          ],
        ],
      ],
    );
  }
}

class _DeliveryMetrics extends StatelessWidget {
  const _DeliveryMetrics({
    required this.total,
    required this.active,
    required this.completed,
  });

  final int total;
  final int active;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 850
            ? 3
            : constraints.maxWidth >= 520
            ? 2
            : 1;
        final gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            SizedBox(
              width: width,
              child: DashboardMetricCard(
                label: 'Total deliveries',
                value: '$total',
                detail: 'All delivery records',
                icon: Icons.local_shipping_outlined,
                accent: colors.primary,
              ),
            ),
            SizedBox(
              width: width,
              child: DashboardMetricCard(
                label: 'Active deliveries',
                value: '$active',
                detail: 'Assigned or in progress',
                icon: Icons.route_outlined,
                accent: colors.primaryContainer,
              ),
            ),
            SizedBox(
              width: width,
              child: DashboardMetricCard(
                label: 'Completed',
                value: '$completed',
                detail: total == 0
                    ? 'No deliveries recorded'
                    : '${(completed * 100 / total).round()}% of deliveries',
                icon: Icons.check_circle_outline_rounded,
                accent: colors.secondary,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DeliveryFilters extends StatelessWidget {
  const _DeliveryFilters({
    required this.controller,
    required this.filter,
    required this.allCount,
    required this.activeCount,
    required this.completedCount,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final String filter;
  final int allCount;
  final int activeCount;
  final int completedCount;
  final VoidCallback onSearchChanged;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final options = [
      ('All', allCount),
      ('Active', activeCount),
      ('Completed', completedCount),
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final search = SizedBox(
            width: narrow ? constraints.maxWidth : 280,
            child: TextField(
              controller: controller,
              onChanged: (_) => onSearchChanged(),
              decoration: InputDecoration(
                hintText: 'Search by order ID, landmark, or courier...',
                prefixIcon: const Icon(Icons.search_rounded, size: 19),
                isDense: true,
                filled: true,
                fillColor: colors.surfaceContainerLow,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: colors.outlineVariant),
                ),
              ),
            ),
          );
          final filters = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final option in options)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _DeliveryFilterChip(
                      label: option.$1,
                      count: option.$2,
                      selected: filter == option.$1,
                      onTap: () => onFilterChanged(option.$1),
                    ),
                  ),
              ],
            ),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [search, const SizedBox(height: 10), filters],
            );
          }
          return Row(
            children: [
              search,
              const SizedBox(width: 12),
              Expanded(child: filters),
            ],
          );
        },
      ),
    );
  }
}

class _DeliveryRecords extends StatelessWidget {
  const _DeliveryRecords({
    required this.deliveries,
    required this.selectedId,
    required this.totalCount,
    required this.matchingCount,
    required this.startIndex,
    required this.currentPage,
    required this.pageCount,
    required this.onSelect,
    required this.onPageChanged,
  });

  final List<Delivery> deliveries;
  final String? selectedId;
  final int totalCount;
  final int matchingCount;
  final int startIndex;
  final int currentPage;
  final int pageCount;
  final ValueChanged<Delivery> onSelect;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 700;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'CONSIGNMENT RECORDS',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),
                Text(
                  'Page ${currentPage + 1} of $pageCount',
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (wide)
            Container(
              color: colors.surfaceContainerLow,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              child: Row(
                children: const [
                  Expanded(flex: 3, child: _RecordsColumnLabel('ORDER ID')),
                  Expanded(flex: 4, child: _RecordsColumnLabel('RECIPIENT')),
                  Expanded(flex: 3, child: _RecordsColumnLabel('COURIER')),
                  Expanded(flex: 3, child: _RecordsColumnLabel('STATUS')),
                ],
              ),
            ),
          if (deliveries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                totalCount == 0
                    ? 'No deliveries have been created yet.'
                    : 'No deliveries match your search and filter.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            )
          else
            for (final delivery in deliveries)
              _DeliveryRecordRow(
                delivery: delivery,
                selected: delivery.id == selectedId,
                wide: wide,
                onTap: () => onSelect(delivery),
              ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 11),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    matchingCount == 0
                        ? 'Showing 0 of $totalCount deliveries'
                        : 'Showing ${startIndex + 1}–'
                              '${startIndex + deliveries.length} of '
                              '$matchingCount deliveries',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ),
                IconButton(
                  tooltip: 'Previous page',
                  visualDensity: VisualDensity.compact,
                  onPressed: currentPage > 0
                      ? () => onPageChanged(currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Text(
                  '${currentPage + 1}',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  tooltip: 'Next page',
                  visualDensity: VisualDensity.compact,
                  onPressed: currentPage < pageCount - 1
                      ? () => onPageChanged(currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordsColumnLabel extends StatelessWidget {
  const _RecordsColumnLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _DeliveryRecordRow extends StatelessWidget {
  const _DeliveryRecordRow({
    required this.delivery,
    required this.selected,
    required this.wide,
    required this.onTap,
  });

  final Delivery delivery;
  final bool selected;
  final bool wide;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = _statusLabel(delivery.status);
    final statusColor = _statusColor(context, delivery.status);

    return Material(
      color: selected ? colors.primary.withValues(alpha: 0.045) : null,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 59),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.surfaceContainer)),
          ),
          child: wide
              ? Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        delivery.orderId,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: _RecordText(
                        title:
                            delivery.customerPhone ?? 'Recipient unavailable',
                        detail: delivery.customerLandmark,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _RecordText(
                        title: delivery.driverName ?? 'Unassigned',
                        detail: delivery.driverPhone,
                        titleColor: delivery.driverName == null
                            ? colors.error
                            : null,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _DeliveryStatusPill(
                        label: status,
                        color: statusColor,
                      ),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _RecordText(
                        title: delivery.orderId,
                        detail:
                            delivery.businessName ?? 'Recipient unavailable',
                        titleColor: colors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _DeliveryStatusPill(label: status, color: statusColor),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RecordText extends StatelessWidget {
  const _RecordText({required this.title, this.detail, this.titleColor});

  final String title;
  final String? detail;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: titleColor ?? colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (detail != null && detail!.isNotEmpty)
          Text(
            detail!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _DeliveryDetailPanel extends StatelessWidget {
  const _DeliveryDetailPanel({required this.delivery});

  final Delivery delivery;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = _statusLabel(delivery.status);
    final statusColor = _statusColor(context, delivery.status);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: colors.surfaceContainer),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    color: colors.primary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.orderId,
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Updated ${_formatDate(delivery.updatedAt)}',
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _DeliveryStatusPill(label: status, color: statusColor),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_nonEmpty(delivery.customerPhone) != null) ...[
                  const SizedBox(height: 13),
                  _DetailSection(
                    label: 'RECIPIENT NUMBER',
                    icon: Icons.phone_outlined,
                    child: SelectableText(
                      delivery.customerPhone!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (_nonEmpty(delivery.customerLandmark) != null) ...[
                  const SizedBox(height: 13),
                  _DetailSection(
                    label: 'DELIVERY LANDMARK',
                    icon: Icons.location_on_outlined,
                    child: Text(
                      delivery.customerLandmark!,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
                if (delivery.customerLat != null &&
                    delivery.customerLng != null) ...[
                  const SizedBox(height: 13),
                  _CoordinateCard(
                    latitude: delivery.customerLat!,
                    longitude: delivery.customerLng!,
                  ),
                ],
                const SizedBox(height: 13),
                _DetailSection(
                  label: 'ASSIGNED COURIER',
                  icon: Icons.badge_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.driverName ?? 'No courier assigned',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: delivery.driverName == null
                              ? colors.error
                              : null,
                        ),
                      ),
                      if (_nonEmpty(delivery.driverPhone) != null)
                        Text(
                          delivery.driverPhone!,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colors.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 13),
                _DetailSection(
                  label: 'DELIVERY RECORD ID',
                  icon: Icons.tag_rounded,
                  child: SelectableText(
                    delivery.id,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
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

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.label,
    required this.icon,
    required this.child,
  });

  final String label;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: colors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Padding(padding: const EdgeInsets.only(left: 20), child: child),
      ],
    );
  }
}

class _CoordinateCard extends StatelessWidget {
  const _CoordinateCard({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Future<void> _copy(BuildContext context) async {
    final coordinates =
        '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    await Clipboard.setData(ClipboardData(text: coordinates));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Coordinates copied')));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Icon(Icons.my_location_rounded, size: 15, color: colors.primary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              '${latitude.toStringAsFixed(5)}, '
              '${longitude.toStringAsFixed(5)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copy coordinates',
            visualDensity: VisualDensity.compact,
            onPressed: () => _copy(context),
            icon: const Icon(Icons.copy_rounded, size: 15),
          ),
        ],
      ),
    );
  }
}

class _DeliveryStatusPill extends StatelessWidget {
  const _DeliveryStatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(14),
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
}

class _DeliveryFilterChip extends StatelessWidget {
  const _DeliveryFilterChip({
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
      borderRadius: BorderRadius.circular(5),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

class _NoDeliverySelected extends StatelessWidget {
  const _NoDeliverySelected();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 180),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Select a delivery record to view its details.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: colors.onSurfaceVariant),
      ),
    );
  }
}

bool _isActive(Delivery delivery) {
  final status = _normalizedStatus(delivery);
  return status == 'pending' ||
      status == 'accepted' ||
      status == 'assigned' ||
      status == 'in_transit' ||
      status == 'in_progress';
}

String _normalizedStatus(Delivery delivery) =>
    delivery.status.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');

String _statusLabel(String status) {
  final normalized = status.toLowerCase().replaceAll('_', ' ');
  return normalized
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

Color _statusColor(BuildContext context, String status) {
  final colors = Theme.of(context).colorScheme;
  return switch (status.toLowerCase().replaceAll('-', '_')) {
    'completed' || 'delivered' => colors.secondary,
    'failed' || 'cancelled' || 'canceled' => colors.error,
    'pending' || 'pending_driver' => colors.tertiary,
    'accepted' || 'assigned' || 'in_transit' || 'in_progress' => colors.primary,
    _ => colors.onSurfaceVariant,
  };
}

String _formatDate(DateTime? date) {
  if (date == null) return 'time unavailable';
  final local = date.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '${local.year}-${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')} · $hour:$minute $period';
}

String? _nonEmpty(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
