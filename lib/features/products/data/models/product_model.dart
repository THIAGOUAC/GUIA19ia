// ============================================================================
//  features/products/data/models/product_model.dart
// ============================================================================

import '../../domain/entities/product_entity.dart';

class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final String artisan;
  final String origin;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    required this.artisan,
    required this.origin,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int? ?? 0;
    final rawCategory = json['category'] as String? ?? 'otro';

    return ProductModel(
      id: id,
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: rawCategory,
      imageUrl:
          _resolveImageUrl(json['image'] ?? json['imageUrl'], id, rawCategory),
      stock: json['stock'] as int? ?? 10,
      artisan: json['artisan'] as String? ?? 'Artesano Andino',
      origin: json['origin'] as String? ?? 'Cusco',
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final id = map['id'] as int? ?? 0;
    final rawCategory = map['category'] as String? ?? 'otro';

    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: rawCategory,
      imageUrl:
          _resolveImageUrl(map['imageUrl'] ?? map['image'], id, rawCategory),
      stock: map['stock'] as int? ?? 0,
      artisan: map['artisan'] as String? ?? '',
      origin: map['origin'] as String? ?? '',
    );
  }

  ProductEntity toEntity() {
    final fixedImage = _resolveImageUrl(imageUrl, id, category);

    return ProductEntity(
      id: id,
      name: name,
      description: description,
      price: price,
      category: _mapCategory(category),
      imageUrl: fixedImage,
      stock: stock,
      artisan: artisan,
      origin: origin,
    );
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    final category = _categoryToString(entity.category);

    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      price: entity.price,
      category: category,
      imageUrl: _resolveImageUrl(entity.imageUrl, entity.id, category),
      stock: entity.stock,
      artisan: entity.artisan,
      origin: entity.origin,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'imageUrl': _resolveImageUrl(imageUrl, id, category),
        'stock': stock,
        'artisan': artisan,
        'origin': origin,
      };

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'imageUrl': _resolveImageUrl(imageUrl, id, category),
        'stock': stock,
        'artisan': artisan,
        'origin': origin,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      };

  static String _resolveImageUrl(dynamic rawImage, int id, String category) {
    final image = rawImage?.toString().trim() ?? '';

    if (image.startsWith('https://')) {
      return image;
    }

    final fallbackImages = <int, String>{
      1: 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png',
      2: 'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_t.png',
      3: 'https://fakestoreapi.com/img/71li-ujtlUL._AC_UX679_t.png',
      4: 'https://fakestoreapi.com/img/71YXzeOuslL._AC_UY879_t.png',
      5: 'https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_QL65_ML3_t.png',
      6: 'https://fakestoreapi.com/img/61sbMiUnoGL._AC_UL640_QL65_ML3_t.png',
      7: 'https://fakestoreapi.com/img/71YAIFU48IL._AC_UL640_QL65_ML3_t.png',
      8: 'https://fakestoreapi.com/img/51UDEzMJVpL._AC_UL640_QL65_ML3_t.png',
      9: 'https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_t.png',
      10: 'https://fakestoreapi.com/img/61U7T1koQqL._AC_SX679_t.png',
      11: 'https://fakestoreapi.com/img/71kWymZ+c+L._AC_SX679_t.png',
      12: 'https://fakestoreapi.com/img/61mtL65D4cL._AC_SX679_t.png',
      13: 'https://fakestoreapi.com/img/81QpkIctqPL._AC_SX679_t.png',
      14: 'https://fakestoreapi.com/img/81Zt42ioCgL._AC_SX679_t.png',
      15: 'https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_t.png',
      16: 'https://fakestoreapi.com/img/81XH0e8fefL._AC_UY879_t.png',
      17: 'https://fakestoreapi.com/img/71HblAHs5xL._AC_UY879_-2_t.png',
      18: 'https://fakestoreapi.com/img/71z3kpMAYsL._AC_UY879_t.png',
      19: 'https://fakestoreapi.com/img/51eg55uWmdL._AC_UX679_t.png',
      20: 'https://fakestoreapi.com/img/61pHAEJ4NML._AC_UX679_t.png',
    };

    return fallbackImages[id] ?? _fallbackByCategory(category);
  }

  static String _fallbackByCategory(String category) {
    switch (_mapCategory(category)) {
      case ProductCategory.textiles:
        return 'https://fakestoreapi.com/img/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_t.png';
      case ProductCategory.joyeria:
        return 'https://fakestoreapi.com/img/71pWzhdJNwL._AC_UL640_QL65_ML3_t.png';
      case ProductCategory.ceramica:
        return 'https://fakestoreapi.com/img/61IBBVJvSDL._AC_SY879_t.png';
      case ProductCategory.pintura:
        return 'https://fakestoreapi.com/img/51Y5NI-I5jL._AC_UX679_t.png';
      case ProductCategory.madera:
      case ProductCategory.otro:
        return 'https://fakestoreapi.com/img/81fPKd-2AYL._AC_SL1500_t.png';
    }
  }

  static ProductCategory _mapCategory(String category) {
    switch (category.toLowerCase()) {
      case "men's clothing":
      case 'textiles':
        return ProductCategory.textiles;
      case 'electronics':
      case 'ceramica':
      case 'cerámica':
        return ProductCategory.ceramica;
      case 'jewelery':
      case 'jewelry':
      case 'joyeria':
      case 'joyería':
        return ProductCategory.joyeria;
      case 'madera':
        return ProductCategory.madera;
      case "women's clothing":
      case 'pintura':
        return ProductCategory.pintura;
      default:
        return ProductCategory.otro;
    }
  }

  static String _categoryToString(ProductCategory category) {
    switch (category) {
      case ProductCategory.textiles:
        return 'textiles';
      case ProductCategory.ceramica:
        return 'ceramica';
      case ProductCategory.joyeria:
        return 'joyeria';
      case ProductCategory.madera:
        return 'madera';
      case ProductCategory.pintura:
        return 'pintura';
      case ProductCategory.otro:
        return 'otro';
    }
  }
}
