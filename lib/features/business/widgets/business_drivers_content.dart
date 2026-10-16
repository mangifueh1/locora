import 'package:flutter/material.dart';

import 'package:locora/features/business/widgets/dashboard_metric_card.dart';
import 'package:locora/features/driver/models/delivery.dart';
import 'package:locora/features/driver/models/driver.dart';

class BusinessDriversContent extends StatefulWidget {
  const BusinessDriversContent({
    super.key,
    required this.drivers,
    required this.deliveries,
    this.onMenuTap,
    this.isLoading = false,
    this.error,
  });

  final List<Driver> drivers;
  final List<Delivery> deliveries;
  final VoidCallback? onMenuTap;
  final bool isLoading;
  final Object? error;

  @override
  State<BusinessDriversContent> createState() => _BusinessDriversContentState();
}

class _BusinessDriversContentState extends State<BusinessDriversContent> {
  static const _pageSize = 6;
  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'All';
  int _page = 0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final matching = widget.drivers.where((driver) {
      final matchesSearch =
          query.isEmpty ||
          driver.name.toLowerCase().contains(query) ||
          driver.phone.toLowerCase().contains(query) ||
          driver.id.toLowerCase().contains(query);
      return matchesSearch && _matchesFilter(driver, _selectedFilter);
    }).toList();
    final pageCount = matching.isEmpty
        ? 1
        : (matching.length / _pageSize).ceil();
    final currentPage = _page.clamp(0, pageCount - 1);
    final startIndex = currentPage * _pageSize;
    final visibleDrivers = matching.skip(startIndex).take(_pageSize).toList();
    final onlineCount = widget.drivers
        .where((driver) => _driverStatus(driver) == 'online')
        .length;
    final deliveryCount = widget.deliveries.where((delivery) {
      final status = delivery.status.toLowerCase();
      return status == 'assigned' ||
          status == 'in_progress' ||
          status == 'in_transit';
    }).length;
    final availableCount = widget.drivers
        .where((driver) => _driverStatus(driver) == 'online')
        .length;
    final onDeliveryDriverCount = widget.drivers
        .where((driver) => _driverStatus(driver) == 'on_delivery')
        .length;
    final offlineCount = widget.drivers
        .where((driver) => _driverStatus(driver) == 'offline')
        .length;
    final disabledCount = widget.drivers
        .where((driver) => _driverStatus(driver) == 'disabled')
        .length;
    final counts = <String, String>{
      'All': '${widget.drivers.length}',
      'Online': _hasOnlineData ? '$onlineCount' : '—',
      'On Delivery': _hasStatusData ? '$onDeliveryDriverCount' : '—',
      'Offline': _hasOnlineData ? '$offlineCount' : '—',
      'Disabled': _hasStatusData ? '$disabledCount' : '—',
    };
    final colors = Theme.of(context).colorScheme;

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
                          text: 'DRIVERS',
                          style: TextStyle(color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Driver Fleet Management',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Manage your registered drivers and review fleet activity.',
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (widget.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Text(
              'Could not load driver data: ${widget.error}',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.error),
            ),
          )
        else ...[
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 850
                  ? 3
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;
              final gap = 12.0;
              final itemWidth =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;

              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: DashboardMetricCard(
                      label: 'Total registered',
                      value: '${widget.drivers.length}',
                      detail: 'Drivers on your fleet roster',
                      icon: Icons.groups_rounded,
                      accent: colors.primary,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: DashboardMetricCard(
                      label: 'Online & available',
                      value: _hasOnlineData ? '$availableCount' : '—',
                      detail: _hasOnlineData
                          ? 'Currently reporting online'
                          : 'Availability is not provided by the service',
                      icon: Icons.wifi_tethering_rounded,
                      accent: colors.secondary,
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: DashboardMetricCard(
                      label: 'On active delivery',
                      value: '$deliveryCount',
                      detail: 'Assigned or in progress',
                      icon: Icons.local_shipping_outlined,
                      accent: colors.primaryContainer,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 620;
                final search = SizedBox(
                  width: narrow ? constraints.maxWidth : 250,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() => _page = 0),
                    decoration: InputDecoration(
                      hintText: 'Search name, phone, or driver ID...',
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
                      for (final filter in counts.entries)
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: _DriverFilterChip(
                            label: filter.key,
                            count: filter.value,
                            selected: _selectedFilter == filter.key,
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter.key;
                                _page = 0;
                              });
                            },
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
          ),
          const SizedBox(height: 12),
          _DriverTable(drivers: visibleDrivers, showStatus: _hasStatusData),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  matching.isEmpty
                      ? 'No drivers match your search.'
                      : 'Showing ${startIndex + 1}–'
                            '${(startIndex + visibleDrivers.length)} of '
                            '${matching.length} drivers',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
              IconButton(
                tooltip: 'Previous page',
                onPressed: currentPage > 0
                    ? () => setState(() => _page = currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              if (pageCount <= 5)
                for (var page = 0; page < pageCount; page++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _PageButton(
                      page: page,
                      selected: page == currentPage,
                      onTap: () => setState(() => _page = page),
                    ),
                  )
              else
                Text('${currentPage + 1} / $pageCount'),
              IconButton(
                tooltip: 'Next page',
                onPressed: currentPage < pageCount - 1
                    ? () => setState(() => _page = currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
        ],
      ],
    );
  }

  bool get _hasOnlineData => widget.drivers.any(
    (driver) =>
        driver.load != null ||
        driver.isOnline != null ||
        const {
          'online',
          'available',
          'offline',
        }.contains(driver.status?.toLowerCase()),
  );

  bool get _hasStatusData => widget.drivers.any(
    (driver) =>
        driver.load != null ||
        driver.status != null ||
        driver.isOnline != null ||
        driver.activeDeliveryCount != null,
  );
}

class _DriverTable extends StatelessWidget {
  const _DriverTable({required this.drivers, required this.showStatus});

  final List<Driver> drivers;
  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 660;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (wide) _DriverTableHeader(showStatus: showStatus),
          if (drivers.isEmpty)
            Padding(
              padding: const EdgeInsets.all(28),
              child: Text(
                'No drivers found.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            )
          else
            for (final driver in drivers)
              _DriverRow(driver: driver, showStatus: showStatus, wide: wide),
        ],
      ),
    );
  }
}

