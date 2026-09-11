import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:fpdart/fpdart.dart';

/// Contrato de acesso à previsão do tempo, visto pelo domínio.
///
/// Dois métodos, dois papéis bem separados — quem decide a ordem e compõe
/// os dois é o use case (`GetForecast`), não o repositório:
/// - [getCachedForecast] nunca toca rede, é só leitura local, sempre rápida.
/// - [refreshForecast] é quem de fato busca fresco (e só tenta se houver
///   conexão — ver `NetworkInfo`).
abstract interface class WeatherRepository {
  /// `null` quando nunca buscamos essa área antes.
  Future<WeatherForecast?> getCachedForecast(Coordinates coordinates);

  Future<Either<Failure, WeatherForecast>> refreshForecast(
    Coordinates coordinates,
  );
}
