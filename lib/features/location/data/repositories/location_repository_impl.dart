// Dart — lib/features/location/data/repositories/location_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationDataSource dataSource;
  LocationRepositoryImpl(this.dataSource);
  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      final model = await dataSource.getCurrentLocation();
      return Right(model);
    } on LocationException catch (e) {
      return Left(LocationFailure(message: e.message));
    } catch (e) {
      return Left(LocationFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, LocationEntity>> watchLocation() {
    return dataSource
        .watchLocation()
        .map<Either<Failure, LocationEntity>>(
          (model) => Right(model),
        )
        .handleError((e) => Left(LocationFailure(message: e.toString())));
  }

  @override
  Future<Either<Failure, bool>> checkLocationPermission() async {
    final granted = await dataSource.checkPermission();
    return Right(granted);
  }

  @override
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final granted = await dataSource.requestPermission();
      return Right(granted);
    } catch (e) {
      return Left(LocationFailure(message: e.toString()));
    }
  }
}
