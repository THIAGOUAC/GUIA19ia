import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/camera_controller.dart';
import '../widgets/photo_preview_card.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraState = ref.watch(cameraProvider);

    ref.listen<CameraState>(cameraProvider, (previous, next) {
      if (next.status == CameraStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Error al usar la cámara'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: cameraState.photo != null
                  ? PhotoPreviewCard(photo: cameraState.photo!)
                  : _EmptyPhotoPlaceholder(
                      isLoading: cameraState.status == CameraStatus.capturing,
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: cameraState.status == CameraStatus.capturing
                  ? null
                  : () => ref.read(cameraProvider.notifier).takePhoto(),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Tomar foto'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: cameraState.status == CameraStatus.capturing
                  ? null
                  : () => ref.read(cameraProvider.notifier).pickFromGallery(),
              icon: const Icon(Icons.photo_library),
              label: const Text('Seleccionar de galería'),
            ),
            if (cameraState.photo != null) ...[
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(cameraState.photo);
                },
                icon: const Icon(Icons.check),
                label: const Text('Usar esta imagen'),
              ),
              TextButton(
                onPressed: () => ref.read(cameraProvider.notifier).reset(),
                child: const Text('Volver a intentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyPhotoPlaceholder extends StatelessWidget {
  final bool isLoading;

  const _EmptyPhotoPlaceholder({
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Toma o selecciona una imagen',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}