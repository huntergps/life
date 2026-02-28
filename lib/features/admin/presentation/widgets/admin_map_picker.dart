import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/core/l10n/strings.g.dart';
import 'package:galapagos_wildlife/core/theme/app_colors.dart';

/// A compact map picker widget for selecting geographic coordinates.
/// Displays a FlutterMap centered on the Galapagos Islands with a draggable
/// marker and bidirectional text fields for manual lat/lng entry.
class AdminMapPicker extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final ValueChanged<(double lat, double lng)> onLocationChanged;

  const AdminMapPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationChanged,
  });

  @override
  State<AdminMapPicker> createState() => _AdminMapPickerState();
}

class _AdminMapPickerState extends State<AdminMapPicker> {
  static const _galapagosLat = -0.9538;
  static const _galapagosLng = -90.9656;
  static const _defaultZoom = 8.0;

  late final MapController _mapController;
  late final TextEditingController _latController;
  late final TextEditingController _lngController;

  LatLng? _selectedPosition;
  bool _updatingFromMap = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedPosition = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }

    _latController = TextEditingController(
      text: _selectedPosition?.latitude.toStringAsFixed(6) ?? '',
    );
    _lngController = TextEditingController(
      text: _selectedPosition?.longitude.toStringAsFixed(6) ?? '',
    );

    _latController.addListener(_onTextChanged);
    _lngController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _latController.removeListener(_onTextChanged);
    _lngController.removeListener(_onTextChanged);
    _latController.dispose();
    _lngController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_updatingFromMap) return;

    final lat = double.tryParse(_latController.text);
    final lng = double.tryParse(_lngController.text);

    if (lat != null && lng != null && lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180) {
      setState(() {
        _selectedPosition = LatLng(lat, lng);
      });
      _mapController.move(_selectedPosition!, _mapController.camera.zoom);
      widget.onLocationChanged((lat, lng));
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    _updatingFromMap = true;
    setState(() {
      _selectedPosition = point;
      _latController.text = point.latitude.toStringAsFixed(6);
      _lngController.text = point.longitude.toStringAsFixed(6);
    });
    widget.onLocationChanged((point.latitude, point.longitude));
    _updatingFromMap = false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.darkBorder : Colors.grey[300]!;

    final mapCenter = _selectedPosition ?? const LatLng(_galapagosLat, _galapagosLng);
    final initialZoom = _selectedPosition != null ? 10.0 : _defaultZoom;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            context.t.admin.location,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // Map container
        Container(
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: mapCenter,
              initialZoom: initialZoom,
              onTap: _onMapTap,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.galapagos.wildlife',
                tileBuilder: isDark ? _darkTileBuilder : null,
              ),
              if (_selectedPosition != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedPosition!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.location_on,
                        color: AppColors.secondary,
                        size: 40,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Lat/Lng text fields
        Row(
          children: [
            Expanded(
              child: _CoordinateField(
                label: context.t.admin.latitude,
                controller: _latController,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _CoordinateField(
                label: context.t.admin.longitude,
                controller: _lngController,
                isDark: isDark,
              ),
            ),
          ],
        ),

        // Current coordinates display
        if (_selectedPosition != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_selectedPosition!.latitude.toStringAsFixed(6)}, ${_selectedPosition!.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
          ),
      ],
    );
  }

  /// Applies a dark color filter to map tiles for dark mode.
  Widget _darkTileBuilder(BuildContext context, Widget tileWidget, TileImage tile) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        -0.6, 0, 0, 0, 180,
        0, -0.6, 0, 0, 180,
        0, 0, -0.6, 0, 180,
        0, 0, 0, 1, 0,
      ]),
      child: tileWidget,
    );
  }
}

/// A compact text field for entering a coordinate value.
class _CoordinateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isDark;

  const _CoordinateField({
    required this.label,
    required this.controller,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
        ],
        style: TextStyle(color: isDark ? Colors.white : null),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white70 : null),
          border: const OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.darkBorder : Colors.grey[300]!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isDark ? AppColors.primaryLight : AppColors.primary,
              width: 2,
            ),
          ),
          filled: isDark,
          fillColor: isDark ? AppColors.darkSurface : null,
          isDense: true,
        ),
      ),
    );
  }
}
