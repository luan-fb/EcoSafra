import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:ecosafra/features/weather/domain/entities/location_description.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:equatable/equatable.dart';

enum DashboardStatus { initial, loading, loaded, error }

final class DashboardState extends Equatable {
  const DashboardState._({
    required this.status,
    this.forecast,
    this.advice,
    this.location,
    this.failure,
    this.refreshFailure,
  });

  const DashboardState.initial() : this._(status: DashboardStatus.initial);

  const DashboardState.loading() : this._(status: DashboardStatus.loading);

  const DashboardState.loaded(
    WeatherForecast forecast,
    FertilizerAdvice advice, {
    LocationDescription? location,
  }) : this._(
         status: DashboardStatus.loaded,
         forecast: forecast,
         advice: advice,
         location: location,
       );

  const DashboardState.error(Failure failure)
      : this._(status: DashboardStatus.error, failure: failure);

  final DashboardStatus status;
  final WeatherForecast? forecast;

  /// O resultado do motor de decisão para o [forecast] atual — é o que o
  /// card verde/amarelo/vermelho lê para saber a cor e o texto.
  final FertilizerAdvice? advice;

  /// Nome do lugar da previsão. Chega depois dela: o geocodificador do
  /// aparelho pode levar alguns segundos.
  final LocationDescription? location;

  final Failure? failure;

  /// Em `loaded`, a falha ao atualizar que não apagou a previsão (snackbar).
  final Failure? refreshFailure;

  DashboardState withLocation(LocationDescription location) => DashboardState._(
    status: status,
    forecast: forecast,
    advice: advice,
    location: location,
    failure: failure,
    refreshFailure: refreshFailure,
  );

  DashboardState withRefreshFailure(Failure? refreshFailure) =>
      DashboardState._(
        status: status,
        forecast: forecast,
        advice: advice,
        location: location,
        failure: failure,
        refreshFailure: refreshFailure,
      );

  @override
  List<Object?> get props => [
    status,
    forecast,
    advice,
    location,
    failure,
    refreshFailure,
  ];
}
