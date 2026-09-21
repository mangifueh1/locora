import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/features/picker/models/delivery_location.dart';
import 'package:locora/features/picker/providers/picker_provider.dart';
import 'package:locora/features/picker/widgets/location_map.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, required this.token, this.returnUrl});

  final String token;
  final String? returnUrl;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  LatLng _center = const LatLng(4.1560, 9.2632);

  Future<void> _confirm() async {
    final result = await ref
        .read(pickerControllerProvider(widget.token).notifier)
        .confirm(
          DeliveryLocation(
            latitude: _center.latitude,
            longitude: _center.longitude,
          ),
        );

    if (!mounted || result == null) return;

    final backendReturnUrl = result['return_url']?.toString();

    final destination = backendReturnUrl ?? widget.returnUrl;

    if (destination != null && destination.isNotEmpty) {
      final uri = Uri.tryParse(destination);

      if (uri != null) {
        await launchUrl(uri);
        return;
      }
    }

    await showDialog<void>(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text('Location saved'),
        content: Text('Your delivery location has been saved successfully.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickerControllerProvider(widget.token));

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm your delivery location')),
      body: Stack(
        children: [
          LocationMap(
            center: _center,
            onCenterChanged: (value) {
              setState(() => _center = value);
            },
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: SafeArea(
              child: FilledButton(
                onPressed: state.isLoading ? null : _confirm,
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirm this location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
