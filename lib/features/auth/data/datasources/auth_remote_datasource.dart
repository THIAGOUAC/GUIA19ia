// ============================================================================
//  features/auth/data/datasources/auth_remote_datasource.dart
// ============================================================================

import '../../../../core/errors/exceptions.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login(String email, String password);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<AuthModel> login(String email, String password) async {
    // 👇 Credenciales que muestra la UI
    const fixedUser = 'johnd@gmail.com';
    const fixedPass = 'johnd@21_3';

    // ✅ VALIDACIÓN
    if (email != fixedUser || password != fixedPass) {
      throw const ServerException(
        message: 'Usuario o contraseña incorrectos',
      );
    }

    // ⏳ Simulación de request
    await Future.delayed(const Duration(milliseconds: 300));

    // ✅ RESPUESTA
    return const AuthModel(
      id: '1',
      name: 'John Doe',
      email: fixedUser,
      role: 'customer',
      token: 'demo_token_123',
    );
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