class _DriverTableHeader extends StatelessWidget {
  const _DriverTableHeader({required this.showStatus});

  final bool showStatus;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        children: [
          const Expanded(flex: 5, child: _ColumnLabel('DRIVER & ID')),
          const Expanded(flex: 4, child: _ColumnLabel('PHONE')),
          if (showStatus)
            const Expanded(flex: 3, child: _ColumnLabel('STATUS')),
          const SizedBox(width: 76, child: _ColumnLabel('LOAD')),
        ],
      ),
    );
  }
}

class _ColumnLabel extends StatelessWidget {
  const _ColumnLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.35,
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({
    required this.driver,
    required this.showStatus,
    required this.wide,
  });

  final Driver driver;
  final bool showStatus;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = _driverStatus(driver);
    final statusStyle = _statusPresentation(context, status);
    final initials = _initials(driver.name);
    final driverReference = _driverReference(driver.id);

    if (!wide) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: colors.surfaceContainer)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _DriverAvatar(initials: initials),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driver.name,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        driverReference,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _StatusPill(label: statusStyle.$1, color: statusStyle.$2),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                const Icon(Icons.phone_outlined, size: 15),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    driver.phone,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                _LoadBadge(count: driver.load ?? driver.activeDeliveryCount),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 60),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.surfaceContainer)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Row(
              children: [
                _DriverAvatar(initials: initials),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        driver.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        driverReference,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall
                            ?.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              driver.phone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          if (showStatus)
            Expanded(
              flex: 3,
              child: _StatusPill(label: statusStyle.$1, color: statusStyle.$2),
            ),
          SizedBox(
            width: 76,
          child: Center(
            child: _LoadBadge(
              count: driver.load ?? driver.activeDeliveryCount,
            ),
          ),
          ),
        ],
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 31,
      height: 31,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        initials,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: colors.primary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _LoadBadge extends StatelessWidget {
  const _LoadBadge({required this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 30),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        count?.toString() ?? '—',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DriverFilterChip extends StatelessWidget {
  const _DriverFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: selected ? colors.primary : Colors.transparent,
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

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.selected,
    required this.onTap,
  });

  final int page;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '${page + 1}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: selected ? colors.onPrimary : colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

bool _matchesFilter(Driver driver, String filter) {
  final status = _driverStatus(driver);
  return switch (filter) {
    'Online' => status == 'online',
    'On Delivery' => status == 'on_delivery',
    'Offline' => status == 'offline',
    'Disabled' => status == 'disabled',
    _ => true,
  };
}

String _driverStatus(Driver driver) {
  final status = driver.status?.toLowerCase().replaceAll('-', '_');
  if (status == 'disabled' || status == 'suspended') return 'disabled';
  if (driver.load != null) return driver.load! > 0 ? 'online' : 'offline';
  if (status == 'on_delivery' || status == 'in_progress' || status == 'busy') {
    return 'on_delivery';
  }
  if (status == 'offline' || driver.isOnline == false) return 'offline';
  if (status == 'online' || status == 'available' || driver.isOnline == true) {
    return 'online';
  }
  if ((driver.activeDeliveryCount ?? 0) > 0) return 'on_delivery';
  return 'unknown';
}

(String, Color) _statusPresentation(BuildContext context, String status) {
  final colors = Theme.of(context).colorScheme;
  return switch (status) {
    'online' => ('Online', colors.secondary),
    'on_delivery' => ('On Delivery', colors.primary),
    'offline' => ('Offline', colors.outline),
    'disabled' => ('Disabled', colors.error),
    _ => ('Not reported', colors.onSurfaceVariant),
  };
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  return parts
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
      .join();
}

String _driverReference(String id) {
  final normalized = id.trim();
  if (normalized.length <= 12) return normalized;
  return '${normalized.substring(0, 8)}…';
}
