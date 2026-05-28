// ============================================================================
//  features/products/presentation/pages/product_list_page.dart
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';

import '../controllers/product_controller.dart';

import '../widgets/product_card.dart';
import '../widgets/category_filter_bar.dart';

class ProductListPage extends ConsumerWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productListProvider);

    final filteredProducts = ref.watch(filteredProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Artesanías Andinas'),
        actions: [
          // ── Favoritos ───────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Favoritos',
            onPressed: () => context.go('/favorites'),
          ),

          // ── GPS / Mapa ──────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'GPS',
            onPressed: () => context.push('/location'),
          ),

          // ── Perfil de usuario ──────────────────────────────────
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () => context.push('/profile'),
          ),

          // ── Buscar productos ───────────────────────────────────
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Buscar',
            onPressed: () => _showSearch(context, ref),
          ),

          // ── Logout ─────────────────────────────────────────────
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barra de filtros por categoría ────────────────────
          const CategoryFilterBar(),

          Expanded(
            child: productsState.when(
              // ── Loading ────────────────────────────────────────
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              // ── Error ──────────────────────────────────────────
              error: (error, _) => Center(
                child: Text(
                  'Error: $error',
                  textAlign: TextAlign.center,
                ),
              ),

              // ── Data ───────────────────────────────────────────
              data: (_) {
                // Lista vacía
                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron productos',
                    ),
                  );
                }

                // Lista de productos
                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(productListProvider.notifier).refresh(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (ctx, i) {
                      return ProductCard(
                        product: filteredProducts[i],
                        onTap: () => context.go(
                          '/products/${filteredProducts[i].id}',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  // Mostrar buscador
  // ────────────────────────────────────────────────────────────────
  void _showSearch(BuildContext context, WidgetRef ref) {
    showSearch(
      context: context,
      delegate: _ProductSearchDelegate(ref),
    );
  }
}

// ============================================================================
//  SEARCH DELEGATE
// ============================================================================

class _ProductSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  _ProductSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) => [
        // Limpiar búsqueda
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';

            ref.read(searchResultsProvider.notifier).clear();

            showSuggestions(context);
          },
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          ref.read(searchResultsProvider.notifier).clear();

          close(context, '');
        },
      );

  @override
  Widget buildResults(BuildContext context) {
    // Query vacía
    if (query.trim().isEmpty) {
      return const Center(
        child: Text('Escribe algo para buscar'),
      );
    }

    // Ejecutar búsqueda
    Future.microtask(
      () => ref.read(searchResultsProvider.notifier).search(
            query.trim(),
          ),
    );

    return _buildResultsList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Menos de 3 caracteres
    if (query.trim().length < 3) {
      return const Center(
        child: Text(
          'Escribe al menos 3 caracteres',
        ),
      );
    }

    // Buscar sugerencias
    Future.microtask(
      () => ref.read(searchResultsProvider.notifier).search(
            query.trim(),
          ),
    );

    return _buildResultsList(context);
  }

  // ────────────────────────────────────────────────────────────────
  // Lista de resultados
  // ────────────────────────────────────────────────────────────────
  Widget _buildResultsList(BuildContext context) {
    final results = ref.watch(searchResultsProvider);

    return results.when(
      // Loading
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),

      // Error
      error: (e, _) => Center(
        child: Text('Error: $e'),
      ),

      // Data
      data: (products) {
        // Sin resultados
        if (products.isEmpty) {
          return const Center(
            child: Text('Sin resultados'),
          );
        }

        // Lista encontrada
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (ctx, i) => ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(products[i].name),
            subtitle: Text(products[i].formattedPrice),
            onTap: () {
              ref.read(searchResultsProvider.notifier).clear();

              close(context, '');

              context.go('/products/${products[i].id}');
            },
          ),
        );
      },
    );
  }
}
