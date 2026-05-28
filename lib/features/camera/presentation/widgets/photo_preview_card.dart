import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/captured_photo_entity.dart';

class PhotoPreviewCard extends StatelessWidget {
  final CapturedPhotoEntity photo;

  const PhotoPreviewCard({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    final sizeKB = (photo.fileSizeBytes / 1024).toStringAsFixed(1);
    final sourceText =
        photo.source == PhotoSource.camera ? 'Cámara' : 'Galería';

    return Column(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(photo.localPath),
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(label: Text('$sizeKB KB')),
            Chip(label: Text(sourceText)),
            if (photo.canBeUsedForProduct)
              const Chip(label: Text('Lista para producto')),
            if (photo.canBeUsedForProfile)
              const Chip(label: Text('Lista para perfil')),
            if (!photo.isWithinSizeLimit)
              const Chip(label: Text('Imagen muy grande')),
          ],
        ),
      ],
    );
  }
}