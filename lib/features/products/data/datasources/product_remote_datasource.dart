// ============================================================================
//  features/products/data/datasources/product_remote_datasource.dart
// ============================================================================

import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts();
  Future<ProductModel> fetchProductById(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio client;

  const ProductRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> fetchProducts() async {
    try {
      final response = await client.get('/products');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data as List<dynamic>;

        return data
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Error al obtener productos',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error de red',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }

  @override
  Future<ProductModel> fetchProductById(int id) async {
    try {
      final response = await client.get('/products/$id');

      // 🔥 FIX CLAVE
      if (response.statusCode == 200 && response.data != null) {
        return ProductModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: 'Producto #$id no encontrado',
          statusCode: response.statusCode ?? 404,
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error de red',
        statusCode: e.response?.statusCode ?? 500,
      );
    }
  }
}
