import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hourly_forecast_point_model.freezed.dart';
part 'hourly_forecast_point_model.g.dart';

/// Ponto horário, no formato que ESTE app escolheu para o cache — não o
/// formato colunar da Open-Meteo (isso é desmontado uma única vez em
/// `OpenMeteoRemoteDataSource`). Um objeto por hora é o que `json_serializable`
/// gera de graça; brigar com o formato original não valeria a pena.
@freezed
sealed class HourlyForecastPointModel with _$HourlyForecastPointModel {
  const HourlyForecastPointModel._();

  const factory HourlyForecastPointModel({
    required DateTime time,
    required double precipitation,
    required int precipitationProbability,
    required double temperature,
    required int relativeHumidity,
    required double windSpeed,
    double? soilMoisture,
  }) = _HourlyForecastPointModel;

  factory HourlyForecastPointModel.fromJson(Map<String, dynamic> json) =>
      _$HourlyForecastPointModelFromJson(json);

  HourlyForecastPoint toEntity() => HourlyForecastPoint(
        time: time,
        precipitation: precipitation,
        precipitationProbability: precipitationProbability,
        temperature: temperature,
        relativeHumidity: relativeHumidity,
        windSpeed: windSpeed,
        soilMoisture: soilMoisture,
      );
}
