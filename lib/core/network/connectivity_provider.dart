import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceConnectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  return Stream<bool>.multi((controller) {
    var receivedChange = false;
    final subscription = connectivity.onConnectivityChanged.listen(
      (results) {
        receivedChange = true;
        controller.add(_hasConnection(results));
      },
      onError: (Object error, StackTrace stackTrace) {
        controller.addError(error, stackTrace);
      },
    );

    unawaited(
      connectivity.checkConnectivity().then(
        (results) {
          if (!receivedChange) controller.add(_hasConnection(results));
        },
        onError: (Object error, StackTrace stackTrace) {
          controller.addError(error, stackTrace);
        },
      ),
    );

    controller.onCancel = () {
      unawaited(subscription.cancel());
    };
  });
});

bool _hasConnection(List<ConnectivityResult> results) =>
    results.any((result) => result != ConnectivityResult.none);
