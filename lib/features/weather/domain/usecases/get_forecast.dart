import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/weather/domain/entities/coordinates.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:ecosafra/features/weather/domain/repositories/weather_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Cache-first: mostra o que já temos guardado na hora, e só depois tenta
/// atualizar. É por isso que o app nunca fica preso esperando uma resposta
/// de rede que pode nem vir — quem tem algo pra mostrar, mostra primeiro.
///
/// Emite até duas vezes:
/// 1. `Right(cache)` imediatamente, se existir cache para esta área, ainda
///    sem `isStale`: a atualização nem foi tentada;
/// 2. o resultado de tentar atualizar. Se ela falhar e havia cache (sem
///    internet, típico caso do talhão sem sinal), emite o mesmo cache com
///    `isStale`, em vez da falha: a tela continua com os dados e passa a
///    avisar que são antigos. Sem cache, a falha é a única informação.
class GetForecast
    implements StreamUseCase<Either<Failure, WeatherForecast>, Coordinates> {
  const GetForecast(this._repository);

  final WeatherRepository _repository;

  @override
  Stream<Either<Failure, WeatherForecast>> call(Coordinates params) async* {
    final cached = await _repository.getCachedForecast(params);
    if (cached != null) yield Right(cached);

    final refreshed = await _repository.refreshForecast(params);
    if (refreshed.isRight() || cached == null) {
      yield refreshed;
    } else {
      yield Right(cached.asStale());
    }
  }
}
