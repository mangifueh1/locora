import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:locora/shared/theme/app_colors.dart';
import 'package:locora/shared/widgets/buttons.dart';

class ContactCta extends StatelessWidget {
  const ContactCta({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    return Container(
      padding: compact
          ? const EdgeInsets.all(16)
          : EdgeInsets.symmetric(horizontal: 25, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _ContactCtaCopy(),
                const SizedBox(height: 14),
                PrimaryButton(
                  height: 42,
                  label: 'Get Started',
                  onPressed: () => context.go('/business/register'),
                  suffixIcon: const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const Expanded(child: _ContactCtaCopy()),
                PrimaryButton(
                  width: 115,
                  height: 34,
                  label: 'Get Started',
                  labelSize: 8,
                  onPressed: () => context.go('/business/register'),
                  suffixIcon: Icon(
                    Icons.arrow_forward,
                    size: 12,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
    );
  }
}

class _ContactCtaCopy extends StatelessWidget {
  const _ContactCtaCopy();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Ready to simplify delivery?',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.onSurface,
        ),
      ),
      SizedBox(height: 3),
      Text(
        'Coordinate exact drop-offs and integrate precision waypoint verification in minutes.',
        style: TextStyle(fontSize: 9, color: AppColors.onSurfaceVariant),
      ),
    ],
  );
}
