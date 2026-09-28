import 'package:flutter/material.dart';
import 'package:locora/shared/theme/app_colors.dart';

class LocationPickerMapHeader extends StatelessWidget {
  const LocationPickerMapHeader({
    super.key,
    required this.isCompact,
    required this.coordinates,
    this.onUseCurrentLocation,
    this.onZoomIn,
    this.onZoomOut,
  });

  final bool isCompact;
  final String coordinates;
  final VoidCallback? onUseCurrentLocation;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (isCompact) {
      return Positioned.fill(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _CoordinatePill(coordinates: coordinates),
              ),
              Positioned(
                left: 0,
                bottom: 0,
                child: _MapHint(
                  icon: Icons.pan_tool_alt_outlined,
                  label: 'Drag map to position pin',
                  dark: true,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Column(
                  children: [
                    _MapActionButton(
                      icon: Icons.my_location,
                      tooltip: 'Use my current location',
                      onPressed: onUseCurrentLocation ?? () {},
                    ),
                    const SizedBox(height: 8),
                    _MapActionButton(
                      icon: Icons.layers_outlined,
                      tooltip: 'Map layers',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                width: 350,
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 13),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x180B2340),
                      blurRadius: 18,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE PINPOINT',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.7,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      'Where should we deliver?',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Move the map to place the pin exactly where you want your delivery.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: _MapHint(
                icon: Icons.lock_outline,
                label: 'Reticle locked: Urban Cluster 4-B',
                dark: false,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  _MapActionButton(
                    icon: Icons.my_location,
                    tooltip: 'Use my current location',
                    onPressed: onUseCurrentLocation ?? () {},
                  ),
                  const SizedBox(height: 8),
                  _MapActionButton(
                    icon: Icons.add,
                    tooltip: 'Zoom in',
                    onPressed: onZoomIn ?? () {},
                  ),
                  _MapActionButton(
                    icon: Icons.remove,
                    tooltip: 'Zoom out',
                    onPressed: onZoomOut ?? () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoordinatePill extends StatelessWidget {
  const _CoordinatePill({required this.coordinates});

  final String coordinates;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220B2340),
            blurRadius: 14,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gps_fixed, size: 15, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(coordinates, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(width: 8),
            Text(
              'GPS ACTIVE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapHint extends StatelessWidget {
  const _MapHint({required this.icon, required this.label, required this.dark});

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: dark
            ? const Color(0xE6101C2A)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180B2340),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: dark ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: dark ? Colors.white : AppColors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.primary),
        ),
      ),
    );
  }
}
