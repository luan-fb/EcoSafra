import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:equatable/equatable.dart';

/// Previsão para uma hora específica.
final class HourlyForecastPoint extends Equatable {
  const HourlyForecastPoint({
    required this.time,
    required this.precipitation,
    required this.precipitationProbability,
    required this.temperature,
    required this.relativeHumidity,
    required this.windSpeed,
    this.soilMoisture,
  });

  final DateTime time;

  /// Volume de chuva na hora, em mm.
  final double precipitation;

  /// Chance de chover na hora, 0-100.
  final int precipitationProbability;

  /// °C.
  final double temperature;

  /// 0-100.
  final int relativeHumidity;

  /// km/h.
  final double windSpeed;

  /// m³/m³ — nem toda coordenada tem esse dado (depende da estação mais
  /// próxima que a Open-Meteo usa como referência), por isso é nullable.
  final double? soilMoisture;

  @override
  List<Object?> get props => [
        time,
        precipitation,
        precipitationProbability,
        temperature,
        relativeHumidity,
        windSpeed,
        soilMoisture,
      ];
}

/// Previsão agregada de um dia inteiro.
final class DailyForecastPoint extends Equatable {
  const DailyForecastPoint({
    required this.date,
    required this.precipitationSum,
    required this.precipitationProbabilityMax,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.windSpeedMax,
    required this.weatherCode,
  });

  final DateTime date;
  final double precipitationSum;
  final int precipitationProbabilityMax;
  final double temperatureMax;
  final double temperatureMin;
  final double windSpeedMax;

  /// Código WMO do clima predominante do dia (ex.: 61 = chuva fraca). A
  /// tradução pra ícone/texto fica na camada de apresentação — o domínio só
  /// carrega o número.
  final int weatherCode;

  @override
  List<Object?> get props => [
        date,
        precipitationSum,
        precipitationProbabilityMax,
        temperatureMax,
        temperatureMin,
        windSpeedMax,
        weatherCode,
      ];
}

/// Previsão completa para um talhão: o que o `GetForecast` devolve.
final class WeatherForecast extends Equatable {
  const WeatherForecast({
    required this.coordinates,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
    this.isStale = false,
  });

  final Coordinates coordinates;

  /// Próximas ~48h, uma entrada por hora.
  final List<HourlyForecastPoint> hourly;

  /// Próximos ~7 dias, uma entrada por dia.
  final List<DailyForecastPoint> daily;

  /// Quando estes dados foram buscados da Open-Meteo com sucesso pela
  /// última vez — não necessariamente agora, ver [isStale].
  final DateTime fetchedAt;

  /// `true` quando isto veio do cache local porque a busca de agora falhou
  /// (tipicamente por falta de internet no talhão). É o sinal que a UI usa
  /// pra avisar "dados de X horas atrás" em vez de fingir tempo real.
  final bool isStale;

  @override
  List<Object?> get props => [coordinates, hourly, daily, fetchedAt, isStale];
}
