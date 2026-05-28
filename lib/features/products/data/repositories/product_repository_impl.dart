// ============================================================================
//  features/products/data/repositories/product_repository_impl.dart
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

import '../models/product_model.dart';
import '../models/product_firestore_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  // ==========================================================================
  // CACHE-FIRST + CLOUD SYNC
  // ==========================================================================

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts() async {
    try {
      // ─────────────────────────────────────────────────────────────────────
      // 1. DEVOLVER CACHE LOCAL INMEDIATAMENTE
      // ─────────────────────────────────────────────────────────────────────

      final cachedProducts = await localDataSource.getCachedProducts();

      // ─────────────────────────────────────────────────────────────────────
      // 2. SINCRONIZAR FIRESTORE EN BACKGROUND
      // ─────────────────────────────────────────────────────────────────────

      _syncProductsFromCloud();

      // ─────────────────────────────────────────────────────────────────────
      // 3. RETORNAR CACHE
      // ─────────────────────────────────────────────────────────────────────

      return Right(
        cachedProducts.map((e) => e.toEntity()).toList(),
      );
    } catch (_) {
      try {
        // Fallback FakeStore
        final remoteProducts = await remoteDataSource.fetchProducts();

        await localDataSource.cacheProducts(
          remoteProducts,
        );

        return Right(
          remoteProducts.map((e) => e.toEntity()).toList(),
        );
      } catch (_) {
        return const Left(
          DatabaseFailure(
            message: 'No hay conexión y no existen productos guardados.',
          ),
        );
      }
    }
  }

  // ==========================================================================
  // PRODUCT DETAIL
  // ==========================================================================

  @override
  Future<Either<Failure, ProductEntity>> getProductById(
    int id,
  ) async {
    try {
      final cached = await localDataSource.getCachedProductById(id);

      return Right(cached.toEntity());
    } catch (_) {
      try {
        final doc =
            await _firestore.collection('products').doc(id.toString()).get();

        if (!doc.exists) {
          throw Exception('Producto no encontrado');
        }

        final model = ProductModelFirestore.fromFirestore(doc);

        await localDataSource.cacheProducts([model]);

        return Right(model.toEntity());
      } catch (_) {
        return const Left(
          DatabaseFailure(
            message: 'Producto no encontrado',
          ),
        );
      }
    }
  }

  // ==========================================================================
  // SEARCH
  // ==========================================================================

  @override
  Future<Either<Failure, List<ProductEntity>>> searchProducts(
    String query,
  ) async {
    try {
      final cached = await localDataSource.getCachedProducts();

      final q = query.trim().toLowerCase();

      if (q.isEmpty) {
        return Right(
          cached.map((e) => e.toEntity()).toList(),
        );
      }

      final results = cached
          .where(
            (m) =>
                m.name.toLowerCase().contains(q) ||
                m.description.toLowerCase().contains(q) ||
                m.category.toLowerCase().contains(q) ||
                m.artisan.toLowerCase().contains(q) ||
                m.origin.toLowerCase().contains(q),
          )
          .map((e) => e.toEntity())
          .toList();

      return Right(results);
    } catch (_) {
      return const Right([]);
    }
  }

  // ==========================================================================
  // CATEGORY
  // ==========================================================================

  @override
  Future<Either<Failure, List<ProductEntity>>> getProductsByCategory(
    ProductCategory category,
  ) async {
    try {
      final cached = await localDataSource.getCachedProducts();

      final results = cached
          .where((m) => m.category == category.name)
          .map((e) => e.toEntity())
          .toList();

      return Right(results);
    } catch (_) {
      return const Right([]);
    }
  }

  // ==========================================================================
  // CACHE PRODUCTS
  // ==========================================================================

  @override
  Future<Either<Failure, void>> cacheProducts(
    List<ProductEntity> products,
  ) async {
    try {
      final models = products.map(ProductModel.fromEntity).toList();

      await localDataSource.cacheProducts(models);

      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(
        DatabaseFailure(
          message: e.message,
        ),
      );
    }
  }

  // ==========================================================================
  // FIRESTORE → DRIFT SYNC
  // ==========================================================================

  Future<void> _syncProductsFromCloud() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      final products = snapshot.docs
          .map(
            (doc) => ProductModelFirestore.fromFirestore(doc),
          )
          .toList();

      await localDataSource.cacheProducts(products);
    } catch (_) {
      // sync silencioso
    }
  }
}
