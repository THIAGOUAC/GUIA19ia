import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<ProductModel> getCachedProductById(int id);
  Future<void> cacheProducts(List<ProductModel> products);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final AppDatabase db;

  const ProductLocalDataSourceImpl({required this.db});

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final result = await db.select(db.products).get();

      if (result.isEmpty) {
        throw const CacheException(message: 'No hay productos en caché');
      }

      return result.map((p) {
        return ProductModel(
          id: p.id,
          name: p.name,
          description: p.description,
          price: p.price,
          category: p.category,
          imageUrl: p.imageUrl,
          stock: p.stock,
          artisan: p.artisan ?? '',
          origin: p.origin ?? '',
        );
      }).toList();
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<ProductModel> getCachedProductById(int id) async {
    try {
      final result =
          await (db.select(db.products)..where((p) => p.id.equals(id))).get();

      if (result.isEmpty) {
        throw const CacheException(message: 'Producto no encontrado');
      }

      final p = result.first;

      return ProductModel(
        id: p.id,
        name: p.name,
        description: p.description,
        price: p.price,
        category: p.category,
        imageUrl: p.imageUrl,
        stock: p.stock,
        artisan: p.artisan ?? '',
        origin: p.origin ?? '',
      );
    } catch (e) {
      throw CacheException(message: e.toString());
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      await db.batch((batch) {
        batch.deleteAll(db.products);

        batch.insertAll(
          db.products,
          products.map((p) {
            return ProductsCompanion.insert(
              id: Value(p.id), // 🔥 CLAVE
              name: p.name,
              description: p.description,
              price: p.price,
              category: p.category,
              imageUrl: p.imageUrl,
              stock: Value(p.stock),
              artisan: Value(p.artisan),
              origin: Value(p.origin),
              cachedAt: Value(DateTime.now()),
            );
          }).toList(),
        );
      });
    } catch (e) {
      throw DatabaseException(message: 'Error guardando productos: $e');
    }
  }
}
