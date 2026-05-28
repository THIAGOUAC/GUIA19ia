// ============================================================================
//  features/auth/data/repositories/auth_repository_impl.dart
// ============================================================================

import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

// 🔐 Storage seguro
const _storage = FlutterSecureStorage();
const _userKey = 'cached_user';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AuthEntity>> login(
      String email, String password) async {
    try {
      final model = await remoteDataSource.login(email, password);
      final entity = model.toEntity();

      // 🔐 Guardar usuario en storage seguro
      await _storage.write(
        key: _userKey,
        value: entity.toJson(), // 👈 necesitas esto en tu entidad
      );

      return Right(entity);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();

      // 🔐 eliminar sesión
      await _storage.delete(key: _userKey);

      return const Right(null);
    } on ServerException catch (e) {
      return Left(AuthFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> getCurrentUser() async {
    try {
      final jsonString = await _storage.read(key: _userKey);

      if (jsonString == null) return const Right(null);

      // 🔐 reconstruir usuario
      final entity = AuthEntity.fromJson(jsonString);

      return Right(entity);
    } catch (e) {
      return const Right(null);
    }
  }
}
