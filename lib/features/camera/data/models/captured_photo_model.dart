import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../domain/entities/captured_photo_entity.dart';

class CapturedPhotoModel extends CapturedPhotoEntity {
  const CapturedPhotoModel({
    required super.localPath,
    required super.fileSizeBytes,
    required super.capturedAt,
    required super.source,
    super.productId,
    super.profileId,
  });

  factory CapturedPhotoModel.fromXFile(
    XFile file, {
    required PhotoSource source,
    String? productId,
    String? profileId,
  }) {
    final fileObj = File(file.path);

    return CapturedPhotoModel(
      localPath: file.path,
      fileSizeBytes: fileObj.existsSync() ? fileObj.lengthSync() : 0,
      capturedAt: DateTime.now(),
      source: source,
      productId: productId,
      profileId: profileId,
    );
  }
}