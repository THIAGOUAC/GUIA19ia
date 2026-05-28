import 'package:artesanias_andinas/core/errors/failures.dart';
import 'package:artesanias_andinas/core/usecases/usecase.dart';
import 'package:artesanias_andinas/features/location/domain/entities/location_entity.dart';
import 'package:artesanias_andinas/features/location/domain/repositories/location_repository.dart';
import 'package:artesanias_andinas/features/location/domain/usecases/get_current_location_usecase.dart';
import 'package:artesanias_andinas/features/location/domain/usecases/watch_location_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'location_test.mocks.dart';

@GenerateMocks([LocationRepository])
void main() {
  late MockLocationRepository mockRepo;
  late GetCurrentLocationUseCase getCurrentUseCase;
  late WatchLocationUseCase watchUseCase;

  final tLocation = LocationEntity(
    latitude: -13.5319,
    longitude: -71.9675,
    accuracy: 12.5,
    altitude: 3399.0,
    speed: 0.0,
    timestamp: DateTime(2026, 5, 14),
  );

  setUp(() {
    mockRepo = MockLocationRepository();
    getCurrentUseCase = GetCurrentLocationUseCase(mockRepo);
    watchUseCase = WatchLocationUseCase(mockRepo);
  });

  group('LocationEntity — reglas de negocio', () {
    test('isAccurate retorna true si accuracy <= 50 metros', () {
      expect(tLocation.isAccurate, isTrue);
    });

    test('isAccurate retorna false si accuracy > 50 metros', () {
      final imprecise = LocationEntity(
        latitude: -13.5,
        longitude: -71.9,
        accuracy: 120.0,
        timestamp: DateTime.now(),
      );

      expect(imprecise.isAccurate, isFalse);
    });

    test('isFresh retorna true si timestamp es reciente', () {
      final fresh = LocationEntity(
        latitude: -13.5,
        longitude: -71.9,
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      );

      expect(fresh.isFresh, isTrue);
    });

    test('isFresh retorna false si timestamp es mayor a 5 minutos', () {
      final stale = LocationEntity(
        latitude: -13.5,
        longitude: -71.9,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      expect(stale.isFresh, isFalse);
    });
  });

  group('GetCurrentLocationUseCase', () {
    test('retorna LocationEntity cuando el repositorio tiene éxito', () async {
      when(mockRepo.getCurrentLocation()).thenAnswer(
        (_) async => Right(tLocation),
      );

      final result = await getCurrentUseCase(NoParams());

      expect(result, Right(tLocation));
      verify(mockRepo.getCurrentLocation()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('retorna LocationFailure cuando el repositorio falla', () async {
      const failure = LocationFailure(message: 'GPS no disponible');

      when(mockRepo.getCurrentLocation()).thenAnswer(
        (_) async => const Left(failure),
      );

      final result = await getCurrentUseCase(NoParams());

      expect(result, const Left(failure));
    });
  });

  group('WatchLocationUseCase — Stream', () {
    test('retorna Stream de LocationEntity cuando hay permiso', () async {
      final locations = [
        tLocation,
        LocationEntity(
          latitude: -13.5320,
          longitude: -71.9680,
          accuracy: 12.5,
          altitude: 3399.0,
          speed: 0.0,
          timestamp: DateTime(2026, 5, 14),
        ),
      ];

      when(mockRepo.watchLocation()).thenAnswer(
        (_) => Stream.fromIterable(
          locations.map((location) => Right(location)),
        ),
      );

      final result = watchUseCase();
      final emitted = await result.toList();

      expect(emitted.length, 2);
      expect(emitted[0], Right(locations[0]));
      expect(emitted[1], Right(locations[1]));
    });

    test('Stream vacío cuando el repositorio no emite', () async {
      when(mockRepo.watchLocation()).thenAnswer(
        (_) => const Stream.empty(),
      );

      final result = watchUseCase();
      final emitted = await result.toList();

      expect(emitted, isEmpty);
    });
  });

  group('Gestión de permisos', () {
    test('checkLocationPermission retorna true cuando está concedido',
        () async {
      when(mockRepo.checkLocationPermission()).thenAnswer(
        (_) async => const Right(true),
      );

      final result = await mockRepo.checkLocationPermission();

      expect(result, const Right(true));
    });
    test('requestLocationPermission retorna false cuando se deniega', () async {
      when(mockRepo.requestLocationPermission()).thenAnswer(
        (_) async => const Right(false),
      );

      final result = await mockRepo.requestLocationPermission();

      expect(result, const Right(false));
    });
  });
}
