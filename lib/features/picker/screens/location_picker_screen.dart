import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/core/location/location_service.dart';
import 'package:locora/features/picker/models/delivery_location.dart';
import 'package:locora/features/picker/providers/picker_provider.dart';
import 'package:locora/features/picker/widgets/location_picker_map_header.dart';
import 'package:locora/features/picker/widgets/location_map.dart';
import 'package:locora/features/picker/widgets/picker_confirmation_panel.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({
    super.key,
    required this.token,
    this.returnUrl,
    this.isPreview = false,
  });

  final String token;
  final String? returnUrl;
  final bool isPreview;

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  LatLng _center = const LatLng(4.1560, 9.2632);
  double _zoom = 15;
  final _sheetController = DraggableScrollableController();
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;

    if (position == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location unavailable, so the map is staying in the default area. You can move it manually.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _zoom = 15;
    });
  }

  void _zoomIn() {
    setState(() => _zoom = (_zoom + 1).clamp(5, 20).toDouble());
  }

  void _zoomOut() {
    setState(() => _zoom = (_zoom - 1).clamp(5, 20).toDouble());
  }

  Future<void> _confirm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (widget.isPreview) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preview mode: no location was sent.')),
      );
      return;
    }

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
    final coordinates =
        '${_center.latitude.toStringAsFixed(5)}, ${_center.longitude.toStringAsFixed(5)}';

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final map = Stack(
            fit: StackFit.expand,
            children: [
              LocationMap(
                center: _center,
                zoom: _zoom,
                onCenterChanged: (value) {
                  setState(() => _center = value);
                },
              ),
              LocationPickerMapHeader(
                isCompact: !isWide,
                coordinates: coordinates,
                onUseCurrentLocation: _loadCurrentLocation,
                onZoomIn: _zoomIn,
                onZoomOut: _zoomOut,
              ),
            ],
          );
          final panel = PickerConfirmationPanel(
            formKey: _formKey,
            descriptionController: _descriptionController,
            notesController: _notesController,
            coordinates: coordinates,
            isLoading: state.isLoading,
            isPreview: widget.isPreview,
            isWide: isWide,
            onConfirm: _confirm,
          );

          if (isWide) {
            return Row(
              children: [
                Expanded(flex: 7, child: map),
                SizedBox(
                  width: 370,
                  height: constraints.maxHeight,
                  child: panel,
                ),
              ],
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              map,
              DraggableScrollableSheet(
                controller: _sheetController,
                initialChildSize: 0.3,
                minChildSize: 0.12,
                maxChildSize: 0.92,
                snap: true,
                snapSizes: const [0.12, 0.3, 0.92],
                builder: (context, scrollController) {
                  return PickerConfirmationPanel(
                    formKey: _formKey,
                    descriptionController: _descriptionController,
                    notesController: _notesController,
                    coordinates: coordinates,
                    isLoading: state.isLoading,
                    isPreview: widget.isPreview,
                    isWide: false,
                    onConfirm: _confirm,
                    scrollController: scrollController,
                    onHandleTap: _toggleSheet,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _toggleSheet() {
    if (!_sheetController.isAttached) return;

    final targetSize = _sheetController.size > 0.4 ? 0.12 : 0.92;
    _sheetController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }
}
