import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_forecast_point_model.freezed.dart';
part 'daily_forecast_point_model.g.dart';

@freezed
sealed class DailyForecastPointModel with _$DailyForecastPointModel {
  const DailyForecastPointModel._();

  const factory DailyForecastPointModel({
    required DateTime date,
    required double precipitationSum,
    required int precipitationProbabilityMax,
    required double temperatureMax,
    required double temperatureMin,
    required double windSpeedMax,
    required int weatherCode,
  }) = _DailyForecastPointModel;

  factory DailyForecastPointModel.fromJson(Map<String, dynamic> json) =>
      _$DailyForecastPointModelFromJson(json);

  DailyForecastPoint toEntity() => DailyForecastPoint(
        date: date,
        precipitationSum: precipitationSum,
        precipitationProbabilityMax: precipitationProbabilityMax,
        temperatureMax: temperatureMax,
        temperatureMin: temperatureMin,
        windSpeedMax: windSpeedMax,
        weatherCode: weatherCode,
      );
}
