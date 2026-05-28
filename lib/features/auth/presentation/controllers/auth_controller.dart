// ============================================================================
//  features/auth/presentation/controllers/auth_controller.dart
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../data/datasources/firebase_auth_datasource.dart';

// Provider principal usado por login_page.dart
final authControllerProvider =
    AsyncNotifierProvider<AuthController, User?>(AuthController.new);

// Alias para no romper pantallas antiguas que aún usen authProvider
final authProvider = authControllerProvider;

class AuthController extends AsyncNotifier<User?> {
  late final FirebaseAuthDataSource _dataSource;

  @override
  Future<User?> build() async {
    _dataSource = FirebaseAuthDataSource(
      auth: ref.read(firebaseAuthProvider),
    );

    return ref.watch(authStateProvider).valueOrNull;
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final credential = await _dataSource.signInWithGoogle();

      state = AsyncValue.data(
        credential.user,
      );
    } catch (e, st) {
      state = AsyncValue.error(
        'Error al iniciar sesión con Google: $e',
        st,
      );
    }
  }

  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      final credential = await _dataSource.signInWithApple();

      state = AsyncValue.data(
        credential.user,
      );
    } catch (e, st) {
      state = AsyncValue.error(
        'Error al iniciar sesión con Apple: $e',
        st,
      );
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();

    try {
      await _dataSource.signOut();

      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(
        'Error al cerrar sesión: $e',
        st,
      );
    }
  }

  bool get isAuthenticated {
    return state.valueOrNull != null;
  }
}
