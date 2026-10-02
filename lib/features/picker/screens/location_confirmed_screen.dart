import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:locora/shared/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationConfirmedScreen extends StatelessWidget {
  const LocationConfirmedScreen({super.key, this.token, this.trackingLink});

  final String? token;
  final String? trackingLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasTrackingLink = (trackingLink ?? '').trim().isNotEmpty;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: AppColors.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Location confirmed',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'This location will be saved for future purchases.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (hasTrackingLink) ...[
                        const Divider(),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () =>
                              _openTrackingLink(context, trackingLink!),
                          icon: const Icon(Icons.route_outlined),
                          label: const Text('Track your delivery here'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openTrackingLink(
    BuildContext context,
    String trackingLink,
  ) async {
    final uri = Uri.tryParse(trackingLink);
    if (uri == null) return;

    final path = uri.path;
    final isInAppTracking = path == '/track' || path.startsWith('/track/');

    if (isInAppTracking) {
      final targetPath = uri.query.isEmpty ? path : '$path?${uri.query}';
      context.go(targetPath);
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
