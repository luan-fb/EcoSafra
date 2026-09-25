import 'package:clock/clock.dart';
import 'package:drift/native.dart';
import 'package:ecosafra/core/database/app_database.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/auth/domain/entities/app_user.dart';
import 'package:ecosafra/features/auth/domain/repositories/auth_repository.dart';
import 'package:ecosafra/features/weather/data/datasources/chosen_location_local_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/device_location_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/device_place_name_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/drift_chosen_location_local_data_source.dart';
import 'package:ecosafra/features/weather/data/repositories/location_repository_impl.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceLocationDataSource extends Mock
    implements DeviceLocationDataSource {}

class MockDevicePlaceNameDataSource extends Mock
    implements DevicePlaceNameDataSource {}

class MockChosenLocationLocalDataSource extends Mock
    implements ChosenLocationLocalDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

const _alice = AppUser(uid: 'uid-alice');
const _bob = AppUser(uid: 'uid-bob');

const _gps = Coordinates(latitude: -15.6, longitude: -56.1);

const _sorriso = Place(
  name: 'Sorriso',
  region: 'Mato Grosso',
  country: 'Brasil',
  coordinates: Coordinates(latitude: -12.54528, longitude: -55.71139),
);

const _signedOut = AuthFailure(
  'É preciso estar logado para escolher a localização.',
);

