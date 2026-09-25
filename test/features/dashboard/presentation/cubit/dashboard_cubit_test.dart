import 'package:bloc_test/bloc_test.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:ecosafra/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/usecases/evaluate_application_safety.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_current_location.dart';
import 'package:ecosafra/features/weather/domain/usecases/get_forecast.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class MockGetForecast extends Mock implements GetForecast {}

void main() {
  late MockGetCurrentLocation getCurrentLocation;
  late MockGetForecast getForecast;
  const evaluate = EvaluateApplicationSafety();
  const coordinates = Coordinates(latitude: -15.6, longitude: -56.1);

  WeatherForecast forecastAt(int hour) => WeatherForecast(
    coordinates: coordinates,
    hourly: const [],
    daily: const [],
    fetchedAt: DateTime(2026, 9, 25, hour),
  );

  DashboardState loadedWith(WeatherForecast forecast) => DashboardState.loaded(
    forecast,
    evaluate(forecast).getOrElse((_) => throw StateError('sem conselho')),
  );

  setUp(() {
    getCurrentLocation = MockGetCurrentLocation();
    getForecast = MockGetForecast();
    when(
      () => getCurrentLocation(const NoParams()),
    ).thenAnswer((_) async => const Right(coordinates));
  });

  DashboardCubit buildCubit() => DashboardCubit(
    getCurrentLocation: getCurrentLocation,
    getForecast: getForecast,
    evaluateApplicationSafety: evaluate,
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
}
