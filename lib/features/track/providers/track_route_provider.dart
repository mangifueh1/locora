import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:locora/core/providers.dart';
import 'package:locora/features/track/data/track_route_api.dart';

final trackRouteApiProvider = Provider<TrackRouteApi>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return TrackRouteApi(
    client: client,
    accessToken: ref.watch(appConfigProvider).mapboxToken,
  );
});

final trackRouteProvider = NotifierProvider.autoDispose
    .family<TrackRouteController, TrackRouteState, String>(
      TrackRouteController.new,
    );

class TrackRouteState {
  const TrackRouteState({this.geometry, this.isLoading = false, this.error});

  final List<LatLng>? geometry;
  final bool isLoading;
  final Object? error;
}

class TrackRouteController extends Notifier<TrackRouteState> {
  TrackRouteController(this.deliveryId);

  static const _minimumRefreshInterval = Duration(seconds: 30);
  static const _minimumDriverMovementMeters = 120.0;
  static const _minimumCustomerMovementMeters = 30.0;

  final String deliveryId;
  final Distance _distance = const Distance();

  late TrackRouteApi _api;
  LatLng? _latestDriverLocation;
  LatLng? _latestCustomerLocation;
  LatLng? _requestedDriverLocation;
  LatLng? _requestedCustomerLocation;
  DateTime? _lastRequestAt;
  Timer? _refreshTimer;
  bool _requestInFlight = false;
  int _generation = 0;

  @override
  TrackRouteState build() {
    _api = ref.watch(trackRouteApiProvider);
    ref.onDispose(() {
      _refreshTimer?.cancel();
      _generation++;
    });
    return const TrackRouteState();
  }

  void updateLocations({
    required LatLng? driverLocation,
    required LatLng? customerLocation,
  }) {
    _latestDriverLocation = driverLocation;
    _latestCustomerLocation = customerLocation;

    if (driverLocation == null || customerLocation == null) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      _generation++;
      _requestedDriverLocation = null;
      _requestedCustomerLocation = null;
      _lastRequestAt = null;
      state = const TrackRouteState();
      return;
    }

    if (_hasSignificantMovement) _scheduleOrRequest();
  }

  bool get _hasSignificantMovement {
    final latestDriver = _latestDriverLocation;
    final latestCustomer = _latestCustomerLocation;
    final requestedDriver = _requestedDriverLocation;
    final requestedCustomer = _requestedCustomerLocation;
    if (latestDriver == null || latestCustomer == null) return false;
    if (requestedDriver == null || requestedCustomer == null) return true;

    return _distance.as(LengthUnit.Meter, requestedDriver, latestDriver) >=
            _minimumDriverMovementMeters ||
        _distance.as(LengthUnit.Meter, requestedCustomer, latestCustomer) >=
            _minimumCustomerMovementMeters;
  }

  void _scheduleOrRequest() {
    if (_requestInFlight) return;
    final lastRequestAt = _lastRequestAt;
    if (lastRequestAt == null) {
      unawaited(_requestRoute());
      return;
    }

    final remaining =
        _minimumRefreshInterval - DateTime.now().difference(lastRequestAt);
    if (remaining <= Duration.zero) {
      unawaited(_requestRoute());
      return;
    }
    if (_refreshTimer != null) return;

    _refreshTimer = Timer(remaining, () {
      _refreshTimer = null;
      if (_hasSignificantMovement) _scheduleOrRequest();
    });
  }

  Future<void> _requestRoute() async {
    final driverLocation = _latestDriverLocation;
    final customerLocation = _latestCustomerLocation;
    if (_requestInFlight ||
        driverLocation == null ||
        customerLocation == null) {
      return;
    }

    _requestInFlight = true;
    _requestedDriverLocation = driverLocation;
    _requestedCustomerLocation = customerLocation;
    _lastRequestAt = DateTime.now();
    final generation = ++_generation;
    state = TrackRouteState(geometry: state.geometry, isLoading: true);

    try {
      final geometry = await _api.getDrivingRoute(
        driverLocation: driverLocation,
        customerLocation: customerLocation,
      );
      if (generation == _generation) {
        state = TrackRouteState(geometry: geometry);
      }
    } catch (error) {
      if (generation == _generation) {
        state = TrackRouteState(geometry: state.geometry, error: error);
      }
    } finally {
      _requestInFlight = false;
      if (_hasSignificantMovement) _scheduleOrRequest();
    }
  }
}
