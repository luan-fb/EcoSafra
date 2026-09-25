import 'package:ecosafra/core/error/exception_mapper.dart';
import 'package:ecosafra/core/error/exceptions.dart';
import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/network/network_info.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_local_data_source.dart';
import 'package:ecosafra/features/weather/data/datasources/weather_remote_data_source.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/repositories/weather_repository.dart';
import 'package:fpdart/fpdart.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  const WeatherRepositoryImpl({
    required WeatherRemoteDataSource remote,
    required WeatherLocalDataSource local,
    required NetworkInfo networkInfo,
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo;

  final WeatherRemoteDataSource _remote;
  final WeatherLocalDataSource _local;
  final NetworkInfo _networkInfo;

  @override
  Future<WeatherForecast?> getCachedForecast(Coordinates coordinates) async {
    final cached = await _local.getCached(coordinates.cacheKey);
    if (cached == null) return null;
    // Sem `isStale`: se o cache está desatualizado só se sabe depois de
    // tentar a rede, e quem tenta é o `GetForecast`.
    return cached.model.toEntity(
      coordinates: coordinates,
      fetchedAt: cached.fetchedAt,
    );
  }

  @override
  Future<Either<Failure, WeatherForecast>> refreshForecast(
    Coordinates coordinates,
  ) async {
    // A checagem em si não faz nenhuma chamada de rede — só pergunta ao
    // sistema operacional se há uma interface ativa. Sem ela, "sem
    // internet" só seria descoberto depois de esperar o Dio estourar o
    // próprio timeout, e o talhão sem sinal é exatamente o caso comum,
    // não a exceção rara que justificaria pagar esse preço toda vez.
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final model = await _remote.getForecast(coordinates);
      final fetchedAt = DateTime.now();
      // Falhar aqui não pode custar a previsão que acabou de chegar: o
      // produtor prefere ver o dado novo sem cache a não ver nada.
      try {
        await _local.cache(coordinates.cacheKey, model);
      } on Object {
        // Erro de gravação não impede a previsão de aparecer.
      }
      return Right(
        model.toEntity(coordinates: coordinates, fetchedAt: fetchedAt),
      );
    } on AppException catch (exception) {
      return Left(exception.toFailure());
    }
  }
}
