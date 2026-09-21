import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locora/core/providers.dart';
import 'package:locora/features/track/data/tracker_api.dart';
import 'package:locora/features/track/models/delivery_model.dart';

final trackerApiProvider = Provider<TrackerApi>((ref) {
  return TrackerApi(ref.watch(apiClientProvider));
});

final trackingProvider = FutureProvider.autoDispose
    .family<DeliveryModel, String>((ref, token) async {
      final response = await ref
          .watch(trackerApiProvider)
          .getData(token: token);
      final delivery = response['delivery'];
      if (delivery is! Map<String, dynamic>) {
        throw const FormatException(
          'Tracking response did not include a delivery',
        );
      }
      return DeliveryModel.fromJson(delivery);
    });
