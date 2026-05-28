import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/location_entity.dart';
import '../controllers/location_controller.dart';
import '../widgets/gps_track_map.dart';
import '../widgets/location_card.dart';

/// Pantalla principal del módulo GPS.
///
/// Muestra:
/// - estado de permisos
/// - ubicación actual
/// - tracking en tiempo real
/// - mapa con la ruta recorrida
class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  @override
  void initState() {
    super.initState();

    // Verificar y solicitar permisos al iniciar la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationPermProvider.notifier).checkAndRequest();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Estado del permiso GPS
    final permStatus = ref.watch(locationPermProvider);

    // Ubicación actual (FutureProvider)
    final currentLoc = ref.watch(currentLocationProvider);

    // Stream GPS en tiempo real
    final streamedLoc = ref.watch(locationStreamProvider);

    // Historial de posiciones GPS
    final history = ref.watch(locationHistoryProvider);

    // Escuchar nuevas posiciones y acumular historial
    ref.listen(locationStreamProvider, (_, next) {
      next.whenData((loc) {
        ref.read(locationHistoryProvider.notifier).update(
              (list) => [...list, loc],
            );
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Artesanos Andinos'),
        actions: [
          // Botón para refrescar ubicación
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Centrar mapa',
            onPressed: () {
              ref.invalidate(currentLocationProvider);
            },
          ),
        ],
      ),
      body: _buildBody(
        permStatus,
        currentLoc,
        streamedLoc,
        history,
      ),
    );
  }

  /// Construye el contenido según el estado del permiso GPS.
  Widget _buildBody(
    LocationPermStatus permStatus,
    AsyncValue<LocationEntity?> currentLoc,
    AsyncValue<LocationEntity> streamedLoc,
    List<LocationEntity> history,
  ) {
    // Estado: solicitando permisos
    if (permStatus == LocationPermStatus.requesting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Estado: permiso denegado
    if (permStatus == LocationPermStatus.denied ||
        permStatus == LocationPermStatus.permanentlyDenied) {
      return _PermissionDeniedWidget(
        isPermanent: permStatus == LocationPermStatus.permanentlyDenied,
        onRetry: () {
          ref.read(locationPermProvider.notifier).checkAndRequest();
        },
      );
    }

    // Estado inicial
    if (permStatus == LocationPermStatus.initial) {
      return const Center(
        child: Text('Inicializando GPS...'),
      );
    }

    // Estado: permiso concedido
    return Column(
      children: [
        /// ── Tarjeta con información GPS ─────────────────────
        currentLoc.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) {
            return LocationCard.error(
              message: e.toString(),
            );
          },
          data: (loc) {
            if (loc == null) {
              return const SizedBox.shrink();
            }

            return LocationCard(location: loc);
          },
        ),

        /// ── Mapa GPS en tiempo real ─────────────────────────
        Expanded(
          child: GpsTrackMap(
            currentLocation: streamedLoc.valueOrNull,
            trackHistory: history,
          ),
        ),
      ],
    );
  }
}

/// Widget mostrado cuando el permiso GPS es denegado.
class _PermissionDeniedWidget extends StatelessWidget {
  final bool isPermanent;
  final VoidCallback onRetry;

  const _PermissionDeniedWidget({
    required this.isPermanent,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final message = isPermanent
        ? 'Permiso denegado permanentemente.\nVe a Configuración para habilitarlo.'
        : 'Necesitamos acceso a tu ubicación para mostrar artesanos cercanos.';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.settings),
              label: Text(
                isPermanent ? 'Abrir Configuración' : 'Intentar de nuevo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
