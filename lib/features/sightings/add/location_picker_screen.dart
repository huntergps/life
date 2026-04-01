import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:galapagos_wildlife/core/constants/app_constants.dart';

/// Pantalla para seleccionar una ubicación tocando el mapa.
/// Retorna un [LatLng] con la ubicación seleccionada, o null si se cancela.
class LocationPickerScreen extends StatefulWidget {
  /// Ubicación inicial del marcador (opcional).
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _mapController;
  LatLng? _selectedLocation;

  static const _defaultCenter = LatLng(
    AppConstants.galapagosDefaultLat,
    AppConstants.galapagosDefaultLng,
  );

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onTap(TapPosition tapPosition, LatLng point) {
    setState(() => _selectedLocation = point);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasSelection = _selectedLocation != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación'),
        actions: [
          if (hasSelection)
            TextButton(
              onPressed: () => Navigator.of(context).pop(_selectedLocation),
              child: Text(
                'Confirmar',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // --- Mapa ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation ?? _defaultCenter,
              initialZoom: widget.initialLocation != null ? 14 : AppConstants.galapagosDefaultZoom,
              minZoom: 6,
              maxZoom: 19,
              onTap: _onTap,
            ),
            children: [
              // OSM tiles
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.galapagos.galapagos_wildlife',
                maxNativeZoom: 19,
              ),

              // Marcador de la ubicación seleccionada
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 48,
                      height: 48,
                      child: const _LocationPin(),
                    ),
                  ],
                ),
            ],
          ),

          // --- Instrucción en la parte superior ---
          Positioned(
            top: 12,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.75)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, size: 16,
                      color: isDark ? Colors.white70 : Colors.grey.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Toca el mapa para colocar el marcador',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- Coordenadas de la ubicación seleccionada ---
          if (_selectedLocation != null)
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red.shade600, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_selectedLocation!.latitude.toStringAsFixed(5)}, '
                        '${_selectedLocation!.longitude.toStringAsFixed(5)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(_selectedLocation),
                      child: const Text('Confirmar'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pin rojo con sombra para marcar la ubicación seleccionada.
class _LocationPin extends StatelessWidget {
  const _LocationPin();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.location_on, color: Colors.red, size: 40),
      ],
    );
  }
}
