import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class LocationMap extends StatelessWidget {
  const LocationMap({
    super.key,
    required this.center,
    required this.zoom,
    required this.onCenterChanged,
  });

  final LatLng center;
  final double zoom;
  final ValueChanged<LatLng> onCenterChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MapWidget(
          styleUri: MapboxStyles.STANDARD_SATELLITE,
          viewport: CameraViewportState(
            center: Point(
              coordinates: Position(center.longitude, center.latitude),
            ),
            zoom: zoom,
            bearing: 0,
            pitch: 0,
          ),
          onCameraChangeListener: (event) {
            onCenterChanged(
              LatLng(
                event.cameraState.center.coordinates.lat.toDouble(),
                event.cameraState.center.coordinates.lng.toDouble(),
              ),
            );
          },
        ),

        // The pin stays fixed while the customer moves the map.
        // This makes the center of the screen represent the selected house.
        IgnorePointer(
          child: Transform.translate(
            offset: const Offset(0, -24),
            child: const Icon(Icons.location_pin, size: 48, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
