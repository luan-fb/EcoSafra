import 'package:ecosafra/features/weather/data/models/daily_forecast_point_model.dart';
import 'package:ecosafra/features/weather/data/models/hourly_forecast_point_model.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_forecast_model.freezed.dart';
part 'weather_forecast_model.g.dart';

/// O que efetivamente vira o JSON salvo em `CachedForecasts.payloadJson`.
///
/// Não carrega `fetchedAt`/`isStale`: o "quando" já é uma coluna própria da
/// tabela (`CachedForecasts.fetchedAt`), e "isStale" nem é um dado — é uma
/// interpretação que só existe no momento em que o repositório decide
/// servir o cache. Guardá-los aqui dentro seria duplicar informação que já
/// mora em outro lugar.
@freezed
sealed class WeatherForecastModel with _$WeatherForecastModel {
  const WeatherForecastModel._();

  const factory WeatherForecastModel({
    required List<HourlyForecastPointModel> hourly,
    required List<DailyForecastPointModel> daily,
  }) = _WeatherForecastModel;

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastModelFromJson(json);

  WeatherForecast toEntity({
    required Coordinates coordinates,
    required DateTime fetchedAt,
    bool isStale = false,
  }) =>
      WeatherForecast(
        coordinates: coordinates,
        hourly: hourly.map((point) => point.toEntity()).toList(),
        daily: daily.map((point) => point.toEntity()).toList(),
        fetchedAt: fetchedAt,
        isStale: isStale,
      );
}
