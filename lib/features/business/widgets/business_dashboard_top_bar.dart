import 'package:flutter/material.dart';

import 'package:locora/features/business/models/business_profile.dart';

class BusinessDashboardTopBar extends StatelessWidget {
  const BusinessDashboardTopBar({
    super.key,
    required this.profile,
    this.isLoading = false,
    this.error,
  });

  final BusinessProfile? profile;
  final bool isLoading;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final businessName = profile?.name ?? 'Business account';
    final businessId = profile?.id;
    final initials = _initials(businessName);

    return Container(
      width: double.infinity,
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: colors.surfaceContainer, width: 1),
        ),
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 1,
                height: 38,
                color: colors.surfaceContainer,
                margin: const EdgeInsets.only(right: 12),
              ),
              CircleAvatar(
                radius: 16,
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      error != null
                          ? 'Could not load business profile'
                          : isLoading
                          ? 'Loading business profile...'
                          : businessId ?? 'Business ID unavailable',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: error != null ? colors.error : colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  final initials = parts
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part[0].toUpperCase())
      .join();
  return initials.isEmpty ? 'B' : initials;
}
