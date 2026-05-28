// ============================================================================
//  features/products/presentation/widgets/product_card.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(imageUrl: product.imageUrl),
                  if (product.isPremium)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A017),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '✦ Premium',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  if (!product.isAvailable)
                    Container(
                      color: Colors.black45,
                      alignment: Alignment.center,
                      child: const Text(
                        'Sin stock',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      product.formattedPrice,
                      style: const TextStyle(
                        color: Color(0xFF8B4513),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      product.category.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  final String imageUrl;

  const _ProductImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isEmpty || !cleanUrl.startsWith('http')) {
      return _imageFallback(
        icon: Icons.shopping_bag_outlined,
        text: 'Sin imagen',
      );
    }

    return Container(
      color: Colors.brown.shade50,
      child: CachedNetworkImage(
        imageUrl: cleanUrl,
        fit: BoxFit.contain,
        useOldImageOnUrlChange: true,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 100),
        memCacheWidth: 500,
        placeholder: (context, url) => _imagePlaceholder(),
        errorWidget: (context, url, error) => _imageFallback(
          icon: Icons.image_not_supported_outlined,
          text: 'Imagen no disponible',
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.brown.shade50,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _imageFallback({
    required IconData icon,
    required String text,
  }) {
    return Container(
      color: Colors.brown.shade50,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.brown,
            size: 34,
          ),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.brown.shade700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
