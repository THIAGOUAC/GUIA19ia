// Dart — lib/features/location/domain/repositories/location_repository.dart
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/location_entity.dart';

/// Contrato del repositorio de ubicación.
///
/// Pertenece a la capa Domain.
/// Define las operaciones que necesita la app, sin depender de geolocator,
/// permission_handler ni ninguna implementación concreta.
abstract class LocationRepository {
  /// Obtiene la ubicación actual una sola vez.
  Future<Either<Failure, LocationEntity>> getCurrentLocation();

  /// Escucha las ubicaciones GPS en tiempo real.
  ///
  /// Se usa para tracking continuo del usuario.
  Stream<Either<Failure, LocationEntity>> watchLocation();

  /// Verifica si el permiso de localización está concedido.
  Future<Either<Failure, bool>> checkLocationPermission();

  /// Solicita el permiso de localización al usuario.
  Future<Either<Failure, bool>> requestLocationPermission();
}
