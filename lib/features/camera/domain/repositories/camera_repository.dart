import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/captured_photo_entity.dart';

abstract class CameraRepository {
  Future<Either<Failure, CapturedPhotoEntity>> takePhoto();

  Future<Either<Failure, CapturedPhotoEntity>> pickFromGallery();

  Future<Either<Failure, bool>> checkCameraPermission();

  Future<Either<Failure, bool>> requestCameraPermission();
}