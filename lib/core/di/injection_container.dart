// ============================================================================
//  core/di/injection_container.dart
// ============================================================================

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../network/dio_client.dart';
import '../database/app_database.dart';

// Features - Products
import '../../features/products/data/datasources/product_remote_datasource.dart';
import '../../features/products/data/datasources/product_local_datasource.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_products_usecase.dart';
import '../../features/products/domain/usecases/get_product_detail_usecase.dart';
import '../../features/products/domain/usecases/search_products_usecase.dart';

// Features - Favorites
import '../../features/favorites/data/datasources/favorite_local_datasource.dart';
import '../../features/favorites/data/repositories/favorite_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorite_repository.dart';
import '../../features/favorites/domain/usecases/add_favorite_usecase.dart';
import '../../features/favorites/domain/usecases/get_favorites_usecase.dart';

// Features - Auth antiguo FakeStore
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/datasources/biometric_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/authenticate_biometric_usecase.dart';

// Features - Artisans
import '../../features/artisans/data/datasources/artisan_remote_datasource.dart';
import '../../features/artisans/data/repositories/artisan_repository_impl.dart';
import '../../features/artisans/domain/repositories/artisan_repository.dart';
import '../../features/artisans/domain/usecases/get_artisans_usecase.dart';

// Features - Location GPS Lab 17
import '../../features/location/data/datasources/location_datasource.dart';
import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_current_location_usecase.dart';
import '../../features/location/domain/usecases/watch_location_usecase.dart';

// Features - Camera Lab 18
import '../../features/camera/data/datasources/camera_datasource.dart';
import '../../features/camera/data/repositories/camera_repository_impl.dart';
import '../../features/camera/domain/repositories/camera_repository.dart';
import '../../features/camera/domain/usecases/pick_from_gallery_usecase.dart';
import '../../features/camera/domain/usecases/take_photo_usecase.dart';

// Features - AI Chat Lab 19
import '../../features/ai_chat/data/datasources/gemini_datasource.dart';
import '../../features/ai_chat/data/repositories/ai_chat_repository_impl.dart';
import '../../features/ai_chat/domain/repositories/ai_chat_repository.dart';
import '../../features/ai_chat/domain/usecases/get_chat_history_usecase.dart';
import '../../features/ai_chat/domain/usecases/send_message_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ══════════════════════════════════════════════════════════════════════════
  // INFRAESTRUCTURA
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());

  sl.registerLazySingleton<Dio>(() => DioClient.createDio());

  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ══════════════════════════════════════════════════════════════════════════
  // PRODUCTS
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(
      client: sl<Dio>(),
    ),
  );

  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(
      db: sl<AppDatabase>(),
    ),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl<ProductRemoteDataSource>(),
      localDataSource: sl<ProductLocalDataSource>(),
    ),
  );

  sl.registerFactory(
    () => GetProductsUseCase(
      repository: sl<ProductRepository>(),
    ),
  );

  sl.registerFactory(
    () => GetProductDetailUseCase(
      repository: sl<ProductRepository>(),
    ),
  );

  sl.registerFactory(
    () => SearchProductsUseCase(
      repository: sl<ProductRepository>(),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // FAVORITES
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<FavoriteLocalDataSource>(
    () => FavoriteLocalDataSourceImpl(
      db: sl<AppDatabase>(),
    ),
  );

  sl.registerLazySingleton<FavoriteRepository>(
    () => FavoriteRepositoryImpl(
      localDataSource: sl<FavoriteLocalDataSource>(),
      db: sl<AppDatabase>(),
    ),
  );

  sl.registerFactory(
    () => AddFavoriteUseCase(
      repository: sl<FavoriteRepository>(),
    ),
  );

  sl.registerFactory(
    () => RemoveFavoriteUseCase(
      repository: sl<FavoriteRepository>(),
    ),
  );

  sl.registerFactory(
    () => GetFavoritesUseCase(
      repository: sl<FavoriteRepository>(),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH ANTIGUO
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
    ),
  );

  sl.registerFactory(
    () => LoginUseCase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerFactory(
    () => LogoutUseCase(
      repository: sl<AuthRepository>(),
    ),
  );

  sl.registerFactory(
    () => GetCurrentUserUseCase(
      repository: sl<AuthRepository>(),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // ARTISANS
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<ArtisanRemoteDataSource>(
    () => ArtisanRemoteDataSourceImpl(
      client: sl<Dio>(),
    ),
  );

  sl.registerLazySingleton<ArtisanRepository>(
    () => ArtisanRepositoryImpl(
      remoteDataSource: sl<ArtisanRemoteDataSource>(),
    ),
  );

  sl.registerFactory(
    () => GetArtisansUseCase(
      repository: sl<ArtisanRepository>(),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // LOCATION GPS - LAB 17
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(),
  );

  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(
      sl<LocationDataSource>(),
    ),
  );

  sl.registerLazySingleton<LocationRepositoryImpl>(
    () => sl<LocationRepository>() as LocationRepositoryImpl,
  );

  sl.registerFactory(
    () => GetCurrentLocationUseCase(
      sl<LocationRepository>(),
    ),
  );

  sl.registerFactory(
    () => WatchLocationUseCase(
      sl<LocationRepository>(),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // CAMERA - LAB 18
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<CameraDataSource>(
    () => CameraDataSourceImpl(),
  );

  sl.registerLazySingleton<CameraRepository>(
    () => CameraRepositoryImpl(
      sl<CameraDataSource>(),
    ),
  );

  sl.registerFactory(
    () => TakePhotoUseCase(
      sl<CameraRepository>(),
    ),
  );

  sl.registerFactory(
    () => PickFromGalleryUseCase(
      sl<CameraRepository>(),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // BIOMETRIC - LAB 18
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<BiometricDataSource>(
    () => BiometricDataSourceImpl(),
  );

  sl.registerFactory(
    () => AuthenticateBiometricUseCase(
      sl<BiometricDataSource>(),
    ),
  );

  // ══════════════════════════════════════════════════════════════════════════
  // AI CHAT - LAB 19
  // ══════════════════════════════════════════════════════════════════════════

  sl.registerLazySingleton<GeminiDataSource>(
    () => GeminiDataSourceImpl(),
  );

  sl.registerLazySingleton<AiChatRepository>(
    () => AiChatRepositoryImpl(
      geminiDataSource: sl<GeminiDataSource>(),
      firestore: sl<FirebaseFirestore>(),
    ),
  );

  sl.registerFactory(
    () => SendMessageStreamingUseCase(
      sl<AiChatRepository>(),
    ),
  );

  sl.registerFactory(
    () => SendMessageUseCase(
      sl<AiChatRepository>(),
    ),
  );

  sl.registerFactory(
    () => GetChatHistoryUseCase(
      sl<AiChatRepository>(),
    ),
  );
}
