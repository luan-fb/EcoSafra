import 'package:ecosafra/features/weather/data/models/weather_forecast_model.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';

abstract interface class WeatherRemoteDataSource {
  Future<WeatherForecastModel> getForecast(Coordinates coordinates);
}
