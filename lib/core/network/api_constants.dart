/// Endpoints e parâmetros da Open-Meteo.
///
/// A API é pública e não pede API key — por isso o EcoSafra consegue ser
/// 100% client-side, sem backend próprio.
abstract final class ApiConstants {
  /// Chave usada para registrar/resolver o `Dio` da Open-Meteo no container
  /// (`Modular.get<Dio>(key: ApiConstants.openMeteoDioKey)`), já pensando em
  /// um segundo cliente HTTP futuro sem ambiguidade entre eles.
  static const String openMeteoDioKey = 'openMeteoDio';

  static const String forecastBaseUrl = 'https://api.open-meteo.com/v1';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1';

  static const String forecast = '/forecast';
  static const String reverseGeocoding = '/search';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// Variáveis horárias que interessam à decisão de aplicar fertilizante.
  static const List<String> hourlyVariables = [
    'precipitation',
    'precipitation_probability',
    'temperature_2m',
    'relative_humidity_2m',
    'wind_speed_10m',
    'soil_moisture_0_to_1cm',
  ];

  /// Agregados diários para a visão de 7 dias.
  static const List<String> dailyVariables = [
    'precipitation_sum',
    'precipitation_probability_max',
    'temperature_2m_max',
    'temperature_2m_min',
    'wind_speed_10m_max',
    'weather_code',
  ];
}
