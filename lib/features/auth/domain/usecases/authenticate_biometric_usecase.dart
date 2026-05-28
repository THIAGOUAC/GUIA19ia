import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/datasources/biometric_datasource.dart';

class AuthenticateBiometricParams {
  final String reason;

  const AuthenticateBiometricParams({
    required this.reason,
  });
}

class AuthenticateBiometricUseCase {
  final BiometricDataSource dataSource;

  AuthenticateBiometricUseCase(this.dataSource);

  Future<Either<Failure, bool>> call(
    AuthenticateBiometricParams params,
  ) async {
    try {
      final isDeviceSupported = await dataSource.isDeviceSupported();
      final canCheckBiometrics = await dataSource.canCheckBiometrics();

      if (!isDeviceSupported || !canCheckBiometrics) {
        return const Left(
          BiometricFailure(
            message: 'Este dispositivo no tiene biometría disponible.',
          ),
        );
      }

      final authenticated = await dataSource.authenticate(
        reason: params.reason,
      );

      return Right(authenticated);
    } catch (e) {
      return Left(
        BiometricFailure(
          message: e.toString(),
        ),
      );
    }
  }
}