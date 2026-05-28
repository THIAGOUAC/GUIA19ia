// ============================================================================
//  features/products/data/models/product_firestore_model.dart
// ============================================================================

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import 'product_model.dart';

extension ProductModelFirestore on ProductModel {
  static ProductModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: int.tryParse(doc.id) ?? (data['id'] as num?)?.toInt() ?? 0,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? 'otro',
      imageUrl: data['imageUrl'] as String? ?? data['image'] as String? ?? '',
      stock: (data['stock'] as num?)?.toInt() ?? 0,
      artisan: data['artisan'] as String? ?? 'Artesano Andino',
      origin: data['origin'] as String? ?? 'Cusco',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'stock': stock,
      'artisan': artisan,
      'origin': origin,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProductsCompanion toDriftCompanion() {
    return ProductsCompanion.insert(
      id: Value(id),
      name: name,
      description: description,
      price: price,
      category: category,
      imageUrl: imageUrl,
      stock: Value(stock),
      artisan: Value(artisan),
      origin: Value(origin),
      cachedAt: Value(DateTime.now()),
    );
  }
}
