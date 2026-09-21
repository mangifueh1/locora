import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  SocketService(this.baseUrl);

  final String baseUrl;

  io.Socket connect() {
    return io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );
  }

  void joinDelivery(
    io.Socket socket,
    String deliveryId,
  ) {
    socket.emit('join-delivery', deliveryId);
  }

  void sendDriverLocation(
    io.Socket socket, {
    required String deliveryId,
    required double latitude,
    required double longitude,
  }) {
    socket.emit('driver-location', {
      'deliveryId': deliveryId,
      'lat': latitude,
      'lng': longitude,
    });
  }
}


