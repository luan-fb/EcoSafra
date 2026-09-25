import 'package:dio/dio.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/network/api_constants.dart';
import 'package:ecosafra/core/network/dio_error_unwrapper.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:ecosafra/features/weather/data/models/daily_forecast_point_model.dart';
import 'package:ecosafra/features/weather/data/models/hourly_forecast_point_model.dart';
import 'package:ecosafra/features/weather/data/models/weather_forecast_model.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';

/// Fala com a Open-Meteo e já entrega no formato que o resto do app usa.
///
/// A resposta da Open-Meteo é "colunar": cada variável é o próprio array
/// (`hourly.precipitation[3]` e `hourly.time[3]` são a mesma hora), em vez
/// da lista de objetos que `json_serializable` esperaria. Por isso o
/// parsing aqui é manual — é o único lugar do app que precisa conhecer
/// esse formato; daqui pra frente, tudo trabalha com [WeatherForecastModel].
class OpenMeteoRemoteDataSource implements WeatherRemoteDataSource {
  const OpenMeteoRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<WeatherForecastModel> getForecast(Coordinates coordinates) async {
    final Response<Map<String, dynamic>> response;
    try {
      response = await _dio.get<Map<String, dynamic>>(
        ApiConstants.forecast,
        queryParameters: {
          'latitude': coordinates.latitude,
          'longitude': coordinates.longitude,
          'hourly': ApiConstants.hourlyVariables.join(','),
          'daily': ApiConstants.dailyVariables.join(','),
          'forecast_days': WeatherForecast.coverageDays,
          // Sem isto, a Open-Meteo devolve os horários em UTC — o produtor
          // não deveria ter que fazer essa conta de cabeça pra saber se "vai
          // chover às 15h" é daqui a três horas ou daqui a seis.
          'timezone': 'auto',
        },
      );
    } on DioException catch (e) {
      throw unwrapDioException(e);
    }

    final data = response.data;
    if (data == null) {
      throw const ServerException('Resposta vazia da Open-Meteo.');
    }

    try {
      final hourly = _parseHourly(data['hourly'] as Map<String, dynamic>);
      final daily = _parseDaily(data['daily'] as Map<String, dynamic>);
      if (hourly.isEmpty || daily.isEmpty) {
        throw const ServerException(
          'A previsão veio incompleta. Tente novamente mais tarde.',
        );
      }
      return WeatherForecastModel(hourly: hourly, daily: daily);
    }
    // Resposta de uma API externa é fronteira do sistema: um campo ausente
    // ou de outro tipo não é bug nosso, é o contrato mudando do lado de
    // fora — por isso capturamos aqui em vez de deixar subir.
    // ignore: avoid_catching_errors
    on TypeError {
      throw const ServerException(
        'A Open-Meteo devolveu dados em um formato inesperado.',
      );
    }
  }

  List<HourlyForecastPointModel> _parseHourly(Map<String, dynamic> hourly) {
    final times = hourly['time']! as List;
    final precipitation = hourly['precipitation']! as List;
    final precipitationProbability =
        hourly['precipitation_probability']! as List;
    final temperature = hourly['temperature_2m']! as List;
    final relativeHumidity = hourly['relative_humidity_2m']! as List;
    final windSpeed = hourly['wind_speed_10m']! as List;
    // Nem toda coordenada tem estação de referência para umidade do solo —
    // ao contrário das outras variáveis, esta pode vir ausente.
    final soilMoisture = hourly['soil_moisture_0_to_1cm'] as List?;

    return List.generate(
      times.length,
      (i) => HourlyForecastPointModel(
        time: DateTime.parse(times[i] as String),
        precipitation: (precipitation[i] as num).toDouble(),
        precipitationProbability: (precipitationProbability[i] as num).toInt(),
        temperature: (temperature[i] as num).toDouble(),
        relativeHumidity: (relativeHumidity[i] as num).toInt(),
        windSpeed: (windSpeed[i] as num).toDouble(),
        soilMoisture: (soilMoisture?[i] as num?)?.toDouble(),
      ),
    );
  }

  List<DailyForecastPointModel> _parseDaily(Map<String, dynamic> daily) {
    final dates = daily['time']! as List;
    final precipitationSum = daily['precipitation_sum']! as List;
    final precipitationProbabilityMax =
        daily['precipitation_probability_max']! as List;
    final temperatureMax = daily['temperature_2m_max']! as List;
    final temperatureMin = daily['temperature_2m_min']! as List;
    final windSpeedMax = daily['wind_speed_10m_max']! as List;
    final weatherCode = daily['weather_code']! as List;

    return List.generate(
      dates.length,
      (i) => DailyForecastPointModel(
        date: DateTime.parse(dates[i] as String),
        precipitationSum: (precipitationSum[i] as num).toDouble(),
        precipitationProbabilityMax: (precipitationProbabilityMax[i] as num)
            .toInt(),
        temperatureMax: (temperatureMax[i] as num).toDouble(),
        temperatureMin: (temperatureMin[i] as num).toDouble(),
        windSpeedMax: (windSpeedMax[i] as num).toDouble(),
        weatherCode: (weatherCode[i] as num).toInt(),
      ),
    );
  }
}
