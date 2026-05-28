import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_current_location_usecase.dart';
import '../../domain/usecases/watch_location_usecase.dart';

enum LocationPermStatus {
  initial,
  requesting,
  granted,
  denied,
  permanentlyDenied,
}

final locationPermProvider =
    StateNotifierProvider<LocationPermNotifier, LocationPermStatus>(
  (ref) => LocationPermNotifier(),
);

class LocationPermNotifier extends StateNotifier<LocationPermStatus> {
  LocationPermNotifier() : super(LocationPermStatus.initial);

  Future<void> checkAndRequest() async {
    state = LocationPermStatus.requesting;

    final checkResult =
        await sl<LocationRepositoryImpl>().checkLocationPermission();

    checkResult.fold(
      (_) => state = LocationPermStatus.denied,
      (granted) {
        if (granted) {
          state = LocationPermStatus.granted;
        } else {
          _requestPermission();
        }
      },
    );
  }

  Future<void> _requestPermission() async {
    final result =
        await sl<LocationRepositoryImpl>().requestLocationPermission();

    result.fold(
      (_) => state = LocationPermStatus.denied,
      (granted) => state =
          granted ? LocationPermStatus.granted : LocationPermStatus.denied,
    );
  }
}

final currentLocationProvider =
    FutureProvider.autoDispose<LocationEntity?>((ref) async {
  final permStatus = ref.watch(locationPermProvider);

  if (permStatus != LocationPermStatus.granted) return null;

  final useCase = sl<GetCurrentLocationUseCase>();
  final result = await useCase(NoParams());

  return result.fold((_) => null, (loc) => loc);
});

final locationStreamProvider =
    StreamProvider.autoDispose<LocationEntity>((ref) {
  final permStatus = ref.watch(locationPermProvider);

  if (permStatus != LocationPermStatus.granted) {
    return const Stream.empty();
  }

  final useCase = sl<WatchLocationUseCase>();

  return useCase().map(
    (either) => either.fold(
      (failure) => throw Exception(failure.message),
      (loc) => loc,
    ),
  );
});

final locationHistoryProvider =
    StateProvider<List<LocationEntity>>((ref) => []);
