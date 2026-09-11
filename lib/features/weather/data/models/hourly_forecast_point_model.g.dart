// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hourly_forecast_point_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HourlyForecastPointModel _$HourlyForecastPointModelFromJson(
  Map<String, dynamic> json,
) => _HourlyForecastPointModel(
  time: DateTime.parse(json['time'] as String),
  precipitation: (json['precipitation'] as num).toDouble(),
  precipitationProbability: (json['precipitation_probability'] as num).toInt(),
  temperature: (json['temperature'] as num).toDouble(),
  relativeHumidity: (json['relative_humidity'] as num).toInt(),
  windSpeed: (json['wind_speed'] as num).toDouble(),
  soilMoisture: (json['soil_moisture'] as num?)?.toDouble(),
);

Map<String, dynamic> _$HourlyForecastPointModelToJson(
  _HourlyForecastPointModel instance,
) => <String, dynamic>{
  'time': instance.time.toIso8601String(),
  'precipitation': instance.precipitation,
  'precipitation_probability': instance.precipitationProbability,
  'temperature': instance.temperature,
  'relative_humidity': instance.relativeHumidity,
  'wind_speed': instance.windSpeed,
  'soil_moisture': ?instance.soilMoisture,
};
