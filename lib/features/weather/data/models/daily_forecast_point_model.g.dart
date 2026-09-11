// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_forecast_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DailyForecastPointModel _$DailyForecastPointModelFromJson(
  Map<String, dynamic> json,
) => _DailyForecastPointModel(
  date: DateTime.parse(json['date'] as String),
  precipitationSum: (json['precipitation_sum'] as num).toDouble(),
  precipitationProbabilityMax: (json['precipitation_probability_max'] as num)
      .toInt(),
  temperatureMax: (json['temperature_max'] as num).toDouble(),
  temperatureMin: (json['temperature_min'] as num).toDouble(),
  windSpeedMax: (json['wind_speed_max'] as num).toDouble(),
  weatherCode: (json['weather_code'] as num).toInt(),
);

Map<String, dynamic> _$DailyForecastPointModelToJson(
  _DailyForecastPointModel instance,
) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'precipitation_sum': instance.precipitationSum,
  'precipitation_probability_max': instance.precipitationProbabilityMax,
  'temperature_max': instance.temperatureMax,
  'temperature_min': instance.temperatureMin,
  'wind_speed_max': instance.windSpeedMax,
  'weather_code': instance.weatherCode,
};
