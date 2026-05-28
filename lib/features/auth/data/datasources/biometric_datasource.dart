import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

abstract class BiometricDataSource {
  Future<bool> isDeviceSupported();

  Future<bool> canCheckBiometrics();

  Future<List<BiometricType>> getAvailableBiometrics();

  Future<bool> authenticate({
    required String reason,
  });
}

class BiometricDataSourceImpl implements BiometricDataSource {
  final LocalAuthentication _auth;

  BiometricDataSourceImpl({
    LocalAuthentication? auth,
  }) : _auth = auth ?? LocalAuthentication();

  @override
  Future<bool> isDeviceSupported() {
    return _auth.isDeviceSupported();
  }

  @override
  Future<bool> canCheckBiometrics() {
    return _auth.canCheckBiometrics;
  }

  @override
  Future<List<BiometricType>> getAvailableBiometrics() {
    return _auth.getAvailableBiometrics();
  }

  @override
  Future<bool> authenticate({
    required String reason,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable ||
          e.code == auth_error.notEnrolled) {
        return false;
      }

      if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        throw Exception('Biometría bloqueada. Usa el PIN o contraseña.');
      }

      rethrow;
    }
  }
}