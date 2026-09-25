import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:clock/clock.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_location_description.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class MockGetForecast extends Mock implements GetForecast {}

class MockGetLocationDescription extends Mock
    implements GetLocationDescription {}

void main() {
  setUpAll(
    () => registerFallbackValue(const Coordinates(latitude: 0, longitude: 0)),
  );

  late MockGetCurrentLocation getCurrentLocation;
  late MockGetForecast getForecast;
  late MockGetLocationDescription getLocationDescription;
  // Relógio fixo na meia-noite do dia dos testes: com pontos horários
  // cobrindo o dia inteiro, `hourlyFrom` sempre encontra cobertura, seja
  // qual for o `hour` passado a `forecastAt`.
  final evaluate = EvaluateApplicationSafety(
    clock: Clock.fixed(DateTime(2026, 9, 25)),
  );
  const coordinates = Coordinates(latitude: -15.6, longitude: -56.1);

  WeatherForecast forecastAt(int hour) => WeatherForecast(
    coordinates: coordinates,
    hourly: [
      for (var h = 0; h < 24; h++)
        HourlyForecastPoint(
          time: DateTime(2026, 9, 25, h),
          precipitation: 0,
          precipitationProbability: 0,
          temperature: 20,
          relativeHumidity: 60,
          windSpeed: 10,
        ),
    ],
    daily: const [],
    fetchedAt: DateTime(2026, 9, 25, hour),
  );

  DashboardState loadedWith(
    WeatherForecast forecast, {
    LocationDescription? location,
  }) => DashboardState.loaded(
    forecast,
    evaluate(forecast).getOrElse((_) => throw StateError('sem conselho')),
    location: location,
  );

  setUp(() {
    getCurrentLocation = MockGetCurrentLocation();
    getForecast = MockGetForecast();
    getLocationDescription = MockGetLocationDescription();
    // Por padrão o nome do lugar não chega: os testes que não tratam dele
    // veem só os estados da previsão.
    when(
      () => getLocationDescription(any()),
    ).thenAnswer((_) => Completer<LocationDescription>().future);
    when(
      () => getCurrentLocation(const NoParams()),
    ).thenAnswer((_) async => const Right(coordinates));
  });

  DashboardCubit buildCubit() => DashboardCubit(
    getCurrentLocation: getCurrentLocation,
    getForecast: getForecast,
    evaluateApplicationSafety: evaluate,
    getLocationDescription: getLocationDescription,
  );

  // O `loading` da abertura sai no construtor, antes de o blocTest ouvir o
  // stream: as listas abaixo começam depois dele.
  blocTest<DashboardCubit, DashboardState>(
    'ao abrir, mostra a previsão',
    setUp: () => when(
      () => getForecast(coordinates),
    ).thenAnswer((_) => Stream.value(Right(forecastAt(8)))),
    build: buildCubit,
    expect: () => [loadedWith(forecastAt(8))],
  );

  blocTest<DashboardCubit, DashboardState>(
    'ao atualizar com a previsão na tela, não volta ao carregamento',
    setUp: () {
      var calls = 0;
      when(() => getForecast(coordinates)).thenAnswer(
        (_) => Stream.value(Right(forecastAt(calls++ == 0 ? 8 : 12))),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.loadForecast();
    },
    expect: () => [loadedWith(forecastAt(8)), loadedWith(forecastAt(12))],
  );

  blocTest<DashboardCubit, DashboardState>(
    'depois de um erro, tentar de novo mostra o carregamento',
    setUp: () {
      var calls = 0;
      when(() => getForecast(coordinates)).thenAnswer(
        (_) => Stream.value(
          calls++ == 0
              ? const Left<Failure, WeatherForecast>(NetworkFailure())
              : Right(forecastAt(12)),
        ),
      );
    },
    build: buildCubit,
    act: (cubit) async {
      await Future<void>.delayed(Duration.zero);
      await cubit.loadForecast();
    },
    expect: () => [
      const DashboardState.error(NetworkFailure()),
      const DashboardState.loading(),
      loadedWith(forecastAt(12)),
    ],
  );

  group('LOCV-01: nome da localização', () {
    const cuiaba = LocationDescription(
      label: 'Cuiabá, Mato Grosso',
      source: LocationSource.device,
    );

    blocTest<DashboardCubit, DashboardState>(
      'a previsão sai sem esperar o nome, que entra quando chegar',
      setUp: () {
        final description = Completer<LocationDescription>();
        when(
          () => getLocationDescription(coordinates),
        ).thenAnswer((_) => description.future);
        when(() => getForecast(coordinates)).thenAnswer((_) async* {
          yield Right(forecastAt(8));
          description.complete(cuiaba);
        });
      },
      build: buildCubit,
      wait: Duration.zero,
      expect: () => [
        loadedWith(forecastAt(8)),
        loadedWith(forecastAt(8), location: cuiaba),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'a previsão seguinte já sai com o nome que chegou',
      setUp: () {
        when(
          () => getLocationDescription(coordinates),
        ).thenAnswer((_) async => cuiaba);
        when(() => getForecast(coordinates)).thenAnswer(
          (_) =>
              Stream.fromFuture(
                Future<void>.delayed(Duration.zero),
              ).asyncExpand(
                (_) => Stream.fromIterable([
                  Right<Failure, WeatherForecast>(forecastAt(8)),
                  Right<Failure, WeatherForecast>(forecastAt(12)),
                ]),
              ),
        );
      },
      build: buildCubit,
      wait: Duration.zero,
      expect: () => [
        loadedWith(forecastAt(8), location: cuiaba),
        loadedWith(forecastAt(12), location: cuiaba),
      ],
    );

    const campinasCoordinates = Coordinates(
      latitude: -22.9,
      longitude: -47.06,
    );
    const campinas = LocationDescription(
      label: 'Campinas',
      source: LocationSource.chosen,
    );

    void stubLocationChange() {
      var calls = 0;
      when(() => getCurrentLocation(const NoParams())).thenAnswer(
        (_) async => Right(calls++ == 0 ? coordinates : campinasCoordinates),
      );
      when(
        () => getForecast(coordinates),
      ).thenAnswer((_) => Stream.value(Right(forecastAt(8))));
    }

    blocTest<DashboardCubit, DashboardState>(
      'depois de trocar o lugar, o nome antigo que chega atrasado é '
      'descartado',
      setUp: () {
        stubLocationChange();
        final oldDescription = Completer<LocationDescription>();
        final newDescription = Completer<LocationDescription>();
        when(
          () => getLocationDescription(coordinates),
        ).thenAnswer((_) => oldDescription.future);
        when(
          () => getLocationDescription(campinasCoordinates),
        ).thenAnswer((_) => newDescription.future);
        when(() => getForecast(campinasCoordinates)).thenAnswer((_) async* {
          yield Right(forecastAt(12));
          newDescription.complete(campinas);
          await Future<void>.delayed(Duration.zero);
          oldDescription.complete(cuiaba);
        });
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.loadForecast();
      },
      wait: Duration.zero,
      expect: () => [
        loadedWith(forecastAt(8)),
        loadedWith(forecastAt(12)),
        loadedWith(forecastAt(12), location: campinas),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'o nome do lugar novo não rotula a previsão do lugar anterior',
      setUp: () {
        stubLocationChange();
        when(
          () => getLocationDescription(campinasCoordinates),
        ).thenAnswer((_) async => campinas);
        // A previsão do lugar novo ainda não chegou.
        when(
          () => getForecast(campinasCoordinates),
        ).thenAnswer((_) => const Stream.empty());
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.loadForecast();
      },
      wait: Duration.zero,
      expect: () => [loadedWith(forecastAt(8))],
    );
  });

  group('ROB-04: falha de localização ao atualizar', () {
    const gpsOff = LocationFailure('Ative a localização do aparelho.');

    blocTest<DashboardCubit, DashboardState>(
      'com a previsão na tela, mantém a mesma previsão e guarda a falha',
      setUp: () {
        var calls = 0;
        when(() => getCurrentLocation(const NoParams())).thenAnswer(
          (_) async =>
              calls++ == 0 ? const Right(coordinates) : const Left(gpsOff),
        );
        when(
          () => getForecast(coordinates),
        ).thenAnswer((_) => Stream.value(Right(forecastAt(8))));
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.loadForecast();
      },
      expect: () => [
        loadedWith(forecastAt(8)),
        loadedWith(forecastAt(8)).withRefreshFailure(gpsOff),
      ],
      verify: (cubit) {
        expect(cubit.state.status, DashboardStatus.loaded);
        expect(cubit.state.forecast, forecastAt(8));
        expect(cubit.state.refreshFailure, gpsOff);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'a mesma falha de novo gera um estado novo, para avisar outra vez',
      setUp: () {
        var calls = 0;
        when(() => getCurrentLocation(const NoParams())).thenAnswer(
          (_) async =>
              calls++ == 0 ? const Right(coordinates) : const Left(gpsOff),
        );
        when(
          () => getForecast(coordinates),
        ).thenAnswer((_) => Stream.value(Right(forecastAt(8))));
      },
      build: buildCubit,
      act: (cubit) async {
        await Future<void>.delayed(Duration.zero);
        await cubit.loadForecast();
        await cubit.loadForecast();
      },
      expect: () => [
        loadedWith(forecastAt(8)),
        loadedWith(forecastAt(8)).withRefreshFailure(gpsOff),
        loadedWith(forecastAt(8)),
        loadedWith(forecastAt(8)).withRefreshFailure(gpsOff),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'sem previsão na tela, a falha de localização vira erro',
      setUp: () => when(
        () => getCurrentLocation(const NoParams()),
      ).thenAnswer((_) async => const Left(gpsOff)),
      build: buildCubit,
      expect: () => [const DashboardState.error(gpsOff)],
    );
  });
}
