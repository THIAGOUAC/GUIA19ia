import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/captured_photo_entity.dart';
import '../../domain/repositories/camera_repository.dart';
import '../datasources/camera_datasource.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraDataSource dataSource;

  CameraRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, CapturedPhotoEntity>> takePhoto() async {
    try {
      final photo = await dataSource.takePhoto();
      return Right(photo);
    } catch (e) {
      return Left(CameraFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CapturedPhotoEntity>> pickFromGallery() async {
    try {
      final photo = await dataSource.pickFromGallery();
      return Right(photo);
    } catch (e) {
      return Left(CameraFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkCameraPermission() async {
    try {
      final granted = await dataSource.checkPermission();
      return Right(granted);
    } catch (e) {
      return Left(CameraFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> requestCameraPermission() async {
    try {
      final granted = await dataSource.requestPermission();
      return Right(granted);
    } catch (e) {
      return Left(CameraFailure(message: e.toString()));
    }
  }
}