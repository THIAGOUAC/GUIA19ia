// ============================================================================
//  core/router/app_router.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/firebase_providers.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/auth_lock_page.dart';

import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';

import '../../features/favorites/presentation/pages/favorites_page.dart';

// ── Lab 17: GPS / Geolocalización ───────────────────────────────────
import '../../features/location/presentation/pages/location_page.dart';

// ── Lab 18: Cámara ─────────────────────────────────────────────────
import '../../features/camera/presentation/pages/camera_page.dart';

// ── Lab 19: Asistente IA Tupac ────────────────────────────────────
import '../../features/ai_chat/presentation/pages/chat_page.dart';

// ── Perfil de usuario ───────────────────────────────────────────────
import '../../features/profile/presentation/pages/profile_page.dart';

final appUnlockedProvider = StateProvider<bool>((ref) => false);

GoRouter appRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/login',

    // ── Control global de autenticación ─────────────────────────────
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isUnlocked = ref.read(appUnlockedProvider);

      final isLoading = authState.isLoading;
      final isLogged = authState.valueOrNull != null;

      final currentLocation = state.matchedLocation;

      final isGoingToLogin = currentLocation == '/login';
      final isGoingToLock = currentLocation == '/auth-lock';

      if (isLoading) {
        return null;
      }

      // Usuario no autenticado → solo puede ir al login
      if (!isLogged) {
        ref.read(appUnlockedProvider.notifier).state = false;

        if (!isGoingToLogin) {
          return '/login';
        }

        return null;
      }

      // Usuario autenticado, pero app aún bloqueada → pedir biometría/PIN
      if (isLogged && !isUnlocked && !isGoingToLock) {
        return '/auth-lock';
      }

      // Si ya está autenticado y desbloqueado, evitar volver a login o lock
      if (isLogged && isUnlocked && (isGoingToLogin || isGoingToLock)) {
        return '/products';
      }

      return null;
    },

    routes: [
      // ──────────────────────────────────────────────────────────────
      // LOGIN
      // ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // ──────────────────────────────────────────────────────────────
      // AUTH LOCK - LAB 18 BIOMETRÍA
      // ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/auth-lock',
        name: 'auth-lock',
        builder: (context, state) {
          return AuthLockPage(
            onUnlocked: () {
              ref.read(appUnlockedProvider.notifier).state = true;
              context.go('/products');
            },
          );
        },
      ),

      // ──────────────────────────────────────────────────────────────
      // PRODUCTS
      // ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/products',
        name: 'products',
        builder: (context, state) => const ProductListPage(),
        routes: [
          // ── Detalle de producto ──────────────────────────────────
          GoRoute(
            path: ':id',
            name: 'product-detail',
            builder: (context, state) {
              final id = int.parse(
                state.pathParameters['id'] ?? '0',
              );

              return ProductDetailPage(
                productId: id,
              );
            },
          ),
        ],
      ),

      // ──────────────────────────────────────────────────────────────
      // FAVORITES
      // ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/favorites',
        name: 'favorites',
        builder: (context, state) => const FavoritesPage(),
      ),

      // ──────────────────────────────────────────────────────────────
      // LOCATION GPS - LAB 17
      // ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/location',
        name: 'location',
        builder: (context, state) => const LocationPage(),
      ),

      // ──────────────────────────────────────────────────────────────
      // CAMERA - LAB 18
      // ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/camera',
        name: 'camera',
        builder: (context, state) => const CameraPage(),
      ),

      // ──────────────────────────────────────────────────────────────
      // AI CHAT - LAB 19
      // ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is Map<String, String>) {
            return ChatPage(
              productName: extra['productName'],
              productContext: extra['productContext'],
            );
          }

          return const ChatPage();
        },
      ),

      // ──────────────────────────────────────────────────────────────
      // PERFIL DE USUARIO
      // ──────────────────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],

    // ────────────────────────────────────────────────────────────────
    // ERROR PAGE
    // ────────────────────────────────────────────────────────────────
    errorBuilder: (context, state) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Página no encontrada',
          ),
        ),
        body: Center(
          child: Text(
            'Ruta no encontrada: ${state.uri}',
          ),
        ),
      );
    },
  );
}
