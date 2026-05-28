import 'package:equatable/equatable.dart';

/// Entidad de dominio que representa una ubicación GPS.
///
/// Esta clase pertenece a la capa Domain, por eso no depende de paquetes
/// externos como geolocator, Firebase, Drift o Flutter.
class LocationEntity extends Equatable {
  /// Latitud geográfica.
  /// Ejemplo Cusco: -13.5319
  final double latitude;

  /// Longitud geográfica.
  /// Ejemplo Cusco: -71.9675
  final double longitude;

  /// Precisión de la ubicación en metros.
  /// Mientras menor sea el valor, más precisa es la ubicación.
  final double? accuracy;

  /// Altitud sobre el nivel del mar.
  /// Es útil para zonas andinas como Cusco.
  final double? altitude;

  /// Velocidad del dispositivo en metros por segundo.
  final double? speed;

  /// Fecha y hora en la que se obtuvo la ubicación.
  final DateTime timestamp;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    required this.timestamp,
  });

  /// Regla de negocio:
  /// una ubicación se considera precisa si tiene una precisión menor o igual
  /// a 50 metros.
  bool get isAccurate => accuracy != null && accuracy! <= 50.0;

  /// Regla de negocio:
  /// una ubicación se considera reciente si fue obtenida hace menos de
  /// 5 minutos.
  bool get isFresh {
    final diff = DateTime.now().difference(timestamp);
    return diff.inMinutes < 5;
  }

  /// Permite crear una copia de la entidad modificando solo algunos campos.
  ///
  /// Esto ayuda en tests y en flujos donde se necesita actualizar una parte
  /// de la ubicación sin reconstruir todo manualmente.
  LocationEntity copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    DateTime? timestamp,
  }) {
    return LocationEntity(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Lista de propiedades usadas por Equatable para comparar objetos.
  ///
  /// Dos LocationEntity serán iguales si todos estos campos son iguales.
  @override
  List<Object?> get props => [
        latitude,
        longitude,
        accuracy,
        altitude,
        speed,
        timestamp,
      ];
}
