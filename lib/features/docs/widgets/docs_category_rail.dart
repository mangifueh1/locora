import 'package:flutter/material.dart';

import '../models/api_endpoint.dart';

class DocsCategoryRail extends StatelessWidget {
  const DocsCategoryRail({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final ApiEndpointCategory selected;
  final ValueChanged<ApiEndpointCategory> onSelected;

  static const _labels = {
    ApiEndpointCategory.business: 'Business',
    ApiEndpointCategory.driver: 'Driver',
    ApiEndpointCategory.delivery: 'Delivery',
    ApiEndpointCategory.customer: 'Customer',
    ApiEndpointCategory.health: 'Health',
    ApiEndpointCategory.realtime: 'Realtime',
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontal = constraints.maxWidth > constraints.maxHeight;
        final items = ApiEndpointCategory.values.map((category) {
          final active = category == selected;
          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: horizontal ? 8 : 0,
              bottom: horizontal ? 0 : 4,
            ),
            child: InkWell(
              onTap: () => onSelected(category),
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFE5F3F0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: horizontal
                      ? MainAxisSize.min
                      : MainAxisSize.max,
                  children: [
                    Icon(
                      _iconFor(category),
                      size: 16,
                      color: active
                          ? const Color(0xFF176B5B)
                          : const Color(0xFF737C7B),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      _labels[category]!,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active
                            ? const Color(0xFF174E45)
                            : const Color(0xFF535C5B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList();
        if (horizontal) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: items),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: items,
        );
      },
    );
  }

  IconData _iconFor(ApiEndpointCategory category) => switch (category) {
    ApiEndpointCategory.business => Icons.storefront_outlined,
    ApiEndpointCategory.driver => Icons.local_shipping_outlined,
    ApiEndpointCategory.delivery => Icons.inventory_2_outlined,
    ApiEndpointCategory.customer => Icons.person_outline,
    ApiEndpointCategory.health => Icons.monitor_heart_outlined,
    ApiEndpointCategory.realtime => Icons.sensors_outlined,
  };
}
