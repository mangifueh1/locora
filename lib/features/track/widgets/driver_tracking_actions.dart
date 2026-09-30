import 'package:flutter/material.dart';

class DriverTrackingActions extends StatelessWidget {
  const DriverTrackingActions({
    super.key,
    required this.status,
    required this.isSharing,
    required this.isLoading,
    required this.error,
    required this.onStart,
    required this.onResume,
    required this.onComplete,
  });

  final String status;
  final bool isSharing;
  final bool isLoading;
  final String? error;
  final VoidCallback? onStart;
  final VoidCallback? onResume;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase();
    final isAssigned = normalizedStatus == 'assigned';
    final isInProgress = normalizedStatus == 'in_progress';
    final isDelivered = normalizedStatus == 'delivered';
    final primaryAction = isAssigned
        ? onStart
        : isInProgress && !isSharing
        ? onResume
        : null;
    final primaryLabel = isSharing
        ? 'Sharing location'
        : isAssigned
        ? 'Start delivery'
        : 'Resume tracking';

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null) ...[
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
            ],
            if (isDelivered)
              const Text(
                'Delivery completed',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600),
              )
            else ...[
              FilledButton.icon(
                onPressed: isLoading ? null : primaryAction,
                icon: isLoading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isSharing
                            ? Icons.my_location_rounded
                            : Icons.play_arrow_rounded,
                      ),
                label: Text(primaryLabel),
              ),
              if (isInProgress)
                OutlinedButton.icon(
                  onPressed: isLoading ? null : onComplete,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Mark delivered'),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
