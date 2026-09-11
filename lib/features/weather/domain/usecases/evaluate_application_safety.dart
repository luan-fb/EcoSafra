import 'package:ecosafra/core/error/failure.dart';
import 'package:ecosafra/core/usecase/usecase.dart';
import 'package:ecosafra/features/weather/domain/entities/fertilizer_advice.dart';
import 'package:ecosafra/features/weather/domain/entities/weather_forecast.dart';
import 'package:fpdart/fpdart.dart';

/// O motor de decisão — a regra de negócio que dá nome ao app.
///
/// É `SyncUseCase` (não `UseCase`): não faz I/O nenhum, só olha a previsão
/// que já foi buscada e calcula. Por ser puro, testar não precisa de mock —
/// só de uma `WeatherForecast` de entrada e o `FertilizerAdvice` esperado
/// na saída.
///
/// Os limiares abaixo são uma heurística de partida (chuva acumulada nas
/// próximas 24h é o que mais importa pra escoamento superficial logo após
/// a aplicação); ajustar por cultura/solo fica para quando o app tiver
/// dados reais de adoção.
class EvaluateApplicationSafety
    implements SyncUseCase<FertilizerAdvice, WeatherForecast> {
  const EvaluateApplicationSafety();

  /// Acima disso em 24h, o insumo tem risco alto de escoar antes de agir.
  static const double dangerThresholdMm = 10;

  /// Entre isto e o limiar de perigo, ainda dá pra aplicar, mas com cautela.
  static const double cautionThresholdMm = 3;

  @override
  Either<Failure, FertilizerAdvice> call(WeatherForecast params) {
    final rainNext24h = _sumPrecipitation(params, hours: 24);
    final rainNext48h = _sumPrecipitation(params, hours: 48);

    final level = switch (rainNext24h) {
      > dangerThresholdMm => AdviceLevel.danger,
      > cautionThresholdMm => AdviceLevel.caution,
      _ => AdviceLevel.safe,
    };

    return Right(
      FertilizerAdvice(
        level: level,
        rainNext24h: rainNext24h,
        rainNext48h: rainNext48h,
        estimatedLossPercent: level == AdviceLevel.danger
            ? _estimateLossPercent(rainNext24h)
            : null,
      ),
    );
  }

  double _sumPrecipitation(WeatherForecast forecast, {required int hours}) =>
      forecast.hourly
          .take(hours)
          .fold(0, (total, point) => total + point.precipitation);

  /// Quanto mais chuva além do limiar de perigo, maior a fração do insumo
  /// que se estima perdida por escoamento — cresce com o excesso, mas nunca
  /// alega "perda total", já que sempre sobra alguma absorção do solo.
  double _estimateLossPercent(double rainNext24h) {
    final excess = rainNext24h - dangerThresholdMm;
    return (20 + excess * 2).clamp(0, 80);
  }
}
