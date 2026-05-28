// ============================================================================
//  main.dart
// ============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

import 'core/providers/firebase_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Inicializar Firebase ────────────────────────────────────────────────
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ── Inyección de dependencias ───────────────────────────────────────────
  await di.init();

  runApp(
    const ProviderScope(
      child: ArtesaniasApp(),
    ),
  );
}

class ArtesaniasApp extends ConsumerWidget {
  const ArtesaniasApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escucha reactiva del estado Firebase Auth
    ref.watch(authStateProvider);

    return MaterialApp.router(
      title: 'Artesanías Andinas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRouter(ref),
    );
  }
}
