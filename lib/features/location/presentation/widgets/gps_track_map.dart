import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/location_entity.dart';

/// Widget que muestra:
/// - mapa OpenStreetMap
/// - marcador GPS actual
/// - ruta recorrida en tiempo real
class GpsTrackMap extends StatelessWidget {
  /// Ubicación actual del usuario.
  final LocationEntity? currentLocation;

  /// Historial completo de posiciones GPS.
  final List<LocationEntity> trackHistory;

  const GpsTrackMap({
    super.key,
    required this.currentLocation,
    required this.trackHistory,
  });

  @override
  Widget build(BuildContext context) {
    // Centro inicial del mapa:
    // ubicación actual o Cusco por defecto.
    final center = currentLocation != null
        ? LatLng(
            currentLocation!.latitude,
            currentLocation!.longitude,
          )
        : const LatLng(-13.5319, -71.9675);

    // Convertir historial GPS → puntos del mapa.
    final trackPoints =
        trackHistory.map((loc) => LatLng(loc.latitude, loc.longitude)).toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,

        // Zoom cercano tipo navegación GPS.
        initialZoom: 16.0,
      ),
      children: [
        /// ── Capa base OpenStreetMap ─────────────────────────────
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.artesanias.andinas',
        ),

        /// ── Línea de recorrido GPS ──────────────────────────────
        if (trackPoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: trackPoints,
                strokeWidth: 4.0,

                // Transparencia moderna
                color: Colors.blue.withValues(alpha: 0.7),
              ),
            ],
          ),

        /// ── Marcador de ubicación actual ───────────────────────
        if (currentLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 48,
                height: 48,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.navigation,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
