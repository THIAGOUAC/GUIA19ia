// Dart — lib/features/location/data/models/location_model.dart
import 'package:geolocator/geolocator.dart';

import '../../domain/entities/location_entity.dart';

/// DTO / Model de ubicación.
///
/// Convierte Position de geolocator
/// a LocationEntity del dominio.
class LocationModel extends LocationEntity {
  const LocationModel({
    required super.latitude,
    required super.longitude,
    super.accuracy,
    super.altitude,
    super.speed,
    required super.timestamp,
  });

  /// Factory constructor:
  /// Position (geolocator) → LocationModel
  factory LocationModel.fromPosition(Position pos) {
    return LocationModel(
      latitude: pos.latitude,
      longitude: pos.longitude,
      accuracy: pos.accuracy,
      altitude: pos.altitude,
      speed: pos.speed,
      timestamp: pos.timestamp,
    );
  }
}
