import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BusinessDashboardHeader extends StatelessWidget {
  const BusinessDashboardHeader({super.key, required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OPERAIONAL OVERVIEW',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hello There!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Here's what's happening with your deliveries today.",
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Back to home',
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.home_outlined),
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerLowest,
                foregroundColor: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Refresh dashboard',
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded),
              style: IconButton.styleFrom(
                backgroundColor: colors.surfaceContainerLowest,
                foregroundColor: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
