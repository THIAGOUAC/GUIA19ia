import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/captured_photo_entity.dart';
import '../repositories/camera_repository.dart';

class TakePhotoUseCase implements UseCase<CapturedPhotoEntity, NoParams> {
  final CameraRepository repository;

  TakePhotoUseCase(this.repository);

  @override
  Future<Either<Failure, CapturedPhotoEntity>> call(NoParams params) {
    return repository.takePhoto();
  }
}