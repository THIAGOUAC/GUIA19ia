import 'package:flutter/material.dart';

import '../../domain/entities/location_entity.dart';

/// Tarjeta visual que muestra información GPS.
///
/// Muestra:
/// - coordenadas
/// - precisión
/// - altitud
/// - velocidad
/// - estado del GPS
class LocationCard extends StatelessWidget {
  /// Ubicación actual recibida desde Riverpod.
  final LocationEntity? location;

  /// Mensaje de error opcional.
  final String? errorMessage;

  const LocationCard({
    super.key,
    this.location,
    this.errorMessage,
  });

  /// Factory constructor para crear rápidamente una tarjeta de error.
  factory LocationCard.error({required String message}) {
    return LocationCard(errorMessage: message);
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar tarjeta roja si ocurrió un error.
    if (errorMessage != null) {
      return Card(
        color: Colors.red.shade50,
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),

              // Texto del error
              Expanded(
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si todavía no existe ubicación, no mostrar nada.
    if (location == null) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),

        // Columna principal con datos GPS
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icono GPS: verde si es preciso, naranja si es aproximado.
                Icon(
                  Icons.gps_fixed,
                  color: location!.isAccurate ? Colors.green : Colors.orange,
                ),

                const SizedBox(width: 8),

                // Estado del GPS
                Text(
                  'GPS ${location!.isAccurate ? "Preciso" : "Aproximado"}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                // Mostrar etiqueta si la ubicación es antigua.
                if (!location!.isFresh)
                  const Chip(
                    label: Text('Desactualizado'),
                    backgroundColor: Colors.orange,
                  ),
              ],
            ),

            const Divider(),

            // Coordenadas
            _dataRow(
              'Latitud',
              '${location!.latitude.toStringAsFixed(6)}°',
            ),

            _dataRow(
              'Longitud',
              '${location!.longitude.toStringAsFixed(6)}°',
            ),

            // Precisión GPS
            if (location!.accuracy != null)
              _dataRow(
                'Precisión',
                '${location!.accuracy!.toStringAsFixed(1)} m',
              ),

            // Altitud
            if (location!.altitude != null)
              _dataRow(
                'Altitud',
                '${location!.altitude!.toStringAsFixed(0)} m.s.n.m.',
              ),

            // Velocidad convertida de m/s → km/h
            if (location!.speed != null)
              _dataRow(
                'Velocidad',
                '${(location!.speed! * 3.6).toStringAsFixed(1)} km/h',
              ),
          ],
        ),
      ),
    );
  }

  /// Widget auxiliar para mostrar cada dato en formato fila.
  Widget _dataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
