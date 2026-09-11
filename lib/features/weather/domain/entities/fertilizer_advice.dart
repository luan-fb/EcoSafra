import 'package:equatable/equatable.dart';

/// As três respostas possíveis à pergunta "posso adubar agora?".
enum AdviceLevel {
  /// Solo deve seguir seco, sem chuva forte prevista.
  safe,

  /// Chuva moderada a caminho — aplicar é uma aposta.
  caution,

  /// Chuva forte prevista: o insumo escorre pro rio antes de fazer efeito.
  danger,
}

/// O resultado do motor de decisão: o que mostrar no card do painel.
final class FertilizerAdvice extends Equatable {
  const FertilizerAdvice({
    required this.level,
    required this.rainNext24h,
    required this.rainNext48h,
    this.estimatedLossPercent,
  });

  final AdviceLevel level;

  /// mm acumulados nas próximas 24h — é o que decide o nível.
  final double rainNext24h;

  /// mm acumulados nas próximas 48h — informativo, ajuda a planejar o dia
  /// seguinte mesmo quando hoje está liberado.
  final double rainNext48h;

  /// 0-100. Só vem preenchido quando [level] é [AdviceLevel.danger] — não
  /// faz sentido estimar prejuízo de uma aplicação que nem vai acontecer.
  final double? estimatedLossPercent;

  @override
  List<Object?> get props =>
      [level, rainNext24h, rainNext48h, estimatedLossPercent];
}
