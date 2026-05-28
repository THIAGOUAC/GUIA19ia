import 'package:drift/drift.dart'; // 🔥 NECESARIO para Value

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/favorite_model.dart';

abstract class FavoriteLocalDataSource {
  Future<List<FavoriteModel>> getFavorites();
  Future<void> addFavorite(int productId, String productName);
  Future<void> removeFavorite(int productId);
  Future<bool> isFavorite(int productId);
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  final AppDatabase db;

  const FavoriteLocalDataSourceImpl({required this.db});

  @override
  Future<List<FavoriteModel>> getFavorites() async {
    try {
      final result = await db.select(db.favorites).get();

      return result
          .map(
            (f) => FavoriteModel(
              productId: f.productId,
              productName: f.productName,
              addedAt: f.addedAt.millisecondsSinceEpoch,
            ),
          )
          .toList();
    } catch (e) {
      throw DatabaseException(message: 'Error al obtener favoritos: $e');
    }
  }

  @override
  Future<void> addFavorite(int productId, String productName) async {
    try {
      await db.into(db.favorites).insertOnConflictUpdate(
            FavoritesCompanion.insert(
              productId: Value(productId), // ✅ ahora funciona
              productName: productName,
            ),
          );
    } catch (e) {
      throw DatabaseException(message: 'Error al agregar favorito: $e');
    }
  }

  @override
  Future<void> removeFavorite(int productId) async {
    try {
      await (db.delete(db.favorites)
            ..where((f) => f.productId.equals(productId)))
          .go();
    } catch (e) {
      throw DatabaseException(message: 'Error al eliminar favorito: $e');
    }
  }

  @override
  Future<bool> isFavorite(int productId) async {
    try {
      final result = await (db.select(db.favorites)
            ..where((f) => f.productId.equals(productId)))
          .get();

      return result.isNotEmpty;
    } catch (e) {
      throw DatabaseException(message: 'Error al verificar favorito: $e');
    }
  }
}
