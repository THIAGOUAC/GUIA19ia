import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/biometric_datasource.dart';
import '../../domain/usecases/authenticate_biometric_usecase.dart';

enum BiometricStatus {
  checking,
  unavailable,
  available,
  authenticating,
  success,
  failed,
}

class BiometricState {
  final BiometricStatus status;
  final List<BiometricType> availableTypes;
  final String? errorMessage;

  const BiometricState({
    this.status = BiometricStatus.checking,
    this.availableTypes = const [],
    this.errorMessage,
  });

  BiometricState copyWith({
    BiometricStatus? status,
    List<BiometricType>? availableTypes,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BiometricState(
      status: status ?? this.status,
      availableTypes: availableTypes ?? this.availableTypes,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class BiometricNotifier extends StateNotifier<BiometricState> {
  final BiometricDataSource _dataSource;
  final AuthenticateBiometricUseCase _authenticateBiometric;

  BiometricNotifier(
    this._dataSource,
    this._authenticateBiometric,
  ) : super(const BiometricState()) {
    checkAvailability();
  }

  Future<void> checkAvailability() async {
    try {
      final isDeviceSupported = await _dataSource.isDeviceSupported();
      final canCheckBiometrics = await _dataSource.canCheckBiometrics();

      if (!isDeviceSupported || !canCheckBiometrics) {
        state = state.copyWith(status: BiometricStatus.unavailable);
        return;
      }

      final types = await _dataSource.getAvailableBiometrics();

      state = state.copyWith(
        status: BiometricStatus.available,
        availableTypes: types,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: BiometricStatus.unavailable,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> authenticate() async {
    state = state.copyWith(
      status: BiometricStatus.authenticating,
      clearError: true,
    );

    final result = await _authenticateBiometric(
      const AuthenticateBiometricParams(
        reason: 'Verifica tu identidad para volver a entrar a Artesanías Andinas',
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: BiometricStatus.failed,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copyWith(
          status: success ? BiometricStatus.success : BiometricStatus.failed,
          errorMessage: success ? null : 'No se pudo verificar tu identidad.',
        );
      },
    );
  }

  void resetToAvailable() {
    state = state.copyWith(
      status: BiometricStatus.available,
      clearError: true,
    );
  }
}

final biometricProvider =
    StateNotifierProvider<BiometricNotifier, BiometricState>(
  (ref) {
    return BiometricNotifier(
      sl<BiometricDataSource>(),
      sl<AuthenticateBiometricUseCase>(),
    );
  },
);