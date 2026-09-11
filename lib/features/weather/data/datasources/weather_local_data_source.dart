import 'package:ecosafra/features/weather/data/models/weather_forecast_model.dart';

/// Uma previsão cacheada, com o momento em que foi salva — é esse horário
/// que a UI mostra como "dados de X horas atrás" quando serve do cache.
typedef CachedWeather = ({WeatherForecastModel model, DateTime fetchedAt});

abstract interface class WeatherLocalDataSource {
  Future<CachedWeather?> getCached(String locationKey);

  Future<void> cache(String locationKey, WeatherForecastModel model);
}
