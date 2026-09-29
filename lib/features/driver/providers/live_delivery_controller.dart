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

final liveDeliveryControllerProvider =
    NotifierProvider.family<LiveDeliveryController, LiveDeliveryState, String>(
      LiveDeliveryController.new,
    );

class LiveDeliveryState {
  const LiveDeliveryState({
    this.isSharing = false,
    this.isLoading = false,
    this.error,
    this.driverLatitude,
    this.driverLongitude,
  });

  final bool isSharing;
  final bool isLoading;
  final String? error;
  final double? driverLatitude;
  final double? driverLongitude;

  LiveDeliveryState copyWith({
    bool? isSharing,
    bool? isLoading,
    String? error,
    double? driverLatitude,
    double? driverLongitude,
  }) {
    return LiveDeliveryState(
      isSharing: isSharing ?? this.isSharing,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      driverLatitude: driverLatitude ?? this.driverLatitude,
      driverLongitude: driverLongitude ?? this.driverLongitude,
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
    _locationService = ref.watch(driverLocationServiceProvider);
    _config = ref.watch(appConfigProvider);
    _socketService = SocketService(_config.apiBaseUrl);

    ref.onDispose(() {
      _positionSubscription?.cancel();
      _socket?.dispose();
    });

    return const LiveDeliveryState();
  }

  Future<void> start() async {
    await _activate(startDelivery: true);
  }

  Future<void> resume() async {
    await _activate(startDelivery: false);
  }

  Future<void> _activate({required bool startDelivery}) async {
    if (state.isSharing || state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);

    try {
      final permitted = await _locationService.ensurePermission();
      if (!permitted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission is required to start tracking.',
        );
        return;
      }

      if (startDelivery) {
        await _driverApi.startDelivery(deliveryId);
      }

      _socket = _socketService.connect();
      _socket!.connect();

      _socketService.joinDelivery(_socket!, deliveryId);

      _positionSubscription = _locationService.positionStream().listen((
        position,
      ) {
        state = state.copyWith(
          driverLatitude: position.latitude,
          driverLongitude: position.longitude,
        );
        _socketService.sendDriverLocation(
          _socket!,
          deliveryId: deliveryId,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        unawaited(
          _driverApi
              .updateLocation(
                deliveryId,
                latitude: position.latitude,
                longitude: position.longitude,
              )
              .catchError((Object error) {
                state = state.copyWith(error: error.toString());
              }),
        );
      });

      state = state.copyWith(isSharing: true, isLoading: false, error: null);
    } catch (error) {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      _socket?.dispose();
      _socket = null;
      state = state.copyWith(
        isSharing: false,
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> stop() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    await _positionSubscription?.cancel();
    _positionSubscription = null;

    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;

    try {
      await _driverApi.completeDelivery(deliveryId);
      state = state.copyWith(isSharing: false, isLoading: false, error: null);
    } catch (error) {
      state = state.copyWith(
        isSharing: false,
        isLoading: false,
        error: error.toString(),
      );
    }
  }
}
