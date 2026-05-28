import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/captured_photo_entity.dart';
import '../models/captured_photo_model.dart';

abstract class CameraDataSource {
  Future<CapturedPhotoModel> takePhoto();

  Future<CapturedPhotoModel> pickFromGallery();

  Future<bool> checkPermission();

  Future<bool> requestPermission();
}

class CameraDataSourceImpl implements CameraDataSource {
  final ImagePicker _picker;

  CameraDataSourceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static const double _maxWidth = 1080;
  static const double _maxHeight = 1080;
  static const int _quality = 85;

  @override
  Future<bool> checkPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission() async {
    final current = await Permission.camera.status;

    if (current.isGranted) return true;

    if (current.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    final result = await Permission.camera.request();
    return result.isGranted;
  }

  @override
  Future<CapturedPhotoModel> takePhoto() async {
    final hasPermission = await requestPermission();

    if (!hasPermission) {
      throw Exception('Permiso de cámara denegado');
    }

    final XFile? file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _maxWidth,
      maxHeight: _maxHeight,
      imageQuality: _quality,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (file == null) {
      throw Exception('cancelled');
    }

    return CapturedPhotoModel.fromXFile(
      file,
      source: PhotoSource.camera,
    );
  }

  @override
  Future<CapturedPhotoModel> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxWidth,
      maxHeight: _maxHeight,
      imageQuality: _quality,
    );

    if (file == null) {
      throw Exception('cancelled');
    }

    return CapturedPhotoModel.fromXFile(
      file,
      source: PhotoSource.gallery,
    );
  }
}