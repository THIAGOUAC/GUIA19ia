// ============================================================================
//  features/favorites/data/repositories/favorite_repository_impl.dart
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';

import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorite_repository.dart';

import '../datasources/favorite_local_datasource.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource localDataSource;
  final AppDatabase db;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FavoriteRepositoryImpl({
    required this.localDataSource,
    required this.db,
  });

  @override
  Future<Either<Failure, List<FavoriteEntity>>> getFavorites() async {
    try {
      await syncFavoritesFromCloud();

      final models = await localDataSource.getFavorites();

      return Right(
        models.map((m) => m.toEntity()).toList(),
      );
    } on DatabaseException catch (e) {
      return Left(
        DatabaseFailure(message: e.message),
      );
    } catch (e) {
      return Left(
        DatabaseFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(
    int productId,
    String productName,
  ) async {
    try {
      await localDataSource.addFavorite(
        productId,
        productName,
      );

      await db.into(db.syncQueue).insert(
            SyncQueueCompanion.insert(
              action: 'add_favorite',
              productId: productId,
            ),
          );

      await _syncFavoriteToCloud(
        productId: productId,
        productName: productName,
      );

      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(
    int productId,
  ) async {
    try {
      await localDataSource.removeFavorite(productId);

      await db.into(db.syncQueue).insert(
            SyncQueueCompanion.insert(
              action: 'remove_favorite',
              productId: productId,
            ),
          );

      await _removeFavoriteFromCloud(productId);

      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(
    int productId,
  ) async {
    try {
      final result = await localDataSource.isFavorite(productId);

      return Right(result);
    } on DatabaseException catch (e) {
      return Left(
        DatabaseFailure(message: e.message),
      );
    }
  }

  Future<void> syncFavoritesFromCloud() async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final productId = int.tryParse(doc.id) ?? 0;
      final productName = data['productName'] as String? ?? 'Producto';

      if (productId > 0) {
        await localDataSource.addFavorite(
          productId,
          productName,
        );
      }
    }
  }

  Future<Either<Failure, void>> syncPendingActions() async {
    try {
      final pendingActions = await db.select(db.syncQueue).get();

      for (final action in pendingActions) {
        if (action.action == 'add_favorite') {
          await _syncFavoriteToCloud(
            productId: action.productId,
            productName: 'Producto',
          );
        }

        if (action.action == 'remove_favorite') {
          await _removeFavoriteFromCloud(
            action.productId,
          );
        }

        await (db.delete(db.syncQueue)..where((q) => q.id.equals(action.id)))
            .go();
      }

      return const Right(null);
    } catch (e) {
      return Left(
        DatabaseFailure(
          message: 'Error al sincronizar pendientes: $e',
        ),
      );
    }
  }

  Future<void> _syncFavoriteToCloud({
    required int productId,
    required String productName,
  }) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId.toString())
        .set({
      'productId': productId,
      'productName': productName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _removeFavoriteFromCloud(
    int productId,
  ) async {
    final uid = _auth.currentUser?.uid;

    if (uid == null) return;

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(productId.toString())
        .delete();
  }
}
