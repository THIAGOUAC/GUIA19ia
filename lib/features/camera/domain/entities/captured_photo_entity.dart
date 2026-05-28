import 'package:equatable/equatable.dart';

enum PhotoSource { camera, gallery }

class CapturedPhotoEntity extends Equatable {
  final String localPath;
  final int fileSizeBytes;
  final DateTime capturedAt;
  final PhotoSource source;
  final String? productId;
  final String? profileId;

  const CapturedPhotoEntity({
    required this.localPath,
    required this.fileSizeBytes,
    required this.capturedAt,
    required this.source,
    this.productId,
    this.profileId,
  });

  bool get isWithinSizeLimit => fileSizeBytes <= 5 * 1024 * 1024;

  bool get isFreshCapture {
    return DateTime.now().difference(capturedAt).inMinutes < 10;
  }

  bool get canBeUsedForProduct => localPath.isNotEmpty && isWithinSizeLimit;

  bool get canBeUsedForProfile => localPath.isNotEmpty && isWithinSizeLimit;

  CapturedPhotoEntity copyWith({
    String? localPath,
    int? fileSizeBytes,
    DateTime? capturedAt,
    PhotoSource? source,
    String? productId,
    String? profileId,
  }) {
    return CapturedPhotoEntity(
      localPath: localPath ?? this.localPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      capturedAt: capturedAt ?? this.capturedAt,
      source: source ?? this.source,
      productId: productId ?? this.productId,
      profileId: profileId ?? this.profileId,
    );
  }

  @override
  List<Object?> get props => [
        localPath,
        fileSizeBytes,
        capturedAt,
        source,
        productId,
        profileId,
      ];
}