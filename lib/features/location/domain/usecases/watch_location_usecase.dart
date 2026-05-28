import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

/// Caso de uso para escuchar la ubicación GPS en tiempo real.
///
/// No implementa el UseCase base porque devuelve un Stream,
/// mientras que el UseCase base del proyecto trabaja con Future.
class WatchLocationUseCase {
  final LocationRepository repository;

  const WatchLocationUseCase(this.repository);

  Stream<Either<Failure, LocationEntity>> call() {
    return repository.watchLocation();
  }
}
