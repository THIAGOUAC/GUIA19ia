import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/location_model.dart';

/// Contrato del DataSource de ubicación.
///
/// Esta capa es la única que interactúa directamente con:
/// - geolocator
/// - permission_handler
///
/// El resto del proyecto nunca debe importar esos paquetes.
abstract class LocationDataSource {
  /// Obtiene la ubicación actual una sola vez.
  Future<LocationModel> getCurrentLocation();

  /// Escucha cambios de ubicación en tiempo real.
  Stream<LocationModel> watchLocation();

  /// Verifica si el permiso ya fue concedido.
  Future<bool> checkPermission();

  /// Solicita el permiso de localización al usuario.
  Future<bool> requestPermission();
}

/// Implementación concreta del datasource GPS.
class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<bool> checkPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  @override
  Future<bool> requestPermission() async {
    // Verificar primero si ya está concedido
    final current = await Permission.locationWhenInUse.status;

    if (current.isGranted) return true;

    // Si fue denegado permanentemente → abrir Configuración
    if (current.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    // Solicitar al usuario mediante diálogo nativo Android/iOS
    final result = await Permission.locationWhenInUse.request();

    return result.isGranted;
  }

  @override
  Future<LocationModel> getCurrentLocation() async {
    // geolocator usa MethodChannel internamente para comunicarse
    // con Android/iOS y obtener la ubicación actual.
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );

    return LocationModel.fromPosition(position);
  }

  @override
  Stream<LocationModel> watchLocation() {
    // geolocator usa EventChannel para emitir ubicaciones en tiempo real.
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,

        // Actualizar cada 10 metros de movimiento
        distanceFilter: 10,
      ),
    ).map((pos) => LocationModel.fromPosition(pos));
  }
}
