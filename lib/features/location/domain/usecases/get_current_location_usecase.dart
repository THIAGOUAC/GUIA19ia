import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

/// Caso de uso para obtener la ubicación actual una sola vez.
///
/// Esta clase pertenece a la capa Domain.
/// No usa geolocator directamente; solo llama al contrato LocationRepository.
class GetCurrentLocationUseCase implements UseCase<LocationEntity, NoParams> {
  final LocationRepository repository;

  const GetCurrentLocationUseCase(this.repository);

  @override
  Future<Either<Failure, LocationEntity>> call(NoParams params) {
    return repository.getCurrentLocation();
  }
}
