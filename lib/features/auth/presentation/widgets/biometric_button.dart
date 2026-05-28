import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../controllers/biometric_controller.dart';

class BiometricButton extends ConsumerWidget {
  final VoidCallback onSuccess;

  const BiometricButton({
    super.key,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricState = ref.watch(biometricProvider);

    ref.listen<BiometricState>(biometricProvider, (previous, next) {
      if (next.status == BiometricStatus.success) {
        onSuccess();
      }

      if (next.status == BiometricStatus.failed &&
          next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    if (biometricState.status == BiometricStatus.unavailable) {
      return const SizedBox.shrink();
    }

    final hasFace = biometricState.availableTypes.contains(BiometricType.face);

    final icon = hasFace ? Icons.face : Icons.fingerprint;

    final label = hasFace
        ? 'Entrar con rostro o clave del dispositivo'
        : 'Entrar con huella o clave del dispositivo';

    return Column(
      children: [
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        const Text(
          'o vuelve a entrar de forma segura',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: biometricState.status == BiometricStatus.authenticating
              ? null
              : () => ref.read(biometricProvider.notifier).authenticate(),
          icon: biometricState.status == BiometricStatus.authenticating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon),
          label: Text(label),
        ),
      ],
    );
  }
}