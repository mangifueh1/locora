import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:locora/core/location/location_service.dart';
import 'package:locora/core/routing/app_router.dart';
import 'package:locora/features/picker/models/delivery_location.dart';
import 'package:locora/features/picker/providers/picker_provider.dart';
import 'package:locora/features/picker/widgets/location_picker_map_header.dart';
import 'package:locora/features/picker/widgets/location_map.dart';
import 'package:locora/features/picker/widgets/picker_confirmation_panel.dart';

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
  bool _isLoadingSavedLocation = true;
  bool _showMap = false;
  DeliveryLocation? _savedLocation;
  Object? _savedLocationError;

  @override
  void initState() {
    super.initState();
    if (widget.isPreview) {
      _showMap = true;
    } else {
      _loadSavedLocation();
    }
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

  Future<void> _loadSavedLocation() async {
    try {
      final location = await ref
          .read(pickerApiProvider)
          .getSavedLocation(token: widget.token);
      if (!mounted) return;

      setState(() {
        _savedLocation = location;
        _savedLocationError = null;
        _isLoadingSavedLocation = false;
        _showMap = location == null;
      });
      if (location == null) await _loadCurrentLocation();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _savedLocationError = error;
        _isLoadingSavedLocation = false;
      });
    }
  }

  void _chooseNewLocation() {
    final savedLocation = _savedLocation;
    setState(() {
      _showMap = true;
      _descriptionController.text = savedLocation?.addressDescription ?? '';
      if (savedLocation != null) {
        _center = LatLng(savedLocation.latitude, savedLocation.longitude);
        _zoom = 15;
      }
    });
    if (savedLocation == null) _loadCurrentLocation();
  }

  void _retrySavedLocationLoad() {
    setState(() {
      _isLoadingSavedLocation = true;
      _savedLocationError = null;
    });
    _loadSavedLocation();
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

    await _submitLocation(
      DeliveryLocation(
        latitude: _center.latitude,
        longitude: _center.longitude,
        addressDescription: _descriptionController.text,
      ),
    );
  }

  Future<void> _useSavedLocation() async {
    final location = _savedLocation;
    if (location == null) return;
    await _submitLocation(location);
  }

  Future<void> _submitLocation(DeliveryLocation location) async {
    final result = await ref
        .read(pickerControllerProvider(widget.token).notifier)
        .confirm(location);

    if (!mounted) return;
    if (result == null) {
      final error = ref.read(pickerControllerProvider(widget.token)).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error?.toString() ?? 'Unable to save location')),
      );
      return;
    }

    final trackingLink = result['tracking_link']?.toString();
    markPickerCompleted(widget.token, trackingLink);

    if (!mounted) return;

    GoRouter.of(context)
        .replace('/pick/${widget.token}/confirmed', extra: trackingLink);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(pickerControllerProvider(widget.token));
    if (!_showMap) {
      if (_isLoadingSavedLocation) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (_savedLocationError != null) {
        return _buildSavedLocationError();
      }
      if (_savedLocation != null) {
        return _buildSavedLocationChoice(state);
      }
    }

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

  Widget _buildSavedLocationChoice(AsyncValue<void> state) {
    final location = _savedLocation!;
    final description = location.addressDescription?.trim();
    final coordinates =
        '${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}';
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.home_outlined, size: 30, color: colors.primary),
                  const SizedBox(height: 18),
                  Text(
                    'Use your saved address?',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your saved delivery location or pick a new one.',
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, color: colors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                description?.isNotEmpty == true
                                    ? description!
                                    : 'Saved delivery location',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                coordinates,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.hasError) ...[
                    const SizedBox(height: 12),
                    Text(
                      state.error.toString(),
                      style: TextStyle(color: colors.error),
                    ),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: state.isLoading ? null : _useSavedLocation,
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(
                        state.isLoading
                            ? 'Confirming location'
                            : 'Use saved location',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: state.isLoading ? null : _chooseNewLocation,
                      icon: const Icon(Icons.edit_location_alt_outlined),
                      label: const Text('Choose a new location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSavedLocationError() {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_searching, size: 36, color: colors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Could not check for a saved address',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _savedLocationError.toString(),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _retrySavedLocationLoad,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _chooseNewLocation,
                    icon: const Icon(Icons.edit_location_alt_outlined),
                    label: const Text('Choose a new location'),
                  ),
                ],
              ),
            ),
          ),
        ),
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
