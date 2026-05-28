import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/captured_photo_entity.dart';
import '../../domain/usecases/pick_from_gallery_usecase.dart';
import '../../domain/usecases/take_photo_usecase.dart';

enum CameraStatus {
  idle,
  capturing,
  success,
  error,
  cancelled,
}

class CameraState {
  final CameraStatus status;
  final CapturedPhotoEntity? photo;
  final String? errorMessage;

  const CameraState({
    this.status = CameraStatus.idle,
    this.photo,
    this.errorMessage,
  });

  CameraState copyWith({
    CameraStatus? status,
    CapturedPhotoEntity? photo,
    String? errorMessage,
    bool clearPhoto = false,
    bool clearError = false,
  }) {
    return CameraState(
      status: status ?? this.status,
      photo: clearPhoto ? null : photo ?? this.photo,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CameraNotifier extends StateNotifier<CameraState> {
  final TakePhotoUseCase _takePhoto;
  final PickFromGalleryUseCase _pickFromGallery;

  CameraNotifier(
    this._takePhoto,
    this._pickFromGallery,
  ) : super(const CameraState());

  Future<void> takePhoto() async {
    state = state.copyWith(
      status: CameraStatus.capturing,
      clearError: true,
    );

    final result = await _takePhoto(NoParams());

    result.fold(
      (failure) {
        final message = failure.message;

        state = state.copyWith(
          status: message.toLowerCase().contains('cancelled')
              ? CameraStatus.cancelled
              : CameraStatus.error,
          errorMessage: message,
        );
      },
      (photo) {
        if (!photo.isWithinSizeLimit) {
          state = state.copyWith(
            status: CameraStatus.error,
            errorMessage: 'La imagen supera el límite de 5 MB.',
          );
          return;
        }

        state = state.copyWith(
          status: CameraStatus.success,
          photo: photo,
          clearError: true,
        );
      },
    );
  }

  Future<void> pickFromGallery() async {
    state = state.copyWith(
      status: CameraStatus.capturing,
      clearError: true,
    );

    final result = await _pickFromGallery(NoParams());

    result.fold(
      (failure) {
        final message = failure.message;

        state = state.copyWith(
          status: message.toLowerCase().contains('cancelled')
              ? CameraStatus.cancelled
              : CameraStatus.error,
          errorMessage: message,
        );
      },
      (photo) {
        if (!photo.isWithinSizeLimit) {
          state = state.copyWith(
            status: CameraStatus.error,
            errorMessage: 'La imagen supera el límite de 5 MB.',
          );
          return;
        }

        state = state.copyWith(
          status: CameraStatus.success,
          photo: photo,
          clearError: true,
        );
      },
    );
  }

  void reset() {
    state = const CameraState();
  }
}

final cameraProvider =
    StateNotifierProvider.autoDispose<CameraNotifier, CameraState>(
  (ref) {
    return CameraNotifier(
      sl<TakePhotoUseCase>(),
      sl<PickFromGalleryUseCase>(),
    );
  },
);