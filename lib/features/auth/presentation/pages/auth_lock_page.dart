import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/biometric_controller.dart';

class AuthLockPage extends ConsumerWidget {
  final VoidCallback onUnlocked;

  const AuthLockPage({
    super.key,
    required this.onUnlocked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricState = ref.watch(biometricProvider);

    ref.listen<BiometricState>(biometricProvider, (previous, next) {
      if (next.status == BiometricStatus.success) {
        onUnlocked();
      }

      if (next.status == BiometricStatus.failed && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.orange,
          ),
        );
      }
    });

    final isLoading = biometricState.status == BiometricStatus.authenticating ||
        biometricState.status == BiometricStatus.checking;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 90,
                    color: Color(0xFF8B4513),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Verifica tu identidad',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B4513),
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tu sesión sigue iniciada. Usa huella, rostro, PIN, patrón o contraseña del dispositivo para volver a entrar.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: isLoading
                        ? null
                        : () =>
                            ref.read(biometricProvider.notifier).authenticate(),
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(
                      isLoading ? 'Verificando...' : 'Desbloquear',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}