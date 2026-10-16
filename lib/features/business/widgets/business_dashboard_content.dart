import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:locora/features/business/models/business_dashboard_data.dart';
import 'package:locora/features/business/models/business_profile.dart';
import 'package:locora/features/business/widgets/business_dashboard_header.dart';
import 'package:locora/features/business/widgets/business_dashboard_metrics.dart';
import 'package:locora/features/business/widgets/business_dashboard_sidebar.dart';
import 'package:locora/features/business/widgets/business_dashboard_top_bar.dart';
import 'package:locora/features/business/widgets/business_delivery_ledger.dart';
import 'package:locora/features/business/widgets/business_deliveries_content.dart';
import 'package:locora/features/business/widgets/business_drivers_content.dart';
import 'package:locora/features/business/widgets/business_settings_content.dart';
import 'package:locora/features/business/widgets/dispatch_queue_panel.dart';
import 'package:locora/features/business/widgets/driver_roster_panel.dart';

class BusinessDashboardContent extends StatefulWidget {
  const BusinessDashboardContent({
    super.key,
    required this.dashboard,
    required this.profile,
    required this.isProfileLoading,
    required this.profileError,
    required this.onRegenerateApiKey,
    required this.onRefresh,
  });

  final AsyncValue<BusinessDashboardData> dashboard;
  final BusinessProfile? profile;
  final bool isProfileLoading;
  final Object? profileError;
  final Future<String> Function() onRegenerateApiKey;
  final Future<void> Function() onRefresh;

  @override
  State<BusinessDashboardContent> createState() =>
      _BusinessDashboardContentState();
}

class _BusinessDashboardContentState extends State<BusinessDashboardContent> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _dashboardKey = GlobalKey();
  final GlobalKey _deliveriesKey = GlobalKey();
  final GlobalKey _driversKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();

  String _selectedSection = 'Dashboard';

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateTo(String section) {
    setState(() => _selectedSection = section);
    if (section == 'Settings' ||
        section == 'Dashboard' ||
        section == 'Drivers' ||
        section == 'Deliveries') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) _scrollController.jumpTo(0);
      });
      return;
    }

    final target = switch (section) {
      'Deliveries' => _deliveriesKey,
      _ => _dashboardKey,
    };
    final targetContext = target.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.02,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 920;
        final dashboardData = widget.dashboard.asData?.value;
        final colors = Theme.of(context).colorScheme;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: colors.surface,
          drawer: wide
              ? null
              : Drawer(
                  width: 276,
                  child: BusinessDashboardSidebar(
                    selectedSection: _selectedSection,
                    profile: widget.profile,
                    onNavigate: _navigateTo,
                    isDrawer: true,
                  ),
                ),
          body: Row(
            children: [
              if (wide)
                SizedBox(
                  width: 220,
                  child: BusinessDashboardSidebar(
                    selectedSection: _selectedSection,
                    profile: widget.profile,
                    onNavigate: _navigateTo,
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    BusinessDashboardTopBar(
                      profile: widget.profile,
                      isLoading: widget.isProfileLoading,
                      error: widget.profileError,
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: widget.onRefresh,
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            wide ? 30 : 18,
                            wide ? 28 : 20,
                            wide ? 30 : 18,
                            36,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 1320),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (_selectedSection == 'Settings')
                                    BusinessSettingsContent(
                                      profile: widget.profile,
                                      onRegenerateApiKey:
                                          widget.onRegenerateApiKey,
                                      onMenuTap: wide
                                          ? null
                                          : () => _scaffoldKey.currentState
                                                ?.openDrawer(),
                                    )
                                  else if (_selectedSection == 'Drivers')
                                    BusinessDriversContent(
                                      drivers:
                                          dashboardData?.drivers ?? const [],
                                      deliveries:
                                          dashboardData?.allDeliveries ??
                                          const [],
                                      isLoading: widget.dashboard.isLoading,
                                      error: widget.dashboard.hasError
                                          ? widget.dashboard.error
                                          : null,
                                      onMenuTap: wide
                                          ? null
                                          : () => _scaffoldKey.currentState
                                                ?.openDrawer(),
                                    )
                                  else if (_selectedSection == 'Deliveries')
                                    BusinessDeliveriesContent(
                                      deliveries:
                                          dashboardData?.allDeliveries ??
                                          const [],
                                      isLoading: widget.dashboard.isLoading,
                                      error: widget.dashboard.hasError
                                          ? widget.dashboard.error
                                          : null,
                                      onMenuTap: wide
                                          ? null
                                          : () => _scaffoldKey.currentState
                                                ?.openDrawer(),
                                    )
                                  else ...[
                                    KeyedSubtree(
                                      key: _dashboardKey,
                                      child: BusinessDashboardHeader(
                                        onRefresh: widget.onRefresh,
                                        onMenuTap: wide
                                            ? null
                                            : () => _scaffoldKey.currentState
                                                  ?.openDrawer(),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    if (dashboardData != null) ...[
                                      BusinessDashboardMetrics(
                                        totalDeliveries:
                                            dashboardData.allDeliveries.length,
                                        activeDeliveries: dashboardData
                                            .allDeliveries
                                            .where((delivery) {
                                              final status = delivery.status
                                                  .toLowerCase();
                                              return status == 'pending' ||
                                                  status == 'accepted' ||
                                                  status == 'in_transit';
                                            })
                                            .length,
                                        registeredDrivers:
                                            dashboardData.drivers.length,
                                        completedDeliveries: dashboardData
                                            .allDeliveries
                                            .where(
                                              (delivery) =>
                                                  delivery.status
                                                      .toLowerCase() ==
                                                  'completed',
                                            )
                                            .length,
                                      ),
                                      const SizedBox(height: 20),
                                      if (wide)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: DispatchQueuePanel(
                                                deliveries: dashboardData
                                                    .pendingDeliveries,
                                              ),
                                            ),
                                            const SizedBox(width: 18),
                                            Expanded(
                                              flex: 2,
                                              child: KeyedSubtree(
                                                key: _driversKey,
                                                child: DriverRosterPanel(
                                                  drivers:
                                                      dashboardData.drivers,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      else ...[
                                        DispatchQueuePanel(
                                          deliveries:
                                              dashboardData.pendingDeliveries,
                                        ),
                                        const SizedBox(height: 18),
                                        KeyedSubtree(
                                          key: _driversKey,
                                          child: DriverRosterPanel(
                                            drivers: dashboardData.drivers,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 20),
                                      KeyedSubtree(
                                        key: _deliveriesKey,
                                        child: BusinessDeliveryLedger(
                                          deliveries:
                                              dashboardData.allDeliveries,
                                        ),
                                      ),
                                    ] else if (widget.dashboard.isLoading) ...[
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 48,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                    ] else ...[
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: colors.surfaceContainerLowest,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Could not load dashboard data: '
                                          '${widget.dashboard.error}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(color: colors.error),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
