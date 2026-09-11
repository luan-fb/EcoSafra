// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_forecast_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeatherForecastModel _$WeatherForecastModelFromJson(
  Map<String, dynamic> json,
) => _WeatherForecastModel(
  hourly: (json['hourly'] as List<dynamic>)
      .map((e) => HourlyForecastPointModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  daily: (json['daily'] as List<dynamic>)
      .map((e) => DailyForecastPointModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WeatherForecastModelToJson(
  _WeatherForecastModel instance,
) => <String, dynamic>{
  'hourly': instance.hourly.map((e) => e.toJson()).toList(),
  'daily': instance.daily.map((e) => e.toJson()).toList(),
};
