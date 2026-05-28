// ============================================================================
//  lib/core/providers/firebase_providers.dart
// ============================================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FirebaseAuth Singleton
// ─────────────────────────────────────────────────────────────────────────────

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

// ─────────────────────────────────────────────────────────────────────────────
// Stream reactivo de autenticación
// ─────────────────────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>(
  (ref) {
    return ref.watch(firebaseAuthProvider).authStateChanges();
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// ¿Usuario autenticado?
// ─────────────────────────────────────────────────────────────────────────────

final isAuthenticatedProvider = Provider<bool>(
  (ref) {
    return ref.watch(authStateProvider).valueOrNull != null;
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Usuario actual
// ─────────────────────────────────────────────────────────────────────────────

final currentUserProvider = Provider<User?>(
  (ref) {
    return ref.watch(authStateProvider).valueOrNull;
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// UID actual
// ─────────────────────────────────────────────────────────────────────────────

final currentUidProvider = Provider<String?>(
  (ref) {
    return ref.watch(currentUserProvider)?.uid;
  },
);

// ─────────────────────────────────────────────────────────────────────────────
// Email actual
// ─────────────────────────────────────────────────────────────────────────────

final currentEmailProvider = Provider<String?>(
  (ref) {
    return ref.watch(currentUserProvider)?.email;
  },
);