void main() {
  late MockDeviceLocationDataSource device;
  late MockDevicePlaceNameDataSource placeName;
  late MockAuthRepository authRepository;

  setUpAll(() {
    registerFallbackValue(_gps);
    registerFallbackValue(_sorriso);
  });

  setUp(() {
    device = MockDeviceLocationDataSource();
    placeName = MockDevicePlaceNameDataSource();
    authRepository = MockAuthRepository();
    when(() => device.getCurrentLocation()).thenAnswer((_) async => _gps);
    when(() => authRepository.currentUser).thenReturn(_alice);
  });

  void signInAs(AppUser? user) =>
      when(() => authRepository.currentUser).thenReturn(user);

  group('com o banco em memória', () {
    late AppDatabase database;
    late LocationRepositoryImpl repository;

    setUp(() {
      database = AppDatabase.withExecutor(NativeDatabase.memory());
      repository = LocationRepositoryImpl(
        device: device,
        chosen: DriftChosenLocationLocalDataSource(
          database,
          Clock.fixed(DateTime(2026, 9, 25, 8)),
        ),
        placeName: placeName,
        authRepository: authRepository,
      );
    });

    tearDown(() => database.close());

    test('sem escolhida: getCurrentLocation vem do GPS', () async {
      final result = await repository.getCurrentLocation();

      expect(result, const Right<Failure, Coordinates>(_gps));
      verify(() => device.getCurrentLocation()).called(1);
    });

    test(
      'com escolhida: devolve as coordenadas dela sem chamar o GPS',
      () async {
        await repository.choosePlace(_sorriso);

        final result = await repository.getCurrentLocation();

        expect(
          result,
          const Right<Failure, Coordinates>(
            Coordinates(latitude: -12.54528, longitude: -55.71139),
          ),
        );
        verifyNever(() => device.getCurrentLocation());
      },
    );

    test('choosePlace devolve Right e getChosenPlace lê o lugar', () async {
      expect(
        await repository.choosePlace(_sorriso),
        isA<Right<Failure, void>>(),
      );

      expect(await repository.getChosenPlace(), _sorriso);
    });

    test('clearChosenPlace volta ao GPS', () async {
      await repository.choosePlace(_sorriso);

      expect(
        await repository.clearChosenPlace(),
        isA<Right<Failure, void>>(),
      );
      final result = await repository.getCurrentLocation();

      expect(result, const Right<Failure, Coordinates>(_gps));
      expect(await repository.getChosenPlace(), isNull);
      verify(() => device.getCurrentLocation()).called(1);
    });

    test('a conta B não vê a escolha da conta A', () async {
      await repository.choosePlace(_sorriso);

      signInAs(_bob);

      expect(await repository.getChosenPlace(), isNull);
      expect(
        await repository.getCurrentLocation(),
        const Right<Failure, Coordinates>(_gps),
      );
      verify(() => device.getCurrentLocation()).called(1);

      signInAs(_alice);

      expect(await repository.getChosenPlace(), _sorriso);
    });

    test('sem conta: getCurrentLocation vai ao GPS', () async {
      signInAs(null);

      expect(
        await repository.getCurrentLocation(),
        const Right<Failure, Coordinates>(_gps),
      );
      expect(await repository.getChosenPlace(), isNull);
    });

    test('sem conta: choosePlace devolve AuthFailure', () async {
      signInAs(null);

      expect(
        await repository.choosePlace(_sorriso),
        const Left<Failure, void>(_signedOut),
      );
    });

    test('sem conta: clearChosenPlace devolve AuthFailure', () async {
      signInAs(null);

      expect(
        await repository.clearChosenPlace(),
        const Left<Failure, void>(_signedOut),
      );
    });

    test('falha do GPS sem escolhida: LocationFailure', () async {
      when(() => device.getCurrentLocation()).thenThrow(
        const LocationException('GPS desligado.'),
      );

      expect(
        await repository.getCurrentLocation(),
        const Left<Failure, Coordinates>(LocationFailure('GPS desligado.')),
      );
    });

    group('describe', () {
      test('com escolhida: nome dela e fonte chosen', () async {
        await repository.choosePlace(_sorriso);

        final description = await repository.describe(_sorriso.coordinates);

        expect(
          description,
          const LocationDescription(
            label: 'Sorriso, Mato Grosso',
            source: LocationSource.chosen,
          ),
        );
        verifyNever(() => placeName.describe(any()));
      });

      test('GPS com nome: "Cidade, Estado" e fonte device', () async {
        when(
          () => placeName.describe(_gps),
        ).thenAnswer((_) async => 'Cuiabá, Mato Grosso');

        final description = await repository.describe(_gps);

        expect(
          description,
          const LocationDescription(
            label: 'Cuiabá, Mato Grosso',
            source: LocationSource.device,
          ),
        );
      });

      test('GPS sem nome: coordenadas com 2 casas e vírgula', () async {
        when(() => placeName.describe(any())).thenAnswer((_) async => null);

        final description = await repository.describe(
          const Coordinates(latitude: -15.59611, longitude: -56.09667),
        );

        expect(
          description,
          const LocationDescription(
            label: '-15,60, -56,10',
            source: LocationSource.device,
          ),
        );
      });
    });
  });

  group('com erro no banco', () {
    late MockChosenLocationLocalDataSource chosen;
    late LocationRepositoryImpl repository;

    setUp(() {
      chosen = MockChosenLocationLocalDataSource();
      repository = LocationRepositoryImpl(
        device: device,
        chosen: chosen,
        placeName: placeName,
        authRepository: authRepository,
      );
    });

    test('erro ao ler a escolhida: cai para o GPS', () async {
      when(() => chosen.get(any())).thenThrow(Exception('database locked'));

      expect(
        await repository.getCurrentLocation(),
        const Right<Failure, Coordinates>(_gps),
      );
      verify(() => device.getCurrentLocation()).called(1);
    });

    test('erro ao gravar a escolhida: CacheFailure', () async {
      when(
        () => chosen.save(any(), any()),
      ).thenThrow(Exception('disk I/O error'));

      expect(
        await repository.choosePlace(_sorriso),
        const Left<Failure, void>(
          CacheFailure('Não foi possível salvar a localização escolhida.'),
        ),
      );
    });

    test('erro ao apagar a escolhida: CacheFailure', () async {
      when(() => chosen.clear(any())).thenThrow(Exception('disk I/O error'));

      expect(
        await repository.clearChosenPlace(),
        const Left<Failure, void>(
          CacheFailure('Não foi possível voltar à localização do aparelho.'),
        ),
      );
    });

    test('grava com o uid da conta logada', () async {
      when(() => chosen.save(any(), any())).thenAnswer((_) async {});

      await repository.choosePlace(_sorriso);

      verify(() => chosen.save('uid-alice', _sorriso)).called(1);
    });
  });
}
