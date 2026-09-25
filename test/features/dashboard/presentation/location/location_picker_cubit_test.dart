import 'dart:async';

import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/location/location_picker_state.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/place.dart';
import 'package:ecosafra/features/weather/domain/usecases/choose_place.dart';
import 'package:ecosafra/features/weather/domain/usecases/search_places.dart';
import 'package:ecosafra/features/weather/domain/usecases/use_device_location.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockSearchPlaces extends Mock implements SearchPlaces {}

class MockChoosePlace extends Mock implements ChoosePlace {}

class MockUseDeviceLocation extends Mock implements UseDeviceLocation {}

void main() {
  const cuiaba = Place(
    name: 'Cuiabá',
    region: 'Mato Grosso',
    country: 'Brasil',
    coordinates: Coordinates(latitude: -15.6, longitude: -56.1),
  );
  const campinas = Place(
    name: 'Campinas',
    region: 'São Paulo',
    country: 'Brasil',
    coordinates: Coordinates(latitude: -22.9, longitude: -47.06),
  );

  setUpAll(() => registerFallbackValue(cuiaba));

  late MockSearchPlaces searchPlaces;
  late MockChoosePlace choosePlace;
  late MockUseDeviceLocation useDeviceLocation;

  setUp(() {
    searchPlaces = MockSearchPlaces();
    choosePlace = MockChoosePlace();
    useDeviceLocation = MockUseDeviceLocation();
  });

  LocationPickerCubit buildCubit() => LocationPickerCubit(
    searchPlaces: searchPlaces,
    choosePlace: choosePlace,
    useDeviceLocation: useDeviceLocation,
  );

  /// Roda [body] em tempo falso e devolve os estados emitidos.
  List<LocationPickerState> runFake(
    void Function(LocationPickerCubit cubit, FakeAsync async) body,
  ) {
    final states = <LocationPickerState>[];
    fakeAsync((async) {
      final cubit = buildCubit();
      final subscription = cubit.stream.listen(states.add);
      body(cubit, async);
      async.flushMicrotasks();
      unawaited(subscription.cancel());
      unawaited(cubit.close());
      async.flushMicrotasks();
    });
    return states;
  }

  test('começa em idle', () {
    expect(buildCubit().state, const LocationPickerState.idle());
  });

  test('LOCM-01: com 2 caracteres não busca e fica em idle', () {
    final states = runFake((cubit, async) {
      cubit.queryChanged('Cu');
      async.elapse(const Duration(seconds: 1));
    });

    verifyNever(() => searchPlaces(any()));
    expect(states, [const LocationPickerState.idle()]);
  });

  test('LOCM-01: espaços não contam para o mínimo de 3 caracteres', () {
    runFake((cubit, async) {
      cubit.queryChanged('  Cu  ');
      async.elapse(const Duration(seconds: 1));
    });

    verifyNever(() => searchPlaces(any()));
  });

  test(
    'LOCM-01: busca o texto sem espaços só 400 ms depois da última tecla',
    () {
      when(
        () => searchPlaces('Cuiabá'),
      ).thenAnswer((_) async => const Right([cuiaba]));

      runFake((cubit, async) {
        cubit.queryChanged(' Cuiabá ');
        async.elapse(const Duration(milliseconds: 399));
        verifyNever(() => searchPlaces(any()));
        async.elapse(const Duration(milliseconds: 1));
      });

      verify(() => searchPlaces('Cuiabá')).called(1);
    },
  );

  test('LOCM-01: digitação rápida busca uma vez, com o último texto', () {
    when(
      () => searchPlaces(any()),
    ).thenAnswer((_) async => const Right([cuiaba]));

    runFake((cubit, async) {
      cubit.queryChanged('Cui');
      async.elapse(const Duration(milliseconds: 200));
      cubit.queryChanged('Cuia');
      async.elapse(const Duration(milliseconds: 200));
      cubit.queryChanged('Cuiab');
      async.elapse(const Duration(milliseconds: 400));
    });

    verify(() => searchPlaces('Cuiab')).called(1);
    verifyNever(() => searchPlaces('Cui'));
    verifyNever(() => searchPlaces('Cuia'));
  });

  test('LOCM-01: com resultados, emite searching e depois os lugares', () {
    when(
      () => searchPlaces('Cuiabá'),
    ).thenAnswer((_) async => const Right([cuiaba, campinas]));

    final states = runFake((cubit, async) {
      cubit.queryChanged('Cuiabá');
      async.elapse(LocationPickerCubit.debounce);
    });

    expect(states, [
      const LocationPickerState.searching(),
      const LocationPickerState.results([cuiaba, campinas]),
    ]);
  });

  test('LOCM-06: nenhum lugar encontrado emite empty', () {
    when(
      () => searchPlaces('Xyzw'),
    ).thenAnswer((_) async => const Right(<Place>[]));

    final states = runFake((cubit, async) {
      cubit.queryChanged('Xyzw');
      async.elapse(LocationPickerCubit.debounce);
    });

    expect(states, [
      const LocationPickerState.searching(),
      const LocationPickerState.empty(),
    ]);
  });

  test('LOCM-05: busca sem rede emite a falha de rede', () {
    when(
      () => searchPlaces('Cuiabá'),
    ).thenAnswer((_) async => const Left(NetworkFailure()));

    final states = runFake((cubit, async) {
      cubit.queryChanged('Cuiabá');
      async.elapse(LocationPickerCubit.debounce);
    });

    expect(states, [
      const LocationPickerState.searching(),
      const LocationPickerState.failure(NetworkFailure()),
    ]);
  });

  test('apagar para menos de 3 caracteres volta a idle', () {
    when(
      () => searchPlaces('Cuiabá'),
    ).thenAnswer((_) async => const Right([cuiaba]));

    final states = runFake((cubit, async) {
      cubit.queryChanged('Cuiabá');
      async.elapse(LocationPickerCubit.debounce);
      cubit.queryChanged('Cu');
    });

    expect(states.last, const LocationPickerState.idle());
  });

  test(
    'resultado de uma busca antiga que chega depois da nova é descartado',
    () {
      final slow = Completer<Either<Failure, List<Place>>>();
      when(() => searchPlaces('Cuiabá')).thenAnswer((_) => slow.future);
      when(
        () => searchPlaces('Campinas'),
      ).thenAnswer((_) async => const Right([campinas]));

      final states = runFake((cubit, async) {
        cubit.queryChanged('Cuiabá');
        async.elapse(LocationPickerCubit.debounce);
        cubit.queryChanged('Campinas');
        async.elapse(LocationPickerCubit.debounce);
        slow.complete(const Right([cuiaba]));
      });

      expect(states.last, const LocationPickerState.results([campinas]));
      expect(
        states,
        isNot(contains(const LocationPickerState.results([cuiaba]))),
      );
    },
  );

  test('close cancela a busca agendada', () {
    fakeAsync((async) {
      final cubit = buildCubit()..queryChanged('Cuiabá');
      unawaited(cubit.close());
      async.elapse(const Duration(seconds: 1));
    });

    verifyNever(() => searchPlaces(any()));
  });

  group('choose', () {
    test('LOCM-02: grava o lugar e devolve true', () async {
      when(
        () => choosePlace(cuiaba),
      ).thenAnswer((_) async => const Right(null));
      final cubit = buildCubit();

      expect(await cubit.choose(cuiaba), isTrue);
      verify(() => choosePlace(cuiaba)).called(1);
      expect(cubit.state, const LocationPickerState.idle());
    });

    test('falha ao gravar emite a falha e devolve false', () async {
      when(
        () => choosePlace(cuiaba),
      ).thenAnswer((_) async => const Left(AuthFailure()));
      final cubit = buildCubit();

      expect(await cubit.choose(cuiaba), isFalse);
      expect(cubit.state, const LocationPickerState.failure(AuthFailure()));
    });
  });

  group('useDevice', () {
    test('LOCM-04: apaga a escolha e devolve true', () async {
      when(
        () => useDeviceLocation(const NoParams()),
      ).thenAnswer((_) async => const Right(null));
      final cubit = buildCubit();

      expect(await cubit.useDevice(), isTrue);
      verify(() => useDeviceLocation(const NoParams())).called(1);
    });

    test('falha ao apagar emite a falha e devolve false', () async {
      const failure = CacheFailure('Não foi possível salvar.');
      when(
        () => useDeviceLocation(const NoParams()),
      ).thenAnswer((_) async => const Left(failure));
      final cubit = buildCubit();

      expect(await cubit.useDevice(), isFalse);
      expect(cubit.state, const LocationPickerState.failure(failure));
    });
  });
}
