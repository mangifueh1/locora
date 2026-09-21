import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:locora/features/driver/providers/driver_providers.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:locora/core/config/app_config.dart';
import 'package:locora/core/location/location_service.dart';
import 'package:locora/core/providers.dart';
import 'package:locora/core/realtime/socket_service.dart';
import 'package:locora/features/driver/data/driver_api.dart';

final liveDeliveryControllerProvider = NotifierProvider
    .family<LiveDeliveryController, LiveDeliveryState, String>(
  LiveDeliveryController.new,
);

class LiveDeliveryState {
  const LiveDeliveryState({
    this.isSharing = false,
    this.error,
  });

  final bool isSharing;
  final String? error;

  LiveDeliveryState copyWith({
    bool? isSharing,
    String? error,
  }) {
    return LiveDeliveryState(
      isSharing: isSharing ?? this.isSharing,
      error: error,
    );
  }
}

class LiveDeliveryController extends Notifier<LiveDeliveryState> {
  LiveDeliveryController(this.deliveryId);

  final String deliveryId;

  StreamSubscription<Position>? _positionSubscription;
  io.Socket? _socket;

  late DriverApi _driverApi;
  late LocationService _locationService;
  late SocketService _socketService;
  late AppConfig _config;

  @override
  LiveDeliveryState build() {
    _driverApi = ref.watch(driverApiProvider);
    _locationService = LocationService();
    _config = ref.watch(appConfigProvider);
    _socketService = SocketService(_config.apiBaseUrl);

    ref.onDispose(() {
      _positionSubscription?.cancel();
      _socket?.dispose();
    });

    return const LiveDeliveryState();
  }

  Future<void> start() async {
    if (state.isSharing) return;

    final permitted = await _locationService.ensurePermission();

    if (!permitted) {
      state = state.copyWith(
        error: 'Location permission is required to start tracking.',
      );
      return;
    }

    try {
      // Ask the backend to change the delivery to in_progress first.
      await _driverApi.startDelivery(deliveryId);

      _socket = _socketService.connect();
      _socket!.connect();

      _socketService.joinDelivery(_socket!, deliveryId);

      _positionSubscription =
          _locationService.positionStream().listen((position) {
        _socketService.sendDriverLocation(
          _socket!,
          deliveryId: deliveryId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
      });

      state = state.copyWith(
        isSharing: true,
      );
    } catch (error) {
      state = state.copyWith(error: error.toString());
    }
  }

  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    await _driverApi.completeDelivery(deliveryId);

    state = state.copyWith(isSharing: false);
  }
}