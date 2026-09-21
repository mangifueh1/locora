import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:locora/core/providers.dart';
import 'package:locora/features/picker/data/picker_api.dart';
import 'package:locora/features/picker/models/delivery_location.dart';

final pickerApiProvider = Provider<PickerApi>((ref) {
  return PickerApi(ref.watch(apiClientProvider));
});

final pickerControllerProvider =
    StateNotifierProvider.family<PickerController, AsyncValue<void>, String>((
      ref,
      token,
    ) {
      return PickerController(ref.watch(pickerApiProvider), token);
    });

class PickerController extends StateNotifier<AsyncValue<void>> {
  final PickerApi _api;
  final String token;

  new(this._api, this.token) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> confirm(DeliveryLocation location) async {
    state = AsyncValue.loading();
    try {
      final result = await _api.confirmLocation(
        token: token,
        location: location,
      );
      state = const AsyncValue.data(null);
      return result;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }
}
