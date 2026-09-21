import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class TrackerMap extends StatefulWidget {
  const TrackerMap({
    super.key,
    required this.center,
    this.customerLocation,
    this.driverLocation,
  });

  final LatLng center;
  final LatLng? customerLocation;
  final LatLng? driverLocation;
  @override
  State<TrackerMap> createState() => _TrackerMapState();
}

class _TrackerMapState extends State<TrackerMap> {
  CircleAnnotationManager? _annotationManager;

  Future<void> _updateAnnotations() async {
    final manager = _annotationManager;
    if (manager == null) return;

    await manager.deleteAll();
    final annotations = <CircleAnnotationOptions>[];
    if (widget.customerLocation != null) {
      annotations.add(_marker(widget.customerLocation!, 0xff1976d2));
    }
    if (widget.driverLocation != null) {
      annotations.add(_marker(widget.driverLocation!, 0xfff4511e));
    }
    if (annotations.isNotEmpty) {
      await manager.createMulti(annotations);
    }
  }

  CircleAnnotationOptions _marker(LatLng location, int color) {
    return CircleAnnotationOptions(
      geometry: Point(
        coordinates: Position(location.longitude, location.latitude),
      ),
      circleColor: color,
      circleRadius: 10,
      circleStrokeColor: 0xffffffff,
      circleStrokeWidth: 3,
    );
  }

  @override
  void didUpdateWidget(covariant TrackerMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateAnnotations();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MapWidget(
          viewport: CameraViewportState(
            center: Point(
              coordinates: Position(
                widget.center.longitude,
                widget.center.latitude,
              ),
            ),
            zoom: 15,
          ),
          onMapCreated: (map) async {
            _annotationManager = await map.annotations
                .createCircleAnnotationManager();
            await _updateAnnotations();
          },
        ),
      ],
    );
  }
}
