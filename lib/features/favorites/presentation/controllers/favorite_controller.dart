// ============================================================================
//  features/favorites/presentation/controllers/favorite_controller.dart
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/favorite_repository_impl.dart';
import '../../domain/entities/favorite_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../../domain/usecases/add_favorite_usecase.dart';
import '../../domain/usecases/get_favorites_usecase.dart';
import '../../../products/domain/entities/product_entity.dart';

final favoritesProvider =
    AsyncNotifierProvider<FavoritesController, List<FavoriteEntity>>(
  FavoritesController.new,
);

class FavoritesController extends AsyncNotifier<List<FavoriteEntity>> {
  late final GetFavoritesUseCase _getFavorites;
  late final AddFavoriteUseCase _addFavorite;
  late final RemoveFavoriteUseCase _removeFavorite;

  @override
  Future<List<FavoriteEntity>> build() async {
    _getFavorites = sl<GetFavoritesUseCase>();
    _addFavorite = sl<AddFavoriteUseCase>();
    _removeFavorite = sl<RemoveFavoriteUseCase>();

    await syncPendingActions();

    return _load();
  }

  Future<List<FavoriteEntity>> _load() async {
    final result = await _getFavorites(NoParams());

    return result.fold(
      (f) => throw Exception(f.message),
      (list) => list,
    );
  }

  Future<void> addFavorite(ProductEntity product) async {
    await _addFavorite(
      AddFavoriteParams(
        productId: product.id,
        productName: product.name,
      ),
    );

    await syncPendingActions();

    state = AsyncValue.data(await _load());
  }

  Future<void> removeFavorite(int productId) async {
    await _removeFavorite(
      RemoveFavoriteParams(productId: productId),
    );

    await syncPendingActions();

    state = AsyncValue.data(await _load());
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();

    await syncPendingActions();

    state = AsyncValue.data(await _load());
  }

  Future<void> syncPendingActions() async {
    final repository = sl<FavoriteRepository>();

    if (repository is FavoriteRepositoryImpl) {
      await repository.syncPendingActions();
    }
  }
}
